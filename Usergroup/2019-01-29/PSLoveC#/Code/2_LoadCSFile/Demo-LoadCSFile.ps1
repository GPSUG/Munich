$CSFilePath = "$PSScriptRoot\Demo-LoadCSFile.cs"

Add-Type -Path $CSFilePath


[GetSalut]::StaticSalutFor("PSUG MUC")


$Instance = New-Object -TypeName GetSalut
$Instance.SalutFor("PSUG")

