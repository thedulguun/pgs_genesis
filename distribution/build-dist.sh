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

  awk -v gh="$GENESIS_HEAVY" \
      -v dh="$DEV_GUIDE_HEAVY" \
      -v ch="$CHAT_INIT_HEAVY" \
      -v gl="$GENESIS_LIGHT" \
      -v dl="$DEV_GUIDE_LIGHT" \
      -v cl="$CHAT_INIT_LIGHT" '
    BEGIN { in_copy = 0 }
    /PROFILE_DIR="\$SCRIPT_DIR\/genesis-light-v1"/ { in_copy = 1 }
    {
      if (in_copy == 0) {
        print $0
      }
    }
    /PROFILE_DIR="\$SCRIPT_DIR\/genesis-light-v1"/ {
      print "      PROFILE_NAME=\"Light\""
      print "      break"
      print "      ;;"
    }
    /PROFILE_DIR="\$SCRIPT_DIR\/genesis-heavy-v1"/ {
      print "      PROFILE_NAME=\"Heavy\""
      print "      break"
      print "      ;;"
    }
    /printf .*CHAT_INIT.md/ && in_copy == 1 {
      in_copy = 2
      print ""
      print "echo"
      print "echo \"Creating project \\\"$PROJECT_NAME\\\" with $PROFILE_NAME profile...\""
      print ""
      print "if [ \"$PROFILE\" = \"1\" ]; then"
      print "  cat <<'EOF' >\"$TARGET_DIR/GENESIS.md\""
      print gl
      print "EOF"
      print "  cat <<'EOF' >\"$TARGET_DIR/DEV_GUIDE.md\""
      print dl
      print "EOF"
      print "  cat <<'EOF' >\"$TARGET_DIR/CHAT_INIT.md\""
      print cl
      print "EOF"
      print "else"
      print "  cat <<'EOF' >\"$TARGET_DIR/GENESIS.md\""
      print gh
      print "EOF"
      print "  cat <<'EOF' >\"$TARGET_DIR/DEV_GUIDE.md\""
      print dh
      print "EOF"
      print "  cat <<'EOF' >\"$TARGET_DIR/CHAT_INIT.md\""
      print ch
      print "EOF"
      print "fi"
      print ""
      print "printf \"Read project-system/CHAT_INIT.md and follow it.\\n\" >\"\\$TARGET_DIR/chat.md\""
    }
  ' "$template" >"$out"
}

build_bat() {
  local template="$1"
  local out="$2"

  {
    sed '/^set "PROFILE_DIR=%SCRIPT_DIR%genesis-light-v1"/d' "$template" | \
    sed '/^set "PROFILE_DIR=%SCRIPT_DIR%genesis-heavy-v1"/d'

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
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$GENESIS_LIGHT"
    echo "'@ | Set-Content -Encoding UTF8 \\\"%TARGET_DIR%\\GENESIS_light.md\\\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$DEV_GUIDE_LIGHT"
    echo "'@ | Set-Content -Encoding UTF8 \\\"%TARGET_DIR%\\DEV_GUIDE_light.md\\\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$CHAT_INIT_LIGHT"
    echo "'@ | Set-Content -Encoding UTF8 \\\"%TARGET_DIR%\\CHAT_INIT_light.md\\\"\" >nul"
    echo
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$GENESIS_HEAVY"
    echo "'@ | Set-Content -Encoding UTF8 \\\"%TARGET_DIR%\\GENESIS_heavy.md\\\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$DEV_GUIDE_HEAVY"
    echo "'@ | Set-Content -Encoding UTF8 \\\"%TARGET_DIR%\\DEV_GUIDE_heavy.md\\\"\" >nul"
    echo "powershell -NoProfile -Command \"@'"
    printf "%s\n" "$CHAT_INIT_HEAVY"
    echo "'@ | Set-Content -Encoding UTF8 \\\"%TARGET_DIR%\\CHAT_INIT_heavy.md\\\"\" >nul"
    echo
    echo "if \"%PROFILE%\"==\"1\" ("
    echo "    move /Y \"%TARGET_DIR%\\GENESIS_light.md\" \"%TARGET_DIR%\\GENESIS.md\" >nul"
    echo "    move /Y \"%TARGET_DIR%\\DEV_GUIDE_light.md\" \"%TARGET_DIR%\\DEV_GUIDE.md\" >nul"
    echo "    move /Y \"%TARGET_DIR%\\CHAT_INIT_light.md\" \"%TARGET_DIR%\\CHAT_INIT.md\" >nul"
    echo ") else ("
    echo "    move /Y \"%TARGET_DIR%\\GENESIS_heavy.md\" \"%TARGET_DIR%\\GENESIS.md\" >nul"
    echo "    move /Y \"%TARGET_DIR%\\DEV_GUIDE_heavy.md\" \"%TARGET_DIR%\\DEV_GUIDE.md\" >nul"
    echo "    move /Y \"%TARGET_DIR%\\CHAT_INIT_heavy.md\" \"%TARGET_DIR%\\CHAT_INIT.md\" >nul"
    echo ")"
    echo
    echo "echo Read project-system/CHAT_INIT.md and follow it.>\"%TARGET_DIR%\\chat.md\""
  } >"$out"
}

build_sh_like "$TEMPLATE_DIR/genesis-setup.sh" "$DIST_DIR/genesis-setup.sh"
chmod +x "$DIST_DIR/genesis-setup.sh"

build_sh_like "$TEMPLATE_DIR/genesis-setup.command" "$DIST_DIR/genesis-setup.command"
chmod +x "$DIST_DIR/genesis-setup.command"

build_bat "$TEMPLATE_DIR/genesis-setup.bat" "$DIST_DIR/genesis-setup.bat"

echo "Dist bootstrap scripts generated in $DIST_DIR"
