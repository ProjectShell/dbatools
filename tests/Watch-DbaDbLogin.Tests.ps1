<#
    The below statement stays in for every test you build.
#>
$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

<#
    Unit test is required for any command added
#>
Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'SqlInstance','Database','Table','SqlCredential','SqlCms','ServersFromFile','EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}
<#
    Integration test are custom to the command you are writing it for,
        but something similar to below should be included if applicable.

    The below examples are by no means set in stone and there are already
        a number of test that you can pull examples from in how they are done.
#>
<#
Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    $testFile = 'C:\temp\Servers.txt'
    $tableName = 'dbatoolsciwatchdblogin'
    $databaseName = 'master'
    if (Test-Path $testFile) {
        Remove-Item $testFile -Force
    }
    $script:instance1, $script:instance2 | Out-File $testFile
    AfterAll {
        $null = (Connect-DbaInstance -SqlInstance $script:instance1).Databases[$databaseName].Query("DROP TABLE $tableName")
    }
    Context "Command actually works" {
        Watch-DbaDbLogin -SqlInstance $script:instance1 -Database $databaseName -Table $tableName -ServersFromFile $testFile -EnableException
        $result = Get-DbaDbTable -SqlInstance $script:instance1 -Database $databaseName -Table $tableName -IncludeSystemDBs
        It "Should have created table $tableName in database $databaseName" {
            $result.Name | Should Be $tableName
        }
        It "Should have data in table $tableName in database $databaseName" {
            $result.Count | Should BeGreaterThan 0
        }
    }
}
#>