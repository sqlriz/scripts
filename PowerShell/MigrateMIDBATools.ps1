Install-Module Az.Resources
Install-Module Az.Storage
Install-Module dbatools
Install-Module -Name Az -AllowClobber -Scope AllUsers

# https://techcommunity.microsoft.com/t5/Azure-SQL-Database/Automate-migration-to-SQL-Managed-Instance-using-Azure/ba-p/830801

Login-AzAccount
Get-AzSubscription
Get-AzContext
$subscription = 'Rizwan_Internal_1000'
Select-AzSubscription -Subscription $subscription
$DBName = 'SQL2017_Nexus'
$randomIdentifier = $(Get-Random)

# temporary resources needed for backups
$location = "EastUS2"
$resourceGroup = "temp-migration-demo-rg-$randomIdentifier"
$blobStorageAccount = "migration33111"
$containerName = "backups"
$backupfilename = "$dbname.bak"
 
# source and target instances
$sourceInstance = "SYHASSANBK2\SQL2017"
$sourceDatabase = $DBName
 
$targetInstance = "tcp:sql1243.public.b955f902d673.database.windows.net,3342"
$targetDatabase = $DBName
$MIResourceGroup = 'SQLResources'



New-AzResourceGroup -Name $resourceGroup -Location $location
 
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup `
-Name $blobStorageAccount `
-Location $location `
-SkuName Standard_LRS `
-Kind StorageV2 -Verbose
 
$ctx = $storageAccount.Context
New-AzStorageContainer -Name $containerName -Context $ctx -Permission Container -Verbose


$sas = (New-AzStorageAccountSASToken -Service Blob -ResourceType Object -Permission "rw" -Context $ctx).TrimStart('?')
# Note: it must have r permission!
 
$sourceCred = New-DbaCredential -SqlInstance $sourceInstance `
                           -Name "https://$blobStorageAccount.blob.core.windows.net/$containerName" `
                           -Identity "SHARED ACCESS SIGNATURE" `
                           -SecurePassword (ConvertTo-SecureString $sas -AsPlainText -Force) -force -Verbose


$blobfile = Get-AzStorageBlob -Container $containerName -Context $ctx -ErrorAction Ignore -Verbose
if ($blobfile.Name -like $backupfilename)
{
    Get-AzStorageBlob -Container $containerName -Context $ctx -Blob $backupfilename | Remove-AzStorageBlob 
    write-host "Removing Blob file $Backupfilename"
}
Else {
    write-host "$backupfilename not found"
}

                           
Backup-DbaDatabase -SqlInstance $sourceInstance -Database $sourceDatabase `
    -AzureBaseUrl "https://$blobStorageAccount.blob.core.windows.net/$containerName" `
    -BackupFileName $backupfilename `
    -Type Full -Checksum -CopyOnly -CompressBackup -Verbose



## Generate new SAS token that will read .bak file
$sas = (New-AzStorageAccountSASToken -Service Blob -ResourceType Object -Permission "r" -Context $ctx).TrimStart('?') # -ResourceType Container,Object
 
$targetLogin = Get-Credential -Message "Login to target Managed Instance as:"
$target = Connect-DbaInstance -SqlInstance $targetInstance -SqlCredential $targetLogin

$targetCred = New-DbaCredential -SqlInstance $target `
                           -Name "https://$blobStorageAccount.blob.core.windows.net/$containerName" `
                           -Identity "SHARED ACCESS SIGNATURE" `
                           -SecurePassword (ConvertTo-SecureString $sas -AsPlainText -Force) `
                           -Force
Restore-DbaDatabase -SqlInstance $target -Database $targetDatabase `
                   -Path "https://$blobStorageAccount.blob.core.windows.net/$containerName/$DBName.bak" -WithReplace -Verbose



Remove-AzResourceGroup $resourceGroup



