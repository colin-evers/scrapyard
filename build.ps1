# Build script for the sample project
# Usage:
#   .\build.ps1           # runs using the current PowerShell session
#   . .\Enable-MSVC.ps1  # if you haven't dot-sourced Enable-MSVC in this session
#   Enable-MSVC           # initialize MSVC environment (or let the script do it)

[CmdletBinding()]
param(
    [switch]$SkipInit
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir

if (-not $SkipInit) {
    if (-not (Get-Command Enable-MSVC -ErrorAction SilentlyContinue)) {
        $possibleEnable = Join-Path $scriptDir 'scripts\Enable-MSVC.ps1'
        if (Test-Path $possibleEnable) {
            . $possibleEnable
        } elseif (Test-Path (Join-Path $scriptDir 'Enable-MSVC.ps1')) {
            # backward compatibility: older location
            . (Join-Path $scriptDir 'Enable-MSVC.ps1')
        }
    }
    if (Get-Command Enable-MSVC -ErrorAction SilentlyContinue) {
        Enable-MSVC
    } else {
        Write-Host "Enable-MSVC function not found; attempting to run cl.exe directly (may fail if environment is not configured)" -ForegroundColor Yellow
    }
}

# Ensure output directory exists
$binDir = Join-Path $scriptDir 'bin'
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

# Compile with sensible defaults: enable exception handling and optimizations
$src = Join-Path $scriptDir 'src\main.cpp'
$exe = Join-Path $binDir 'main.exe'

cl /EHsc /nologo /W3 /O2 /Fe:$exe $src

Pop-Location
