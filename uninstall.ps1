<#
.SYNOPSIS
    Uninstalls .principles assets via bash.
.DESCRIPTION
    Requires bash on PATH (e.g. Git for Windows: https://git-scm.com/download/win).
    All arguments are forwarded to uninstall.sh unchanged.
    Use forward slashes or relative paths for directory arguments.
.EXAMPLE
    .\uninstall.ps1 claude
    .\uninstall.ps1 copilot ~/projects/my-app
    .\uninstall.ps1 all .
#>

bash --version 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'bash not found. Install Git for Windows: https://git-scm.com/download/win'
    exit 1
}

$fixedArgs = $args | ForEach-Object {
    if ($_ -match '^([A-Za-z]):[/\\](.*)$') {
        $drive = $Matches[1].ToLower()
        $rest  = $Matches[2] -replace '\\', '/'
        if (Get-Command wsl -ErrorAction SilentlyContinue) { "/mnt/$drive/$rest" }
        else { "/$drive/$rest" }
    } else { $_ }
}
$safeArgs = $fixedArgs | ForEach-Object { "'" + ($_ -replace "'", "'\\''") + "'" }
Push-Location $PSScriptRoot
bash -c "bash uninstall.sh $($safeArgs -join ' ')"
$exit = $LASTEXITCODE
Pop-Location
exit $exit
