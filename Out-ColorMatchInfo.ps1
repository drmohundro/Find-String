<#
.Synopsis
	Highlights MatchInfo objects similar to the output from ack.
.Description
	Highlights MatchInfo objects similar to the output from ack.
#>
#requires -version 2
param ( 
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)] 
	[Microsoft.PowerShell.Commands.MatchInfo] 
	$match,

	[switch]
	$onlyShowMatches
)

begin {
	$script:priorPath = ''
	$script:hasContext = $false
}
process { 
	function Get-RelativePath([string] $path) {
		$path = $path.Replace($pwd.Path, '')
		if ($path.StartsWith('\') -and (-not $path.StartsWith('\\'))) { 
			$path = $path.Substring(1) 
		}
		$path
	}

	function Write-PathOrSeparator($match) {
		if ($script:priorPath -ne $match.Path) {
			''
			Write-Host (Get-RelativePath $match.Path) -foregroundColor Green
			$script:priorPath = $match.Path
		}
		else {
			if ($script:hasContext) { 
				'--' 
			}
		}
	}

	function Write-HighlightedMatch($match) {
		if (-not $onlyShowMatches) {
			Write-Host "$($match.LineNumber):" -nonewline
		}
		$index = 0
		foreach ($m in $match.Matches) {
			Write-Host $match.Line.SubString($index, $m.Index - $index) -nonewline
			Write-Host $m.Value -ForegroundColor Black -BackgroundColor Yellow -nonewline
			$index = $m.Index + $m.Length
		}
		if ($index -lt $match.Line.Length) {
			Write-Host $match.Line.SubString($index) -nonewline
		}
		Write-Host ''
	}
	
	function Write-ContextLines($context, $contextLines) {
		if ($context.length -eq $null) {return}

		$script:hasContext = $true
		for ($i = 0; $i -lt $context.length; $i++) {
			"$($contextLines[$i])- $($context[$i])"
		}
	}
	
	if (-not $onlyShowMatches) {
		Write-PathOrSeparator $match
	}

	$lines = ($match.LineNumber - $match.Context.DisplayPreContext.Length)..($match.LineNumber - 1)
	Write-ContextLines $match.Context.DisplayPreContext $lines

	Write-HighlightedMatch $match

	$lines = ($match.LineNumber + 1)..($match.LineNumber + $match.Context.DisplayPostContext.Length)
	Write-ContextLines $match.Context.DisplayPostContext $lines
}
end {}
