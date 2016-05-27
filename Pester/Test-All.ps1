Param (
    [Parameter(
        Mandatory = $true,
        ParameterSetName="ISHExternal-UsernamePassword"
    )]
    [Parameter(
        ParameterSetName="ISHExternal-Windows"
    )]
    [string]$Hostname,
    [Parameter(
        Mandatory = $true,
        ParameterSetName="ISHExternal-UsernamePassword"
    )]
    [string[]]$UsernamePasswordDeploymentNames,
    [Parameter(
        Mandatory = $true,
        ParameterSetName="ISHExternal-UsernamePassword"
    )]
    [PSCredential]$UsernamePassword=$null,
    [Parameter(
        Mandatory = $true,
        ParameterSetName="ISHExternal-Windows"
    )]
    [string[]]$WindowsDeploymentNames,
    [Parameter(
        Mandatory = $true,
        ParameterSetName="WSTrust"
    )]
    [string]$MexUri,
    [Parameter(
        Mandatory = $true,
        ParameterSetName="WSTrust"
    )]
    [string]$AuthenticationEndpoint,
    [Parameter(
        Mandatory = $false,
        ParameterSetName="WSTrust"
    )]
    [string[]]$SymmetricIdentifier=$null,
    [Parameter(
        Mandatory = $false,
        ParameterSetName="WSTrust"
    )]
    [string[]]$BearerIdentifier=$null,
    [Parameter(
        Mandatory = $false,
        ParameterSetName="WSTrust"
    )]
    [PSCredential]$Credential=$null,
    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet("LegacyNUnitXml","NUnitXml")]
    [string]$OutputFormat=$null,
    [Parameter(
        Mandatory = $false
    )]
    [string]$OutputPath=$null
)

$failedCount=0
$modulePath= Resolve-Path "$PSScriptRoot\..\Modules\WcfPS"

. "$modulePath\New-WcfWsdlImporter.ps1"
. "$modulePath\New-WcfServiceEndpoint.ps1"
. "$modulePath\Set-WcfBindingConfiguration.ps1"
. "$modulePath\New-WcfProxyType.ps1"
. "$modulePath\New-SecurityToken.ps1"
. "$modulePath\New-WcfChannel.ps1"

$tests=@{}
if($UsernamePasswordDeploymentNames)
{
    $UsernamePasswordDeploymentNames | ForEach-Object {
        $suffix=$_
        $tests+=@{
            Name="Test-ISHExternal.$Hostname.$suffix"
            Script=@{
                Path = "$PSScriptRoot\Test-ISHExternal.ps1"
                Parameters = @{
                    ISHWS = "https://$Hostname/ishws$suffix/"
                    Credential = $UsernamePassword
                }
            }
        }
    }
}
if($WindowsDeploymentNames)
{
    $WindowsDeploymentNames | ForEach-Object {
        $suffix=$_
        $tests+=@{
            Name="Test-ISHExternal.$Hostname.$suffix"
            Script=@{
                Path = "$PSScriptRoot\Test-ISHExternal.ps1"
                Parameters = @{
                    ISHWS = "https://$Hostname/ishws$suffix/"
                }
            }
        }
    }
}

if($MexUri)
{
    if($SymmetricIdentifier)
    {
        $SymmetricIdentifier | ForEach-Object {
            $tests+=@{
                Name="Test-WSTrust.Symmetric"
                Script=@{
                    Path = "$PSScriptRoot\Test-WSTrust.ps1"
                    Parameters = @{
                        MexUri=$MexUri
                        AuthenticationEndpoint=$AuthenticationEndpoint
                        SymmetricAppliesTo=$_
                        Credential=$Credential
                    }
                }
            }
        }
    }
    if($BearerIdentifier)
    {
        $BearerIdentifier | ForEach-Object {
            $tests+=@{
                Name="Test-WSTrust.Bearer"
                Script=@{
                    Path = "$PSScriptRoot\Test-WSTrust.ps1"
                    Parameters = @{
                        MexUri=$MexUri
                        AuthenticationEndpoint=$AuthenticationEndpoint
                        BearerAppliesTo=$_
                        Credential=$Credential
                    }
                }
            }
        }
    }
}



$failedCount=0
$counter=0
$tests |ForEach-Object {
    $counter+=1
    $testName="$($_.Name)-$counter"
    $testScript=$_.Script
    Write-Host "Executing $testName"
    
    if($OutputFormat) {
        $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".").Replace(".ps1", "")
        if($OutputPath -and ($OutputPath -ne ""))
        {
            $outputFile="$OutputPath\$testName.xml"
        }
        else
        {
            $outputFile="$PSScriptRoot\$testName.xml"
        }
        $pesterResult = Invoke-Pester -Script $testScript -OutputFormat $OutputFormat -OutputFile $outputFile -PassThru
    }
    else {
        $tests |ForEach-Object {
            $pesterResult = Invoke-Pester -Script $testScript -PassThru
        }
    }
    if($pesterResult.FailedCount -gt 0)
    {
        $failedCount+=$pesterResult.FailedCount
        Write-Error "$testName failed count $($pesterResult.FailedCount)/$($pesterResult.TotalCount)"
    }
    else
    {
        Write-Host "Success $testName count $($pesterResult.PassedCount)"
    }
}


exit $failedCount

