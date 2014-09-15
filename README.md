# Find-String

Find-String is a PowerShell script whose purpose is to emulate [grep](http://en.wikipedia.org/wiki/Grep) and/or [ack](http://beyondgrep.com/).
PowerShell already has the built-in `Select-String` cmdlet, but this script wraps
`Select-String` and provides match highlighting on top of the searching capabilities.

It currently highlights matches in a similar style to [ack](http://beyondgrep.com/).

## Examples:

Find all usages of `form` in all .cs files:

```ps1
find-string form *.cs
```

Find the unique file extensions from all of the files that have the string
'jquery' in them:

```ps1
find-string jquery -passThru | 
    Select-Object -ExpandProperty Path | 
    Select-String '.\.(\w+)$' | 
    Select-Object -ExpandProperty Matches | 
    ForEach-Object { $_.Groups[1].Value } | 
    Select-Object -Unique
```

Or the same example using built-in aliases (more succinct, likely reflects more
typical usage):

```ps1
find-string jquery -pass | 
    select -expand path | 
    grep '.\.(\w+)$' | 
    select -expand matches | 
    %{ $_.groups[1].value } | 
    select -uniq
```
 
## Installation:

### PsGet Install

* Install [PsGet](http://psget.net/)
* Run `Install-Module Find-String`

See [Find-String on PsGet](http://psget.net/directory/Find-String/) for more details.

### Manual Install

* Clone (or download) the repository to "~/Documents/WindowsPowerShell/Modules/Find-String"

## Alternative Tools

I like options, so I want to ensure everyone is aware of the other tools out there, particularly in Windows (as PowerShell currently only runs in Windows).

* [Grep](http://gnuwin32.sourceforge.net/packages/grep.htm)
* [Ack](http://beyondgrep.com/) - installable via [Chocolatey](https://chocolatey.org/packages/ack)
* [The Silver Searcher (aka AG)](http://blog.kowalczyk.info/software/the-silver-searcher-for-windows.html) - fork of the official AG that is built specifically for Windows
* [The Platinum Searcher (aka PT)](https://github.com/monochromegane/the_platinum_searcher) - text searching tool written in Go, multi-platform

To be honest, Platinum Searcher is my default now because of its speed and its cross platform support. It works great in Windows as well as in Linux and OSX. I do fall back to Find-String often, too.

## Usage:

    NAME
        c:\MyScriptDir\Find-String.ps1

    SYNOPSIS
        Searches text files by pattern and displays the results.

    SYNTAX
        Find-String [-pattern] <Regex> [-filter] <String> [-path <String[]>] 
        [-recurse] [-caseSensitive] [-context <Int32[]>] [-passThru] [-pipeOutput] 
        [<CommonParameters>]

        Find-String [-pattern] <Regex> [-include] <String[]> [-path<String[]>] 
        [-recurse] [-caseSensitive] [-context <Int32[]>] [-passThru] [-pipeOutput] 
        [<CommonParameters>]


    DESCRIPTION
        Searches text files by pattern and displays the results.


    PARAMETERS
        -pattern <Regex>
            Specifies the text to find. Type a string or regular expression.

            Required?                    true
            Position?                    1
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -filter <String>
            Specifies the file types to search in. The default is all file types (*.*).

            Required?                    true
            Position?                    2
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -include <String[]>
            Specifies the file types to search in. This allows you to search across multiple file types (i.e. *.
            ps1,*.psm1).

            Required?                    true
            Position?                    2
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -path <String[]>
            Specifies the path to the files to be searched. Wildcards are permitted. 
            The default location is the local directory.

            Required?                    false
            Position?                    named
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -recurse [<SwitchParameter>]
            Gets the items in the specified path and in all child directies. This is 
            the default.

            Required?                    false
            Position?                    named
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -caseSensitive [<SwitchParameter>]
            Makes matches case-sensitive. By default, matches are not case-sensitive.

            Required?                    false
            Position?                    named
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -context <Int32[]>
            Captures the specified number of lines before and after the line with the 
            match. This allows you to view the match in context.

            Required?                    false
            Position?                    named
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -passThru [<SwitchParameter>]
            Passes the literal MatchInfo object representing the found match to the 
            pipeline. By default, this cmdlet does not send anything through the 
            object pipeline.

            Required?                    false
            Position?                    named
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?

        -pipeOutput [<SwitchParameter>]
            Sends all output along the object pipeline. By default, this command uses 
            color to help with readability; however, this prevents the output from being 
            piped to another command. If you wish to pipe the output of this command to
            something else, be sure to use this parameter.

            requires -version 2

            Required?                    false
            Position?                    named
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?
