#!/usr/bin/env bash
#
# SUMM: Commit, push, wait briefly, then install the right-side Keyball61 firmware.
#
# USAGE:
# ./scripts/push-and-install.sh [OPTIONS]
#
# EXAMPLES:
# ./scripts/push-and-install.sh
# ./scripts/push-and-install.sh -m "Tune pointer speed"
# ./scripts/push-and-install.sh --wait 20
#
# DEFAULT:
# Prompts for a commit message, runs git fetch, git add ., git rebase
# --autostash origin/main, git commit, git push, sleeps 10 seconds, then runs
# scripts/install-right-firmware.sh --commit from the repo root.
#
# USE CASE:
# After changing ZMK config files, this wraps the repeated commit/push/install
# cycle while still asking for the one thing that changes: the commit message.
#
# OPTIONS:
# -m, --message TEXT      Commit message. If omitted, the script asks for it.
# --wait SECONDS         Seconds to wait after push before installing. Default: 10
# --remote NAME          Remote to fetch/push. Default: origin
# --branch NAME          Upstream branch to rebase onto. Default: main
# --install-script PATH  Firmware installer path.
# -h, --help             Show this help.
#
# REQUIREMENTS:
# git, sleep, and scripts/install-right-firmware.sh.

set -euo pipefail

COMMIT_MESSAGE=""
WAIT_SECONDS=10
REMOTE="origin"
BRANCH="main"
INSTALL_SCRIPT="./scripts/install-right-firmware.sh"

usage() {
  awk '
    NR == 1 { next }
    /^# ?/ { sub(/^# ?/, ""); print; next }
    /^#$/ { print ""; next }
    { exit }
  ' "$0"
}

error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--message)
        [[ $# -ge 2 ]] || error "--message requires text"
        COMMIT_MESSAGE="$2"
        shift 2
        ;;
      --wait)
        [[ $# -ge 2 ]] || error "--wait requires seconds"
        WAIT_SECONDS="$2"
        shift 2
        ;;
      --remote)
        [[ $# -ge 2 ]] || error "--remote requires a name"
        REMOTE="$2"
        shift 2
        ;;
      --branch)
        [[ $# -ge 2 ]] || error "--branch requires a name"
        BRANCH="$2"
        shift 2
        ;;
      --install-script)
        [[ $# -ge 2 ]] || error "--install-script requires a path"
        INSTALL_SCRIPT="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        ;;
    esac
  done
}

validate_number() {
  local value="$1"
  local label="$2"

  [[ "$value" =~ ^[0-9]+$ ]] || error "$label must be a non-negative integer"
}

resolve_install_script() {
  local repo_root="$1"

  if [[ "$INSTALL_SCRIPT" = /* ]]; then
    printf '%s\n' "$INSTALL_SCRIPT"
  else
    printf '%s\n' "${repo_root%/}/${INSTALL_SCRIPT#./}"
  fi
}

ask_commit_message() {
  if [[ -n "$COMMIT_MESSAGE" ]]; then
    return 0
  fi

  printf 'Commit message: '
  IFS= read -r COMMIT_MESSAGE
}

main() {
  parse_args "$@"

  require_command git
  require_command sleep
  validate_number "$WAIT_SECONDS" "--wait"

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || error "Run this script inside the repo"
  local repo_root
  local install_script_path

  repo_root="$(git rev-parse --show-toplevel)"
  install_script_path="$(resolve_install_script "$repo_root")"

  [[ -x "$install_script_path" ]] || error "Install script is not executable: $install_script_path"

  ask_commit_message
  [[ -n "$COMMIT_MESSAGE" ]] || error "Commit message cannot be empty"

  info "Fetching $REMOTE..."
  git fetch "$REMOTE"

  info "Staging changes..."
  git add .

  info "Rebasing onto $REMOTE/$BRANCH..."
  git rebase --autostash "$REMOTE/$BRANCH"

  if git diff --cached --quiet; then
    error "No staged changes to commit after rebase"
  fi

  info "Committing..."
  git commit -m "$COMMIT_MESSAGE"

  info "Pushing..."
  git push "$REMOTE" HEAD

  info "Waiting $WAIT_SECONDS seconds before installing firmware..."
  sleep "$WAIT_SECONDS"

  info "Running firmware installer..."
  "$install_script_path" --commit
}

main "$@"
