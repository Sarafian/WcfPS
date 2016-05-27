# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

function New-WcfProxyType {
    [CmdletBinding()]
    [OutputType([System.ServiceModel.Channels.Binding])]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.ServiceModel.Description.WsdlImporter]$WsdlImporter,
        [Parameter(Mandatory=$false)]
        [string]$FilePath=$null
    )
    Begin {
    }

    Process {
        $generator = new-object System.ServiceModel.Description.ServiceContractGenerator
	
	    foreach($contractDescription in $WsdlImporter.ImportAllContracts())
	    {
		    [void]$generator.GenerateServiceContractType($contractDescription)
	    }
	
	    $parameters = New-Object System.CodeDom.Compiler.CompilerParameters
	    if($FilePath -eq $null)
	    {
		    $parameters.GenerateInMemory = $true
	    }
	    else
	    {
		    $parameters.OutputAssembly = $FilePath
	    }
	
	    $providerOptions = New-Object "Collections.Generic.Dictionary[String,String]"
	    [void]$providerOptions.Add("CompilerVersion","v4.0")
	
	    $compiler = New-Object Microsoft.CSharp.CSharpCodeProvider($providerOptions)
	    $result = $compiler.CompileAssemblyFromDom($parameters, $generator.TargetCompileUnit);
	
	    if($result.Errors.Count -gt 0)
	    {
		    throw "Proxy generation failed"       
	    }
	
	    $result.CompiledAssembly.GetTypes() | Where-Object {$_.BaseType.IsGenericType -and $_.BaseType.GetGenericTypeDefinition().FullName -eq "System.ServiceModel.ClientBase``1" }
    }


    End {
    }

}
