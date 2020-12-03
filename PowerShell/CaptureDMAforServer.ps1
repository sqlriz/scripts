#Captures DMA for each database on the server for analysis
# https://docs.microsoft.com/en-us/sql/dma/dma-sku-recommend-sql-db?view=sql-server-ver15
Set-Location "C:\Program Files\Microsoft Data Migration Assistant"


$ServerName = 'SYHASSANBK2'
$InstanceName = "SQL2017" #for default instance put "MSSQLSERVER"
$SQLServer = $ServerName + "\" +$InstanceName
$Path = "C:\DMASKU\$ServerName" + "_$InstanceName"
$OutputFile = "$Path" + "\$ServerName" + "_$InstanceName.csv"


#WRITE-HOST $Path, $SQLServer, $OutputFile

If (Test-Path -Path $path -PathType Container)

    { Write-Host "$path already exists" -ForegroundColor Red}

    ELSE

        { New-Item -Path $path  -ItemType directory }


#Write-Host $path

.\SkuRecommendationDataCollectionScript.ps1 -ComputerName $ServerName -OutputFilePath $OutputFile -CollectionTimeInSeconds 7200 -DbConnectionString "Server=$SQLServer;Initial Catalog=master;Integrated Security=SSPI;"
