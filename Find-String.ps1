<#
.Synopsis
	Searches text files by pattern and displays the results.
.Description
	Searches text files by pattern and displays the results.
#>
param ( 
	[Parameter(Mandatory=$true)] 
	[regex] $pattern,
	[string] $filter = "*.*",
	[switch] $recurse = $true,
	[switch] $caseSensitive = $false
)

if ((-not $caseSensitive) -and (-not $pattern.Options -match "IgnoreCase")) {
	$pattern = New-Object regex $pattern.ToString(),@($pattern.Options,"IgnoreCase")
}

function Write-HighlightedMatch {
	process { 
		Write-Host $_.Filename -foregroundColor DarkMagenta -nonewline
		Write-Host ':' -foregroundColor Cyan -nonewline
		Write-Host $_.LineNumber -foregroundColor DarkYellow -nonewline
		Write-Host ':' -foregroundColor Cyan -nonewline
	
		$index = 0
		foreach ($match in $_.Matches) {
			Write-Host $_.Line.SubString($index, $match.Index - $index) -nonewline
			Write-Host $match.Value -ForegroundColor Red -nonewline
			$index = $match.Index + $match.Length
		}
		if ($index -lt $_.Line.Length) {
			Write-Host $_.Line.SubString($index) -nonewline
		}
		''
	}
}

Get-ChildItem -recurse:$recurse -filter:$filter |
	Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches | 
	Write-HighlightedMatch
