# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

. "$PSScriptRoot\New-WcfProxyType.ps1"
. "$PSScriptRoot\New-WcfServiceEndpoint.ps1"

function New-WcfChannel {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true,ParameterSetName="NoAuthentication")]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true,ParameterSetName="UsernamePassword")]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true,ParameterSetName="Token")]
        $Endpoint,
        [Parameter(Mandatory=$false,ParameterSetName="NoAuthentication")]
        [Parameter(Mandatory=$false,ParameterSetName="UsernamePassword")]
        [Parameter(Mandatory=$false,ParameterSetName="Token")]
        [Parameter(Mandatory=$false)]
        [System.Type]$ProxyType=$null,
        [Parameter(Mandatory=$true,ParameterSetName="UsernamePassword")]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$true,ParameterSetName="Token")]
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

        switch($PSCmdlet.ParameterSetName)
        {
            'NoAuthentication' {
                $client.ChannelFactory.CreateChannel()
                break;
            }
            'UsernamePassword' {
                throw (New-Object System.NotImplementedException)
                break;
            }
            'Token' {
                $client.ChannelFactory.CreateChannelWithIssuedToken($Token)
                break;
            }
        }
    }


    End {
    }

}
