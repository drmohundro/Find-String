if (Get-Module -Name Find-String) { return }

<#
    Find-String is a PowerShell script whose purpose is to emulate grep and/or ack.
    PowerShell already has the built-in Select-String cmdlet, but this script wraps
    provides match highlighting on top of the searching capabilities.

    It currently highlights matches in a similar style to ack.
#>

#requires -version 2

function Find-String {
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [regex] $pattern,

        [Parameter(Position = 1, ParameterSetName = "Filter")]
        [string] $filter = "*.*",

        [Parameter(Position = 1, ParameterSetName = "Include")]
        [string[]] $include = @(),

        [string[]] $excludeFiles = @(),
        [string[]] $excludeDirectories = @(),
        [string[]] $path = @(),
        [switch] $recurse = $true,
        [switch] $caseSensitive = $false,
        [int[]] $context = 0,
        [switch] $passThru = $false,
        [switch] $pipeOutput = $false,
        [switch] $listMatchesOnly = $false
    )

    if ((-not $caseSensitive) -and (-not $pattern.Options -match "IgnoreCase")) {
        $pattern = New-Object -TypeName regex -Property $pattern.ToString(), @($pattern.Options, "IgnoreCase")
    }

    function directoriesToExclude {
        if ($excludeDirectories.Length -gt 0) {
            return $excludeDirectories
        }
        else {
            'bin', 'obj', '.git', '.hg', '.svn', '_ReSharper\.'

            if ($global:FindStringDirectoriesToExclude -ne $null) {
                $global:FindStringDirectoriesToExclude
            }
        }
    }

    function filesToExclude {
        if ($excludeFiles.Length -gt 0) {
            return $excludeFiles
        }
        else {
            '*exe', '*pdb', '*dll', '*.gif', '*.jpg', '*.doc', '*.pdf'

            if ($global:FindStringFileTypesToExclude -ne $null) {
                $global:FindStringFileTypesToExclude
            }
        }
    }

    function shouldFilterDirectory {
        param (
            [Parameter(Mandatory = $true)]
            $item
        )

        $directoriesToExclude = directoriesToExclude | ForEach-Object { "\\$_" }

        if ((Select-String -Pattern $directoriesToExclude -input $item.DirectoryName) -ne $null) {
            Write-Debug -Message "Excluding results from $item"
            return $true
        }
        else {
            return $false
        }
    }

    function filterExcludes {
        param (
            [Parameter(Mandatory = $true)]
            $item
        )

        if (-not ($item -is [System.IO.FileInfo])) { return $false }
        if (shouldFilterDirectory $item) { return $false }

        return $true
    }

    switch ($PsCmdlet.ParameterSetName) {
        'Filter' {
            if ($passThru) {
                Get-ChildItem -recurse:$recurse -filter:$filter -path $path -exclude (& filesToExclude) |
                    Where-Object { filterExcludes $_ } |
                    Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context
            }
            elseif ($listMatchesOnly) {
                Get-ChildItem -recurse:$recurse -filter:$filter -path $path -exclude (& filesToExclude) |
                    Where-Object { filterExcludes $_ } |
                    Select-String -caseSensitive:$caseSensitive -pattern:$pattern -List |
                    Select-Object -ExpandProperty Path
            }
            else {
                Get-ChildItem -recurse:$recurse -filter:$filter -path $path -exclude (& filesToExclude) |
                    Where-Object { filterExcludes $_ } |
                    Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context |
                    Out-ColorMatchInfo -pipeOutput:$pipeOutput
            }
        }
        'Include' {
            if ($passThru) {
                Get-ChildItem -recurse:$recurse -include:$include -path $path -exclude (& filesToExclude) |
                    Where-Object { filterExcludes $_ } |
                    Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context
            }
            elseif ($listMatchesOnly) {
                Get-ChildItem -recurse:$recurse -include:$include -path $path -exclude (& filesToExclude) |
                    Where-Object { filterExcludes $_ } |
                    Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context |
                    Select-Object -ExpandProperty Path
            }
            else {
                Get-ChildItem -recurse:$recurse -include:$include -path $path -exclude (& filesToExclude) |
                    Where-Object { filterExcludes $_ } |
                    Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context |
                    Out-ColorMatchInfo -pipeOutput:$pipeOutput
            }
        }
    }

    <#
.Synopsis
    Searches text files by pattern and displays the results.
.Description
    Searches text files by pattern and displays the results.
.Parameter Pattern
    Specifies the text to find. Type a string or regular expression.
.Parameter Filter
    Specifies the file types to search in. The default is all file types (*.*).
.Parameter Include
    Specifies the file types to search in. This allows you to search across
    multiple file types (i.e. *.ps1,*.psm1).
.Parameter ExcludeFiles
    Specifies the file types to exclude from searches. If set, this overrides
    any global defaults or configuration.
.Parameter ExcludeDirectories
    Specifies the directories to exclude from searches. It really only makes
    sense for recursive searches. If set, this overrides any global defaults
    or configuration.
.Parameter Path
    Specifies the path to the files to be searched. Wildcards are permitted.
    The default location is the local directory.
.Parameter Recurse
    Gets the items in the specified path and in all child directies. This is
    the default.
.Parameter CaseSensitive
    Makes matches case-sensitive. By default, matches are not case-sensitive.
.Parameter Context
    Captures the specified number of lines before and after the line with the
    match. This allows you to view the match in context.
.Parameter PassThru
    Passes the literal MatchInfo object representing the found match to the
    pipeline. By default, this cmdlet does not send anything through the
    object pipeline.
.Parameter PipeOutput
    Sends all output along the object pipeline. By default, this command uses
    color to help with readability; however, this prevents the output from being
    piped to another command. If you wish to pipe the output of this command to
    something else, be sure to use this parameter.
.Parameter ListMatchesOnly
    Returns all files that have matches existing in them, but doesn't display
    any of the matches themselves.
#>
}

function Out-ColorMatchInfo {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.PowerShell.Commands.MatchInfo]
        $match,

        [switch]
        $onlyShowMatches = $false,

        [switch]
        $pipeOutput = $false
    )

    begin {
        $script:priorPath = ''
        $script:hasContext = $false

        $script:buffer = New-Object -TypeName System.Text.StringBuilder
    }
    process {
        function output {
            param (
                [string]
                $str = '',

                $foregroundColor = $host.ui.RawUI.ForegroundColor,
                $backgroundColor = $host.ui.RawUI.BackgroundColor,

                [switch]
                $noNewLine = $false
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
                $args = @{ Object = $str; NoNewLine = $NoNewLine }
                if (-not($foregroundColor -lt 0)) {
                    $args.Add('ForegroundColor', $foregroundColor)
                }
                if (-not($backgroundColor -lt 0)) {
                    $args.Add('BackgroundColor', $backgroundColor)
                }
                Write-Host @args
            }
        }

        function Get-RelativePath([string] $path = '') {
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

        function Write-Context {
            param (
                $context = '',
                $contextLines = ''
            )

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
        Write-Context $match.Context.DisplayPreContext $lines

        Write-HighlightedMatch $match

        $lines = ($match.LineNumber + 1)..($match.LineNumber + $match.Context.DisplayPostContext.Length)
        Write-Context $match.Context.DisplayPostContext $lines

        if ($script:buffer.Length -gt 0) {
            $script:buffer.ToString()
        }
    }
    end {}

    <#
.Synopsis
    Highlights MatchInfo objects similar to the output from ack.
.Description
    Highlights MatchInfo objects similar to the output from ack.
#>
}

Export-ModuleMember -Function Find-String
Export-ModuleMember -Function Out-ColorMatchInfo
