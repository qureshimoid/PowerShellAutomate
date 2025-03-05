                                            Inactive Active Directory Account Cleanup Script

Overview
This PowerShell script identifies and disables inactive Active Directory user accounts older than a specified number of days. It also generates a report for auditing and optionally disables inactive accounts.
Features
•	Safety Mechanisms
    o	Exclusion list for protected accounts (e.g., Administrator, Service Accounts)
    o	Confirmation prompt before disabling accounts
    o	Report-only mode for previewing results
    o	Detailed error tracking
•	Auditing
    o	Timestamped CSV reports
    o	Logs account metadata before disabling
    o	Optional email notifications
•	Flexibility
    o	Configurable inactivity period
    o	Target specific Organizational Units (OUs)
    o	Dry run mode (-ReportOnly)
    o	Action mode (-DisableAccounts)

Usage
1. Generate Report Only (No Changes Made)
.\InactiveADCleanup.ps1 -DaysInactive 180 -ReportOnly

2. Disable Inactive Accounts
.\InactiveADCleanup.ps1 -DaysInactive 180 -DisableAccounts

3. Target Specific Organizational Unit
.\InactiveADCleanup.ps1 -OU "OU=Contractors,DC=yourdomain,DC=com" -DaysInactive 90 -DisableAccounts

Advanced Options
Schedule the Script (Run Weekly)
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 2am
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' `
  -Argument "-File C:\Scripts\InactiveADCleanup.ps1 -DisableAccounts"
Register-ScheduledTask -TaskName "AD Account Cleanup" `
  -Trigger $Trigger -Action $Action -User "DOMAIN\ADM_Account" -RunLevel Highest
  
 Retention Policy (Delete Old Reports Automatically)
 # Keep reports for 90 days
Get-ChildItem C:\ADAudit\*.csv | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-90)
} | Remove-Item

Best Practices		
•	Pre-Execution Checklist
    o	Test in a non-production environment
    o	Verify backup/restore process
    o	Communicate with stakeholders
•	Post-Disablement Actions
    o	Move disabled accounts to a "Disabled Users" OU
    o	Remove group memberships
    o	Schedule permanent deletion (after 90 days)
•	Monitoring
    o	Review CSV reports weekly
    o	Audit enabled accounts with old LastLogonDate
    o	Monitor Event ID 4725 (Account Disabled) in Security logs

Security Considerations
•	Run the script with least-privilege permissions:
    o	Read access to all users
    o	Write access to userAccountControl attribute
•	Store reports securely in a protected folder
•	Encrypt email notifications if sending sensitive data
