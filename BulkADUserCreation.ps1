#######################################################################################
# BULK ACTIVE DIRECTORY USER CREATION & GROUP ASSIGNMENT SCRIPT   #
#######################################################################################

# Import Active Directory module
Import-Module ActiveDirectory

# Define user list CSV file
$csvPath = "C:\Temp\NewUsers.csv"  # Update path if needed

# Define default password for new users (Modify as per policy)
$defaultPassword = ConvertTo-SecureString "P@ssword123" -AsPlainText -Force

# Import CSV and loop through users
$users = Import-Csv -Path $csvPath
foreach ($user in $users) {
    try {
        # Create the new user
        New-ADUser -SamAccountName $user.Username `
                   -UserPrincipalName "$($user.Username)@yourdomain.com" `
                   -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -Department $user.Department `
                   -Title $user.Title `
                   -EmailAddress $user.Email `
                   -Path "OU=Users,DC=yourdomain,DC=com" `  # Update OU Path
                   -AccountPassword $defaultPassword `
                   -Enabled $true
        
        Write-Host "[+] Created user: $($user.Username)"

        # Add user to groups
        if ($user.Groups -ne "") {
            $groups = $user.Groups -split ";"
            foreach ($group in $groups) {
                Add-ADGroupMember -Identity $group -Members $user.Username
                Write-Host "    -> Added $($user.Username) to group: $group"
            }
        }
        
    } catch {
        Write-Host "[!] ERROR creating user: $($user.Username) - $_" -ForegroundColor Red
    }
}

Write-Host "✅ BULK USER CREATION COMPLETED!" -ForegroundColor Green
