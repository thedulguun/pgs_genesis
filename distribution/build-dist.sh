#!/usr/bin/env bash

# build-dist.sh
# -------------
# Dev-only packaging script.
# Reads the heavy and light Genesis profiles and emits fully inlined
# bootstrap scripts into distribution/dist-package/.
#
# The resulting dist-package/ folder is what you zip and ship:
#   - genesis-setup.bat
#   - genesis-setup.sh
#   - genesis-setup.command
#   - README.md

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/distribution/dist-package"
HEAVY_DIR="$ROOT_DIR/genesis-heavy-v1"
LIGHT_DIR="$ROOT_DIR/genesis-light-v1"

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR"/*

read_file() {
  local path="$1"
  cat "$path"
}

GENESIS_HEAVY="$(read_file "$HEAVY_DIR/GENESIS.md")"
DEV_GUIDE_HEAVY="$(read_file "$HEAVY_DIR/DEV_GUIDE.md")"
CHAT_INIT_HEAVY="$(read_file "$HEAVY_DIR/CHAT_INIT.md")"

GENESIS_LIGHT="$(read_file "$LIGHT_DIR/GENESIS.md")"
DEV_GUIDE_LIGHT="$(read_file "$LIGHT_DIR/DEV_GUIDE.md")"
CHAT_INIT_LIGHT="$(read_file "$LIGHT_DIR/CHAT_INIT.md")"

echo "Building dist bootstrap scripts into $DIST_DIR"

make_unix_script() {
  local out="$1"

  # Common Unix / macOS script (bash)
  cat >"$out" <<'HEADER'
#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo
echo "Project Generation System - Genesis Setup"
echo "========================================"
echo "This will create or prepare a project folder and place"
echo "the Genesis files inside it."
echo "From there, you'll open that folder in your AI tool and run"
echo "\"read GENESIS.md\" once to create the Project OS."
echo
echo "You can enter a NEW folder name (it will be created),"
echo "or point to an EXISTING folder (and we will add Genesis files there)."
echo

ask_project() {
  while true; do
    read -r -p "What should we call your project folder? (new or existing): " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
      echo "Please enter a non-empty folder name."
    else
      break
    fi
  done
}

ask_project

TARGET_DIR="$SCRIPT_DIR/$PROJECT_NAME"

if [ -d "$TARGET_DIR" ]; then
  echo
  echo "The folder \"$PROJECT_NAME\" already exists."
  read -r -p "Use this existing folder and add Genesis files to it? [y/N]: " USE_EXISTING
  case "$USE_EXISTING" in
    [yY]*) ;;
    *) ask_project; TARGET_DIR="$SCRIPT_DIR/$PROJECT_NAME" ;;
  esac
fi

mkdir -p "$TARGET_DIR"

echo
echo "How do you expect to use this project?"
echo "  [1] Light  - smaller or short-lived project"
echo "              - simple OS (2 files), ideal for quick tools, experiments, solo work"
echo "  [2] Heavy  - ongoing or multi-developer project"
echo "              - full OS (rules, context, workflows, schema, changelog)"
echo
echo "This only changes how the AI Project OS is organised."
echo "In both cases, Genesis will ask detailed questions about your project"
echo "and tailor the OS to your answers before creating any files."

PROFILE_NAME=""
PROFILE=""
while true; do
  read -r -p "Enter 1 or 2: " PROFILE
  case "$PROFILE" in
    1)
      PROFILE_NAME="Light"
      break
      ;;
    2)
      PROFILE_NAME="Heavy"
      break
      ;;
    *)
      echo "Please enter 1 for Light or 2 for Heavy."
      ;;
  esac
done

echo
echo "Creating project \"$PROJECT_NAME\" with $PROFILE_NAME profile..."
echo

if [ "$PROFILE" = "1" ]; then
  cat <<'EOF_GENESIS_LIGHT' >"$TARGET_DIR/GENESIS.md"
HEADER

  printf '%s\n' "$GENESIS_LIGHT" >>"$out"

  cat >>"$out" <<'HEADER'
EOF_GENESIS_LIGHT

  cat <<'EOF_DEV_LIGHT' >"$TARGET_DIR/DEV_GUIDE.md"
HEADER

  printf '%s\n' "$DEV_GUIDE_LIGHT" >>"$out"

  cat >>"$out" <<'HEADER'
EOF_DEV_LIGHT

  cat <<'EOF_CHAT_LIGHT' >"$TARGET_DIR/CHAT_INIT.md"
HEADER

  printf '%s\n' "$CHAT_INIT_LIGHT" >>"$out"

  cat >>"$out" <<'HEADER'
EOF_CHAT_LIGHT

else
  cat <<'EOF_GENESIS_HEAVY' >"$TARGET_DIR/GENESIS.md"
