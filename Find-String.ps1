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

Get-ChildItem -recurse:$recurse -filter:$filter |
	Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches | 
	Out-HighlightMatchInfo
