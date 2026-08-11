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
$rootDir = Split-Path $scriptDir -Parent
Push-Location $rootDir

if (-not $SkipInit) {
    if (-not (Get-Command Enable-MSVC -ErrorAction SilentlyContinue)) {
        # Prefer an Enable-MSVC next to this script, or fall back to the parent folder for compatibility
        $possibleEnableLocal = Join-Path $scriptDir 'Enable-MSVC.ps1'
        $possibleEnableParent = Join-Path $rootDir 'Enable-MSVC.ps1'
        if (Test-Path $possibleEnableLocal) {
            . $possibleEnableLocal
        } elseif (Test-Path $possibleEnableParent) {
            . (Resolve-Path $possibleEnableParent)
        }
    }
    if (Get-Command Enable-MSVC -ErrorAction SilentlyContinue) {
        Enable-MSVC
    } else {
        Write-Host "Enable-MSVC function not found; attempting to run cl.exe directly (may fail if environment is not configured)" -ForegroundColor Yellow
    }
}

# Ensure output directory exists
$binDir = Join-Path $rootDir 'bin'
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

# Compile with sensible defaults: enable exception handling and optimizations
$src = Join-Path $rootDir 'src\main.cpp'
$exe = Join-Path $binDir 'main.exe'

cl /EHsc /nologo /W3 /O2 /Fe:$exe /Fo:"$binDir\" $src
$compileExitCode = $LASTEXITCODE
if ($compileExitCode -eq 0) {
    Write-Host "Compile succeeded."
} else {
    Write-Host "Compile failed with exit code $compileExitCode" -ForegroundColor Red
}
return $compileExitCode

Pop-Location
