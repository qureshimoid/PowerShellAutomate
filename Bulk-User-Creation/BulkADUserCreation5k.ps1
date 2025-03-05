Import-Csv "NewStudents.csv" | ForEach-Object { 
    New-ADUser -Name $_.Name `
               -SamAccountName $_.ID `
               -UserPrincipalName "$($_.ID)@uni.edu" `
               -GivenName $_.FirstName `
               -Surname $_.LastName `
               -EmailAddress $_.Email `
               -AccountPassword (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force) `
               -Path "OU=Inactive,DC=uni,DC=edu" `
               -Enabled $true `
               -ChangePasswordAtLogon $true
}
