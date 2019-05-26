$moduleName = "DemoModule"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Get-Module $moduleName | Remove-Module 
Import-Module ("{0}\$moduleName.psd1" -f (Split-Path $here -Parent)) -PassThru

Describe "Get-DemoModuleName parameter tests" -Tags Unit {

    Context "Parameter valid - Parameter Set: Default" {
        $TestCases = @(
            @{
                Expected    = 'Module Test'
            }
        )
        It "Given nothing it should return <Expected>" -TestCases $TestCases {
            param(
                $Expected
            )
            Get-DemoModuleName | Should Be $Expected
        }
    }
}