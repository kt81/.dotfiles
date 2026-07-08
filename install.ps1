# Bootstrap for a fresh Windows host. Installs git if missing, clones the repo
# to ~/.dotfiles, then hands off to setup.ps1.
#
#   iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.ps1'))

$ErrorActionPreference = 'Stop'

$repo = 'https://github.com/kt81/.dotfiles.git'
$dest = Join-Path $HOME '.dotfiles'

function Test-Cmd { param($Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# 1. git (via winget; App Installer ships with Windows 10 2004+/11)
if (-not (Test-Cmd git)) {
    if (-not (Test-Cmd winget)) {
        throw "Neither git nor winget was found. Install 'App Installer' from the Microsoft Store, then re-run this script."
    }
    Write-Host "Installing Git..." -ForegroundColor Green
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
    # refresh PATH so git resolves in this same session
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# 2. clone (or best-effort update) the repo
if (Test-Path $dest) {
    Write-Host "~/.dotfiles already exists — updating." -ForegroundColor DarkGray
    try { git -C $dest pull --ff-only } catch { Write-Warning "Skipped update: $_" }
} else {
    Write-Host "Cloning $repo -> $dest" -ForegroundColor Green
    git clone $repo $dest
}

# 3. hand off to the real installer
& (Join-Path $dest 'setup.ps1')
