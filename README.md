# Find-String

Find-String is a PowerShell script whose purpose is to emulate grep and/or ack.
PowerShell already has the built-in Select-String cmdlet, but this script wraps
Select-String and provides match highlighting on top of the searching capabilities.

It currently highlights matches in a similar style to ack.

## Examples:

Find all usages of `form` in all .cs files:

    find-string form *.cs

Find the unique file extensions from all of the files that have the string
'jquery' in them:

    find-string jquery -passThru | 
      Select-Object -ExpandProperty Path | 
      Select-String '.\.(\w+)$' | 
      Select-Object -ExpandProperty Matches | 
      ForEach-Object { $_.Groups[1].Value } | 
      Select-Object -Unique

Or the same example using built-in aliases (more succinct, likely reflects more
typical usage):

    find-string jquery -pass | 
      select -expand path | 
      grep '.\.(\w+)$' | 
      select -expand matches | 
      %{ $_.groups[1].value } | 
      select -uniq
 
## Installation:

Find-String has [PsGet](http://psget.net/) support - once you have PsGet
installed, all you have to do is run `Install-Module Find-String` and the
Find-String command is ready for you.

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
