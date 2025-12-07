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
#   - (README.md can be added separately)

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/distribution/dist-package"
TEMPLATE_DIR="$ROOT_DIR/distribution/dist-template"

HEAVY_DIR="$ROOT_DIR/genesis-heavy-v1"
LIGHT_DIR="$ROOT_DIR/genesis-light-v1"

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR"/*

read_profile() {
  local dir="$1"
  local name="$2"
  cat "$dir/$name"
}

GENESIS_HEAVY="$(read_profile "$HEAVY_DIR" GENESIS.md)"
DEV_GUIDE_HEAVY="$(read_profile "$HEAVY_DIR" DEV_GUIDE.md)"
CHAT_INIT_HEAVY="$(read_profile "$HEAVY_DIR" CHAT_INIT.md)"

GENESIS_LIGHT="$(read_profile "$LIGHT_DIR" GENESIS.md)"
DEV_GUIDE_LIGHT="$(read_profile "$LIGHT_DIR" DEV_GUIDE.md)"
CHAT_INIT_LIGHT="$(read_profile "$LIGHT_DIR" CHAT_INIT.md)"

echo "Building dist bootstrap scripts into $DIST_DIR"

build_sh_like() {
  local template="$1"
  local out="$2"

  # Copy everything up to (but not including) the profile selection block,
  # then append our own profile selection + inlined content logic.
  awk '
    /PROFILE_DIR=""/ { exit }
    { print }
  ' "$template" >"$out"

  {
    echo
    echo 'PROFILE_NAME=""'
    echo 'PROFILE=""'
    echo 'while true; do'
    echo '  read -r -p "Enter 1 or 2: " PROFILE'
    echo '  case "$PROFILE" in'
    echo '    1)'
    echo '      PROFILE_NAME="Light"'
    echo '      break'
    echo '      ;;'
    echo '    2)'
    echo '      PROFILE_NAME="Heavy"'
    echo '      break'
    echo '      ;;'
    echo '    *)'
    echo '      echo "Please enter 1 for Light or 2 for Heavy."'
    echo '      ;;'
    echo '  esac'
    echo 'done'
    echo
    echo 'echo'
    echo 'echo "Creating project \"$PROJECT_NAME\" with $PROFILE_NAME profile..."'
    echo
    echo 'if [ "$PROFILE" = "1" ]; then'
    echo '  cat <<'\''EOF'\'' >"$TARGET_DIR/GENESIS.md"'
    printf "%s\n" "$GENESIS_LIGHT"
    echo 'EOF'
    echo '  cat <<'\''EOF'\'' >"$TARGET_DIR/DEV_GUIDE.md"'
    printf "%s\n" "$DEV_GUIDE_LIGHT"
    echo 'EOF'
    echo '  cat <<'\''EOF'\'' >"$TARGET_DIR/CHAT_INIT.md"'
    printf "%s\n" "$CHAT_INIT_LIGHT"
    echo 'EOF'
    echo 'else'
    echo '  cat <<'\''EOF'\'' >"$TARGET_DIR/GENESIS.md"'
    printf "%s\n" "$GENESIS_HEAVY"
    echo 'EOF'
    echo '  cat <<'\''EOF'\'' >"$TARGET_DIR/DEV_GUIDE.md"'
    printf "%s\n" "$DEV_GUIDE_HEAVY"
    echo 'EOF'
    echo '  cat <<'\''EOF'\'' >"$TARGET_DIR/CHAT_INIT.md"'
    printf "%s\n" "$CHAT_INIT_HEAVY"
    echo 'EOF'
    echo 'fi'
    echo
    echo 'printf '\''Read project-system/CHAT_INIT.md and follow it.\n'\'' >"$TARGET_DIR/chat.md"'
    echo
    echo 'echo'
    echo 'echo "Done."'
    echo 'echo "Project folder: \"$PROJECT_NAME\""'
    echo 'echo "Profile: $PROFILE_NAME"'
    echo 'echo'
    echo 'echo "Next steps:"'
    echo 'echo "  1) Open the \"$PROJECT_NAME\" folder in your AI tool."'
    echo 'echo "  2) Start a new chat in that folder."'
    echo 'echo "  3) Run:  read GENESIS.md"'
    echo 'echo "  4) Answer the questions. When Genesis finishes, it will create /ai-os/,"'
    echo 'echo "     move DEV_GUIDE.md and CHAT_INIT.md into project-system/, and you can"'
    echo 'echo "     then delete GENESIS.md."'
    echo 'echo'
    echo
    echo 'exit 0'
  } >>"$out"
}

