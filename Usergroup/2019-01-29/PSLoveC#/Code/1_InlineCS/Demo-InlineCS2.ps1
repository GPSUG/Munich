

$Source = @"
using System;
public class Calc
{
    public int Add(int a,int b)
    {
        Console.WriteLine("Add {0} to {1}",a.ToString(),b.ToString());
        return a+b;
    }
    
    public int Mul(int a,int b)
    {
        return a*b;
    }

    public static float Divide(int a,int b)
    {
        return a/b;
    }
}
"@

Add-Type -TypeDefinition $Source


[Calc]::Divide(4,2)


$CalcInstance = New-Object -TypeName Calc
$CalcInstance.Add(20,30)
