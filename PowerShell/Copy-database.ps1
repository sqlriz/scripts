$ResourceGroup = 'SQLMI'
$sourceserver = 'syserver23'
$DatabaseName = 'saled'
$CopyResourceGroup = 'SQLMI'
$CopyServerName = 'syserver23'
$CopyDatabase = 'saled_Copy'

New-AzSqlDatabaseCopy -ResourceGroupName $ResourceGroup -ServerName $sourceserver -DatabaseName $DatabaseName `
    -CopyResourceGroupName $CopyResourceGroup -CopyServerName $CopyServerName -CopyDatabaseName $CopyDatabase -Verbose