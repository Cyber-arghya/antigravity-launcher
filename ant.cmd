@echo off
setlocal enabledelayedexpansion

:: ========================================================
:: Antigravity IDE Quick Launcher for CMD & PowerShell
:: Supports:
::   ant .
::   ant -n .
::   ant "C:\path\to\folder"
:: ========================================================

set "NEW_WINDOW="
set "TARGET="

:parse_args
if "%~1"=="" goto done_args
if /i "%~1"=="-n" (
    set "NEW_WINDOW=-n"
    shift
    goto parse_args
)
if /i "%~1"=="--new-window" (
    set "NEW_WINDOW=-n"
    shift
    goto parse_args
)
if not defined TARGET (
    set "TARGET=%~1"
) else (
    set "TARGET=!TARGET! %~1"
)
shift
goto parse_args

:done_args
if not defined TARGET set "TARGET=."

:: 1. Check if antigravity-ide is directly available in PATH
where antigravity-ide.cmd >nul 2>&1
if !ERRORLEVEL! equ 0 (
    call antigravity-ide.cmd !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

:: 2. Check User LocalAppData
if exist "%LOCALAPPDATA%\Programs\Antigravity IDE\bin\antigravity-ide.cmd" (
    call "%LOCALAPPDATA%\Programs\Antigravity IDE\bin\antigravity-ide.cmd" !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

:: 3. Check System Program Files (64-bit)
if exist "%ProgramFiles%\Antigravity IDE\bin\antigravity-ide.cmd" (
    call "%ProgramFiles%\Antigravity IDE\bin\antigravity-ide.cmd" !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

:: 4. Check System Program Files (x86)
if exist "%ProgramFiles(x86)%\Antigravity IDE\bin\antigravity-ide.cmd" (
    call "%ProgramFiles(x86)%\Antigravity IDE\bin\antigravity-ide.cmd" !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

:: 5. Direct Exe fallback
if exist "%LOCALAPPDATA%\Programs\Antigravity IDE\Antigravity IDE.exe" (
    start "" "%LOCALAPPDATA%\Programs\Antigravity IDE\Antigravity IDE.exe" !NEW_WINDOW! "!TARGET!"
    exit /b 0
)

echo [ERROR] Antigravity IDE could not be found!
echo Please verify that Antigravity IDE is installed.
exit /b 1
