@echo off
setlocal ENABLEDELAYEDEXPANSION

rem Genesis setup script (Windows)
rem Creates a new project folder and copies the chosen Genesis profile into it.

set "SCRIPT_DIR=%~dp0"

echo.
echo Project Generation System - Genesis Setup
echo ========================================
echo This will create or prepare a project folder and place
echo the Genesis files inside it.
echo From there, you'll open that folder in your AI tool and run
echo "read GENESIS.md" once to create the Project OS.
echo
echo You can enter a NEW folder name (it will be created),
echo or point to an EXISTING folder (and we will add Genesis files there).
echo.

:ask_project
set "PROJECT_NAME="
set /p PROJECT_NAME=What should we call your project folder? (new or existing): 
if "%PROJECT_NAME%"=="" (
    echo Please enter a non-empty folder name.
    goto ask_project
)

set "TARGET_DIR=%CD%\%PROJECT_NAME%"

if exist "%TARGET_DIR%\" (
    echo.
    echo The folder "%PROJECT_NAME%" already exists.
    choice /M "Use this existing folder and add Genesis files to it?"
    if errorlevel 2 goto ask_project
) else (
    mkdir "%TARGET_DIR%"
)

echo.
echo How do you expect to use this project?
echo   [1] Light  - smaller or short-lived project
echo               - simple OS (2 files), ideal for quick tools, experiments, solo work
echo   [2] Heavy  - ongoing or multi-developer project
echo               - full OS (rules, context, workflows, schema, changelog)
echo.
echo This only changes how the AI Project OS is organised.
echo In both cases, Genesis will ask detailed questions about your project
echo and tailor the OS to your answers before creating any files.

:ask_profile
set "PROFILE="
set /p PROFILE=Enter 1 or 2: 
if "%PROFILE%"=="1" (
    set "PROFILE_NAME=Light"
    set "PROFILE_DIR=%SCRIPT_DIR%genesis-light-v1"
) else if "%PROFILE%"=="2" (
    set "PROFILE_NAME=Heavy"
    set "PROFILE_DIR=%SCRIPT_DIR%genesis-heavy-v1"
) else (
    echo Please enter 1 for Light or 2 for Heavy.
    goto ask_profile
)

if not exist "%PROFILE_DIR%\GENESIS.md" (
    echo.
    echo ERROR: Could not find GENESIS.md in "%PROFILE_DIR%".
    echo Make sure the genesis-light-v1 and genesis-heavy-v1 folders
    echo are located next to this script.
    goto :eof
)

echo.
echo Creating project "%PROJECT_NAME%" with %PROFILE_NAME% profile...

copy /Y "%PROFILE_DIR%\GENESIS.md" "%TARGET_DIR%\GENESIS.md" >nul
copy /Y "%PROFILE_DIR%\DEV_GUIDE.md" "%TARGET_DIR%\DEV_GUIDE.md" >nul
copy /Y "%PROFILE_DIR%\CHAT_INIT.md" "%TARGET_DIR%\CHAT_INIT.md" >nul

echo Read project-system/CHAT_INIT.md and follow it.>"%TARGET_DIR%\chat.md"

echo.
echo Done.
echo Project folder: "%PROJECT_NAME%"
echo Profile: %PROFILE_NAME%
echo.
echo Next steps:
echo   1^> Open the "%PROJECT_NAME%" folder in your AI tool.
echo   2^> Start a new chat in that folder.
echo   3^> Run:  read GENESIS.md
echo   4^> Answer the questions. When Genesis finishes, it will create /ai-os/
echo      and project-system/, move DEV_GUIDE.md and CHAT_INIT.md, and you can
echo      then delete GENESIS.md.
echo.

endlocal
exit /b 0
