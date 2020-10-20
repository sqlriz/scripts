#Connect to Azure if not already connected
Connect-AzAccount
#Get information which subscriptin you are connected in
Get-AzContext

#Set subscription in which source and target SQL are located
Get-AzSubscription
Set-AzContext 'Rizwan_Internal_1000'

#Variables
$S_ResourceGroup = 'SQLResources'
$S_Server = 'server1p'
$Database = 'salesdb'



$T_ResourceGroup = 'SQLMI'
$T_Server = 'sqlserver2p'
$T_OriginalName = 'salesdb'
$dt = Get-Date -Format yyyyMMdd
$T_DBOriginalRename = $T_OriginalName +'_' +$dt






#Get Target DB Service Level
$T_DB = Get-AzSqlDatabase -ResourceGroupName $T_ResourceGroup -ServerName $T_Server -DatabaseName $T_OriginalName

#Rename TargetDatabse to be refreshed
Set-AzSqlDatabase -ResourceGroupName $T_ResourceGroup -ServerName $T_Server -DatabaseName $T_OriginalName -NewName $T_DBOriginalRename

#Start copy of the sourceDB to TargetDB
New-AzSqlDatabaseCopy -ResourceGroupName $S_ResourceGroup -ServerName $S_Server -DatabaseName $Database -CopyResourceGroupName $T_ResourceGroup -CopyServerName $T_Server -CopyDatabaseName $Database
Get-AzSqlDatabase -ResourceGroupName $T_ResourceGroup -ServerName $T_Server -DatabaseName $Database

Start-Sleep -Seconds 10

#Set Restored DB Service Tier
Set-AzSqlDatabase -ResourceGroupName $T_ResourceGroup -ServerName $T_Server -DatabaseName $Database -Edition $T_DB.Edition -RequestedServiceObjectiveName $T_DB.CurrentServiceObjectiveName
<#
REsources
https://docs.microsoft.com/en-us/powershell/module/az.sql/set-azsqldatabase?view=azps-4.1.0
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-copy?tabs=azure-powershell
https://docs.microsoft.com/en-us/azure/sql-database/scripts/sql-database-copy-database-to-new-server-powershell
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-single-databases-manage#powershell-manage-sql-database-servers-and-single-databases
Get-AzSqlServerServiceObjective -Location 'EastUS2' | Out-GridView
#>
