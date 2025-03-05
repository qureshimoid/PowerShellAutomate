<#
.SYNOPSIS
    Automatically updates Active Directory security group membership based on the Department attribute.
.DESCRIPTION
    - Users are added to their correct "Dept-<Department>" group.
    - If their department changes, they are removed from the old group.
    - Logs all changes for auditing.
.PARAMETER LogPath
    Specifies where to store logs.
.PARAMETER GroupPrefix
    Defines the prefix for department groups (default: "Dept-").
.PARAMETER DomainDN
    Sets the AD domain DN.
.EXAMPLE
    .\DepartmentGroupSync.ps1 -LogPath "C:\Logs\ADSync.log" -GroupPrefix "Dept-"
#>

param (
    [string]$LogPath = "C:\Logs\DepartmentGroupSync_$(Get-Date -Format 'yyyyMMdd').log",
    [string]$GroupPrefix = "Dept-",
    [string]$DomainDN = "DC=yourdomain,DC=com"
)

# Import Active Directory Module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "❌ Active Directory module not found. Exiting."
    exit 1
}

# Start Logging
Start-Transcript -Path $LogPath -Append

try {
    # Step 1: Load all relevant groups in one go to reduce repeated queries
    $AllDeptGroups = Get-ADGroup -Filter "Name -like '$GroupPrefix*'" | Select-Object -ExpandProperty Name

    # Step 2: Get all users with the Department attribute
    $Users = Get-ADUser -Filter {Department -like '*'} -Properties Department, MemberOf

    foreach ($User in $Users) {
        $CurrentDepartment = $User.Department
        $TargetGroup = "$GroupPrefix$CurrentDepartment"

        # Validate group exists
        if ($AllDeptGroups -notcontains $TargetGroup) {
            Write-Warning "⚠️ Group '$TargetGroup' doesn't exist for user $($User.SamAccountName)"
            continue
        }

        # Step 3: Get User's Current Groups
        $UserGroups = ($User.MemberOf | Get-ADGroup | Select-Object -ExpandProperty Name) -match "$GroupPrefix*"

        # Step 4: Add User to Correct Department Group (if not already a member)
        if ($UserGroups -notcontains $TargetGroup) {
            Add-ADGroupMember -Identity $TargetGroup -Members $User -ErrorAction Stop
            Write-Host "✅ Added $($User.SamAccountName) to $TargetGroup" -ForegroundColor Green
        }

        # Step 5: Remove from Old Department Groups
        $GroupsToRemove = $UserGroups | Where-Object { $_ -ne $TargetGroup }
        foreach ($OldGroup in $GroupsToRemove) {
            Write-Host "⚠️ Removing $($User.SamAccountName) from $OldGroup" -ForegroundColor Yellow
            Remove-ADGroupMember -Identity $OldGroup -Members $User -Confirm:$false -ErrorAction Stop
        }
    }
} catch {
    Write-Error "❌ Script failed with error: $_"
} finally {
    Stop-Transcript
}
