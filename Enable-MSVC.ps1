<##
.SYNOPSIS
    Dynamically imports the Microsoft C++ compiler (cl.exe) into your current PowerShell session.
.DESCRIPTION
    Locate and invoke the Visual Studio "Developer Command Prompt" entry script (Launch-VsDevShell.ps1)
    to configure PATH/INCLUDE/LIB so cl.exe and the MSVC tooling are available in the current terminal.
.EXAMPLE
    # Dot-source the script once in the session, then call the function:
    . .\Enable-MSVC.ps1
    Enable-MSVC

    # Or call directly (will import the function for the session, then run it):
    & .\Enable-MSVC.ps1; Enable-MSVC
#>
function Enable-MSVC {
    [CmdletBinding()]
    param()

    $vsDeveloperShell = $null
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"

    if (Test-Path $vswhere) {
        try {
            $installPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>$null
            if ($installPath) {
                $candidate = Join-Path $installPath "Common7\Tools\Launch-VsDevShell.ps1"
                if (Test-Path $candidate) {
                    $vsDeveloperShell = $candidate
                }
            }
        } catch {
            # vswhere may return non-zero in rare cases; ignore and fall back to hard-coded paths
        }
    }

    if (-not $vsDeveloperShell) {
        $possiblePaths = @(
            "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\Launch-VsDevShell.ps1",
            "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\Launch-VsDevShell.ps1"
        )
        $vsDeveloperShell = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    }

    if ($null -ne $vsDeveloperShell) {
        Write-Host "Initializing MSVC C++ Build Environment..." -ForegroundColor Yellow
        try {
            # dot-source the Launch-VsDevShell script into the current session and request 64-bit tools
            . $vsDeveloperShell -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
            Write-Host "Success! 'cl.exe' compiler is active in this terminal session." -ForegroundColor Green
        } catch {
            Write-Error "Failed to initialize Visual Studio Developer Shell: $_"
        }
    } else {
        Write-Error "Could not find Visual Studio Build Tools at any standard installation paths.\n" +
                    "If Visual Studio is installed to a custom location, pass the full path to Launch-VsDevShell.ps1 or add that location to this script."
    }
}

# If the file is executed directly (not dot-sourced), import the function into the session so the user can call it.
if ($MyInvocation.InvocationName -and $MyInvocation.InvocationName -ne '.') {
    Export-ModuleMember -Function Enable-MSVC | Out-Null
}
