# Connect-AzAccount
# The SubscriptionId in which to create these objects
$SubscriptionId = '23d34427-d6a7-4313-be73-1169643a85dd'
# Set the information for your managed instance
$SourceResourceGroupName = "SQLResources"
$SourceInstanceName = "sql1243"
$SourceDatabaseName = "pubs4"

# Set the information for your destination managed instance
$TargetResourceGroupName = "SQLMI"
$TargetInstanceName = "rizwansql2443"
$TargetDatabaseName = "pubs4"

#Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

$backup = Get-AzSqlInstanceDatabaseGeoBackup `
-ResourceGroupName $SourceResourceGroupName `
-InstanceName $SourceInstanceName `
-Name $SourceDatabaseName -Verbose

#Set-AzContext 'Rizwan_AzureInternal'

$backup | Restore-AzSqlInstanceDatabase -FromGeoBackup `
-TargetInstanceDatabaseName $TargetDatabaseName `
-TargetInstanceName $TargetInstanceName `
-TargetResourceGroupName $TargetResourceGroupName -Verbose



