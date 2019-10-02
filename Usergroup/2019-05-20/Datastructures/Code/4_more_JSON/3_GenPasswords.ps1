
## load the function
.\4_more_JSON\3_New-Password.ps1

## load the json

$GenPasswordsJson = ConvertFrom-Json $(Get-Content -Path ".\4_more_JSON\3_GenPasswords.json" -Raw )


foreach($item in $GenPasswordsJson)
{
    Write-host "New Password will be generated"
    Write-host "##############################"
    Write-host ""

    if ($null -eq $item.FirstChar)
    {
        New-Password -PasswordLength $item.PasswordLength -InputStrings $item.InputStrings -NoSpecialChars:$([System.Convert]::ToBoolean($item.NoSpecialChars)) -Count $item.Count
    }
    else
    {
        New-Password -PasswordLength $item.PasswordLength -InputStrings $item.InputStrings -FirstChar $item.FirstChar -NoSpecialChars:$([System.Convert]::ToBoolean($item.NoSpecialChars)) -Count $item.Count
    }   
     
    Write-host ""    
    Write-host "##############################"
}