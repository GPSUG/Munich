# OpenSSH auf Windows installieren
# Nach powershell suchen
sudo apt-cache search powershell

# Das Microsoft repo samt Schlüssel hinzufügen
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
# Die Paketliste aktualisieren
sudo apt-get update

# Erneut nach powershell suchen
sudo apt-cache search powershell

# PowerShell Core installieren
sudo apt-get install -y powershell

# Bei Problemen mit dem Lock
sudo rm /var/lib/apt/lists/lock
# Zeigen das die Verbindung noch nicht sauber funktioniert

# SSHd Config anpassen
sudo vi /etc/ssh/sshd_config
#:syntax off

# Password und Key Authentifizierung aktivieren
PasswordAuthentication yes
PubkeyAuthentication yes
# PowerShell Core als Subsystem registrieren
Subsystem powershell /usr/bin/pwsh -sshs -NoLogo -NoProfile

# SSHd neustarten
sudo systemctl restart sshd

#region Authorized Key registrieren Linux
mkdir -p ~/.ssh/
echo 'ssh-rsa USEYOURKEY' >> ~/.ssh/authorized_keys
# Korrekte Berechtigungen setzen
chmod go-w ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
#endregion