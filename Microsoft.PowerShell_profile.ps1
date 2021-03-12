Import-Module posh-git
Import-Module oh-my-posh
Import-Module z
Set-PoshPrompt -Theme ~/.posh-theme.json
Set-PSReadlineOption -EditMode vi

Set-PSReadlineOption -ViModeIndicator Script -ViModeChangeHandler {
    Param($mode)
    $Env:SHELL_VI_MODE = $mode
}

# posh-git settings
$global:GitPromptSettings.AutoRefreshIndex = $false

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion

Set-Alias vim nvim
Set-Alias vi nvim

if (Test-Path ~/.profile.mine.ps1) {
    . ~/.profile.mine.ps1
    Write-Output "Local profile has been loaded: ~/.profile.mine.ps1"
}
