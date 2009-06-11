# Find-String.ps1
#  Wrapper around dir | select-string which will highlight the pattern in the results
#  http://weblogs.asp.net/whaggard/archive/2007/03/23/powershell-script-to-find-strings-and-highlight-them-in-the-output.aspx
param ( 
	[string] $pattern = "",
	[string] $filter = "*.*",
	[switch] $recurse = $true,
	[switch] $caseSensitive = $false
)

if ($pattern -eq $null -or $pattern -eq "") { Write-Error "Please provide a search pattern!" ; return }

$regexPattern = $pattern
if ($caseSensitive -eq $false) { $regexPattern = "(?i)$regexPattern" }
$regex = New-Object System.Text.RegularExpressions.Regex $regexPattern

# Write the line with the pattern highlighted in red
function Write-HostAndHighlightPattern([string]$inputText)
{
	$index = 0
	while($index -lt $inputText.Length)
	{
		$match = $regex.Match($inputText, $index)
		if ($match.Success -and $match.Length -gt 0)
		{
			Write-Host $inputText.SubString($index, $match.Index - $index) -nonewline
			Write-Host $match.Value.ToString() -ForegroundColor Red -nonewline
			$index = $match.Index + $match.Length
		}
		else
		{
			Write-Host $inputText.SubString($index) -nonewline
			$index = $inputText.Length
		}
	}
}

# Do the actual find in the files
Get-ChildItem -recurse:$recurse -filter:$filter | 
	Select-String -caseSensitive:$caseSensitive -pattern:$pattern |pattern
		foreach {
			Write-Host "$($_.RelativePath($pwd.Path))($($_.LineNumber)): " -nonewline
			Write-HostAndHighlightPattern $_.Line
			Write-Host
		}
