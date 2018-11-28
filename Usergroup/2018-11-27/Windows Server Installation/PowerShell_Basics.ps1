#region Pipe
'$(Get-date) ist jetzt'
Get-Process -Name 'svchost'
Get-Process | Where-Object -FilterScript {$PSItem.Handles -gt 500}
Get-Process | Where-Object -FilterScript {$PSItem.Handles -gt 500} | 
    Sort-Object CPU -descending
Get-Process | Where-Object -Filterscript {$PSItem.Handles -gt 500} | 
    Sort-Object CPU -descending | Select-Object -First 10
Get-Process | Where-Object -Filterscript {$PSItem.Handles -gt 500} | 
    Sort-Object CPU -descending | Select-Object -First 10 | Measure-Object -Property CPU -Sum 

Get-Process | Group-Object -Property ProcessName | Where-Object { $PSItem.Count -gt 1 }
$p = Get-Process | Group-Object -Property ProcessName 
$p | Where-Object { $PSItem.Count -gt 1 }
$fileOnMySystem = Get-ChildItem -Path 'c:\' -Recurse
$fileOnMySystem[0] | gm

$p = Get-WmiObject -Class win32_volume | 
    Sort-Object -Property "DriveLetter" | 
        Where-Object {($PSItem.DriveLetter -ne $Null) -and ($PSitem.FreeSpace -ne $Null)} | 
            Format-Table -Property DriveLetter, FreeSpace, Capacity, 
                @{Label="PercentFree";Expression= {"{0:N2}" -f (($PSItem.freespace / $PSItem.capacity) * 100)}}

Get-Volume | 
    Where-Object {($PSItem.DriveLetter) -and ($PSitem.Size -ne 0)} |
        Select-Object -Property DriveLetter, Size, SizeRemaining

#endregion Pipe

#region Condition
# if
if (1 -eq 1) {'Yes'}
If ($true) {"true"} else {"false"}
if (2 -ne 2) {
    '2 != 2'
}
elseif (1 -eq 1) {
    '1=1'
}
if ('18152' -match '[0-9]{5}') {
    'okay'
}
# conditions in pipe
Get-Process | Where-Object {$PSItem.Handles -gt 500}
(Get-Process).Where({$PSItem.Handles -gt 500})

# switch
switch((Get-Date).dayofweek) {
 ([System.DayOfWeek]::Sunday)   {"It's Sunday";break}
 ([System.DayOfWeek]::Monday)   {"I don't like Mondays?";break}
 ([System.DayOfWeek]::Tuesday)  {"It's Tuesday";break}
 ([System.DayOfWeek]::Wednesday){"Weekend in three days!";break}
 ([System.DayOfWeek]::Thursday) {"It's Thursday";break}
 ([System.DayOfWeek]::Friday)   {"Finally Friday, Time for a beer!";break}
 ([System.DayOfWeek]::Saturday) {"Weekend";break}
 default { "what else" } 
}
#endregion

#region Loops
for ($i=0; $i -lt 10; $i++) { $i }
0..9 | ForEach-Object {$PSItem}
ForEach ($i in 0..9) {$i}
@(0..9).ForEach({$PSItem})
@('A','B','C','D','E','F').ForEach({$PSItem})
<#
# not working, because 
@('A'..'F') | ForEach-Object {$PSItem}
#>

0..9 | ForEach-Object {$PSItem} | Sort-Object -Descending
@(0..9).ForEach({$PSItem}) | Sort-Object -Descending
$(for ($i=0; $i -lt 10; $i++) { $i }) | Sort-Object -Descending
<#
# not working: pipe after for/foreach is not allowed
for ($i=0; $i -lt 10; $i++) { $i } | Sort-Object -Descending
ForEach ($i in 0..9) {$i} | Sort-Object -Descending
# solution
#>
$x = for ($i=0; $i -lt 10; $i++) { $i }
$x | Sort-Object -Descending
$x = ForEach ($i in 0..9) {$i}
$x | Sort-Object -Descending

# while/do
$val =0
while($val -ne 3){$val++; $val}
do { $val--; $val } while ($val -ne 0)
do { $val++; $val } until ($val -gt 3)

#endregion loops

#region PSProvider_PSDrive
# list available drives of your system (harddrives, Registry, Environment, Certificates, SQL Server, Active Directory, Exchange, �)
Get-PSProvider
Get-PSDrive

# use different types of PSDrives
Get-ChildItem
Get-ChildItem -Path Env:
Get-ChildItem -Path 'C:\'
Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows"
Get-ChildItem -Path Registry::HKEY_CLASSES_ROOT\mailto
Set-Location -Path "C:\"

# Create a new PSDrive
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
Get-ChildItem -Path 'HKCR:\http'
Remove-PSDrive -Name HKCR

#endregion PSProvider_PSDrive

#region Files
Get-Item -Path 'C:\Temp'

# Check, if path or file exists
Test-Path -Path "C:\TEMP" -PathType Container

if (!(Test-Path -Path "C:\TEMP\PowerShell" -PathType Container)) {
    New-Item -Path "C:\TEMP\PowerShell" -ItemType Directory -Force
}
Set-Location -Path "C:\TEMP\PowerShell"
1..10 | ForEach-Object {$null = New-Item -Path "$PSItem.txt" -ItemType File}
Get-ChildItem
Set-Location -Path "C:\TEMP"
Remove-Item -Path "C:\TEMP\PowerShell" -Force -Confirm:$false -recurse

# resolve a file path
Resolve-Path -Path ".\*"
$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\file.txt")

