# Inactive Account Cleanup Script
# Version: 2.1
# Author: Your Name
# Purpose: Identify and disable AD accounts inactive for X days

#Requires -Module ActiveDirectory

param(
    [int]$DaysInactive = 180,
    [string]$OU = "OU=Users,DC=yourdomain,DC=com",
    [switch]$DisableAccounts,
    [switch]$ReportOnly
)

# Configuration
$LogDate = Get-Date -Format "yyyyMMdd-HHmmss"
$ReportPath = "C:\ADAudit\InactiveAccounts_$LogDate.csv"
$ExcludedUsers = @("Administrator", "Guest", "krbtgt", "ServiceAccount*")

# Email Notification Config (Optional)
$EmailParams = @{
    SmtpServer = "smtp.yourcompany.com"
    From = "ITSecurity@yourcompany.com"
    To = "admin-team@yourcompany.com"
    Subject = "Inactive AD Accounts Disabled"
}

function Write-AuditLog {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
}

try {
    # Validate OU
    if(-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OU} -ErrorAction Stop)) {
        throw "Invalid OU: $OU"
    }

    # Build search filter
    $CutoffDate = (Get-Date).AddDays(-$DaysInactive)
    $Filter = {
        (LastLogonDate -lt $CutoffDate) -or 
        (LastLogonDate -notLike "*") -and
        (Enabled -eq $true)
    }

    # Find inactive accounts
    $InactiveUsers = Search-ADAccount -AccountInactive -DateTime $CutoffDate -UsersOnly |
        Where-Object {
            $_.DistinguishedName -match $OU -and
            $_.SamAccountName -notlike $ExcludedUsers
        } |
        Select-Object SamAccountName, UserPrincipalName, LastLogonDate, 
            DistinguishedName, Enabled, WhenCreated

    # Generate Report
    $InactiveUsers | Export-Csv -Path $ReportPath -NoTypeInformation
    Write-AuditLog "Report generated at $ReportPath with $($InactiveUsers.Count) inactive accounts"

    if($ReportOnly) {
        Write-AuditLog "Running in report-only mode. No changes made."
        return
    }

    if($DisableAccounts) {
        # Safety confirmation
        $Confirmation = Read-Host "WARNING: This will disable $($InactiveUsers.Count) accounts. Continue? (Y/N)"
        if($Confirmation -ne "Y") {
            Write-AuditLog "Operation cancelled by user"
            exit
        }

        # Process accounts
        $Results = foreach($User in $InactiveUsers) {
            try {
                $DisableParams = @{
                    Identity = $User.SamAccountName
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Disable-ADAccount @DisableParams
                Set-ADUser -Identity $User.SamAccountName -Description "Disabled by automation on $(Get-Date -Format 'yyyy-MM-dd') - Inactive for $DaysInactive days"

                [PSCustomObject]@{
                    SamAccountName = $User.SamAccountName
                    Status = "Disabled"
                    Error = $null
                }
            }
            catch {
                [PSCustomObject]@{
                    SamAccountName = $User.SamAccountName
                    Status = "Failed"
                    Error = $_.Exception.Message
                }
            }
        }

        # Generate operation report
        $Results | Export-Csv -Path "C:\ADAudit\DisableResults_$LogDate.csv" -NoTypeInformation

        # Send notification (optional)
        # Send-MailMessage @EmailParams -Body (Get-Content $ReportPath | Out-String)
    }

}
catch {
    Write-AuditLog "ERROR: $_"
    exit 1
}
finally {
    Write-AuditLog "Operation completed"
}
