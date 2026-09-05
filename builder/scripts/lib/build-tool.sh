# shellcheck shell=bash
# =============================================================================
# build-tool.sh — shared git clone helpers for build-time provisioning
#
# NOTE: the first-run helper scripts (srsran-install, yatebts-install, ...)
# are generated from heredocs and execute after boot — they cannot source
# this lib and must stay self-contained. Use these helpers only in code that
# runs at build time.
#
#   clone_if_missing <url> <dir> [git-args...]   — fatal-on-failure clone guard
#   clone_bg <url> <dir>                          — start background clone
#   wait_clones <label>                           — wait, report failures, return rc
# =============================================================================

GIT_QUIET_ARGS=(--depth 1)

clone_if_missing() {
  local url="$1" dir="$2"; shift 2
  if [ -d "$dir" ]; then
    echo "  [clone] $dir already present — skipping"
    return 0
  fi
  echo "  [clone] $dir"
  if ! git clone "${GIT_QUIET_ARGS[@]}" "$@" "$url" "$dir"; then
    echo "  [clone] FAILED: $url" >&2
    return 1
  fi
}

# Track in-flight background clones (bash arrays, name -> pid)
declare -A _BG_CLONE_PIDS 2>/dev/null || true

clone_bg() {
  local url="$1" dir="$2"; shift 2 || true
  if [ -d "$dir" ]; then
    echo "  [clone] $dir already present — skipping"
    return 0
  fi
  (
    if ! git clone "${GIT_QUIET_ARGS[@]}" "$@" "$url" "$dir" 2>/dev/null; then
      echo "  [clone] FAILED: $url" >&2
      exit 1
    fi
  ) &
  _BG_CLONE_PIDS["$(basename "$dir")"]=$!
}

wait_clones() {
  local label="${1:-clones}" name fail=0
  for name in "${!_BG_CLONE_PIDS[@]}"; do
    if ! wait "${_BG_CLONE_PIDS[$name]}"; then
      echo "  $label: clone failed: $name" >&2
      fail=1
    fi
  done
  _BG_CLONE_PIDS=()
  return "$fail"
}