# Split-Path
Split-Path -Path c:\temp\file.txt
Split-Path -Path c:\temp\file.txt -IsAbsolute
Split-Path -Path c:\temp\file.txt -Leaf
Split-Path -Path c:\temp\file.txt -NoQualifier
Split-Path -Path c:\temp\file.txt -Parent
Split-Path -Path c:\temp\file.txt -Qualifier

# Dir = GetChildItem
Get-ChildItem -Path $env:windir | Where-Object { $_.PSIsContainer -eq $true }
Get-ChildItem -Path $env:windir -Directory
# List item in a path with attribute filter: Archive, Compressed, Device, Directory, Encrypted, Hidden, Normal, NotContentIndexed, Offline, ReadOnly, ReparsePoint, SparseFile, System, Temporary (PS3.0)
Get-ChildItem -Path "$env:systemdrive:\" -Attributes Directory+Hidden,!Directory+!System+Compressed

# Create File and Folder in one step
New-Item -Path c:\folder\subfolder\file1.txt -Type File -Force
Remove-Item -Path 'C:\folder' -Force -Recurse -Confirm:$false
# Cleanup Temp-Folders where File age older 2 days
@($env:temp, $env:tmp, "C:\Windows\Temp") | 
    Foreach-Object { 
        Get-ChildItem $PSItem |
            Where-Object {($PSItem.Length -ne $null) -and 
            ($PSItem.LastWriteTime -lt $((Get-Date).AddDays(-2)))}} |
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse -WhatIf

# create a new file
"Das ist ein Test" | Out-File -filepath "C:\TEMP\Testdatei1.txt"
Out-File -FilePath "C:\TEMP\Testdatei1.txt" -InputObject 'This is a test'
Get-Service | Out-String | Set-Content -Path "C:\TEMP\Testdatei2.txt"
Set-Content -Path "C:\TEMP\Testdatei1.txt" -Value "Zeile 1:"

# append text to a file
'Zeile 2:' | Add-Content -Path "C:\TEMP\Testdatei1.txt"
'Zeile 3:' | Out-File -FilePath "C:\TEMP\Testdatei1.txt" -Append

# read a file
Get-Content -Path "C:\TEMP\Testdatei1.txt"

# file attributes
$f = Get-Item -Path "C:\TEMP\Testdatei1.txt"
$f.Attributes
$f.Attributes += [System.IO.FileAttributes]::ReadOnly
$f.Attributes
Set-Content -Path "C:\TEMP\Testdatei1.txt" -Value "Zeile 1:"

$f.Attributes -= [System.IO.FileAttributes]::ReadOnly
# delete file
$f.Delete()
# export object as CSV
Get-Service | Export-Csv -Path "C:\TEMP\Testdatei1.csv" -NoTypeInformation -Delimiter ';'
Get-Content -Path "C:\TEMP\Testdatei1.CSV"
Get-Content -Path "C:\TEMP\Testdatei1.csv" | ConvertTo-Csv
# open CSV file - with prefered application (EXCEL)
Invoke-Item -Path "C:\TEMP\Testdatei1.csv"

# CSV-Datei importieren
$CSV = Import-Csv -Path "C:\TEMP\Testdatei1.csv"
$CSV | Get-Member

# System.IO namespace
[System.IO.Directory]::Exists("C:\TEMP")
Test-Path -Path "C:\TEMP" -PathType Container 
[System.IO.File]::Exists("C:\TEMP\Testdatei1.txt") 
[System.IO.Directory]::GetCurrentDirectory()

# Get biggest folder (in size) from 'c:\Program files'
Get-ChildItem -Path 'C:\Program Files' -Directory |
    ForEach-Object {
        $stat = Get-ChildItem -Path $($PSItem.FullName) -File -Recurse -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum
        $PSItem | Add-Member -MemberType NoteProperty -Name FileCount -Value $stat.count
        $PSItem | Add-Member -MemberType NoteProperty -Name FileSize -Value $stat.sum -PassThru
    } | Sort-Object -Property FileSize -Descending | Select-Object -Property Name,FileSize,FileCount,@{Name='Path';Expression={"C:\Program Files\$($PSItem.Name)"}} |
        Out-GridView -Title "Folder Report" -PassThru | Get-ChildItem
#endregion files

#region Registry
Get-ChildItem -Path 'HKCU:\'
Get-ChildItem -Path 'Registry::HKEY_CURRENT_USER'
Get-ChildItem -Path 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER'
[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::CurrentUser, $env:COMPUTERNAME).GetSubKeyNames()

Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion' | 
    Select-Object -ExpandProperty Property
Copy-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion' -Destination 'hkcu:\Temp'
Remove-Item -Path 'hkcu:\Temp'

New-Item -Path "hkcu:\software_DeleteMe" -ItemType Directory
Rename-Item  -Path "hkcu:\software_DeleteMe" -NewName "DeleteMe"
Remove-Item -Path "hkcu:\DeleteMe"

Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion"
Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion -Name DevicePath
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion -Name PowerShellPath -PropertyType String -Value $PSHome
Rename-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion -Name PowerShellPath -NewName PSHome
Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion -Name PSHome

# Run as Administrator --> for each script
$P1 = "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\shell\runas\command"
if (!(Test-Path -Path $P1 -PathType Container)) {
    $null = New-Item -Path $P1 -Force -ItemType Directory
}
$StartCommand = 'powershell.exe "-Command" "if((Get-ExecutionPolicy ) -ne ''AllSigned'') { Set-ExecutionPolicy -Scope Process Bypass }; & ''%1''"'
$Old=((Get-ItemProperty -LiteralPath $P1).'(default)')
if ($Old -ne $StartCommand) {
    Set-ItemProperty -Path $P1 -Name '(Default)' -Value $StartCommand
}
#endregion Registry