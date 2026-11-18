<#
.SYNOPSIS
    Disables SMBv1 and enforces SMB signing/encryption (CIS-aligned).
.PARAMETER DryRun
    Preview changes without applying.
.PARAMETER Apply
    Apply changes.
.EXAMPLE
    .\Disable-SMBv1.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot/lib/Common.psm1" -Force

if (-not ($DryRun -or $Apply)) {
    throw "Specify -DryRun or -Apply."
}
$mode = if ($DryRun) { 'dry-run' } else { 'apply' }
Assert-Administrator

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord'
    )
    Write-HardeningLog -Message "[$mode] SET $Path\$Name = $Value" -Mode $mode
    if ($mode -eq 'apply') {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    }
}

Write-HardeningLog -Message "Starting SMB hardening ($mode)" -Mode $mode

# CIS Windows Server 2022 v5.0.0 — 2.3.1.1
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'SMB1' 0
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'SMB1' 0
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'RequireSecuritySignature' 1
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'EnableSecuritySignature' 1
Set-RegValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'EncryptData' 1

if ($mode -eq 'apply') {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
    if ($feature -and $feature.State -eq 'Enabled') {
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart | Out-Null
        Write-HardeningLog -Message "SMB1Protocol feature disabled. Reboot may be required." -Mode $mode
    }
    Write-HardeningLog -Message "SMB hardening applied. Verify: Get-SmbServerConfiguration" -Mode $mode
} else {
    Write-HardeningLog -Message "[dry-run] No changes written." -Mode $mode
}
