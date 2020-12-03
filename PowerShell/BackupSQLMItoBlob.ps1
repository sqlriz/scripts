Install-Module dbatools
Install-Module -Name Az -AllowClobber -Scope AllUsers

Get-AzSubscription | Format-Table

Set-AzContext "Rizwan_Internal_1000"

$subscription = 'Rizwan_Internal_1000'
Select-AzSubscription -Subscription $subscription

$dt = Get-Date -Format yyyyMMdd_HHmmss
$server = "tcp:sql1243.public.b955f902d673.database.windows.net,3342"
$Database = "Pubs"
$server_Login = (Get-Credential)
$BackupFileName = $Database + "_$dt" + ".bak"

$ResourceGroupName = "SQLResources"

#Get information about container
$StorageAccount = "sqlbackuprizwan"
$container = "sqlbackup"
$BlobStorageURL = "https://$StorageAccount.blob.core.windows.net/$container"





$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccount
$ctx = $storageAccount.Context

Get-AzStorageContainer -Context $ctx -Name $container


#checking if credential already exist or need be created
$SASCredential = Get-DbaCredential -SqlInstance $server -SqlCredential $server_Login 

$SQLMI = Connect-DbaInstance -SqlInstance $server -SqlCredential $server_Login


if ($SASCredential.Name -eq $BlobStorageURL)
{
     
    write-host "Credential already exists, skipping this step"
}
Else {
    $sas = (New-AzStorageAccountSASToken -Service Blob -ResourceType Object -Permission "rwdl" -Context $ctx).TrimStart('?')
    $serverCred = New-DbaCredential -SqlInstance $SQLMI `
                           -Name $BlobStorageURL `
                           -Identity "SHARED ACCESS SIGNATURE" `
                           -SecurePassword (ConvertTo-SecureString $sas -AsPlainText -Force) `
                           -Force
                           
    write-host "Credential does NOT and it has been created"
}


Backup-DbaDatabase -SqlInstance $SQLMI -Database $Database `
    -AzureBaseUrl $BlobStorageURL `
    -BackupFileName $BackupFileName `
    -Type Full -Checksum -CopyOnly -CompressBackup -Verbose