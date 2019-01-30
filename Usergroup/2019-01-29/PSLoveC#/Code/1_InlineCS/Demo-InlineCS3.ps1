

$Source = @"
using System;
using System.Collections;
using System.Collections.Generic;

namespace People
{
    public enum Gender
    {
        X,
        Male,
        Female
    }

    public class Person
    {
        public Person (){}

        public Person(string Name, Gender Gender, int Age)
        {
            this.Name = Name;
            this.Gender = Gender;
            this.Age = Age;
        }

        public string Name {get;set;}
        public Gender Gender {get;set;}
        public int Age {get;set;}
    }
}
"@

Add-Type -TypeDefinition $Source

$Instance = New-Object -TypeName People.Person


$Instance.Gender = [People.Gender]::Male
$Instance.Age = 30
$Instance.Name = "Christoph"

$Instance


$Instance2 = New-Object -TypeName People.Person -ArgumentList "Hanna", ([People.Gender]::Female),"26"
$Instance2