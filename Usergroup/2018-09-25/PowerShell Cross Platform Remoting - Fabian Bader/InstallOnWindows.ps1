# Start PowerShell Elevated as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (!( $isAdmin )) {
    Write-Warning "Please run elevated as admin"
    exit
}

#region OpenSSH installieren
Set-Location ~
# Download von OpenSSH for Windows with TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.6.1.0p1-Beta/OpenSSH-Win64.zip -OutFile "$PWD\Downloads\OpenSSH-Win64.zip"

# Entpacken der Daten
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\Downloads\OpenSSH-Win64.zip",$ENV:ProgramFiles)
Get-ChildItem "$($ENV:ProgramFiles)\OpenSSH-Win64\"

# Anpassen der 'Path' Variable
$oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$newPath=$oldPath+";$($ENV:ProgramFiles)\OpenSSH-Win64\"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath
# logoff auf Client durchführen
# Nach der Anmeldung ist ssh in der PATH Variable
#endregion

#region SSHD aktivieren
# SSHD als Dienst registrieren
& "C:\Program Files\OpenSSH-Win64\install-sshd.ps1"

# Firewall Ports öffnen
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22

# Dienste starten und auf automatisch setzen
Start-Service sshd
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic

# Berechtigungen anpassen
& "C:\Program Files\OpenSSH-Win64\FixHostFilePermissions.ps1" -Confirm:$False

# Standard Shell = PowerShell Core
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\6-preview\pwsh.exe" -PropertyType String -Force
# Subsystem registrieren
notepad "C:\ProgramData\ssh\sshd_config"
# Manuell folgende Zeile einfügen
#Subsystem	powershell	C:/Program Files/PowerShell/6-preview/pwsh.exe -sshs -NoLogo -NoProfile
# Dienst neustarten
Restart-Service sshd
#endregion

#region Schlüsselpaar auf dem Client generieren
ssh-keygen
#endregion

#region Authorized Key registrieren Windows
$PublicKey = @'
ssh-rsa USEYOURKEY
'@
# Ordner anlegen
New-Item -Path $env:USERPROFILE -Name ".ssh" -ItemType Directory -Force
# Ordner verstecken
Get-Item "$($env:USERPROFILE)\.ssh" -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
# Private Key schreiben
$PublicKey | Out-File -Encoding utf8 -Force -NoClobber "$($env:USERPROFILE)\.ssh\authorized_keys"
# Berechtigungen setzen
& "C:\Program Files\OpenSSH-Win64\FixUserFilePermissions.ps1" -Confirm:$False
#endregion

#region Get-Process über mehrere Maschinen
Invoke-Command -Hostname SERVER1,LINUXSERVER1 -ScriptBlock { Get-Process } -OutVariable Result -KeyFilePath ~/id_rsa

# Um den Schlüssel nicht anzugeben kann dieser durch den ssh-agent verwaltet werden
ssh-add

# Ohne Angabe des Schlüssels
Invoke-Command -Hostname SERVER1,LINUXSERVER1 -ScriptBlock { Get-Process } -OutVariable Result
#endregion

