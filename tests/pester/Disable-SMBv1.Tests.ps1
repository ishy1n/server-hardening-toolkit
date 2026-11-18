# tests/pester/Disable-SMBv1.Tests.ps1 — smoke tests for the SMBv1 script
BeforeAll {
    $repoRoot   = Resolve-Path "$PSScriptRoot/../.."
    $scriptPath = Join-Path $repoRoot 'windows/Disable-SMBv1.ps1'
    $modulePath = Join-Path $repoRoot 'windows/lib/Common.psm1'
}

Describe 'Disable-SMBv1.ps1' {
    It 'exists' {
        Test-Path $scriptPath | Should -BeTrue
    }

    It 'uses the shared Common.psm1 module' {
        (Get-Content $scriptPath -Raw) | Should -Match 'Common\.psm1'
    }

    It 'references SMB1 registry value' {
        (Get-Content $scriptPath -Raw) | Should -Match "LanmanServer"
        (Get-Content $scriptPath -Raw) | Should -Match "'SMB1'"
    }

    It 'requires -DryRun or -Apply' {
        { & $scriptPath } | Should -Throw
    }
}

Describe 'Common.psm1' {
    It 'exports Write-HardeningLog and Assert-Administrator' {
        Import-Module $modulePath -Force
        (Get-Command Write-HardeningLog).Name  | Should -Be 'Write-HardeningLog'
        (Get-Command Assert-Administrator).Name | Should -Be 'Assert-Administrator'
    }
}
