@echo off
setlocal EnableDelayedExpansion

bash --version >nul 2>&1
if errorlevel 1 (
    echo Error: bash not found. Install Git for Windows: https://git-scm.com/download/win
    exit /b 1
)

set "ARGS=%*"
set "ARGS=%ARGS:\=/%"
pushd "%~dp0"
bash install.sh %ARGS%
set _ERR=%ERRORLEVEL%
popd
exit /b %_ERR%
