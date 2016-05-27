Param (
    [Parameter(
        Mandatory = $true
    )]
    [string]$MexUri,
    [Parameter(
        Mandatory = $true
    )]
    [string]$AuthenticationEndpoint,
    [Parameter(
        Mandatory = $false
    )]
    [PSCredential]$Credential=$null,
    [Parameter(
        Mandatory = $false
    )]
    [string]$SymmetricAppliesTo=$null,
    [Parameter(
        Mandatory = $false
    )]
    [string]$BearerAppliesTo=$null
)

Describe "New-WcfWsdlImporter" {
    Context "Parameter" {
        It "HttpGet" {
            $wsdlImporter=New-WcfWsdlImporter -Endpoint $MexUri
        }
    }
    Context "Pipe" {
        It "HttpGet" {
            $wsdlImporter=$MexUri | New-WcfWsdlImporter
        }
    }
}

Describe "New-WcfServiceEndpoint" {
    Context "Parameter" {
        It "Endpoint not defined" {
            $endpoints=New-WcfServiceEndpoint -WsdlImporter $importer
            $endpoints.Count | Should BeGreaterThan 1
        }
        It "Endpoint defined" {
            $endpoints=New-WcfServiceEndpoint -WsdlImporter $importer -Endpoint $AuthenticationEndpoint
            $endpoints.Count | Should Be 1
        }
    }
    Context "Pipe" {
        It "Endpoint not defined" {
            $endpoints=$importer | New-WcfServiceEndpoint
            $endpoints.Count | Should BeGreaterThan 1
        }
        It "Endpoint defined" {
            $endpoints=$importer | New-WcfServiceEndpoint -Endpoint $AuthenticationEndpoint
            $endpoints.Count | Should Be 1
        }
    }
    BeforeEach {
        $importer=New-WcfWsdlImporter -Endpoint $MexUri
    }
}


Describe "New-WcfProxyType" {
    Context "Parameter" {
        It "Save assembly" {
            $filePath=[System.IO.Path]::GetTempFileName()
            $proxyType=New-WcfProxyType -WsdlImporter $importer -FilePath $filePath
            $proxyType.Name | Should Match "WSTrust13.*Client"
        }
        It "In memory" {
            $proxyType=New-WcfProxyType -WsdlImporter $importer
            $proxyType.Name | Should Match "WSTrust13.*Client"
        }
    }
    Context "Pipe" {
        It "Save assembly" {
            $filePath=[System.IO.Path]::GetTempFileName()
            $proxyType=$importer | New-WcfProxyType -FilePath $filePath
            $proxyType.Name | Should Match "WSTrust13.*Client"
        }
        It "In memory" {
            $proxyType=$importer | New-WcfProxyType
            $proxyType.Name | Should Match "WSTrust13.*Client"
        }
    }
    BeforeEach {
        $importer=New-WcfWsdlImporter -Endpoint $MexUri
    }
}


if($SymmetricAppliesTo) {
    Describe "New-SecurityToken for Symmetric Token" {
        It "Issue token" {
            {New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $SymmetricAppliesTo -Symmetric} | Should Not Throw
        }
        BeforeEach {
            $importer=New-WcfWsdlImporter -Endpoint $MexUri
            $issuerEndpoint=$importer | New-WcfServiceEndpoint -Endpoint $AuthenticationEndpoint
        }
    }
}

if($BearerAppliesTo) {
    Describe "New-SecurityToken for Bearer Token" {
        It "Issue token" {
            {New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $BearerAppliesTo -Bearer} | Should Not Throw
        }
        BeforeEach {
            $importer=New-WcfWsdlImporter -Endpoint $MexUri
            $issuerEndpoint=$importer | New-WcfServiceEndpoint -Endpoint $AuthenticationEndpoint
        }
    }
}