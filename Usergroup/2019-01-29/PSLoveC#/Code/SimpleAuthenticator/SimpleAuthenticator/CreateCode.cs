using System;

namespace SimpleAuthenticator
{
    public class CreateCode
    {
        /// <summary>
        /// Return a new Code. Can be called like this
        /// int Code = new CreateCode().Code; 
        /// </summary>
        public int Code => GenerateCode();
               
        // instance for static method
        private static CreateCode CCInstance = new CreateCode();
        /// <summary>
        /// Static Method
        /// Return a new Code. Can be called like this
        /// int Code = [SimpleAuthenticator.CreateCode]::StaticMethodGetCode
        /// </summary>
        public static int StaticMethodGetCode => CCInstance.GenerateCode();

        /// <summary>
        /// With this function you generate a new Code
        /// </summary>
        /// <returns>int</returns>
        private int GenerateCode()
        {
            // Define MaxLifeTimeTicks from timespan
            TimeSpan ts = TimeSpan.FromMinutes(15);
            long MaxLifeTimeTicks = ts.Ticks;

            // Seed the RNG with an integer that changes after maxlifetimeticks.
            Random rnd = new Random((int)(DateTime.UtcNow.Ticks / MaxLifeTimeTicks));
            // Generate a 6 digit random number.
            return rnd.Next(100000, 999999);
        }
    }
}
