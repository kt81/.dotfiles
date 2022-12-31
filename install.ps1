$tmpFile = "dotrile-tmp.zip"
$expectedPath = ".dotfiles-master"

# see https://zenn.dev/awtnb/articles/72762324b9fda6
function Use-TempDir {
    param (
        [ScriptBlock]$script
    )
    $tmp = $env:TEMP | Join-Path -ChildPath $([System.Guid]::NewGuid().Guid)
    New-Item -ItemType Directory -Path $tmp | Push-Location
    "working on tempdir: {0}" -f $tmp | Write-Host -ForegroundColor DarkBlue
    $result = Invoke-Command -ScriptBlock $script
    Pop-Location
    $tmp | Remove-Item -Recurse
    return $result
}

Use-TempDir {
    Invoke-WebRequest https://github.com/kt81/.dotfiles/archive/refs/heads/master.zip -OutFile $tmpFile
    Expand-Archive $tmpFile .
    cd $expectedPath

}

# https://zenn.dev/nobokko/articles/idea_winget_wsb