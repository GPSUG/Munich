
#region preparation

$inlinecs = @"
using System;
using System.IO;
public class CreateNewFile
{

    public void Create()
    {
        Guid Guid;
        string path = "C:\\temp\\GUIDS\\" + Guid.NewGuid().ToString()  + ".txt";
        File.Create(path);
    }    
}
"@

	
Add-Type -TypeDefinition $inlinecs
$CreateNewFile = New-Object -TypeName CreateNewFile

#endregion

$run1 = Measure-Command { New-Item -Path $("C:\temp\GUIDS\" + $(New-Guid) + ".txt") }

$run2 = Measure-Command { $CreateNewFile.Create() }



Write-host "------------"
$run1


Write-host "------------"
$run2
