# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

. "$PSScriptRoot\Set-WcfBindingConfiguration.ps1"

function New-WcfWsdlImporter {
    [CmdletBinding()]
    [OutputType([System.ServiceModel.Description.WsdlImporter])]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Endpoint, 
        [Parameter(Mandatory=$false)]
        [switch]$HttpGet=$false
    )
    Begin {
    }

    Process {
	    if($HttpGet)
	    {
		    $mode = [System.ServiceModel.Description.MetadataExchangeClientMode]::HttpGet
            $mexEndpoint="$Endpoint"+"?wsdl"
	    }
	    else
	    {
		    $mode = [System.ServiceModel.Description.MetadataExchangeClientMode]::MetadataExchange
            $mexEndpoint=$Endpoint
	    }
	    
        $mexUri=[Uri]$mexEndpoint
	    if($mexUri.Schema -eq [Uri]::UriSchemeHttp)
	    {
		    $mexBinding=[System.ServiceModel.Description.MetadataExchangeBindings]::CreateMexHttpBinding()
	    }
	    else
	    {
		    $mexBinding=[System.ServiceModel.Description.MetadataExchangeBindings]::CreateMexHttpsBinding()
	    }
        $mexBinding | Set-WcfBindingConfiguration -MaxOut

	    $mexClient = New-Object System.ServiceModel.Description.MetadataExchangeClient($mexBinding);
	    $mexClient.MaximumResolvedReferences = [System.Int32]::MaxValue

	    $metadataSet = $mexClient.GetMetadata($mexUri,$mode)
	    New-Object System.ServiceModel.Description.WsdlImporter($metadataSet)
   }


    End {
    }

}
