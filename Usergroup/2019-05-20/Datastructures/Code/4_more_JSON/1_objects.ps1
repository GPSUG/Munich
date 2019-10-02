$obj = @()

for ($i = 0; $i -le 100; $i++)
{
    $obj += New-Object PSObject -Property @{ ID = $i; Username="User$i"; HomeDrive="%userprofile%\User$i\Workdir$i" }
}
New-Item -ItemType File -Path ".\4_more_JSON\users.json" -Value $(ConvertTo-Json $obj) -Force


### kill session now :)


$NewSessionObj = ConvertFrom-Json $(Get-Content -Path ".\4_more_JSON\users.json" -Raw )
$NewSessionObj

#region working with these
foreach ($item in $newSessionObj )
{
    if ($item.ID -like "*7*")
    {
        $item.HomeDrive = $item.HomeDrive + "xxx"
    }
}

Set-Content -Path ".\4_more_JSON\users.json" -Value $(ConvertTo-Json $NewSessionObj) -Force
#endregion