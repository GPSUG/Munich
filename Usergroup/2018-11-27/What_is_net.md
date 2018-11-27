# What is .NET?

[George Kosmidis](http://georgekosmidis.gr/) 

This presentation walks through the basics of what .NET is & what you can build with it. It walks through the platform at a very high level, talks about the open source journey and history, and demonstrates how to get started learning.

[slides](https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2Fdotnet-presentations%2Fhome%2Ftree%2Fmaster%2F.NET%2520Intro&data=02%7C01%7CMark.Warneke%40microsoft.com%7Ce755fef4740b4d88ad7608d65125787f%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C636785618712677118&sdata=tkwm%2FOlnigGnEv8I36jqeEQeQehGrJ19P0fkidtzyvM%3D&reserved=0)


## Creat .NET PowerShell Module


```
$module = 'testmodule'
mkdir $module
dotnet new -i Microsoft.PowerShell.Standard.Module.Template
dotnet new psmodule
dotnet build
Import-Module "bin\Debug\netstandard2.0\$module.dll"
Get-Module $module
```