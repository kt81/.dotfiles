# Windows software installer (entry point). Runs under Windows PowerShell 5.1
# or PowerShell 7. No admin required for the script itself: packages install
# via winget (which self-elevates per package as needed), and the symlinks in
# setup.core.ps1 rely on Developer Mode instead of an elevated shell.
#
# Declarative package set lives in windows/winget.json (edit that, not this file).
# Chocolatey is no longer used; winget covers apps + modern CLI, and HackGen
# Nerd Font is installed from its GitHub release in setup.core.ps1.

$repoRoot = $PSScriptRoot

if ($IsLinux -or $IsMacOS) {
    Write-Error "This script is for Windows only." -Category InvalidOperation
    Exit 1
}

function Test-Cmd { param($Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Update-SessionPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# ------------------------------------------------------------------
# winget (App Installer ships with Windows 10 2004+/11)
# ------------------------------------------------------------------
if (-not (Test-Cmd winget)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -Category NotInstalled
    Exit 1
}

Write-Host "Installing packages from windows/winget.json ..." -ForegroundColor Green
winget import --import-file "$repoRoot\windows\winget.json" `
    --accept-package-agreements --accept-source-agreements `
    --ignore-versions --ignore-unavailable --no-upgrade
Update-SessionPath

# ------------------------------------------------------------------
# Hand off to the pwsh 7 configuration script (installed above if it was missing)
# ------------------------------------------------------------------
$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwshCmd) { $pwsh = $pwshCmd.Source } else { $pwsh = "$env:ProgramFiles\PowerShell\7\pwsh.exe" }
if (-not (Test-Path $pwsh)) {
    Write-Error "PowerShell 7 (pwsh) was not found after install. Open a new terminal and run setup.core.ps1 manually." -Category NotInstalled
    Exit 1
}

& $pwsh -NoProfile "$repoRoot\setup.core.ps1"
