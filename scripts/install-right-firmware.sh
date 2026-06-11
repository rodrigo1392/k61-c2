#!/usr/bin/env bash
#
# SUMM: Download the latest Keyball61 right-side ZMK firmware artifact and install it via Windows.
#
# USAGE:
# ./scripts/install-right-firmware.sh [OPTIONS]
#
# EXAMPLES:
# ./scripts/install-right-firmware.sh
# ./scripts/install-right-firmware.sh --commit
# ./scripts/install-right-firmware.sh --commit --dest /mnt/d --volume-label NICENANO --timeout 45
# ./scripts/install-right-firmware.sh --repo rodrigo1392/zmk-config-Keyball61-rr --workflow build.yml
#
# DEFAULT:
# Dry-run. Finds the GitHub Actions run for the current HEAD commit, waits for it,
# downloads artifacts into a temporary directory, locates the target UF2, and shows
# the copy actions. Pass -c/--commit to copy to /mnt/d, create or refresh the
# PowerShell helper only when needed, run ~/.local/bin/codex-done-sound, and then
# run PowerShell so Windows copies the file from D:\ to the mounted NICENANO
# drive. Downloaded firmware is cached in vault/ with consecutive numbers.
#
# USE CASE:
# After pushing a ZMK config commit, GitHub Actions builds UF2 firmware files.
# This automates waiting for the matching build, downloading the artifacts, and
# installing keyball61_right-nice_nano_v2-zmk.uf2 onto the keyboard drive.
#
# OPTIONS:
# -c, --commit            Copy the UF2 to /mnt/d and run the PowerShell installer.
# -d, --dry-run           Force preview mode.
# --dest PATH             WSL staging destination. Default: /mnt/d
# --firmware NAME         UF2 filename to install.
# --vault-dir PATH        Repo-local artifact cache directory. Default: vault
# --volume-label LABEL    Windows volume label to auto-detect. Default: NICENANO
# --windows-target PATH   Fallback Windows target if label is not found. Default: E:\
# --ps-script-name NAME   PowerShell helper script name checked/created in --dest.
# --repo OWNER/REPO       GitHub repo. Default: inferred from origin.
# --workflow NAME         Workflow name or file. Default: build.yml
# --poll SECONDS          Poll interval while waiting. Default: 10
# --timeout MINUTES       Maximum wait time. Default: 30
# -h, --help              Show this help.
#
# REQUIREMENTS:
# gh, git, find, cp, grep, sed, tr, cut, wslpath, powershell.exe,
# ~/.local/bin/codex-done-sound.
# Run `gh auth login` before downloading new artifacts.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
DEST="/mnt/d"
FIRMWARE="keyball61_right-nice_nano_v2-zmk.uf2"
VAULT_DIR="vault"
WINDOWS_TARGET='E:\'
WINDOWS_VOLUME_LABEL="NICENANO"
PS_SCRIPT_NAME="copy-keyball61-firmware.ps1"
DONE_SOUND_SCRIPT="${HOME}/.local/bin/codex-done-sound"
REPO=""
WORKFLOW="build.yml"
POLL_SECONDS=10
TIMEOUT_MINUTES=30
COMMIT=false
DRY_RUN=false

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
      -c|--commit)
        COMMIT=true
        shift
        ;;
      -d|--dry-run)
        DRY_RUN=true
        shift
        ;;
      --dest)
        [[ $# -ge 2 ]] || error "--dest requires a path"
        DEST="$2"
        shift 2
        ;;
      --firmware)
        [[ $# -ge 2 ]] || error "--firmware requires a filename"
        FIRMWARE="$2"
        shift 2
        ;;
      --vault-dir)
        [[ $# -ge 2 ]] || error "--vault-dir requires a path"
        VAULT_DIR="$2"
        shift 2
        ;;
      --windows-target)
        [[ $# -ge 2 ]] || error "--windows-target requires a Windows path"
        WINDOWS_TARGET="$2"
        shift 2
        ;;
      --volume-label)
        [[ $# -ge 2 ]] || error "--volume-label requires a label"
        WINDOWS_VOLUME_LABEL="$2"
        shift 2
        ;;
      --ps-script-name)
        [[ $# -ge 2 ]] || error "--ps-script-name requires a filename"
        PS_SCRIPT_NAME="$2"
        shift 2
        ;;
      --repo)
        [[ $# -ge 2 ]] || error "--repo requires OWNER/REPO"
        REPO="$2"
        shift 2
        ;;
      --workflow)
        [[ $# -ge 2 ]] || error "--workflow requires a workflow name or file"
        WORKFLOW="$2"
        shift 2
        ;;
      --poll)
        [[ $# -ge 2 ]] || error "--poll requires seconds"
        POLL_SECONDS="$2"
        shift 2
        ;;
      --timeout)
        [[ $# -ge 2 ]] || error "--timeout requires minutes"
        TIMEOUT_MINUTES="$2"
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

  [[ "$value" =~ ^[0-9]+$ ]] || error "$label must be a positive integer"
  [[ "$value" -gt 0 ]] || error "$label must be greater than zero"
}

infer_repo() {
  local remote_url

  remote_url="$(git remote get-url origin 2>/dev/null || true)"
  [[ -n "$remote_url" ]] || error "Could not infer repo because origin is not configured"

  case "$remote_url" in
    git@github.com:*)
      REPO="${remote_url#git@github.com:}"
      REPO="${REPO%.git}"
      ;;
    https://github.com/*)
      REPO="${remote_url#https://github.com/}"
      REPO="${REPO%.git}"
      ;;
    *)
      error "Could not infer GitHub repo from origin: $remote_url"
      ;;
  esac
}

wait_for_run_id() {
  local head_sha="$1"
  local deadline="$2"
  local run_id=""

  while [[ "$(date +%s)" -lt "$deadline" ]]; do
    run_id="$(
      gh run list \
        --repo "$REPO" \
        --workflow "$WORKFLOW" \
        --commit "$head_sha" \
        --limit 10 \
        --json databaseId \
        --jq '.[0].databaseId // empty'
    )"

    if [[ -n "$run_id" ]]; then
      printf '%s\n' "$run_id"
      return 0
    fi

    info "Waiting for GitHub Actions run to appear..." >&2
    sleep "$POLL_SECONDS"
  done

  return 1
}

wait_for_run_completion() {
  local run_id="$1"
  local deadline="$2"
  local status=""
  local conclusion=""
  local url=""

  while [[ "$(date +%s)" -lt "$deadline" ]]; do
    status="$(gh run view "$run_id" --repo "$REPO" --json status --jq '.status')"
    conclusion="$(gh run view "$run_id" --repo "$REPO" --json conclusion --jq '.conclusion // ""')"
    url="$(gh run view "$run_id" --repo "$REPO" --json url --jq '.url')"

    case "$status" in
      completed)
        [[ "$conclusion" == "success" ]] || error "GitHub Actions finished with conclusion '$conclusion': $url"
        info "GitHub Actions build completed successfully."
        return 0
        ;;
      queued|in_progress|requested|waiting|pending)
        info "Build status: $status. Waiting..."
        sleep "$POLL_SECONDS"
        ;;
      *)
        info "Build status: $status. Waiting..."
        sleep "$POLL_SECONDS"
        ;;
    esac
  done

  error "Timed out waiting for GitHub Actions run $run_id"
}

download_artifacts() {
  local run_id="$1"
  local download_dir="$2"

  gh run download "$run_id" --repo "$REPO" --dir "$download_dir" >/dev/null
}

find_firmware() {
  local download_dir="$1"
  local matches
  local count

  matches="$(find "$download_dir" -type f -name "$FIRMWARE" -print)"
  count="$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')"

  [[ "$count" -gt 0 ]] || error "Firmware not found in downloaded artifacts: $FIRMWARE"
  [[ "$count" -eq 1 ]] || error "Multiple firmware files found named $FIRMWARE. Refine --firmware."

  printf '%s\n' "$matches"
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g' \
    | cut -c 1-60
}

firmware_label() {
  local name="$1"

  name="${name%.uf2}"
  slugify "$name"
}

find_cached_firmware() {
  local vault_dir="$1"
  local short_sha="$2"
  local label="$3"
  local matches
  local count

  [[ -d "$vault_dir" ]] || return 1

  matches="$(find "$vault_dir" -maxdepth 1 -type f -name "*_${label}_${short_sha}.uf2" -print)"
  count="$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')"

  [[ "$count" -gt 0 ]] || return 1
  [[ "$count" -eq 1 ]] || error "Multiple cached firmware files found for $label and $short_sha in $vault_dir"

  printf '%s\n' "$matches"
}

next_vault_number() {
  local vault_dir="$1"
  local max_number=0
  local path
  local base
  local number

  [[ -d "$vault_dir" ]] || {
    printf '0001\n'
    return 0
  }

  while IFS= read -r path; do
    base="$(basename "$path")"
    number="${base%%-*}"
    [[ "$number" =~ ^[0-9]+$ ]] || continue
    if [[ "$number" -gt "$max_number" ]]; then
      max_number="$number"
    fi
  done < <(find "$vault_dir" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.uf2' -print)

  printf '%04d\n' "$((max_number + 1))"
}

cache_firmware() {
  local source_file="$1"
  local vault_dir="$2"
  local commit_subject="$3"
  local short_sha="$4"
  local label="$5"
  local number
  local commit_slug
  local cached_file

  mkdir -p "$vault_dir"

  number="$(next_vault_number "$vault_dir")"
  commit_slug="$(slugify "$commit_subject")"
  [[ -n "$commit_slug" ]] || commit_slug="commit"
  cached_file="${vault_dir%/}/${number}-${commit_slug}_${label}_${short_sha}.uf2"

  cp "$source_file" "$cached_file"
  printf '%s\n' "$cached_file"
}

write_powershell_copy_script() {
  local ps_script="$1"

  cat > "$ps_script" <<'POWERSHELL'
# install-right-firmware-helper-version: 3
param(
  [Parameter(Mandatory = $true)]
  [string]$SourceFile,

  [string]$TargetRoot = "E:\",

  [string]$VolumeLabel = "NICENANO"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceFile)) {
  Write-Error "Source firmware not found: $SourceFile"
  exit 1
}

$volume = Get-Volume -FileSystemLabel $VolumeLabel -ErrorAction SilentlyContinue |
  Where-Object { $_.DriveLetter } |
  Select-Object -First 1

if ($volume) {
  $TargetRoot = "$($volume.DriveLetter):\"
  Write-Host "Found $VolumeLabel at $TargetRoot"
} elseif (-not (Test-Path -LiteralPath $TargetRoot)) {
  Write-Error "Target path not found. Could not find volume label '$VolumeLabel' and fallback '$TargetRoot' is unavailable."
  exit 1
} else {
  Write-Host "Could not find volume label '$VolumeLabel'; using fallback $TargetRoot"
}

$targetFile = Join-Path -Path $TargetRoot -ChildPath (Split-Path -Path $SourceFile -Leaf)

Copy-Item -LiteralPath $SourceFile -Destination $targetFile -Force

Write-Host "Copy command completed for $targetFile"
Write-Host "If the keyboard drive disappears now, that usually means flashing started."
POWERSHELL
}

powershell_copy_script_needs_refresh() {
  local ps_script="$1"

  [[ -f "$ps_script" ]] || return 0
  grep -q 'install-right-firmware-helper-version: 3' "$ps_script" && return 1
  return 0
}

run_powershell_copy() {
  local ps_script="$1"
  local source_file="$2"
  local ps_script_win
  local source_file_win

  ps_script_win="$(wslpath -w "$ps_script")"
  source_file_win="$(wslpath -w "$source_file")"

  powershell.exe \
    -NoProfile \
    -ExecutionPolicy Bypass \
    -File "$ps_script_win" \
    -SourceFile "$source_file_win" \
    -TargetRoot "$WINDOWS_TARGET" \
    -VolumeLabel "$WINDOWS_VOLUME_LABEL"
}

run_done_sound() {
  [[ -x "$DONE_SOUND_SCRIPT" ]] || error "Done sound script is not executable: $DONE_SOUND_SCRIPT"

  "$DONE_SOUND_SCRIPT"
}

main() {
  parse_args "$@"

  require_command git
  require_command find
  require_command cp
  require_command wslpath
  validate_number "$POLL_SECONDS" "--poll"
  validate_number "$TIMEOUT_MINUTES" "--timeout"

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || error "Run this script inside the repo"

  [[ -n "$REPO" ]] || infer_repo

  local dry_run=true
  if [[ "$COMMIT" == true && "$DRY_RUN" == false ]]; then
    dry_run=false
  fi

  local head_sha
  local short_sha
  local commit_subject
  local deadline
  local run_id
  local repo_root
  local tmp_dir
  local firmware_path
  local dest_file
  local ps_script
  local vault_path
  local label
  local cached_firmware

  head_sha="$(git rev-parse HEAD)"
  short_sha="$(git rev-parse --short HEAD)"
  commit_subject="$(git log -1 --pretty=%s)"
  deadline="$(( $(date +%s) + TIMEOUT_MINUTES * 60 ))"
  repo_root="$(git rev-parse --show-toplevel)"
  dest_file="${DEST%/}/$FIRMWARE"
  ps_script="${DEST%/}/$PS_SCRIPT_NAME"
  label="$(firmware_label "$FIRMWARE")"
  if [[ "$VAULT_DIR" = /* ]]; then
    vault_path="$VAULT_DIR"
  else
    vault_path="${repo_root%/}/$VAULT_DIR"
  fi

  info "Repo: $REPO"
  info "Workflow: $WORKFLOW"
  info "Commit: $head_sha"
  info "Commit title: $commit_subject"
  info "Target firmware: $FIRMWARE"
  info "Vault: $vault_path"
  info "WSL staging destination: $DEST"
  info "Windows volume label: $WINDOWS_VOLUME_LABEL"
  info "Windows fallback target: $WINDOWS_TARGET"

  if cached_firmware="$(find_cached_firmware "$vault_path" "$short_sha" "$label")"; then
    firmware_path="$cached_firmware"
    info "Using cached firmware: $firmware_path"
  else
    require_command gh
    gh auth status >/dev/null 2>&1 || error "GitHub CLI is not authenticated. Run: gh auth login"

    run_id="$(wait_for_run_id "$head_sha" "$deadline")" || error "No workflow run found for current HEAD before timeout"
    info "GitHub Actions run: $run_id"

    wait_for_run_completion "$run_id" "$deadline"

    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    info "Downloading artifacts..."
    download_artifacts "$run_id" "$tmp_dir"

    firmware_path="$(find_firmware "$tmp_dir")"
    info "Found: $firmware_path"

    if [[ "$dry_run" == true ]]; then
      info "Dry-run: would cache firmware in $vault_path"
    else
      firmware_path="$(cache_firmware "$firmware_path" "$vault_path" "$commit_subject" "$short_sha" "$label")"
      info "Cached firmware: $firmware_path"
    fi
  fi

  if [[ "$dry_run" == true ]]; then
    info "Dry-run: would copy firmware to $dest_file"
    if [[ -f "$ps_script" ]] && ! powershell_copy_script_needs_refresh "$ps_script"; then
      info "Dry-run: would reuse existing PowerShell script at $ps_script"
    elif [[ -f "$ps_script" ]]; then
      info "Dry-run: would refresh old PowerShell script at $ps_script"
    else
      info "Dry-run: would create PowerShell script at $ps_script"
    fi
    info "Dry-run: would run PowerShell to find $WINDOWS_VOLUME_LABEL and copy the firmware there"
    info "Run with --commit to install the firmware."
    exit 0
  fi

  [[ -d "$DEST" ]] || error "Destination does not exist or is not mounted: $DEST"
  [[ -w "$DEST" ]] || error "Destination is not writable: $DEST"
  require_command powershell.exe

  cp "$firmware_path" "$dest_file"
  info "Copied firmware to staging path: $dest_file"

  if [[ -f "$ps_script" ]] && ! powershell_copy_script_needs_refresh "$ps_script"; then
    info "Using existing PowerShell installer: $ps_script"
  elif [[ -f "$ps_script" ]]; then
    write_powershell_copy_script "$ps_script"
    info "Refreshed old PowerShell installer: $ps_script"
  else
    write_powershell_copy_script "$ps_script"
    info "Created PowerShell installer: $ps_script"
  fi

  info "Running done sound before PowerShell installer..."
  run_done_sound

  run_powershell_copy "$ps_script" "$dest_file" || error "PowerShell copy failed"
  info "PowerShell copy completed."

  printf '%s | %s | cwd=%s | action=copy-firmware | target=%s | count=1\n' \
    "$(date -Iseconds)" "$SCRIPT_NAME" "$(pwd)" "$dest_file" >> "$HOME/.scriptcitos-runs.log"
}

main "$@"
