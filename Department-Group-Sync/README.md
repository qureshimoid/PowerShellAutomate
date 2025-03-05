🔥 Active Directory Department Group Sync

🛠 Overview

This PowerShell script automates the process of managing Active Directory (AD) security group memberships based on the Department attribute. If a user's department changes, the script:

✅ Adds them to the correct department group (e.g., Dept-Finance) ✅ Removes them from old department groups ✅ Logs all changes for easy tracking ✅ Runs automatically as a scheduled task

This ensures that users always belong to the right department-based security groups without manual intervention. 💪

🚀 Features

Dynamic Group Memberships: Automatically assigns users to Dept-<DepartmentName> groups.

Full Automation: Designed to run as a daily scheduled task.

Safety First: Logs all changes, includes error handling, and runs without confirmation prompts.

Efficient Processing: Uses Active Directory filters for bulk user retrieval and updates.

📜 Requirements

Active Directory Module for PowerShell

Permissions: The script must be run with an account that has permissions to modify group memberships in AD.

Naming Convention: Department groups should follow this format: Dept-<DepartmentName> (e.g., Dept-HR, Dept-IT).

📂 Setup Guide

1️⃣ Prerequisites

Before running the script, verify that the Active Directory module is installed:

Get-Module -ListAvailable ActiveDirectory

2️⃣ Running the Script Manually

To test the script without making changes:

.\AD_Department_Group_Sync.ps1 -WhatIf

To execute it for real:

.\AD_Department_Group_Sync.ps1

3️⃣ Automate with Task Scheduler (Recommended)

Schedule the script to run daily at 2 AM:

$Trigger = New-ScheduledTaskTrigger -Daily -At 2am
$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
  -Argument "-File C:\Scripts\AD_Department_Group_Sync.ps1"
Register-ScheduledTask -TaskName "AD Department Sync" `
  -Trigger $Trigger -Action $Action -User "DOMAIN\ServiceAccount" `
  -RunLevel Highest

🔍 Best Practices

✅ Testing Before Deployment

Run a dry run first:

.\AD_Department_Group_Sync.ps1 -WhatIf

📜 Monitoring & Logs

Check logs to track changes:

Get-Content C:\Logs\DepartmentGroupSync_*.log -Tail 50

🔐 Security Considerations

Use a dedicated service account with least privilege permissions:

Read access to user objects

Write access to modify group memberships

💡 Why Use This Script?

🚀 IT Efficiency: No more manual group assignments. 🛡 Security Compliance: Ensures users have correct access rights. 📊 Auditable Changes: Everything is logged.

Use it. Modify it. Dominate AD management like a pro. 💥🔥

