# Changelog

This project adheres to [Semantic Versioning](http://semver.org).

## [1.7.2] - 2018-01-25
### Changed

- Changed tags for better support in the [PowerShellGallery](https://www.powershellgallery.com).

## [1.7.1] - 2015-07-14
### Added

- Added `Find-String.psd1` for support with the [PowerShellGallery](https://www.powershellgallery.com).

### Changed

- Modified script to align more closely with recommendations from [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer/).

## [1.7.0] - 2015-06-29
### Added

- Added `listMatchesOnly` which will display all files that have matches in them (but won't actually display the matches).

## [1.6.1] - 2012-04-15
### Fixed

- Added a `Get-Module` check to prevent double imports.

## [1.6.0] - 2012-04-03
### Added

- Added support for installation via PsGet.

## [1.5.0] - 2011-12-15
### Changed

- Converted `Find-String` to be a PowerShell module

## [1.4.2] - 2011-09-17
### Fixed

- Fixed an issue related to a missing pipe character (it worked in PowerShell v2, but failed in PowerShell v3)

## [1.4.1] - 2010-11-19
### Fixed

- Fixed an issue with color output in PowerShell ISE (only outputs with foreground or background color if they're set)

## [1.4.0] - 2010-09-01
### Added

- Added initial file and directory exclusion parameters (`-excludeFiles` and `-excludeDirectories`)

## [1.3.0] - 2010-04-20
### Added

- Added `-include` parameter in addition to the existing `-filter` parameter.

## [1.2.0] - 2010-02-16
### Added

- Added `-passThru` parameter, which bypasses any formatting and allows for additional operations in the PowerShell pipeline (such as working with the `MatchInfo` object)
- Resolves [issue #1](https://github.com/drmohundro/Find-String/issues/1)

## [1.1.0] - 2009-08-06
### Added

- Added support for `-Path` parameter, which allows for searching in a directory other than the current directory.

## 1.0.0 - 2009-06-11
### Added

- Initial version of `Find-String` based on [Wes Haggard's original version](http://weblogs.asp.net/whaggard/powershell-script-to-find-strings-and-highlight-them-in-the-output).
- Requires PowerShell v2.

[1.7.1]: https://github.com/drmohundro/Find-String/compare/1.7.0...1.7.1
[1.7.0]: https://github.com/drmohundro/Find-String/compare/1.6.1...1.7.0
[1.6.1]: https://github.com/drmohundro/Find-String/compare/1.6.0...1.6.1
[1.6.0]: https://github.com/drmohundro/Find-String/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/drmohundro/Find-String/compare/1.4.2...1.5.0
[1.4.2]: https://github.com/drmohundro/Find-String/compare/1.4.1...1.4.2
[1.4.1]: https://github.com/drmohundro/Find-String/compare/1.4.0...1.4.1
[1.4.0]: https://github.com/drmohundro/Find-String/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/drmohundro/Find-String/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/drmohundro/Find-String/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/drmohundro/Find-String/compare/1.0.0...1.1.0
