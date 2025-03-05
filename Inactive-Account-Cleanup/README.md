                                            Inactive Active Directory Account Cleanup Script

Overview
This PowerShell script identifies and disables inactive Active Directory user accounts older than a specified number of days. It also generates a report for auditing and optionally disables inactive accounts.

Features

Safety Mechanisms
<ul>
<li>Exclusion list for protected accounts (e.g., Administrator, Service Accounts)</li>
<li>Confirmation prompt before disabling accounts</li>
<li>Report-only mode for previewing results</li>
</ul>

Auditing
<ul>
<li>Timestamped CSV reports</li>
<li>Logs account metadata before disabling</li>
<li>Optional email notifications</li>
</ul>

Flexibility
<ul>
<li>Configurable inactivity period</li>
<li>Target specific Organizational Units (OUs)</li>
<li>Dry run mode (-ReportOnly)</li>
<li>Action mode (-DisableAccounts)</li>
</ul>

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
<li>Test in a non-production environment</li>
<li>Verify backup/restore process</li>
<li>Communicate with stakeholders</li>
<br/>
Post-Disablement Actions
<li>Move disabled accounts to a "Disabled Users" OU</li>
<li>Remove group memberships</li>
<li>Schedule permanent deletion (after 90 days)</li>
<br/>
Monitoring
<li>Review CSV reports weekly</li>
<li>Audit-enabled accounts with old LastLogonDate</li>
<li>Monitor Event ID 4725 (Account Disabled) in Security logs</li>
<br/>
Security Considerations
<li>Run the script with least-privilege permissions:</li>
    <ul>	
    <li>Read access to all users</li>
    <li>Write access to user AccountControl attribute</li>
    </ul>
<li>Store reports securely in a protected folder</li>
<li>Encrypt email notifications if sending sensitive data</li>
