#requires -version 3.0

function Test-PSRemoting {
    <#
    Jeff Hicks
    https://www.petri.com/test-network-connectivity-powershell-test-connection-cmdlet
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUsePSCredentialType", "")]
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [DbaInstance]$ComputerName,
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [switch]$EnableException
    )

    process {
        $UseSSL = Get-DbatoolsConfigValue -FullName 'PSRemoting.PsSession.UseSSL' -Fallback $false
        [nullable[int]]$Port = Get-DbatoolsConfigValue -FullName 'PSRemoting.PsSession.Port' -Fallback $null

        Write-Message -Level VeryVerbose -Message "Testing $($ComputerName.Computername)"

        try {
            $psWSManSplat = @{
                ComputerName   = $ComputerName.ComputerName
                Authentication = "Default"
                Credential     = $Credential
                UseSSL         = $UseSSL
                ErrorAction    = 'Stop'
            }
            if (($null -ne $Port) -and ($Port -gt 0)) {
                $psWSManSplat.Port = $Port
                Write-Message -Level Verbose -Message "Test using Port: $($psWSManSplat.Port)"
            }

            $null = Test-WSMan @psWSManSplat
            $true
        } catch {
            $false
            Stop-Function -Message "Testing $($ComputerName.Computername)" -Target $ComputerName -ErrorRecord $_ -EnableException:$EnableException
        }

    } #process

} #close function