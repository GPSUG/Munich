 #Requires -Modules Az.ResourceGraph

 <#
      .SYNOPSIS
      Executes an Azure Resource Graph Query
      .DESCRIPTION
      Executes an Azure Resource Graph Query with automatic paging.
      Needs the field id to work and needs to be sorted on it.
      .PARAMETER Query
      The Azure Resource Graph Query to be executed.
      .PARAMETER Threshold
      Dynamic threshold for paging.
      Today it is defined to 1000 and does not need to be changed manually.
      .PARAMETER ExportCSVPath
      Export path for CSV
      .PARAMETER ExportCSVDelimeter
      Default delimeter for exported CSVs. English: ','  German: ';'
      .OUTPUTS
      Resulting object
      .EXAMPLE
      $queryresult = Invoke-ARGQuery -Query $query -ExportCSVPath "$home\query.csv" 
      .NOTES
      Can be used for all queries.
      .LINK
  #>
function Invoke-ARGQuery {
    [CmdletBinding()]
    param (
        #Azure Resource Graph Query
        [Parameter(Mandatory=$true)]
        [string] $Query,
        [Parameter(Mandatory=$false)]
        [int] $Threshold = 1000,
        [Parameter(Mandatory=$false)]
        [string] $ExportCSVPath,
        [Parameter(Mandatory=$false)]
        [char] $ExportCSVDelimeter = ';'
    )
    process {
        $result = $null

        #Retrieve the number of results
        $count = (Search-AzGraph -Query $($Query + ' | summarize count()')).count_

        # number of cycles to retrieve full result data
        $cycles = [Math]::Ceiling($count / $Threshold)

        # gathering resulting data in the threshold steps
        for ($i = 0; $i -lt $cycles; $i++) {
            if ($i -eq 0) {
                $result += Search-AzGraph -Query $Query -First $Threshold
            }
            else
            {
                $result += Search-AzGraph -Query $Query -First $Threshold -Skip $($i * $Threshold)
            }
        }
        #Export path when a path is provided via params.
        if ($ExportCSVPath) {
            $result | Export-CSV -Path $ExportCSVPath -Delimiter $ExportCSVDelimeter -NoTypeInformation
        }
        
        return $result
    }
}

