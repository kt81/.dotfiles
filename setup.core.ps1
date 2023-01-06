#!/usr/bin/env pwsh
#requires -PSEdition Core
# Only works on PowerShell 7.x or above

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$ErrorActionPreference = "Stop"

# ====================================================================
#
# Settings and Utilities
#
# ====================================================================

$repoRoot = $PSScriptRoot
$linuxXdgData = ([string]::IsNullOrEmpty($env:XDG_DATA_HOME) ? "$HOME/.local/share" : $env:XDG_DATA_HOME);
$linuxXdgConfig = ([string]::IsNullOrEmpty($env:XDG_CONFIG_HOME) ? "$HOME/.config" : $env:XDG_CONFIG_HOME);

function task {
    param($message)
    Write-Host -ForegroundColor Green "$message"
}
function skip {
    param($message)
    Write-Host -ForegroundColor DarkGray "$message"
}

function doTested {
    param(
        [scriptblock] $TestScript,
        [scriptblock] $DoScript,
        [string] $SkippedResultMessage = "Skipped.",
        [scriptblock] $ElseScript = $null
    )
    $result = ($TestScript.Invoke()) -and ($DoScript.Invoke())
    if ($result) {
        Return $result
    } elseif ($ElseScript -ne $null) {
        Return ($ElseScript.Invoke())
    } else {
        skip $SkippedResultMessage
    }
}
function installOrUpdateModule {
    param(
        [parameter(mandatory=$true)]
        [string] $Target,
        [switch] $Force = $false
    )
    if ($Force -or !(Get-Module -ListAvailable $Target)) {
        $cmd = "Install-Module $Target -Scope CurrentUser -Force"
    } else {
        $cmd = "Update-Module $Target -Scope CurrentUser"
    }
    Write-Host $cmd
    Invoke-Expression $cmd
}
function linkNx {
    param(
        [string] $DestinationPath,
        [string] $FromPath,
        [string] $SkippedResultMessage = "File exists.",
        [bool] $NoDirCreation = $false,
        [bool] $IsFullPath = $false
    )
    if (!$IsFullPath) {
        $FromPath = Join-Path $repoRoot $FromPath
    }
    task "Linking: $FromPath -> $DestinationPath"
    $destDir = Split-Path $DestinationPath
    $name = Split-Path -Leaf $DestinationPath
    if (!$NoDirCreation -and !(Test-Path $destDir)) {
        New-Item -ItemType Directory $destDir
    }
    
    $result = doTested {!(Test-Path $DestinationPath)} {New-Item -ItemType SymbolicLink -Path $destDir -Name $name -Target $FromPath }
    if ($result) {
        Write-Host -ForegroundColor Blue "Link created."
    }
}

# ====================================================================
#
# Main
#
# ====================================================================

if ($IsWindows) {
    # Admin privilege is required in Windows to create symlinks (if not in dev mode)
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Please run this script as Admin." -Category PermissionDenied
        Exit 1
    }

    Write-Host -ForegroundColor Green 'Enabling windows feature: Japanese Fonts'
    doTested {!(DISM.exe /Online /Get-CapabilityInfo /CapabilityName:Language.Fonts.Jpan~~~und-JPAN~0.0.1.0 | Select-String -Pattern "インストール済み|Installed")} {
        DISM.exe /Online /Add-Capability /CapabilityName:Language.Fonts.Jpan~~~und-JPAN~0.0.1.0
    }

    task "Installing: oh-my-posh"
    doTested {!(Get-Command vim -ErrorAction SilentlyContinue)} {
        winget install oh-my-posh --accept-package-agreements
    } # -ElseScript { winget upgrade oh-my-posh --accept-package-agreements }
}

task "Installing: posh-git"
installOrUpdateModule posh-git
task "Installing: PSReadLine"
installOrUpdateModule PSReadLine -Force
task "Installing: PSFzf"
installOrUpdateModule PSFzf
task "Installing: ZLocation (z)"
installOrUpdateModule ZLocation

task "Creating symbolic links for various settings."
$psProfile = "Microsoft.PowerShell_profile.ps1"
if ($IsWindows) {
    $psProfileDest = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell" $psProfile
    $nvimInitDest = Join-Path $env:LOCALAPPDATA "/nvim/init.vim"
    $ideavimrcDest = "~/_ideavimrc"
} else {
    $psProfileDest = Join-Path $linuxXdgConfig "powershell" $psProfile
    $nvimInitDest = Join-Path $linuxXdgConfig "/nvim/init.vim"
    $ideavimrcDest = "~/.ideavimrc"
}
echo $ideavimrcDest

linkNx $psProfileDest $psProfile
linkNx ~/.posh-theme.json .posh-theme.json
linkNx ~/.vimrc .vimrc
linkNx $nvimInitDest .vimrc
linkNx $ideavimrcDest .ideavimrc
#linkNx ~/.tmux.conf .tmux.conf

task "Installing: vim-plug"
$plugInstalled = $false
if ($IsWindows) {
    $nvimAlPath = "$env:LOCALAPPDATA/nvim-data/site/autoload/plug.vim";
    $vimAlPath = "$HOME/vimfiles/autoload/plug.vim"
} else {
    $nvimAlPath = $linuxXdgData + "/nvim/site/autoload/plug.vim"
    $vimAlPath = "$HOME/.vim/autoload/plug.vim"
}
if (!(Test-Path $nvimAlPath)) {
    Invoke-WebRequest -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
        New-Item $nvimAlPath -Force
    nvim --headless +PlugInstall +qall
    $plugInstalled = $true
}
if ((Get-Command vim -ErrorAction SilentlyContinue) -and !(Test-Path $vimAlPath)) {
    New-Item -ItemType File $vimAlPath -Force
    Copy-Item $nvimAlPath $vimAlPath -Force
    vim +'PlugInstall --sync' +qa
    $plugInstalled = $true
}
if (!$plugInstalled) {
    skip "vim-plug has already been installed."
}

Write-Host -ForegroundColor Yellow -Object "Done!!!"
