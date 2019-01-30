using System;
public class GetSalut
{
    public static string StaticSalutFor(string Name)
    {
        //string result = $"Hello {Name}!"; //THIS DO NOT WORK!!
        string result = "Hello " + Name + "!";
        return result;
    }

    public string SalutFor(string Name)
    {
        //string result = $"Hello {Name}!"; //THIS DO NOT WORK!!
        string result = "Hello " + Name + "!";
        return result;
    }
}