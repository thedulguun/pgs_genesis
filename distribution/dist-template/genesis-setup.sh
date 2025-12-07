#!/usr/bin/env bash

# Genesis setup script (Unix/macOS)
# Creates a new project folder and copies the chosen Genesis profile into it.

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

PROFILE_DIR=""
PROFILE_NAME=""
while true; do
  read -r -p "Enter 1 or 2: " PROFILE
  case "$PROFILE" in
    1)
      PROFILE_NAME="Light"
      PROFILE_DIR="$SCRIPT_DIR/genesis-light-v1"
      break
      ;;
    2)
      PROFILE_NAME="Heavy"
      PROFILE_DIR="$SCRIPT_DIR/genesis-heavy-v1"
      break
      ;;
    *)
      echo "Please enter 1 for Light or 2 for Heavy."
      ;;
  esac
done

if [ ! -f "$PROFILE_DIR/GENESIS.md" ]; then
  echo
  echo "ERROR: Could not find GENESIS.md in \"$PROFILE_DIR\"."
  echo "Make sure the genesis-light-v1 and genesis-heavy-v1 folders"
  echo "are located next to this script."
  exit 1
fi

echo
echo "Creating project \"$PROJECT_NAME\" with $PROFILE_NAME profile..."

cp "$PROFILE_DIR/GENESIS.md" "$TARGET_DIR/GENESIS.md"
cp "$PROFILE_DIR/DEV_GUIDE.md" "$TARGET_DIR/DEV_GUIDE.md"
cp "$PROFILE_DIR/CHAT_INIT.md" "$TARGET_DIR/CHAT_INIT.md"

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
