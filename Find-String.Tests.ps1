BeforeAll {
    Import-Module $PSScriptRoot/Find-String
}

Describe "Find-String" {
    Context "Write-Host Out-ColorMatchInfo" {
        It "MatchInfo Context and Colors" {
            InModuleScope Find-String {
                Mock Write-Host { }

                Get-ChildItem -Path TestData | select-string test | Out-ColorMatchInfo

                Should -Invoke Write-Host -ParameterFilter {
                    $object -match "test.log" -and $ForegroundColor -eq "Green"
                }
                
                Should -Invoke Write-Host -ParameterFilter {
                    $object -eq "2:" -and $noNewLine
                }
                
                Should -Invoke Write-Host -ParameterFilter {
                    $object -eq "this is a " -and $noNewLine
                }

                Should -Invoke Write-Host -Times 2 -ParameterFilter {
                    $object -eq "test" -and $ForegroundColor -eq "Black" -and $backgroundColor -eq "Yellow" -and $noNewLine
                }
                
                Should -Invoke Write-Host -ParameterFilter {
                    $object -eq "--"
                }
                
                Should -Invoke Write-Host -ParameterFilter {
                    $object -eq "3:" -and $noNewLine
                }
                
                Should -Invoke Write-Host -ParameterFilter {
                    $object -eq "this is another "
                }
            }
        }
    }

    # It "Excludes files and directories" {
    #     $result = Find-String -pattern "test" -path "C:\test" -excludeFiles "*.log" -excludeDirectories "temp"
    #     $result | Should -Not -Contain "C:\test\temp\test.txt"
    #     $result | Should -Contain "C:\test\test.log"
    # }

    # It "Returns only matching file names" {
    #     $result = Find-String -pattern "test" -path "C:\test" -listMatchesOnly
    #     $result | Should -Contain "test.txt"
    #     $result | Should -Not -Contain "test.log"
    # }
}