
$DLLPath = "$PSScriptRoot\..\SimpleAuthenticator\SimpleAuthenticator\bin\Release\SimpleAuthenticator.dll"

#Region Way 1
Add-Type -Path $DLLPath
#Endregion

#Region Way 2
[System.Reflection.Assembly]::LoadFile($DLLPath)
#Endregion

#Region Way 3
$bytes = [System.IO.File]::ReadAllBytes($DLLPath)
[System.Reflection.Assembly]::Load($bytes)
#Endregion


$Instance = New-Object -TypeName SimpleAuthenticator.CreateCode
$Instance.Code

# Static Method
[SimpleAuthenticator.CreateCode]::StaticMethodGetCode