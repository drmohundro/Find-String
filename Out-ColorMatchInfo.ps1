<#
.Synopsis
	Highlights MatchInfo objects similar to the output from grep.
.Description
	Highlights MatchInfo objects similar to the output from grep.
#>
param ( 
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)] 
	[Microsoft.PowerShell.Commands.MatchInfo] $match
)

begin {}
process { 
	function Get-RelativePath([string] $path) {
		$path = $path.Replace($pwd.Path, '')
		if ($path.StartsWith('\') -and (-not $path.StartsWith('\\'))) { 
			$path = $path.Substring(1) 
		}
		$path
	}

	$indent = (Get-RelativePath $match.Path).Length + $match.LineNumber.ToString().Length + 2

	if ($match.Context.DisplayPreContext -ne $null) {
		Write-Host ''.PadLeft($indent) -nonewline
		$match.Context.DisplayPreContext
	}

	Write-Host (Get-RelativePath $match.Path) -foregroundColor DarkMagenta -nonewline
	Write-Host ':' -foregroundColor Cyan -nonewline
	Write-Host $match.LineNumber -foregroundColor DarkYellow -nonewline
	Write-Host ':' -foregroundColor Cyan -nonewline

	$index = 0
	foreach ($m in $match.Matches) {
		Write-Host $match.Line.SubString($index, $m.Index - $index) -nonewline
		Write-Host $m.Value -ForegroundColor Red -nonewline
		$index = $m.Index + $m.Length
	}
	if ($index -lt $match.Line.Length) {
		Write-Host $match.Line.SubString($index) -nonewline
	}
	''

	if ($match.Context.DisplayPostContext -ne $null) {
		Write-Host ''.PadLeft($indent) -nonewline
		$match.Context.DisplayPostContext
		'-------------------------------'
	}
}
end {}
