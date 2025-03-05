Inactive Active Directory Account Cleanup Script

Overview

This PowerShell script identifies and disables inactive Active Directory user accounts older than a specified number of days. It also generates a report for auditing and optionally disables inactive accounts.

Features

Safety Mechanisms

Exclusion list for protected accounts (e.g., Administrator, Service Accounts)

Confirmation prompt before disabling accounts

Report-only mode for previewing results

Detailed error tracking

Auditing

Timestamped CSV reports

Logs account metadata before disabling

Optional email notifications

Flexibility

Configurable inactivity period

Target specific Organizational Units (OUs)

Dry run mode (-ReportOnly)

Action mode (-DisableAccounts)


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

Pre-Execution Checklist

Test in a non-production environment

Verify backup/restore process

Communicate with stakeholders

Post-Disablement Actions

Move disabled accounts to a "Disabled Users" OU

Remove group memberships

Schedule permanent deletion (after 90 days)

Monitoring

Review CSV reports weekly

Audit enabled accounts with old LastLogonDate

Monitor Event ID 4725 (Account Disabled) in Security logs


Security Considerations

Run the script with least-privilege permissions:

Read access to all users

Write access to userAccountControl attribute

Store reports securely in a protected folder

Encrypt email notifications if sending sensitive data