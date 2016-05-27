# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

. "$PSScriptRoot\New-WcfProxyType.ps1"
. "$PSScriptRoot\New-WcfServiceEndpoint.ps1"

function New-WcfChannel {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $Endpoint,
        [Parameter(Mandatory=$false)]
        [System.Type]$ProxyType=$null,
        [Parameter(Mandatory=$false,ParameterSetName="UsernamePassword")]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false,ParameterSetName="Token")]
        [System.IdentityModel.Tokens.GenericXmlSecurityToken]$Token

    )
    Begin {
    }

    Process {
        if( -not $ProxyType)
        {
            if($Endpoint.GetType() -eq [System.ServiceModel.Description.ServiceEndpoint])
            {
                $importer = New-WcfWsdlImporter -Endpoint ($Endpoint.Address.ToString()) -HttpGet
            }
            else
            {
                $importer=New-WcfWsdlImporter -Endpoint $Endpoint -HttpGet
            }
            $ProxyType=$importer | New-WcfProxyType
        }

        if($Endpoint.GetType() -ne [System.ServiceModel.Description.ServiceEndpoint])
        {
            $Endpoint=$importer | New-WcfServiceEndpoint -Endpoint $Endpoint
        }

        $client=New-Object $ProxyType($Endpoint.Binding, $Endpoint.Address)
        if($Credential)
        {
            throw (New-Object System.NotImplementedException)
        }
        if($Token)
        {
            $client.ChannelFactory.CreateChannelWithIssuedToken($Token);
        }
    }


    End {
    }

}
