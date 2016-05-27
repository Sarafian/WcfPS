# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

function New-WcfServiceEndpoint {
    [CmdletBinding()]
    [OutputType([System.ServiceModel.Description.ServiceEndpoint])]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.ServiceModel.Description.WsdlImporter]$WsdlImporter,
        [Parameter(Mandatory=$false)]
        [string]$Endpoint
    )
    Begin {
    }

    Process {
        $endpoints = $WsdlImporter.ImportAllEndpoints();
        Write-Verbose "endpoints.Count=$($endpoints.Count)"
        $endpoints | ForEach-Object { Write-Verbose "endpoint=$($_.Address)"}
        
        if($Endpoint)
        {
            $endpoints=$endpoints |Where-Object -Property Address -Match $Endpoint
        }
        $endpoints
    }


    End {
    }

}
