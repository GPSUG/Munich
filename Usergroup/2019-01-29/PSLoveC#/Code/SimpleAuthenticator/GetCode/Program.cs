using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SimpleAuthenticator;

namespace GetCode
{
    class Program
    {
        static void Main(string[] args)
        {
            int code = new CreateCode().Code;

            Console.WriteLine($"Code: {code}");
            Console.ReadKey();
        }
    }
}