HEADER

  printf '%s\n' "$GENESIS_HEAVY" >>"$out"

  cat >>"$out" <<'HEADER'
EOF_GENESIS_HEAVY

  cat <<'EOF_DEV_HEAVY' >"$TARGET_DIR/DEV_GUIDE.md"
HEADER

  printf '%s\n' "$DEV_GUIDE_HEAVY" >>"$out"

  cat >>"$out" <<'HEADER'
EOF_DEV_HEAVY

  cat <<'EOF_CHAT_HEAVY' >"$TARGET_DIR/CHAT_INIT.md"
HEADER

  printf '%s\n' "$CHAT_INIT_HEAVY" >>"$out"

  cat >>"$out" <<'HEADER'
EOF_CHAT_HEAVY
fi

printf 'Read project-system/CHAT_INIT.md and follow it.\n' >"$TARGET_DIR/chat.md"

echo
echo "Done."
echo "Project folder: \"$PROJECT_NAME\""
echo "Profile: $PROFILE_NAME"
echo
echo "Next steps:"
echo "  1) Open the \"$PROJECT_NAME\" folder in your AI tool."
echo "  2) Start a new chat in that folder."
echo "  3) Run:  read GENESIS.md"
echo "  4) Answer the questions. When Genesis finishes, it will create /ai-os/,"
echo "     move DEV_GUIDE.md and CHAT_INIT.md into project-system/, and you can"
echo "     then delete GENESIS.md."
echo

exit 0
HEADER
}

make_bat_script() {
  local out="$1"

  cat >"$out" <<'HEADER'
@echo off
setlocal ENABLEDELAYEDEXPANSION

echo.
echo Project Generation System - Genesis Setup
echo ========================================
echo This will create or prepare a project folder and place
echo the Genesis files inside it.
echo From there, you'll open that folder in your AI tool and run
echo "read GENESIS.md" once to create the Project OS.
echo.
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
) else if "%PROFILE%"=="2" (
    set "PROFILE_NAME=Heavy"
) else (
    echo Please enter 1 for Light or 2 for Heavy.
    goto ask_profile
)

echo.
echo Creating project "%PROJECT_NAME%" with %PROFILE_NAME% profile...
echo.

if "%PROFILE%"=="1" (
    powershell -NoProfile -Command "@'
HEADER

  printf '%s\n' "$GENESIS_LIGHT" >>"$out"

  cat >>"$out" <<'HEADER'
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\GENESIS.md""

    powershell -NoProfile -Command "@'
HEADER

  printf '%s\n' "$DEV_GUIDE_LIGHT" >>"$out"

  cat >>"$out" <<'HEADER'
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\DEV_GUIDE.md""

    powershell -NoProfile -Command "@'
HEADER

  printf '%s\n' "$CHAT_INIT_LIGHT" >>"$out"

  cat >>"$out" <<'HEADER'
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\CHAT_INIT.md""
) else (
    powershell -NoProfile -Command "@'
HEADER

  printf '%s\n' "$GENESIS_HEAVY" >>"$out"

  cat >>"$out" <<'HEADER'
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\GENESIS.md""

    powershell -NoProfile -Command "@'
HEADER

  printf '%s\n' "$DEV_GUIDE_HEAVY" >>"$out"

  cat >>"$out" <<'HEADER'
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\DEV_GUIDE.md""

    powershell -NoProfile -Command "@'
HEADER

  printf '%s\n' "$CHAT_INIT_HEAVY" >>"$out"

  cat >>"$out" <<'HEADER'
'@ | Set-Content -Encoding UTF8 "%TARGET_DIR%\CHAT_INIT.md""
)

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
HEADER
}

# Build Unix-style scripts (.sh and .command)
make_unix_script "$DIST_DIR/genesis-setup.sh"
chmod +x "$DIST_DIR/genesis-setup.sh"

make_unix_script "$DIST_DIR/genesis-setup.command"
chmod +x "$DIST_DIR/genesis-setup.command"

# Build Windows .bat script
make_bat_script "$DIST_DIR/genesis-setup.bat"

# Simple README for the dist bundle
cat >"$DIST_DIR/README.md" <<'EOF'
# Project Generation System – Genesis (dist package)

This folder contains the self-contained bootstrap scripts you can ship to developers.

Files:

- `genesis-setup.bat`      – Windows bootstrapper
- `genesis-setup.sh`       – Linux bootstrapper (run from terminal)
- `genesis-setup.command`  – macOS bootstrapper (double-clickable)
- `README.md`              – This guide

Basic usage:

1. Copy these four files somewhere convenient.
2. Run the script for your OS.
3. Choose a project folder name (new or existing).
4. Choose Light or Heavy profile.
5. Open the created project folder in your AI tool and run: `read GENESIS.md`.
EOF

echo "Dist bootstrap scripts generated in $DIST_DIR"

