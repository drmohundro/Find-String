<#
.Synopsis
    Searches text files by pattern and displays the results.
.Description
    Searches text files by pattern and displays the results.
.Parameter Pattern
    Specifies the text to find. Type a string or regular expression.
.Parameter Filter
    Specifies the file types to search in. The default is all file types.
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
#>
#requires -version 2
param ( 
    [Parameter(Mandatory=$true)] 
    [regex] $pattern,
    [string] $filter = "*.*",
    [string[]] $path,
    [switch] $recurse = $true,
    [switch] $caseSensitive = $false,
    [int[]] $context = 0,
    [switch] $passThru = $false,
    [switch] $pipeOutput
)

if ((-not $caseSensitive) -and (-not $pattern.Options -match "IgnoreCase")) {
    $pattern = New-Object regex $pattern.ToString(),@($pattern.Options,"IgnoreCase")
}

if ($passThru) {
    Get-ChildItem -recurse:$recurse -filter:$filter -path $path |
        Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context | 
}
else {
    Get-ChildItem -recurse:$recurse -filter:$filter -path $path |
        Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context | 
        Out-ColorMatchInfo -pipeOutput:$pipeOutput
}
