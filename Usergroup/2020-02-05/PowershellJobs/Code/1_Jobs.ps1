
# Get all Job cmdlets
Get-Command *-job

#region Start Job
Get-help Start-Job
Start-Job -Name "TestJOB1" -ScriptBlock {Write-host "Hello PSUG!"}
#EndRegion

#Region Get Job
Get-Help Get-Job
Get-Job
#EndRegion

#region Stop Job
Get-Help Stop-Job
Start-Job -Name "TestJOB2" -ScriptBlock {Start-Sleep -Seconds 600}
Get-Job
Stop-Job -Name "TestJOB2"
Get-Job
#EndRegion

#region Wait Job
Get-Help Wait-Job
Start-Job -Name "TestJOB3" -ScriptBlock {Start-Sleep -Seconds 30}
Get-Job
Wait-Job -Name "TestJOB3"
#EndRegion

#region Receive Job
Get-help Receive-Job
Start-Job -Name "TestJOB4" -ScriptBlock {Write-host "Hello PSUG!"} | Wait-Job
Receive-Job -Name "TestJOB4"
#EndRegion

#region Remove Job
Get-Help Remove-Job
Remove-Job -name "*"
Get-Job
#EndRegion

#region AsJob Parameter
Get-Command -ParameterName AsJob

Get-NetAdapter
Get-NetAdapter -AsJob
get-job

$Job = Get-NetAdapter -AsJob
get-job -Id $Job.ID | Wait-Job
Receive-Job $Job | Format-Table  
#EndRegion


#region example timing1
(Measure-Command {
    $i = 0
    while ($i -lt 10) {
        #todo
        New-Item -ItemType File -Name $($(New-Guid).ToString() + ".dat") -Path C:\temp\GUIDS
        Start-Sleep -seconds 2    
        $i++
    }

}).TotalMilliseconds
#endregion

#region example timing2
(Measure-Command {
    $i = 0
    while ($i -lt 10) {
        Start-job -Name "JOB::$i" -ScriptBlock { New-Item -ItemType File -Name $($(New-Guid).ToString() + ".dat") -Path C:\temp\GUIDS; Start-Sleep -seconds 2 }
        $i++
    }
}).TotalMilliseconds
#Endregion
