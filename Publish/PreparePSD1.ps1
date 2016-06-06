& "$PSScriptRoot\..\ISEScripts\Reset-Module.ps1"

$exportedNames=Get-Command -Module WcfPS | Select-Object -ExpandProperty Name

. "$PSScriptRoot\Version.ps1"
$semVersion=Get-Version

$author="Alex Sarafian"
$company=""
$copyright="(c) $($date.Year) $company. All rights reserved."
$description="A powershell module to help work with WCF Services."

$modules=Get-ChildItem "$PSScriptRoot\..\Modules\"

foreach($module in $modules)
{
    Write-Host "Processing $module"
    $name=$module.Name

    $psm1Name=$name+".psm1"
    $psd1Name=$name+".psd1"
    $psd1Path=Join-Path $module.FullName $psd1Name

    $guid="1a3aff35-5184-4bef-9234-386eaf6d50cf"
    $hash=@{
        "Author"=$author;
        "Copyright"=$cop;
        "RootModule"=$psm1Name;
        "Description"=$description;
        "Guid"=$guid;
        "ModuleVersion"=$semVersion;
        "Path"=$psd1Path;
        "Tags"=@('Wcf', 'Tools');
        "LicenseUri"='https://github.com/Sarafian/WcfPS/blob/master/LICENSE';
        "ProjectUri"= 'http://sarafian.github.io/WcfPS/';
        "ReleaseNotes"= 'https://github.com/Sarafian/WcfPS/blob/master/CHANGELOG.md';
        "CmdletsToExport" = $exportedNames;
        "FunctionsToExport" = $exportedNames;
        "PowerShellHostVersion"="4.0"
    }

    New-ModuleManifest  @hash
}


