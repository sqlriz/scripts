Get-service *SQL* | Where-Object {$_.Name -like  "MSSQL*"} | Stop-Service

Get-service *SQL* | Where-Object {$_.Name -like  "MSSQL*"} | Start-Service -Verbose

Stop-Service -Name 'MSSQL$SQL2019'