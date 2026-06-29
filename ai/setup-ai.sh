#!/bin/sh

set -eu

ACTION="${1:-}"
DOTFILES_DIR="${DOTFILES_DIR:-$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd -P)}"
WORK_ROOT="${WORK_ROOT:-$HOME/Workspace}"
DOT_FORCE="${DOT_FORCE:-0}"
DOT_DEBUG="${DOT_DEBUG:-0}"
BACKUP_DIR="$DOTFILES_DIR/.dot/backup"

debug() {
  [ "$DOT_DEBUG" = "1" ] || return 0
  printf "[setup-ai] %s\n" "$*" >&2
}

# Managed entries:
# source path relative to DOTFILES_DIR,target path
entries() {
  cat <<EOF
# Claude
ai/claude/settings.json,~/.claude/settings.json
ai/claude/global/CLAUDE.md,~/.claude/CLAUDE.md
ai/claude/statusline-command.sh,~/.claude/statusline-command.sh
ai/claude/workspace/CLAUDE.md,$WORK_ROOT/.claude/CLAUDE.md
ai/shared/rules,~/.claude/rules

# Codex
ai/codex/global/AGENTS.md,~/.codex/AGENTS.md
ai/codex/workspace/AGENTS.md,$WORK_ROOT/AGENTS.md
EOF
}

expand_target() {
  # shellcheck disable=SC2088
  case "$1" in
  '~/'*)
    printf "%s/%s\n" "$HOME" "${1#??}"
    ;;
  *)
    printf "%s\n" "$1"
    ;;
  esac
}

timestamp() {
  date "+%Y%m%d_%H%M%S"
}

backup_target() {
  target="$1"
  mkdir -p "$BACKUP_DIR"

  backup_name="$(basename "$target").$(timestamp)"
  backup_path="$BACKUP_DIR/$backup_name"
  counter=1

  while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
    backup_path="$BACKUP_DIR/$backup_name.$counter"
    counter=$((counter + 1))
  done

  mv "$target" "$backup_path"
  printf "backed up %s -> %s\n" "$target" "$backup_path"
}

ensure_link() {
  source_rel="$1"
  target_spec="$2"
  source="$DOTFILES_DIR/$source_rel"
  target="$(expand_target "$target_spec")"

  if [ ! -e "$source" ]; then
    printf "missing source: %s\n" "$source" >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    current="$(readlink "$target" || true)"
    if [ "$current" = "$source" ]; then
      return 0
    fi

    if [ "$DOT_FORCE" = "1" ]; then
      backup_target "$target"
    else
      printf "conflicting symlink: %s -> %s\n" "$target" "$current" >&2
      return 1
    fi
  elif [ -e "$target" ]; then
    if [ "$DOT_FORCE" = "1" ]; then
      backup_target "$target"
    else
      printf "conflicting path exists: %s\n" "$target" >&2
      return 1
    fi
  fi

  ln -s "$source" "$target"
  printf "linked %s -> %s\n" "$target" "$source"
}

remove_link() {
  source_rel="$1"
  target_spec="$2"
  source="$DOTFILES_DIR/$source_rel"
  target="$(expand_target "$target_spec")"

  if [ ! -L "$target" ]; then
    return 0
  fi

  current="$(readlink "$target" || true)"
  if [ "$current" != "$source" ]; then
    printf "skip unlink for foreign symlink: %s -> %s\n" "$target" "$current" >&2
    return 0
  fi

  rm "$target"
  printf "unlinked %s\n" "$target"
}

check_link() {
  source_rel="$1"
  target_spec="$2"
  source="$DOTFILES_DIR/$source_rel"
  target="$(expand_target "$target_spec")"

  debug "check source=$source target=$target"

  if [ ! -L "$target" ]; then
    return 1
  fi

  current="$(readlink "$target" || true)"
  [ "$current" = "$source" ]
}

apply_entries() {
  action="$1"

  entries | while IFS=',' read -r source_rel target_spec; do
    [ -n "$source_rel" ] || continue
    case "$source_rel" in
    \#*)
      continue
      ;;
    esac
    debug "action=$action source=$source_rel target=$target_spec"

    case "$action" in
    link)
      ensure_link "$source_rel" "$target_spec"
      ;;
    unlink)
      remove_link "$source_rel" "$target_spec"
      ;;
    *)
      echo "unsupported action: $action" >&2
      exit 1
      ;;
    esac
  done
}

status_entries() {
  entries | while IFS=',' read -r source_rel target_spec; do
    [ -n "$source_rel" ] || continue
    case "$source_rel" in
    \#*)
      continue
      ;;
    esac
    check_link "$source_rel" "$target_spec" || exit 1
  done
}

case "$ACTION" in
status)
  debug "running status"
  status_entries
  ;;
link)
  debug "running link"
  apply_entries link
  ;;
unlink)
  debug "running unlink"
  apply_entries unlink
  ;;
*)
  echo "usage: $0 {status|link|unlink}" >&2
  exit 1
  ;;
esac
