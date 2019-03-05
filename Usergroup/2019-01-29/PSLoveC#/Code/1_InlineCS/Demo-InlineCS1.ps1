
$Source = @"
using System;
public class HelloWorld
{
    public void Hello()
    {
        Console.WriteLine("Hello World!");
    }
}
"@


Add-Type -TypeDefinition $Source

$Instance = New-Object -TypeName HelloWorld
$Instance.Hello()
