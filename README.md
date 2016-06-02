# WcfPS
A powershell module to help work with WCF Services.

# Commandlets

- New-SecurityToken
- New-WcfChannel
- New-WcfProxyType
- New-WcfServiceEndpoint
- New-WcfWsdlImporter
- Set-WcfBindingConfiguration

# Acknowledgesments
Basic understanding of terms such as **binding** and **service endpoint** is required. 

## Reference endpoints
The module is built against WCF endpoints known as **ISHWS** provided by SDL's [Knowledge Center](http://www.sdl.com/cxc/knowledge-delivery/documentation-management-dita/) Content Manager API. The API is power by WCF and the authentication is federated against a security token service implementing **WSTrust13** endpoints. One security token service example is [active directory federation services](https://msdn.microsoft.com/en-us/library/bb897402.aspx).

## Pester 
Pester tests are included both for the **ISHWS** api but also for **WSTrust 13** endpoints. Both are very specific to an environment thus the tests depend on parameters and cannot be automated. 

The test scripts acts as a good showcase on how to use the module's cmdlets.

* [Test-ISHExternal.ps1](Pester\Test-ISHExternal.ps1]
* [Test-WSTrust.ps1](Pester\Test-WSTrust.ps1]

## Not implemented paths
Since I don't have access to various soap endpoints, some flows are not implemented and will throw a new `NotImplementedException`.   

# Working with the module

In principal use the commandlets in the following order

1. Acquire an importer using `New-WcfWsdlImporter`. This queries the endpoint for metadata. Use the `-HttpGet` parameter when you would use the otherwise known `?wsdl` query string
1. Acquire a service endpoint using `New-WcfServiceEndpoint`. The return service endpoint instance acts as a container for the binding and address.
1. Build the internal proxy types using `New-WcfProxyType`. 

At this point you can build the channel for any WCF endpoint. Depending on the service configuration authentication, the channel might require authentication context. Depending on the type do one of the following: 

* When username/password then execute`New-WcfChannel` with `-Credential` parameter
* When windows  then execute `New-WcfChannel`. The process's user crendetials will be used.
* When federated with security token service then
  1. Execute `New-SecurityToken` to acquire a symmetric token. As with the `New-WcfChannel` authentication choices same rules apply for `New-SecurityToken`. 
  2. Execute `New-WcfChannel` with `-Token` parameter.
  
# Example scripts

**A generic example**
```powershell
$wsImporter=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
$proxyType=$wsImporter | New-WcfProxyType
$endpoint=$wsImporter | New-WcfServiceEndpoint -Endpoint $svcEndpoint
$channel=New-WcfChannel -Endpoint $endpoint -ProxyType $proxyType
```  
  
**An ISHWS specific example**
```powershell
#Authenticate on the STS and acquire a token        
$issuerImporter=New-WcfWsdlImporter -Endpoint $mexUri
$issuerEndpoint=$issuerImporter | New-WcfServiceEndpoint -Endpoint $authentiCationEndpoint
$token=New-SecurityToken -Endpoint $issuerEndpoint -Credential $Credential -AppliesTo $ishWSAppliesTo -Symmetric

#Use the token to build a channel for the /Wcf/API25/Application.svc endpoint
$ishWSimporter=New-WcfWsdlImporter -Endpoint $svcEndpoint -HttpGet
$ishWSproxyType=$ishWSimporter | New-WcfProxyType
$ishEndpoint=$ishWSimporter | New-WcfServiceEndpoint -Endpoint $svcEndpoint
$channel25=New-WcfChannel -Endpoint $ishEndpoint -ProxyType $proxyType -Token $token

#Consume the GetVersion method
$channel25.GetVersion
```  