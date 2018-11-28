Function Set-viDisplayResolution {
    [CmdletBinding(SupportsShouldProcess=$true, 
        PositionalBinding=$false,
        HelpUri = 'http://itbsh.de',
        ConfirmImpact='Medium')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName=@($Env:Computername),
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false)]
        [int]$dwidth = 1152,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false)]
        [Parameter(Mandatory=$true)]
        [int]$dheight = 864

    )
    BEGIN {
    }
    PROCESS {
        try {
            Write-Verbose -Message "width: $dwidth height: $dheight"
            if ($pscmdlet.ShouldProcess("WhatIf: Display resolution")) {
                Set-DisplayResolution -width $dwidth -height $dheight -Force
            }
        }
        catch {
            return $false
        }
        $true
    }
    END {
    }
}

Function Get-viDisplayResolution {
    [CmdletBinding(SupportsShouldProcess=$true, 
        PositionalBinding=$false,
        HelpUri = 'http://itbsh.de',
        ConfirmImpact='Medium')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName=@($env:COMPUTERNAME)
    )

    BEGIN {
    }
    PROCESS {
        $DR = Get-DisplayResolution
        $aDR = $DR[0].split('x')
        [PSCustomObject]@{
            Computer = [String]$ComputerName
            Width = [int]($aDR[0].Replace($aDR[0].Substring(1,1),''))
            Height = [int]($aDR[1].Replace($aDR[0].Substring(1,1),''))
        }
    }
    END {
    }
}

Function Validate-viDisplayResolution {
    [CmdletBinding(SupportsShouldProcess=$true, 
        PositionalBinding=$false,
        HelpUri = 'http://itbsh.de',
        ConfirmImpact='Medium')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [PSCustomObject]$CurrentSettings,
        [Parameter(Mandatory=$true)]
        [int]$width = 1152,
        [Parameter(Mandatory=$true)]
        [int]$height = 864
    )

    BEGIN {
    }
    PROCESS {
        if (($width -ne $CurrentSettings.Height) -or ($height -ne $CurrentSettings.Width)) {
            return $false
        }
        else {
            return $null
        }
    }
    END {
    }
}

$FinalResWidth = 1152
$FinalResHeight = 864
Get-viDisplayResolution | 
    Validate-viDisplayResolution -width $FinalResWidth -height $FinalResHeight | 
    Set-viDisplayResolution -whatif -verbose -dwidth $FinalResWidth -dheight $FinalResHeight