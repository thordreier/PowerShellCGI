using System;
using System.Diagnostics;
using System.Linq;

namespace CGIwrap
{
    class Program
    {
        static void Main(string[] args)
        {
            var process = new Process();
            process.StartInfo = new ProcessStartInfo
            {
                FileName = args[0],
                Arguments = String.Join(" ", args.Skip(1).ToArray()),
                UseShellExecute = false,
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            process.OutputDataReceived += (sender, e) =>
            {
                Console.WriteLine(e.Data);
            };

            process.ErrorDataReceived += (sender, e) =>
            {
                Console.Error.WriteLine(e.Data);
            };

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();

            for (UInt32 i = 0; i < UInt32.Parse(Environment.GetEnvironmentVariable("CONTENT_LENGTH")); i++)
            {
                process.StandardInput.Write((char)Console.In.Read());
            }

            process.StandardInput.Close();
            process.WaitForExit();
        }
    }
}
