# Find-String

[![Join the chat at https://gitter.im/drmohundro/Find-String](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/drmohundro/Find-String?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Find-String is a PowerShell script whose purpose is to emulate [grep](http://en.wikipedia.org/wiki/Grep) and/or [ack](http://beyondgrep.com/).
PowerShell already has the built-in `Select-String` cmdlet, but this script wraps
`Select-String` and provides match highlighting on top of the searching capabilities.

It currently highlights matches in a similar style to [ack](http://beyondgrep.com/).

![screenshot](https://user-images.githubusercontent.com/43072/60065075-2051e200-96f2-11e9-90fe-97f2278942ff.png)

## Examples

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
    select-string '.\.(\w+)$' |
    select -expand matches |
    %{ $_.groups[1].value } |
    select -uniq
```

## Installation

### PowerShell Gallery Install

This method of installation requires PowerShell v5 or higher.

* Run `Install-Module Find-String`

See [Find-String on PowerShell Gallery](https://www.powershellgallery.com/packages/Find-String/).

### PsGet Install

* Install [PsGet](http://psget.net/)
* Run `Install-Module Find-String`

See [Find-String on PsGet](http://psget.net/directory/Find-String/) for more details.

### Manual Install

Clone (or download) the repository to:

* If PowerShell 5
    * `~/Documents/WindowsPowerShell/Modules/Find-String`
* If PowerShell Core on Windows
    * `~/Documents/PowerShell/Modules/Find-String`
* If Mac/Linux
    * `~/.local/share/powershell/Modules/Find-String`

## Alternative Tools

I like options, so I want to ensure everyone is aware of the other tools out there. My current preferred tool is RipGrep.

* [Grep](https://www.gnu.org/software/grep/) - "Grep searches one or more input files for lines containing a match to a specified pattern."
* [Ack](https://github.com/beyondgrep/ack2) - "ack is a code-searching tool, similar to grep but optimized for programmers searching large trees of source code."
* [The Silver Searcher (aka AG)](https://github.com/ggreer/the_silver_searcher) - "A code-searching tool similar to ack, but faster."
* [The Platinum Searcher (aka PT)](https://github.com/monochromegane/the_platinum_searcher) - "A code search tool similar to ack and the_silver_searcher(ag). It supports multi platforms and multi encodings."
* [RipGrep (aka RG)](https://github.com/BurntSushi/ripgrep) - "ripgrep recursively searches directories for a regex pattern"

## Editor Integration

### Vim

See [find-string.vim](https://github.com/drmohundro/find-string.vim). Installation should be a simple `Plug 'drmohundro/find-string.vim'` if you [vim-plug](https://github.com/junegunn/vim-plug).

## Options

* `-pattern`
    * Specifies the text to find. Type a string or regular expression.
    * Required
* `-filter`
    * Specifies the file types to search in. The default is all file types (\*.\*).
* `-include`
    * Specifies the file types to search in. This allows you to search across multiple file types (i.e. \*.ps1,\*.psm1).
* `-excludeFiles`
    * Specifies the file types to exclude from searches. If set, this overrides any global defaults or configuration.
    * Comma-separated list of files to exclude from the search
* `-excludeDirectories`
    * Specifies the directories to exclude from searches. It really only makes sense for recursive searches. If set, this overrides any global defaults or configuration.
    * Comma-separated list of directories to exclude from the search
* `-path`
    * Specifies the path to the files to be searched. Wildcards are permitted. The default location is the local directory.
* `-recurse`
    * Gets the items in the specified path and in all child directies. This is the default.
* `-caseSensitive`
    * Makes matches case-sensitive. By default, matches are not case-sensitive.
* `-context`
    * Captures the specified number of lines before and after the line with the match. This allows you to view the match in context.
    * Example:
        * `find-string foo *.cs -context 2,3`
        * Would return a context of 2 lines before the match and 3 lines after the match
* `-passThru`
    * Passes the literal `MatchInfo` object representing the found match to the pipeline. By default, this cmdlet does not send anything through the object pipeline.
    * This is useful if you wish to do additional processing on the results, such as collect any matches in a regular expression that you searched for or to gather unique results.
* `-pipeOutput`
    * Sends all output along the object pipeline. By default, this command uses color to help with readability; however, this prevents the output from being piped to another command. If you wish to pipe the output of this command to something else, be sure to use this parameter.
    * This is useful if you wish to pipe the output to the clipboard.
    * Example:
        * `find-string foo *.cs -pipeOutput | clip`
* `-listMatchesOnly`
    * Returns all files that have matches existing in them, but doesn't display any of the matches themselves.


## Changelog

See [CHANGELOG](CHANGELOG.md) for a list of all changes and their corresponding versions.

## License

Find-String is released under the MIT license. See [LICENSE](LICENSE) for details.
