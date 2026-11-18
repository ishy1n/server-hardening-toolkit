# windows/lib/Common.psm1 — shared helpers for Windows hardening scripts
Set-StrictMode -Version Latest

function Write-HardeningLog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [string]$Mode = 'info',
        [string]$LogPath = "$env:ProgramData\hardening.log"
    )
    $ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $line = "[$ts] [$Mode] $Message"
    Write-Host $line -ForegroundColor Cyan
    try {
        $dir = Split-Path -Parent $LogPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Add-Content -Path $LogPath -Value $line -ErrorAction Stop
    } catch {
        Write-Warning "Could not write log: $_"
    }
}

function Assert-Administrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as Administrator."
    }
}

Export-ModuleMember -Function Write-HardeningLog, Assert-Administrator
