#!/usr/bin/env bash

set -euo pipefail

APP_NAME="Lumon Macrodata Refiner"
DEFAULT_APPS_DIR="$HOME/.local/share/applications"
TARGET_APPS_DIR="$DEFAULT_APPS_DIR"

if ! command -v gum >/dev/null 2>&1; then
  echo "Missing dependency: gum" >&2
  exit 1
fi

print_plan() {
  local apps_dir="$1"
  local icons_dir="$apps_dir/icons"
  local target_icon="$icons_dir/$APP_NAME.png"
  local target_desktop="$apps_dir/$APP_NAME.desktop"
  local title="1"
  local body="7"
  local remove_label="4"
  local remove_path="6"

  {
    gum style --foreground="$title" --bold "Lumon Launcher Removal Preflight"
    echo
    gum style --foreground="$body" "This uninstall will remove:"
    echo
    printf "%s %s\n" \
      "$(gum style --foreground="$remove_label" --bold "Desktop file:")" \
      "$(gum style --foreground="$remove_path" "$target_desktop")"
    printf "%s %s\n" \
      "$(gum style --foreground="$remove_label" --bold "Icon file:")" \
      "$(gum style --foreground="$remove_path" "$target_icon")"
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

  CHOICE="$(gum choose "Proceed" "Uninstall from different path" "Cancel")"

  case "$CHOICE" in
    "Proceed")
      break
      ;;
    "Uninstall from different path")
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

rm -f "$TARGET_DESKTOP" "$TARGET_ICON"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$TARGET_APPS_DIR" >/dev/null 2>&1 || true
fi

printf "%s %s\n" \
  "$(gum style --foreground="4" --bold "Removed $APP_NAME launcher from")" \
  "$(gum style --foreground="6" "$TARGET_DESKTOP")"
