
Start-Process "https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/"



(Measure-Command {
    1..1000 | ForEach-Object -Parallel { "Hello: $_" } 
}).TotalMilliseconds
#10457.962
 
 
(Measure-Command {
    1..1000 | ForEach-Object { "Hello: $_" } 
}).TotalMilliseconds
#18.4473


