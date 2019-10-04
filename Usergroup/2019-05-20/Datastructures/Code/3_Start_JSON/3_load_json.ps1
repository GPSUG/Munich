
$Obj = ConvertFrom-Json $(Get-Content -Path ".\3_Start_JSON\2_arrayvalue.json" -Raw )
$Obj


#region $obj
$obj.Name
$obj.skills
#endregion

#region $obj foreach
$obj[1].Skills

foreach ($i in $obj)
{
    write-host "New Line --------------------------"
    write-host "Name: $($i.Name)"
    write-host "Age: $($i.Age)"
    write-host "Skills: $($i.Skills)"

}
#endregion
