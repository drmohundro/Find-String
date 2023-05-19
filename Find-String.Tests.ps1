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

        It "Shouldn't Call Write-Host if PipeOutput is Used" {
            $results = Get-ChildItem -Path TestData | select-string test | Out-ColorMatchInfo -pipeOutput

            $results.Length | Should -Be 2

            $matchInfoResult = $results[0] -split '\r?\n'
            $textOutput = $results[1] -split '\r?\n'

            $matchInfoResult[0] | Should -Be ""
            $matchInfoResult[1] | Should -Match "test.log"
            $matchInfoResult[2] | Should -Match "2:this is a test"
            $matchInfoResult[3] | Should -Be ""

            $textOutput[0] | Should -Be ""
            $textOutput[1] | Should -Match "test.log"
            $textOutput[2] | Should -Be "2:this is a test"
            $textOutput[3] | Should -Be "--"
            $textOutput[4] | Should -Be "3:this is another test"
            $textOutput[5] | Should -Be ""
        }
    }
}