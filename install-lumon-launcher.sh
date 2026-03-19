#!/usr/bin/env bash

set -euo pipefail

APP_NAME="Lumon Macrodata Refiner"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ICON="$SCRIPT_DIR/applications/icons/$APP_NAME.png"
SOURCE_DESKTOP="$SCRIPT_DIR/$APP_NAME.desktop"
DEFAULT_APPS_DIR="$HOME/.local/share/applications"
TARGET_APPS_DIR="$DEFAULT_APPS_DIR"

if [[ ! -f "$SOURCE_ICON" ]]; then
  echo "Missing icon: $SOURCE_ICON" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_DESKTOP" ]]; then
  echo "Missing desktop entry: $SOURCE_DESKTOP" >&2
  exit 1
fi

if ! command -v gum >/dev/null 2>&1; then
  echo "Missing dependency: gum" >&2
  exit 1
fi

print_plan() {
  local apps_dir="$1"
  local icons_dir="$apps_dir/icons"
  local target_icon="$icons_dir/$APP_NAME.png"
  local target_desktop="$apps_dir/$APP_NAME.desktop"
  local title="6"
  local body="7"
  local source_label="4"
  local source_path="6"
  local target_label="4"
  local target_path="6"

  {
    gum style --foreground="$title" --bold "Lumon Launcher Preflight"
    echo
    gum style --foreground="$body" "This installer will:"
    echo
    printf "%s %s\n" \
      "$(gum style --foreground="$source_label" --bold "Source desktop file:")" \
      "$(gum style --foreground="$source_path" "$SOURCE_DESKTOP")"
    printf "%s %s\n" \
      "$(gum style --foreground="$source_label" --bold "Source icon:")" \
      "$(gum style --foreground="$source_path" "$SOURCE_ICON")"
    printf "%s %s\n" \
      "$(gum style --foreground="$target_label" --bold "Install desktop to:")" \
      "$(gum style --foreground="$target_path" "$target_desktop")"
    printf "%s %s\n" \
      "$(gum style --foreground="$target_label" --bold "Install icon to:")" \
      "$(gum style --foreground="$target_path" "$target_icon")"
  } | gum style \
    --no-strip-ansi \
    --border rounded \
    --border-foreground="$title" \
    --padding "1 2" \
    --margin "0 0"
}

while true; do
  TARGET_ICONS_DIR="$TARGET_APPS_DIR/icons"
  TARGET_ICON="$TARGET_ICONS_DIR/$APP_NAME.png"
  TARGET_DESKTOP="$TARGET_APPS_DIR/$APP_NAME.desktop"

  clear
  print_plan "$TARGET_APPS_DIR"
  echo

  CHOICE="$(gum choose "Proceed" "Install to different path" "Cancel")"

  case "$CHOICE" in
    "Proceed")
      break
      ;;
    "Install to different path")
      TARGET_APPS_DIR="$(gum input --value "$TARGET_APPS_DIR" --placeholder "/path/to/applications" --header "Applications directory")"
      if [[ -z "$TARGET_APPS_DIR" ]]; then
        TARGET_APPS_DIR="$DEFAULT_APPS_DIR"
      fi
      ;;
    "Cancel")
      echo "Cancelled."
      exit 0
      ;;
  esac
done

mkdir -p "$TARGET_APPS_DIR" "$TARGET_ICONS_DIR"

cp -f "$SOURCE_ICON" "$TARGET_ICON"
sed "s|^Icon=.*$|Icon=$TARGET_ICON|" "$SOURCE_DESKTOP" > "$TARGET_DESKTOP"
chmod +x "$TARGET_DESKTOP"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$TARGET_APPS_DIR" >/dev/null 2>&1 || true
fi

printf "%s %s\n" \
  "$(gum style --foreground="4" --bold "Installed $APP_NAME launcher to")" \
  "$(gum style --foreground="6" "$TARGET_DESKTOP")"
