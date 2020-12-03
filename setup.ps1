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
    # prefer scoop
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    # If installation failed, check if you are using ESET.
}

scoop bucket add versions
scoop install 7zip dotnet-sdk git git-lfs neovim-nightly pwsh sudo win32-openssh

pwsh $repoRoot\git.ps1 
pwsh $repoRoot\setup.common.ps1