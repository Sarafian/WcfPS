Param (
    [Parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string]$NuGetApiKey
)

& "$PSScriptRoot\PreparePSD1.ps1"

Publish-Module -Path "$PSScriptRoot\..\Modules\WcfPS" -NuGetApiKey $NuGetApiKey 

