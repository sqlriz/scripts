#For Demo

Connect-AzAccount

Get-AzContext #Get information about which Subscription is session running in
Get-AzSubscription #find all subscriptions under the account


$subscription = '<Subscriptionname>'
Set-AzContext $subscription


$randomIdentifier = $(Get-Random)
$ResourceGroup = "rg-$randomIdentifier"
$location = 'East US2'
$VaultName = "ak-$randomIdentifier"
$Userprincipal = '<email@microsoft.com>'
$keyname = "azkey-$randomIdentifier"
$outputfile = "C:\$randomIdentifier\backup_$keyname.keybackup"



#New Resource group if it doesn't exist
New-AzResourceGroup -Name $ResourceGroup -Location $location

#Create a new vault"
New-AzKeyVault -Name $VaultName -ResourceGroupName $ResourceGroup -Location $location -Sku 'standard' -SoftDeleteRetentionInDays 7 -EnabledForDiskEncryption -verbose



#Grant your account permissions to add keys
$objID=(Get-AzADUser -UserPrincipalName $Userprincipal).Id
Set-AzKeyVaultAccessPolicy -VaultName $VaultName `
                           -ResourceGroupName $ResourceGroup `
                           -ObjectId $objID `
                           -PermissionsToKeys decrypt, encrypt, unwrapKey, wrapKey, verify, sign, get, list, update, create, import, delete, backup, restore, recover, purge


#Add key in the vault
$Expires = (Get-Date).AddYears(1).ToUniversalTime()
Add-AzKeyVaultKey -VaultName $VaultName -Name $keyname -Destination 'Software' -size 2048 -Expires $Expires

#Get information about the new key created
Get-Azkeyvaultkey -VaultName $VaultName -Name $keyname
   
#Backup key

$path = "C:\$randomIdentifier"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
Backup-AzKeyVaultKey -VaultName $VaultName -Name $keyname -OutputFile $outputfile