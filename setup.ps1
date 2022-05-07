# for windows (PowerShell 5.1 <=)

$repoRoot = $PSScriptRoot

if ($IsLinux -or $IsMacOS) {
    # There's no $IsWindows definition on old PowerShell
    Write-Error "This script should be run on Windows only." -Category InvalidOperation
    Exit 1
}

# Check privilege
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Admin." -Category PermissionDenied
    Exit 1
}

if (!(Get-Command choco -ErrorAction SilentlyContinue) -and !(Get-Command scoop -ErrorAction SilentlyContinue)) {
    # prefer chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # to make `refreshenv` works immediately
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
}

# Winget Packages 
winget upgrade "App Installer" -s msstore --accept-package-agreements
winget install Microsoft.WindowsTerminal --accept-package-agreements
winget install Microsoft.VisualStudioCode --accept-package-agreements
winget install M2Team.NanaZip --accept-package-agreements
winget install -e --id JetBrains.Toolbox --accept-package-agreements

# Chocolatey Packages
if (Get-Command choco -ErrorAction SilentlyContinue) {
    # Essentials
    choco install -y git git-lfs dotnet-sdk pwsh gsudo openssh make
    # Util
    choco install -y `
        ctrl2cap fd fzf ripgrep ntop.portable bottom `
        shellcheck `
        font-hackgen font-hackgen-nerd
    # Pre packages
    choco install -y --pre neovim

    refreshenv

    $pwsh = "C:\Program Files\PowerShell\7\pwsh.exe"
} else {
    # Pray that pwsh exists in the PATH
    $pwsh = "pwsh"
}

& $pwsh $repoRoot\git.ps1 
& $pwsh $repoRoot\setup.core.ps1
