Param (
    [Parameter(
        Mandatory = $true
    )]
    [string]$ISHWS,
    [Parameter(
        Mandatory = $false
    )]
    [PSCredential]$Credential=$null
)

$tempPath=[System.IO.Path]::GetTempFileName()
Invoke-WebRequest -Uri ($ISHWS+"connectionconfiguration.xml") -OutFile $tempPath
$connectionConfiguration=[xml](Get-Content $tempPath)

$authenticationEndpoint=$connectionConfiguration.connectionconfiguration.issuer.url

$ishWSAppliesTo=$connectionConfiguration.connectionconfiguration.infosharewsurl
$ishCMAppliesTo=$connectionConfiguration.connectionconfiguration.infoshareauthorurl
$svcEndpoint=$ISHWS+"Wcf/API25/Application.svc"

$ishWSimporter=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
$ishWSproxyType=$ishWSimporter | New-WcfProxyType
$ishEndpoint=$ishWSimporter | New-WcfServiceEndpoint -Endpoint $svcEndpoint

if($ishEndpoint.Address.Uri.Scheme -eq "http")
{
	$protectionTokenParameters=$ishEndpoint.Binding.Elements[0].ProtectionTokenParameters.BootstrapSecurityBindingElement.ProtectionTokenParameters
}
else
{
	$protectionTokenParameters=$ishEndpoint.Binding.Elements[0].EndpointSupportingTokenParameters.Endorsing[0].BootstrapSecurityBindingElement.EndpointSupportingTokenParameters.Endorsing[0]
}
$mexUri=$protectionTokenParameters.IssuerMetadataAddress.Uri.AbsoluteUri


Describe "New-WcfWsdlImporter" {
    Context "Parameter" {
        It "HttpGet" {
            $wsdlImporter=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
        }
    }
    Context "Pipe" {
        It "HttpGet" {
            $wsdlImporter=$svcEndpoint | New-WcfWsdlImporter -HttpGet
        }
    }
}

Describe "New-WcfServiceEndpoint" {
    Context "Parameter" {
        It "Endpoint not defined" {
            $endpoints=New-WcfServiceEndpoint -WsdlImporter $importer
            $endpoints.Count | Should Be 2
        }
        It "Endpoint defined" {
            $endpoints=New-WcfServiceEndpoint -WsdlImporter $importer -Endpoint $svcEndpoint
            $endpoints.Count | Should Be 1
        }
    }
    Context "Pipe" {
        It "Endpoint not defined" {
            $endpoints=$importer | New-WcfServiceEndpoint
            $endpoints.Count | Should Be 2
        }
        It "Endpoint defined" {
            $endpoints=$importer | New-WcfServiceEndpoint -Endpoint $svcEndpoint
            $endpoints.Count | Should Be 1
        }
    }
    BeforeEach {
        $importer=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
    }
}

Describe "Set-WcfBindingConfiguration" {
    Context "MexBinding" {
        It "MessageEncoding parameter set" {
            Set-WcfBindingConfiguration -Binding $binding -MaxArrayLength 1 -MaxBytesPerRead 1 -MaxDepth 1 -MaxNameTableCharCount 1 -MaxStringContentLength 1
        }
        It "HttpTransport parameter set" {
            Set-WcfBindingConfiguration -Binding $binding -MaxReceivedMessageSize 1 -MaxBufferPoolSize 1
        }
        BeforeEach {
            $binding=[System.ServiceModel.Description.MetadataExchangeBindings]::CreateMexHttpsBinding()
        }
    }
    Context "CustomBinding" {
        It "No parameter set defined" {
            { Set-WcfBindingConfiguration -Binding $binding } | Should Throw "Parameter set cannot be resolved using the specified named parameters"
            { $binding | Set-WcfBindingConfiguration } | Should Throw "Parameter set cannot be resolved using the specified named parameters"
        }
        It "MessageEncoding parameter set" {
            Set-WcfBindingConfiguration -Binding $binding -MaxArrayLength 1 -MaxBytesPerRead 1 -MaxDepth 1 -MaxNameTableCharCount 1 -MaxStringContentLength 1
        }
        It "HttpTransport parameter set" {
            Set-WcfBindingConfiguration -Binding $binding -MaxReceivedMessageSize 1 -MaxBufferPoolSize 1
        }
        BeforeEach {
            $binding=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet | New-WcfServiceEndpoint -Endpoint $svcEndpoint |Select-Object -ExpandProperty Binding
        }
    }
}

Describe "New-WcfProxyType" {
    Context "CustomBinding" {
        It "Save assembly" {
            $filePath=[System.IO.Path]::GetTempFileName()
            $proxy=New-WcfProxyType -WsdlImporter $importer -FilePath $filePath
            $proxy.Name | Should Be "ApplicationClient"
        }
        It "In memory" {
            $proxy=New-WcfProxyType -WsdlImporter $importer
            $proxy.Name | Should Be "ApplicationClient"
        }
        BeforeEach {
            $importer=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
        }
    }
}

Describe "New-SecurityToken" {
    Context "Symmetric" {
        It "-Symmetric switch defined" {
            {New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $ishWSAppliesTo -Symmetric} | Should Not Throw
        }
    }
    Context "Bearer" {
        It "-Bearer switch defined" {
            {$token=New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $ishCMAppliesTo -Bearer} | Should Not Throw
        }
    }
    BeforeEach {
        $importer=New-WcfWsdlImporter -Endpoint $mexUri
        $issuerEndpoint=$importer | New-WcfServiceEndpoint -Endpoint $authentiCationEndpoint
    }
}




Describe "New-WcfChannel" {
    Context "Parameter" {
        It "ProxyType defined" {
            {New-WcfChannel -Endpoint $ishEndpoint -ProxyType $proxyType -Token $token} |Should Not Throw
        }
        It "ProxyType not defined" {
            {New-WcfChannel -Endpoint $ishEndpoint -Token $token} |Should Not Throw
        }
    }
    Context "Pipe" {
        It "ProxyType defined" {
            {$ishEndpoint | New-WcfChannel -ProxyType $proxyType -Token $token} |Should Not Throw
        }
        It "ProxyType not defined" {
            {$ishEndpoint | New-WcfChannel -Token $token} |Should Not Throw
        }
    }
    BeforeEach {
        $ishWSimporter=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
        $ishWSproxyType=$ishWSimporter | New-WcfProxyType
        $ishEndpoint=$ishWSimporter | New-WcfServiceEndpoint -Endpoint $svcEndpoint
        
        $issuerImporter=New-WcfWsdlImporter -Endpoint $mexUri
        $issuerEndpoint=$issuerImporter | New-WcfServiceEndpoint -Endpoint $authentiCationEndpoint
        $token=New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $ishWSAppliesTo -Symmetric
    }
}

Describe "Wcf/API25/Application.25" {
    It "GetVersion" {
        {$channel25.GetVersion} |Should Not Throw
    }
    It "Authenticate2" {
        {$channel25.Authenticate2} |Should Not Throw
    }
    BeforeEach {
        $issuerImporter=New-WcfWsdlImporter -Endpoint $mexUri
        $issuerEndpoint=$issuerImporter | New-WcfServiceEndpoint -Endpoint $authentiCationEndpoint
        $token=New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $ishWSAppliesTo -Symmetric
        $channel25=New-WcfChannel -Endpoint $ishEndpoint -ProxyType $proxyType -Token $token
    }
}