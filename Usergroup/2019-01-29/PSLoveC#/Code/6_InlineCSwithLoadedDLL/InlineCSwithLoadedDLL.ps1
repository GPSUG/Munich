$DLLPath = "$PSScriptRoot\..\SimpleAuthenticator\SimpleAuthenticator\bin\Release\SimpleAuthenticator.dll"

$Assem = ( $DLLPath )

$Source = @"
using SimpleAuthenticator;
public class GetCode
{
    public string PostCode()
    {
        int code = new CreateCode().Code;
        return code.ToString();
    }
}
"@

[System.Reflection.Assembly]::LoadFile($DLLPath) 
Add-Type -ReferencedAssemblies $Assem -TypeDefinition $Source -Language CSharp 

$Code = New-Object -TypeName GetCode
$Code.PostCode()