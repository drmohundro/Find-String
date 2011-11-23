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
#>
#requires -version 2
[CmdletBinding(DefaultParameterSetName="Filter")]
param ( 
    [Parameter(Position = 0, Mandatory=$true)] 
    [regex] $pattern,

    [Parameter(Position = 1, ParameterSetName="Filter")]
    [string] $filter = "*.*",

    [Parameter(Position = 1, ParameterSetName="Include")]
    [string[]] $include,

    [string[]] $excludeFiles,
    [string[]] $excludeDirectories,
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
    param ($item)
    
    $directoriesToExclude = directoriesToExclude | foreach { "\\$_" }

    if ((Select-String $directoriesToExclude -input $item.DirectoryName) -ne $null) { 
        Write-Debug "Excluding results from $item"
        return $true 
    }
    else {
        return $false
    }
}

function filterExcludes {
    param ($item)

    if (-not ($item -is [System.IO.FileInfo])) { return $false }
    if (shouldFilterDirectory $item) { return $false }

    return $true
}

switch ($PsCmdlet.ParameterSetName)
{
    'Filter' {
        if ($passThru) {
            Get-ChildItem -recurse:$recurse -filter:$filter -path $path -exclude (& filesToExclude) |
                Where { filterExcludes $_ } | 
                Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context
        }
        else {
            Get-ChildItem -recurse:$recurse -filter:$filter -path $path -exclude (& filesToExclude) |
                Where { filterExcludes $_ } | 
                Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context | 
                Out-ColorMatchInfo -pipeOutput:$pipeOutput
        }
    }
    'Include' {
        if ($passThru) {
            Get-ChildItem -recurse:$recurse -include:$include -path $path -exclude (& filesToExclude) |
                Where { filterExcludes $_ } | 
                Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context
        }
        else {
            Get-ChildItem -recurse:$recurse -include:$include -path $path -exclude (& filesToExclude) |
                Where { filterExcludes $_ } | 
                Select-String -caseSensitive:$caseSensitive -pattern:$pattern -AllMatches -context $context | 
                Out-ColorMatchInfo -pipeOutput:$pipeOutput
        }
    }
}
