##https://community.spiceworks.com/how_to/153255-windows-10-signing-a-powershell-script-with-a-self-signed-certificate

New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my `
-Subject "CN=Local Code Signing" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-KeyExportPolicy Exportable `
-KeyUsage DigitalSignature `
-Type CodeSigningCert

$cert = @(Get-ChildItem cert:\CurrentUser\My -CodeSigning)[0]



Set-AuthenticodeSignature 'C:\Users\syhassan\OneDrive - Microsoft\Transfer\Nova\CaptureDMAforServer_Parameters.ps1' $cert