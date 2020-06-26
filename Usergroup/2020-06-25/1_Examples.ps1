#Install dependent modules
Install-Module -Name Az.ResourceGraph -Scope CurrentUser -Force
Install-Module -Name Az -Scope CurrentUser -Force

# clean up old modules if necessary
Uninstall-AzureRm

#Load PowerShell functions
. '.\Invoke-ARGQuery.ps1'

#Connect the Azure Account
Connect-AzAccount

#Gather the subscriptions via UI
$selectedSubscriptions = Get-AzSubscription | Where-Object {$_.State -ne 'Disabled' } | Sort-Object | Out-GridView -PassThru
$selectedSubscriptions | Out-GridView

#Running through all subscriptions
foreach ($subscription in $selectedSubscriptions) {
    # Connecting to Azure subscription
    $null = Set-AzContext -SubscriptionId $subscription.Id

    #code here
}

###################

## List all Public IP addresses
$query= @"
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
"@

#Execute query and save to variable
$queryresult = Invoke-ARGQuery -Query $query -ExportCSVPath "c:\temp\VMs.csv" 

#Visualizing results
$queryresult | Out-GridView