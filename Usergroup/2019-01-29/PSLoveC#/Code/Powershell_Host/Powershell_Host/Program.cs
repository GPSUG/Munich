using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Management.Automation;
using System.Management.Automation.Runspaces;


namespace Powershell_Host
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Write(RunScript(Console.ReadLine()));
            Console.ReadKey();

            Console.WriteLine("Or the different way? All Service Names");
            Console.ReadKey();

            //The first step is to create a new instance of the PowerShell class
            using (PowerShell PowerShellInstance = PowerShell.Create()) //PowerShell.Create() creates an empty PowerShell pipeline for us to use for execution.
            {
                // use "AddScript" to add the contents of a script file to the end of the execution pipeline.
                // use "AddCommand" to add individual commands/cmdlets to the end of the execution pipeline.

                //PowerShellInstance.AddScript("param($param1) $d = get-date; $s = 'test string value'; $d; $s; $param1; get-service");
                PowerShellInstance.AddScript("get-service");

                // use "AddParameter" to add a single parameter to the last command/script on the pipeline.
                // PowerShellInstance.AddParameter("param1", "parameter 1 value!");

                //Result of the script with Invoke()
                Collection<PSObject> result = PowerShellInstance.Invoke();

                //output example : @{yourProperty=value; yourProperty1=value1; yourProperty2=StoppedDeallocated; PowerState=Stopped; OperationStatus=OK}}
                
                foreach (PSObject r in result)
                {
                    //access to values
                    string r1 = r.Properties["Name"].Value.ToString();
                    Console.WriteLine(r1);
                }
            }


        }

        private static string RunScript(string scriptText)
        {
            // create Powershell runspace

            Runspace runspace = RunspaceFactory.CreateRunspace();

            // open it

            runspace.Open();

            // create a pipeline and feed it the script text

            Pipeline pipeline = runspace.CreatePipeline();
            pipeline.Commands.AddScript(scriptText);

            // add an extra command to transform the script
            // output objects into nicely formatted strings

            // remove this line to get the actual objects
            // that the script returns. For example, the script

            // "Get-Process" returns a collection
            // of System.Diagnostics.Process instances.

            pipeline.Commands.Add("Out-String");

            // execute the script

            Collection <PSObject> results = pipeline.Invoke();

            // close the runspace

            runspace.Close();

            // convert the script result into a single string

            StringBuilder stringBuilder = new StringBuilder();
            foreach (PSObject obj in results)
            {
                stringBuilder.AppendLine(obj.ToString());
            }

            return stringBuilder.ToString();
        }
    }
}
