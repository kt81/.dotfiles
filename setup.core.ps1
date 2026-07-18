#!/usr/bin/env pwsh
#requires -PSEdition Core
# Configuration step (PowerShell 7+). Installs PS modules, a Nerd Font, and the
# symlinks that wire the tracked configs into place. Package installation lives
# in setup.ps1 (Windows) / setup.sh (macOS/Linux); this file only configures.
#
# No elevated shell required: symlinks use Developer Mode (Windows), and the
# font installs per-user. Only the optional Japanese system-font capability
# needs admin, and it is skipped with a note when the shell is not elevated.

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$ErrorActionPreference = "Stop"

# ====================================================================
# Settings and Utilities
# ====================================================================

$repoRoot = $PSScriptRoot
$linuxXdgData   = [string]::IsNullOrEmpty($env:XDG_DATA_HOME)   ? "$HOME/.local/share" : $env:XDG_DATA_HOME
$linuxXdgConfig = [string]::IsNullOrEmpty($env:XDG_CONFIG_HOME) ? "$HOME/.config"      : $env:XDG_CONFIG_HOME

function task { param($message) Write-Host -ForegroundColor Green    $message }
function skip { param($message) Write-Host -ForegroundColor DarkGray $message }
function Test-Cmd { param($Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Test-Admin {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Install (or update) a PowerShell module, preferring the modern PSResourceGet
# (bundled with pwsh 7.4+) and falling back to PowerShellGet v2.
function Install-Module2 {
    param([Parameter(Mandatory)][string] $Name)
    if (Test-Cmd Install-PSResource) {
        if (Get-Module -ListAvailable $Name) {
            task "Updating module: $Name"
            Update-PSResource -Name $Name -Scope CurrentUser -ErrorAction SilentlyContinue
        } else {
            task "Installing module: $Name"
            Install-PSResource -Name $Name -Scope CurrentUser -TrustRepository
        }
    } else {
        if (Get-Module -ListAvailable $Name) {
            task "Updating module: $Name"; Update-Module $Name -Scope CurrentUser
        } else {
            task "Installing module: $Name"; Install-Module $Name -Scope CurrentUser -Force
        }
    }
}

# Symlink a file. Never clobbers an existing real file (skips instead), so a
# user's own config is safe.
function linkNx {
    param(
        [string] $DestinationPath,
        [string] $FromPath,
        [bool]   $IsFullPath = $false
    )
    if (!$IsFullPath) { $FromPath = Join-Path $repoRoot $FromPath }
    task "Linking: $FromPath -> $DestinationPath"
    if (Test-Path $DestinationPath) { skip "Exists — leaving as-is."; return }
    $destDir = Split-Path $DestinationPath
    if ($destDir -and !(Test-Path $destDir)) { New-Item -ItemType Directory $destDir | Out-Null }
    New-Item -ItemType SymbolicLink -Path $DestinationPath -Target $FromPath | Out-Null
    Write-Host -ForegroundColor Blue "Link created."
}

# Symlink a directory (or replace a file), backing up anything already there
# that is not already our symlink. Used where we intentionally take ownership.
function linkForce {
    param([string] $DestinationPath, [string] $FromPath, [bool] $IsFullPath = $false)
    if (!$IsFullPath) { $FromPath = Join-Path $repoRoot $FromPath }
    task "Linking: $FromPath -> $DestinationPath"
    if (Test-Path $DestinationPath) {
        $item = Get-Item $DestinationPath -Force
        if ($item.LinkType -eq 'SymbolicLink') { skip "Symlink exists."; return }
        $bak = "$DestinationPath.bak-$(Get-Date -Format yyyyMMddHHmmss)"
        task "Backing up existing target -> $bak"
        Move-Item -LiteralPath $DestinationPath -Destination $bak
    }
    $destDir = Split-Path $DestinationPath
    if ($destDir -and !(Test-Path $destDir)) { New-Item -ItemType Directory $destDir | Out-Null }
    New-Item -ItemType SymbolicLink -Path $DestinationPath -Target $FromPath | Out-Null
    Write-Host -ForegroundColor Blue "Link created."
}

# Per-user install of HackGen Nerd Font from its GitHub release (no admin).
function Install-HackGenNerdFont {
    $userFontsKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Fonts'
    $have = @()
    if (Test-Path $userFontsKey) {
        $have = (Get-ItemProperty $userFontsKey).PSObject.Properties.Name | Where-Object { $_ -match 'HackGen.*NF' }
    }
    if ($have) { skip "HackGen Nerd Font already installed for this user."; return }

    task "Installing HackGen Nerd Font (from GitHub release)"
    try {
        $rel = Invoke-RestMethod 'https://api.github.com/repos/yuru7/HackGen/releases/latest' `
            -Headers @{ 'User-Agent' = 'dotfiles' }
        $asset = $rel.assets | Where-Object { $_.name -match 'HackGen_NF.*\.zip$' } | Select-Object -First 1
        if (-not $asset) { skip "No HackGen_NF asset in latest release; skipping."; return }

        $tmp = Join-Path $env:TEMP ([Guid]::NewGuid())
        New-Item -ItemType Directory $tmp | Out-Null
        $zip = Join-Path $tmp $asset.name
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip
        Expand-Archive $zip $tmp

        $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
        New-Item -ItemType Directory $fontDir -Force | Out-Null
        Get-ChildItem $tmp -Recurse -Filter *.ttf | ForEach-Object {
            $dest = Join-Path $fontDir $_.Name
            Copy-Item $_.FullName $dest -Force
            New-ItemProperty $userFontsKey -Name "$($_.BaseName) (TrueType)" -Value $dest `
                -PropertyType String -Force | Out-Null
        }
        Remove-Item $tmp -Recurse -Force
        Write-Host -ForegroundColor Blue "HackGen Nerd Font installed."
    } catch {
        skip "Font install skipped: $_"
    }
}

# ====================================================================
# Main
# ====================================================================

if ($IsWindows) {
    # Japanese system fonts (OS-level rendering). Needs admin; skip with a note
    # otherwise. This is separate from the HackGen terminal font below.
    $jpCap = Get-WindowsCapability -Online -Name 'Language.Fonts.Jpan~~~und-JPAN~0.0.1.0' -ErrorAction SilentlyContinue
    if ($jpCap -and $jpCap.State -ne 'Installed') {
        if (Test-Admin) {
            task "Enabling Windows capability: Japanese fonts"
            Add-WindowsCapability -Online -Name 'Language.Fonts.Jpan~~~und-JPAN~0.0.1.0'
        } else {
            skip "Japanese system fonts not installed (needs admin). Run elevated to add them."
        }
    }

    Install-HackGenNerdFont
}

# ---- PowerShell modules ----
# Prompt -> starship, dir jump -> zoxide, git status -> starship: posh-git and
# ZLocation are intentionally gone. Only line-editing helpers remain.
Install-Module2 PSReadLine
Install-Module2 PSFzf

# ---- Symlinks ----
# This script owns the symlinks on every OS it runs on (Windows always; unix
# whenever pwsh is present). Ensuring pwsh exists on a given host is that host's
# own responsibility.
task "Creating symbolic links for tracked configs."
$psProfile = "Microsoft.PowerShell_profile.ps1"
if ($IsWindows) {
    $psProfileDest = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell" $psProfile
    $nvimDest      = Join-Path $env:LOCALAPPDATA "nvim"
    $ideavimrcDest = "~/_ideavimrc"
    $miseConfDest  = Join-Path $env:USERPROFILE ".config\mise\conf.d\dotfiles.toml"
    $ovConfDest    = Join-Path $env:USERPROFILE ".config\ov\config.yaml"
} else {
    $psProfileDest = Join-Path $linuxXdgConfig "powershell" $psProfile
    $nvimDest      = Join-Path $linuxXdgConfig "nvim"
    $ideavimrcDest = "~/.ideavimrc"
    $miseConfDest  = Join-Path $linuxXdgConfig "mise/conf.d/dotfiles.toml"
    $ovConfDest    = Join-Path $linuxXdgConfig "ov/config.yaml"
}

linkNx    $psProfileDest $psProfile
linkForce $nvimDest      "nvim"            # whole nvim config dir (lazy.nvim)
linkNx    $ideavimrcDest .ideavimrc
linkNx    ~/.tmux.conf   .tmux.conf
# mise: drop-in so `mise use -g` never dirties the repo (see mise/config.toml)
linkNx    $miseConfDest  "mise/config.toml"
# ov pager config (less-style keybinds; generated via `ov --generate-config=less`)
linkNx    $ovConfDest    "ov/config.yaml"

# Windows Terminal settings are deliberately NOT managed here. Terminal rewrites
# settings.json itself (reordering keys, adding compat flags) and regenerates
# profiles from whatever WSL distros / apps happen to be installed, so the file
# is inherently machine-specific. Its fragment mechanism can't express
# profiles.defaults, actions or globals either — so it stays a local file.

# ---- git: make the local ~/.gitconfig include the managed config ----
# Append the [include] if it isn't there yet (creating the file if needed).
# Appended last so the managed settings win over any legacy local duplicates.
task "Configuring git (include managed config)"
$gitconfig = Join-Path $HOME ".gitconfig"
$inc = ($repoRoot -replace '\\', '/') + "/gitconfig"
if ((Test-Path $gitconfig) -and ((Get-Content $gitconfig -Raw) -match [regex]::Escape($inc))) {
    skip "~/.gitconfig already includes the managed config."
} else {
    "`n[include]`n`tpath = $inc" | Add-Content -Path $gitconfig -Encoding utf8
    task "Added [include] path = $inc to ~/.gitconfig"
}

# ---- mise: install the tools declared in the tracked conf.d drop-in (keifu, ...) ----
if (Test-Cmd mise) {
    task "Installing mise tools (mise install)"
    try { mise install } catch { skip "mise install skipped: $_" }

    # Put mise's shims on PATH. `mise activate` (in the PowerShell profile) only
    # covers shells that source it, so without this, mise-managed tools are
    # invisible to Windows PowerShell 5.1, IDEs, and anything launched from the
    # GUI. The shims still resolve per-project versions; activate takes
    # precedence in interactive pwsh.
    if ($IsWindows) {
        $shims = Join-Path $env:LOCALAPPDATA "mise\shims"
        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if (($userPath -split ';') -notcontains $shims) {
            [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $shims), 'User')
            task "Added mise shims to the user PATH: $shims"
        } else {
            skip "mise shims already on PATH."
        }
    }
}

# ---- nvim: let lazy.nvim bootstrap itself and sync plugins ----
if (Test-Cmd nvim) {
    task "Syncing Neovim plugins (lazy.nvim)"
    try { nvim --headless "+Lazy! sync" +qa } catch { skip "Plugin sync skipped: $_" }
} else {
    skip "nvim not on PATH yet — open nvim once to let lazy.nvim install plugins."
}

Write-Host -ForegroundColor Yellow "Done!!!"
