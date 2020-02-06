
#Variables
$ALLProccesors = Get-Process # array what is to processing (For Example: for each file in a folder)

$JobLimit = 5 # Max concurrent jobs
$ProcessingCount = $ALLProccesors.Count #Counter of All Processes who need to be processed.
$JOBID = "PSUGJOBS" # Name of Jobs beginn with this...

$global:i = 1 # Counter for Joblimit
$n = 0 # counter for the processes


function Get-AllJobsbyState {
	param ( $State )
	return (Get-Job | Where-Object { ($_.Name -Like "$JOBID*") -and ($_.State -eq $state) } )
}

function Get-RunningInstances {
	$global:i = 0
	# sleep time between job instances
	start-sleep -s 5
	foreach ($job in (Get-AllJobsbyState -state "running" )) {$global:i++}
	Write-Host "::Currently running instances: $global:i"
    if ($global:i -eq 0) { $global:i = 1 }
}


While (($global:i -le $JobLimit) -and ($global:i -ge 1) -and ($ProcessingCount -gt $n)) 
{
    if ($n -lt $ProcessingCount)
    {
		if ($n -lt $ALLProccesors.count)
		{
			$item = $ALLProccesors[$n]
			# scriptblock
			Write-Host "Take Item: $item"


			$ScriptBlock = { Write-host $item.name; Start-Sleep -Seconds "60" }

			# initiate scriptblock
			Start-Job -Name "$JOBID::$($item.Name)" -ScriptBlock $ScriptBlock | Out-Null		
		}

	    # Checking Running instances
	    Get-RunningInstances

	    # to many jobs running,... waiting for completion of Jobs
	    While ($global:i -ge $JobLimit) { Get-RunningInstances }

        $n++
    }
    else { break } # all jobs are triggered cancel while loop
}

# wait for the last jobs to complete
Write-Host "######## Waiting for last Taks #########"
Get-AllJobsbyState -state "running" | Wait-Job

<#
    #alternative
	while ((Get-AllJobsbyState -state "running").count -ge 1)
	{
		Write-Host "Still Waiting for completion of last Tasks...."
		Start-Sleep -Seconds 5
	}
#>

# Report all Jobs
Write-Host "######## Job Report #########"
foreach ($job in (get-job -Name "$JOBID*")) 
{
	if ($Job.State -eq "Failed") { $Color = "red" }
	else { $Color = "white" }
	Write-Host "Job: $($job.Name) :::: JobState: $($job.State)" -ForegroundColor $Color
}

Remove-Job -Name "$JOBID*"