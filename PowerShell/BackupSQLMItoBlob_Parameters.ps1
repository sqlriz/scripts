#Install-Module dbatools
#Install-Module -Name Az -AllowClobber -Scope AllUsers



param(
[string]$server = ".", 
[string] $Database ,
[string] $subscription,
[string] $ResourceGroupName,
[string] $StorageAccount,
[string] $container,
[string] $BackupfileName = "1"
)

#Get-AzSubscription | Format-Table

#Set-AzContext "Rizwan_Internal_1000"

#$subscription = 'Rizwan_Internal_1000'
Select-AzSubscription -Subscription $subscription
Get-AzContext

#$server = "tcp:sql1243.public.b955f902d673.database.windows.net,3342"
#$Database = "Pubs"
$server_Login = (Get-Credential)


#Setting up backup file name
if ($BackupfileName -ne "1")
{
    $BackupfileName = $BackupfileName
}
else {
    $dt = Get-Date -Format yyyyMMdd_HHmmss
    $BackupfileName = $Database + "_$dt" + ".bak"
}


$BlobStorageURL = "https://$StorageAccount.blob.core.windows.net/$container"
Write-Host $BlobStorageURL, $Server, $Database, $subscription


$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccount
$ctx = $storageAccount.Context



#checking if credential already exist or need be created
$SASCredential = Get-DbaCredential -SqlInstance $server -SqlCredential $server_Login 

$SQLMI = Connect-DbaInstance -SqlInstance $server -SqlCredential $server_Login


$sas = (New-AzStorageAccountSASToken -Service Blob -ResourceType Object -Permission "rwdl" -Context $ctx).TrimStart('?')
$serverCred = New-DbaCredential -SqlInstance $SQLMI `
                       -Name $BlobStorageURL `
                       -Identity "SHARED ACCESS SIGNATURE" `
                       -SecurePassword (ConvertTo-SecureString $sas -AsPlainText -Force) `
                       -Force
write-host "Credential recreated"
<#
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
#>

Backup-DbaDatabase -SqlInstance $SQLMI -Database $Database `
    -AzureBaseUrl $BlobStorageURL `
    -BackupFileName $BackupfileName `
    -Type Full -Checksum -CopyOnly -CompressBackup -Verbose




   

# SIG # Begin signature block
# MIIFdgYJKoZIhvcNAQcCoIIFZzCCBWMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUReGuxbZal8mbvEsvDAwBFoOb
# LX+gggMOMIIDCjCCAfKgAwIBAgIQG98ZqjwiS79O/qvA0n1G+jANBgkqhkiG9w0B
# AQUFADAdMRswGQYDVQQDDBJMb2NhbCBDb2RlIFNpZ25pbmcwHhcNMjAwMzMxMTc1
# NjIwWhcNMjEwMzMxMTgxNjIwWjAdMRswGQYDVQQDDBJMb2NhbCBDb2RlIFNpZ25p
# bmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDXQFM2iiZw8pzhSUHq
# e9dNJa9/lZDfqYn+P7NgXqRIs4hSGRrG8jpE7ZOtb7FQJsn5H4Uc8fQxpE8syJkq
# Gu06aWthoJZnKV7yiMfoOZ51R4DCtfSAeYPb+KSCbgNcGnNlcoVaY7/nsXubeLXc
# QWBH7ioaSaXt26vcZR/EJvgAHhvAcL8gN/TV5yccj0mfEPPQK56gk6YRXjLamG9m
# 3XS2MByUUd3UllsvgoJ7dgfBZW1eIAOGUBEpU2/Q6jpy1lB7aY+cuCim22k98UiU
# UtVE0XKaFIGqZvQ5TNK5tFS6Ulown/fsk/rkrW2h/TAs73AwTZqbc2HsgbVB7Z/v
# E7oRAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUzumMLVYfiIHVGaCFrsYxkjZAjpEwDQYJKoZIhvcNAQEFBQAD
# ggEBAFFESvdng9L1fpMtsABhazPqTExKJhydvjSfuiuS05EbN6A+YBMkwusf/7Xi
# LeXLo83fXyZA2BoTt41pwVKCIPcxMHM2nsbLJjofslBb9HREy0TeQ7/AdyyRqZJh
# PmEaiejXKESc6qxwoySZdXFCWeB8EZJA31F77HDX4HZOIDjNy/irCUT0V0VGikDH
# 4jfinexDD85QkiuCcT1ab7GtFDXSsr7zBitkoBgouqZHs2F16z536+dBRGUoqgsu
# YkcVCCtiarb2T3hTIo9s7t7nHe2nmiMIENGZMYXLxtB3Syy6FOdV0/IAX6czXX5g
# TOSuWoKJMxGJ/XDgmhJkW46ZNh4xggHSMIIBzgIBATAxMB0xGzAZBgNVBAMMEkxv
# Y2FsIENvZGUgU2lnbmluZwIQG98ZqjwiS79O/qvA0n1G+jAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUkBNUsjlKztHfr0B1XTe5qh00UCYwDQYJKoZIhvcNAQEBBQAEggEAu1CRDZjF
# gmmNorXf6xMOGfUuZtisSvMTzrw+NahIWWG4iWcZEz6dccrSav1g0560xin+GXGg
# snblzXD6hGAGMrv7JWXKloc+7G2lfBO1Ye4aVhpCDro3nJ335OMtBAvnEw8x/O1k
# LjhL6zrrxfaJ0zE2VpuEkW4+V8AAE2G25L82mLRfYFANeWigQIQhf395/ytAuaaS
# yGYQqSzvdzwP0UAP3m2h3Jos+dBd/2TvTtN0VLYobKpKIQi0Ni3hmRasXT14zpfc
# LbizmixgfSq48SpCkxBGvWGxqhDvxvF5J6ghTTSoy5MgonAX1zEu1xm2/ddxpPuf
# TBWS/S8cn489TA==
# SIG # End signature block
