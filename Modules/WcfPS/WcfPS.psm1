$names=@(
    "New-WcfWsdlImporter"
    "New-WcfProxyType"
    "New-WcfServiceEndpoint"
    "Set-WcfBindingConfiguration"
    "New-WcfChannel"
    "New-SecurityToken"
)

$names | ForEach-Object {. $PSScriptRoot\$_.ps1 }

Export-ModuleMember $names


