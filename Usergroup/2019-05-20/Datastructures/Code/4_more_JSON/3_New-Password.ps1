Function Global:New-Password
{
	<#
    .Synopsis
		Generates one complex password.
    .DESCRIPTION
		Generates one complex password.
    
	.PARAMETER PasswordLength
		Specify an INT how long the password should be. Standard is 30.

	.PARAMETER InputStrings
		Specifies an array of strings containing charactergroups from which the password will be generated.

	.PARAMETER FirstChar
		Specifies a string containing a character group from which the first character in the password will be generated.

  .PARAMETER NoSpecialChars
    Bool for changing inputstring that no SpecialCharakters are included. That Overwrite the InputString Parameter!!
	
	.PARAMETER Count
		Specify how many passwords the CMDLET generate
	
	.NOTES
		Version: 		<1.0.0>
		Author: 		<Christoph Ruf>
		Creation Date:	<2015-03-15>
	
	.EXAMPLE
		scriptname.ps1

	.EXAMPLE
		scriptname.ps1 -PasswordLength "20"
	
	.EXAMPLE
		scriptname.ps1 -FirstChar "ABCDEFG"

	.EXAMPLE
		scriptname.ps1 -InputString "0123","abcd","ABCD"
    #>

	Param 
	(
		[Parameter()][int]$PasswordLength = 30,
		[Parameter()][String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '123456789', '!$)[]{}#%&+-*,.'),
		[Parameter()][String] $FirstChar,
    [Parameter()][Switch]$NoSpecialChars = $false,
		[Parameter()][int]$Count = 1
	)
	
	Function Get-Seed
	{
        # Generate a seed for randomization
        $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
        $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
        $Random.GetBytes($RandomBytes)
        [BitConverter]::ToUInt32($RandomBytes, 0)
    }
	
    if ($NoSpecialChars) { $InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '123456789') }

	For($iteration = 1;$iteration -le $Count; $iteration++)
	{
		$Password = @{}

		# Create char arrays containing groups of possible chars
		[char[][]]$CharGroups = $InputStrings

		# Create char array containing all chars
		$AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

		# If FirstChar is defined, randomize first char in password from that string.
		if($PSBoundParameters.ContainsKey('FirstChar'))
		{
			$Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
		}
		# Randomize one char from each group
		Foreach($Group in $CharGroups) 
		{
			if($Password.Count -lt $PasswordLength) 
			{
				$Index = Get-Seed
				While ($Password.ContainsKey($Index))
				{
					$Index = Get-Seed                        
				}
				$Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
			}
		}

		# Fill out with chars from $AllChars
		for($i=$Password.Count;$i -lt $PasswordLength;$i++) 
		{
			$Index = Get-Seed
			While ($Password.ContainsKey($Index))
			{
				$Index = Get-Seed                        
			}
			$Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
		}
		Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
	}	
}