build_bat() {
  local template="$1"
  local out="$2"

  {
    # Copy everything up to (but not including) the :ask_profile block.
    # We then re-create :ask_profile and everything that follows ourselves,
    # so the dist .bat does not depend on genesis-light-v1 / genesis-heavy-v1.
    awk '
      /^:ask_profile/ { exit }
      { print }
    ' "$template"

    echo
    echo ":ask_profile"
    echo "set \"PROFILE=\""
    echo "set /p PROFILE=Enter 1 or 2: "
    echo
    echo "if \"%PROFILE%\"==\"1\" ("
    echo "    set \"PROFILE_NAME=Light\""
    echo ") else if \"%PROFILE%\"==\"2\" ("
    echo "    set \"PROFILE_NAME=Heavy\""
    echo ") else ("
    echo "    echo Please enter 1 for Light or 2 for Heavy."
    echo "    goto ask_profile"
    echo ")"
    echo
    echo "echo."
    echo "echo Creating project \"%PROJECT_NAME%\" with %PROFILE_NAME% profile..."
    echo
    # Write embedded Light profile files to temporary names
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$GENESIS_LIGHT"
    echo "'@ | Set-Content -Encoding UTF8 \"%%TARGET_DIR%%\\GENESIS_light.md\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$DEV_GUIDE_LIGHT"
    echo "'@ | Set-Content -Encoding UTF8 \"%%TARGET_DIR%%\\DEV_GUIDE_light.md\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$CHAT_INIT_LIGHT"
    echo "'@ | Set-Content -Encoding UTF8 \"%%TARGET_DIR%%\\CHAT_INIT_light.md\"\" >nul"
    echo
    # Write embedded Heavy profile files to temporary names
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$GENESIS_HEAVY"
    echo "'@ | Set-Content -Encoding UTF8 \"%%TARGET_DIR%%\\GENESIS_heavy.md\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$DEV_GUIDE_HEAVY"
    echo "'@ | Set-Content -Encoding UTF8 \"%%TARGET_DIR%%\\DEV_GUIDE_heavy.md\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$CHAT_INIT_HEAVY"
    echo "'@ | Set-Content -Encoding UTF8 \"%%TARGET_DIR%%\\CHAT_INIT_heavy.md\"\" >nul"
    echo
    # Move chosen profile into final filenames
    echo "if \"%PROFILE%\"==\"1\" ("
    echo "    move /Y \"%%TARGET_DIR%%\\GENESIS_light.md\" \"%%TARGET_DIR%%\\GENESIS.md\" >nul"
    echo "    move /Y \"%%TARGET_DIR%%\\DEV_GUIDE_light.md\" \"%%TARGET_DIR%%\\DEV_GUIDE.md\" >nul"
    echo "    move /Y \"%%TARGET_DIR%%\\CHAT_INIT_light.md\" \"%%TARGET_DIR%%\\CHAT_INIT.md\" >nul"
    echo ") else ("
    echo "    move /Y \"%%TARGET_DIR%%\\GENESIS_heavy.md\" \"%%TARGET_DIR%%\\GENESIS.md\" >nul"
    echo "    move /Y \"%%TARGET_DIR%%\\DEV_GUIDE_heavy.md\" \"%%TARGET_DIR%%\\DEV_GUIDE.md\" >nul"
    echo "    move /Y \"%%TARGET_DIR%%\\CHAT_INIT_heavy.md\" \"%%TARGET_DIR%%\\CHAT_INIT.md\" >nul"
    echo ")"
    echo
    echo "echo Read project-system/CHAT_INIT.md and follow it.>\"%%TARGET_DIR%%\\chat.md\""
    echo
    echo "echo."
    echo "echo Done."
    echo "echo Project folder: \"%PROJECT_NAME%\""
    echo "echo Profile: %PROFILE_NAME%"
    echo "echo."
    echo "echo Next steps:"
    echo "echo   1^> Open the \"%PROJECT_NAME%\" folder in your AI tool."
    echo "echo   2^> Start a new chat in that folder."
    echo "echo   3^> Run:  read GENESIS.md"
    echo "echo   4^> Answer the questions. When Genesis finishes, it will create /ai-os/"
    echo "echo      and project-system/, move DEV_GUIDE.md and CHAT_INIT.md, and you can"
    echo "echo      then delete GENESIS.md."
    echo
    echo "endlocal"
    echo "exit /b 0"
  } >"$out"
}

build_sh_like "$TEMPLATE_DIR/genesis-setup.sh" "$DIST_DIR/genesis-setup.sh"
chmod +x "$DIST_DIR/genesis-setup.sh"

build_sh_like "$TEMPLATE_DIR/genesis-setup.command" "$DIST_DIR/genesis-setup.command"
chmod +x "$DIST_DIR/genesis-setup.command"

build_bat "$TEMPLATE_DIR/genesis-setup.bat" "$DIST_DIR/genesis-setup.bat"

echo "Dist bootstrap scripts generated in $DIST_DIR"
