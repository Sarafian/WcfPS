# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.IdentityModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

function New-SecurityToken {
    Param (
        [Parameter(Mandatory=$true)]
        [System.ServiceModel.Description.ServiceEndpoint]$Endpoint,
        [Parameter(Mandatory=$false)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [string]$TokenType,
        [Parameter(Mandatory=$true)]
        [string]$AppliesTo,
        [Parameter(Mandatory=$true,ParameterSetName="Symmetric")]
        [switch]$Symmetric,
        [Parameter(Mandatory=$true,ParameterSetName="Bearer")]
        [switch]$Bearer
    )
    Begin {
        $requestSecurityToken=New-Object System.IdentityModel.Protocols.WSTrust.RequestSecurityToken
        $requestSecurityToken.RequestType = [System.IdentityModel.Protocols.WSTrust.RequestTypes]::Issue
		if($KeyType)
        {
            $requestSecurityToken.KeyType = $KeyType
        }
        else
        {
            if($Symmetric)
            {
                $requestSecurityToken.KeyType = [System.IdentityModel.Protocols.WSTrust.KeyTypes]::Symmetric
            }
            if($Bearer)
            {
                $requestSecurityToken.KeyType = [System.IdentityModel.Protocols.WSTrust.KeyTypes]::Bearer
            }
        }
        
        if($TokenType)
        {
            $requestSecurityToken.TokenType = $TokenType
        }


        $factory=New-Object System.ServiceModel.Security.WSTrustChannelFactory([System.ServiceModel.WS2007HttpBinding]($Endpoint.Binding), $Endpoint.Address)
        $factory.TrustVersion = [System.ServiceModel.Security.TrustVersion]::WSTrust13
		$factory.Credentials.SupportInteractive = $false;
        if($Credential)
        {
            $networkCredential=$Credential.GetNetworkCredential();
            $factory.Credentials.UserName.UserName=$networkCredential.UserName
            $factory.Credentials.UserName.Password=$networkCredential.Password
            if($networkCredential.Domain -and ($networkCredential.Domain -ne ""))
            {
                $factory.Credentials.UserName.UserName=$networkCredential.Domain+"\"+$factory.Credentials.UserName.UserName
            }
        }
        $channel=[System.ServiceModel.Security.WSTrustChannel]$factory.CreateChannel();
    }

    Process {
        $requestSecurityToken.AppliesTo = New-Object System.IdentityModel.Protocols.WSTrust.EndpointReference $AppliesTo
        $channel.Issue($requestSecurityToken)
    }


    End {
    }

}
