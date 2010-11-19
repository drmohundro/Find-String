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
    $onlyShowMatches,

    [switch]
    $pipeOutput
)

begin {
    $script:priorPath = ''
    $script:hasContext = $false

    $script:buffer = New-Object System.Text.StringBuilder
}
process { 
    function output {
        param (
            [string] $str, 
            $foregroundColor = $host.ui.RawUI.ForegroundColor, 
            $backgroundColor = $host.ui.RawUI.BackgroundColor,
            [switch] $noNewLine
        )
        if ($pipeOutput) {
            if ($noNewLine) {
                $script:buffer.Append($str) | out-null
            }
            else {
                $script:buffer.AppendLine($str) | out-null
            }
        }
        else {
            $arg = 'Write-Host $str'
            if (-not($foregroundColor -lt 0)) {
                $arg += ' -foregroundColor $foregroundColor'
            }
            if (-not($backgroundColor -lt 0)) {
                $arg += ' -backgroundColor $backgroundColor'
            }
            $arg += ' -noNewLine:$noNewLine'
            Invoke-Expression $arg
        }
    }

    function Get-RelativePath([string] $path) {
        $path = $path.Replace($pwd.Path, '')
        if ($path.StartsWith('\') -and (-not $path.StartsWith('\\'))) { 
            $path = $path.Substring(1) 
        }
        $path
    }

    function Write-PathOrSeparator($match) {
        if ($script:priorPath -ne $match.Path) {
            output ''
            output (Get-RelativePath $match.Path) -foregroundColor Green
            $script:priorPath = $match.Path
        }
        else {
            if ($script:hasContext) { 
                output '--' 
            }
        }
    }

    function Write-HighlightedMatch($match) {
        if (-not $onlyShowMatches) {
            output "$($match.LineNumber):" -nonewline
        }
        $index = 0
        foreach ($m in $match.Matches) {
            output $match.Line.SubString($index, $m.Index - $index) -nonewline
            output $m.Value -ForegroundColor Black -BackgroundColor Yellow -nonewline
            $index = $m.Index + $m.Length
        }
        if ($index -lt $match.Line.Length) {
            output $match.Line.SubString($index) -nonewline
        }
        output ''
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

    if ($script:buffer.Length -gt 0) {
        $script:buffer.ToString()
    }
}
end {}
