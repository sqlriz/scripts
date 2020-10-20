#Reset password on SQL#
$Password = Read-Host -Prompt 'Please enter your password' -AsSecureString

# $newPassword = 'Rizwan15!'

# $Secure = (ConvertTo-SecureString $newPassword -AsPlainText -Force)

Set-AzSqlServer -ResourceGroupName 'SQLMI' -ServerName 'syserver23' -SqlAdministratorPassword $Password

#Reset on Postgres#
Install-Module -Name Az.PostgreSql <#Requires admin mode#>

$Password = Read-Host -Prompt 'Please enter your password' -AsSecureString 
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)

$Password = Read-Host -Prompt 'Please enter your password'

$Secure = (ConvertTo-SecureString $Password -AsPlainText -Force)

Update-AzPostgreSqlServer -ResourceGroupName 'SQLMIFailoverTesting' -Name 'rizwanpostgres' -AdministratorLoginPassword $Secure





$Password = Read-Host -Prompt 'Please enter your password' 
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
#$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)


Update-AzPostgreSqlServer -ResourceGroupName 'SQLMIFailoverTesting' -Name 'rizwanpostgres' -AdministratorLoginPassword $BSTR