# load Wcf assemblies
Add-Type -AssemblyName "System.ServiceModel"
Add-Type -AssemblyName "System.Runtime.Serialization"

function Set-WcfBindingConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.ServiceModel.Channels.Binding]$Binding, 
        [Parameter(Mandatory=$false,ParameterSetName="MessageEncoding")]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$MaxStringContentLength, 
        [Parameter(Mandatory=$false,ParameterSetName="MessageEncoding")]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$MaxNameTableCharCount, 
        [Parameter(Mandatory=$false,ParameterSetName="MessageEncoding")]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$MaxArrayLength, 
        [Parameter(Mandatory=$false,ParameterSetName="MessageEncoding")]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$MaxBytesPerRead, 
        [Parameter(Mandatory=$false,ParameterSetName="MessageEncoding")]
        [ValidateRange(0,64)]
        [int]$MaxDepth, 
        [Parameter(Mandatory=$false,ParameterSetName="HttpTransport")]
        [ValidateRange(0,2147483647)]
        [int]$MaxReceivedMessageSize, 
        [Parameter(Mandatory=$false,ParameterSetName="HttpTransport")]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$MaxBufferPoolSize, 
        [Parameter(Mandatory=$true,ParameterSetName="Maximize")]
        [switch]$MaxOut=$false
    )
    Begin {
        if($MaxOut)
        {
	        $MaxStringContentLength = [int]::MaxValue;
	        $MaxNameTableCharCount = [int]::MaxValue;
	        $MaxArrayLength = [int]::MaxValue;
	        $MaxBytesPerRead = [int]::MaxValue;
	        $MaxDepth = 64;    

	        $MaxReceivedMessageSize = 2147483647;
	        $MaxBufferPoolSize = [int]::MaxValue;
        }
    }

    Process {
        if($Binding.GetType() -eq [System.ServiceModel.Channels.CustomBinding])
        {
            $transportSecurity=$Binding.Elements |Where-Object {$_.GetType() -eq [System.ServiceModel.Channels.TransportSecurityBindingElement]}
            $textMessageEncoding=$Binding.Elements |Where-Object {$_.GetType() -eq [System.ServiceModel.Channels.TextMessageEncodingBindingElement]}
            $httpTransport=$Binding.Elements |Where-Object {($_.GetType() -eq [System.ServiceModel.Channels.HttpTransportBindingElement]) -or ($_.GetType() -eq [System.ServiceModel.Channels.HttpsTransportBindingElement])}

            if($MaxStringContentLength)
            {
                $textMessageEncoding.ReaderQuotas.MaxStringContentLength = $MaxStringContentLength
            }
            if($MaxNameTableCharCount)
            {
                $textMessageEncoding.ReaderQuotas.MaxNameTableCharCount = $MaxNameTableCharCount
            }
            if($MaxArrayLength)
            {
                $textMessageEncoding.ReaderQuotas.MaxArrayLength = $MaxArrayLength
            }
            if($MaxBytesPerRead)
            {
                $textMessageEncoding.ReaderQuotas.MaxBytesPerRead = $MaxBytesPerRead
            }
            if($MaxDepth)
            {
                $textMessageEncoding.ReaderQuotas.MaxDepth = $MaxDepth
            }
            if($MaxReceivedMessageSize)
            {
                $httpTransport.MaxReceivedMessageSize = $MaxReceivedMessageSize
            }
            if($MaxBufferPoolSize)
            {
                $httpTransport.MaxBufferPoolSize = $MaxBufferPoolSize
            }
        }
        elseif($Binding.GetType() -eq [System.ServiceModel.WSHttpBinding])
        {
            if($MaxStringContentLength)
            {
                $Binding.ReaderQuotas.MaxStringContentLength = $MaxStringContentLength
            }
            if($MaxNameTableCharCount)
            {
                $Binding.ReaderQuotas.MaxNameTableCharCount = $MaxNameTableCharCount
            }
            if($MaxArrayLength)
            {
                $Binding.ReaderQuotas.MaxArrayLength = $MaxArrayLength
            }
            if($MaxBytesPerRead)
            {
                $Binding.ReaderQuotas.MaxBytesPerRead = $MaxBytesPerRead
            }
            if($MaxDepth)
            {
                $Binding.ReaderQuotas.MaxDepth = $MaxDepth
            }
            if($MaxReceivedMessageSize)
            {
                $Binding.MaxReceivedMessageSize = $MaxReceivedMessageSize
            }
            if($MaxBufferPoolSize)
            {
                $Binding.MaxBufferPoolSize = $MaxBufferPoolSize
            }
        }
        else
        {
            Write-Warning "$($Binding.Name) is not a custom binding. Attempting direct property manimulation"
            if($MaxStringContentLength)
            {
                $Binding.ReaderQuotas.MaxStringContentLength = $MaxStringContentLength
            }
            if($MaxNameTableCharCount)
            {
                $Binding.ReaderQuotas.MaxNameTableCharCount = $MaxNameTableCharCount
            }
            if($MaxArrayLength)
            {
                $Binding.ReaderQuotas.MaxArrayLength = $MaxArrayLength
            }
            if($MaxBytesPerRead)
            {
                $Binding.ReaderQuotas.MaxBytesPerRead = $MaxBytesPerRead
            }
            if($MaxDepth)
            {
                $Binding.ReaderQuotas.MaxDepth = $MaxDepth
            }
            if($MaxReceivedMessageSize)
            {
                $Binding.MaxReceivedMessageSize = $MaxReceivedMessageSize
            }
            if($MaxBufferPoolSize)
            {
                $Binding.MaxBufferPoolSize = $MaxBufferPoolSize
            }
        }

    }


    End {
    }

}
