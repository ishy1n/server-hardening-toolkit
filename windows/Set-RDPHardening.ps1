<#
.SYNOPSIS
    Hardens RDP: NLA required, high encryption, idle timeout, drive/printer redirection off.
.PARAMETER DryRun
.PARAMETER Apply
.EXAMPLE
    .\Set-RDPHardening.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/lib/Common.psm1" -Force

if (-not ($DryRun -or $Apply)) { throw "Specify -DryRun or -Apply." }
$mode = if ($DryRun) { 'dry-run' } else { 'apply' }
Assert-Administrator

function Set-RegValue {
    param([string]$Path,[string]$Name,[object]$Value,[string]$Type = 'DWord')
    Write-HardeningLog -Message "[$mode] SET $Path\$Name = $Value" -Mode $mode
    if ($mode -eq 'apply') {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    }
}

Write-HardeningLog -Message "Starting RDP hardening ($mode)" -Mode $mode

$ts = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdp = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

# CIS WS2022 v5.0.0 — 2.3.11.x
# NLA required (2.3.11.1.1)
Set-RegValue "$ts\WinStations\RDP-Tcp" 'UserAuthentication' 1
# High encryption (2.3.11.2.1)
Set-RegValue "$ts\WinStations\RDP-Tcp" 'MinEncryptionLevel' 3
# Disable drive redirection (2.3.11.3.1)
Set-RegValue "$rdp" 'fDisableCdm' 1
# Disable printer redirection (2.3.11.3.2)
Set-RegValue "$rdp" 'fDisableCpm' 1
# Idle session timeout 15 min (2.3.11.5.1)
Set-RegValue "$ts" 'MaxIdleTime' 900000
# Disconnect disconnected sessions after 1 min (2.3.11.5.2)
Set-RegValue "$ts" 'MaxDisconnectionTime' 60000

if ($mode -eq 'apply') {
    Write-HardeningLog -Message "RDP hardening applied." -Mode $mode
} else {
    Write-HardeningLog -Message "[dry-run] No changes written." -Mode $mode
}
