#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync_codex_skill.sh <sync|check> [skill-name...]

Defaults:
  skill-name: all skills under ./skills
EOF
}

main() {
  if [[ $# -lt 1 ]]; then
    usage >&2
    exit 1
  fi

  local action="$1"
  shift

  local repo_root
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  local source_root="$repo_root/skills"
  local target_root="$repo_root/plugins/thousandeyes/skills"
  local -a selected_skills=()
  local scope="selected"

  mapfile -t selected_skills < <(collect_skills "$source_root" "$@")
  if [[ $# -eq 0 ]]; then
    scope="all"
  fi

  case "$action" in
    sync)
      sync_skills "$source_root" "$target_root" "$scope" "${selected_skills[@]}"
      ;;
    check)
      check_skills "$source_root" "$target_root" "$scope" "${selected_skills[@]}"
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
}

collect_skills() {
  local source_root="$1"
  shift

  local skill_name

  if [[ ! -d "$source_root" ]]; then
    echo "Source skills directory not found: $source_root" >&2
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    find "$source_root" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/SKILL.md" \; -print |
      while IFS= read -r skill_dir; do
        basename "$skill_dir"
      done |
      LC_ALL=C sort
    return 0
  fi

  for skill_name in "$@"; do
    if [[ ! -f "$source_root/$skill_name/SKILL.md" ]]; then
      echo "Source skill directory not found: $source_root/$skill_name" >&2
      return 1
    fi
    printf '%s\n' "$skill_name"
  done
}

list_files() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    (
      cd "$dir"
      find . -type f | LC_ALL=C sort
    )
  fi
}

list_skill_dirs() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    find "$dir" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/SKILL.md" \; -print |
      while IFS= read -r skill_dir; do
        basename "$skill_dir"
      done |
      LC_ALL=C sort
  fi
}

sync_skill_dir() {
  local source_dir="$1"
  local target_dir="$2"
  local relative_path

  mkdir -p "$target_dir"

  while IFS= read -r relative_path; do
    [[ -n "$relative_path" ]] || continue
    mkdir -p "$target_dir/$(dirname "$relative_path")"
    cp "$source_dir/$relative_path" "$target_dir/$relative_path"
  done < <(list_files "$source_dir")

  while IFS= read -r relative_path; do
    [[ -n "$relative_path" ]] || continue
    if [[ ! -f "$source_dir/$relative_path" ]]; then
      rm -f "$target_dir/$relative_path"
    fi
  done < <(list_files "$target_dir")

  find "$target_dir" -depth -type d -empty -delete
  echo "Synced $(basename "$source_dir") into plugins/thousandeyes/skills."
}

check_skill_dir() {
  local source_dir="$1"
  local target_dir="$2"
  local relative_path
  local has_diff=0

  if [[ ! -d "$target_dir" ]]; then
    echo "Codex plugin skill directory is missing: $target_dir" >&2
    return 1
  fi

  while IFS= read -r relative_path; do
    [[ -n "$relative_path" ]] || continue
    if [[ ! -f "$target_dir/$relative_path" ]]; then
      echo "Missing plugin copy: plugins/thousandeyes/skills/${source_dir##*/}/${relative_path#./}" >&2
      has_diff=1
      continue
    fi

    if ! cmp -s "$source_dir/$relative_path" "$target_dir/$relative_path"; then
      echo "Out-of-sync file: plugins/thousandeyes/skills/${source_dir##*/}/${relative_path#./}" >&2
      has_diff=1
    fi
  done < <(list_files "$source_dir")

  while IFS= read -r relative_path; do
    [[ -n "$relative_path" ]] || continue
    if [[ ! -f "$source_dir/$relative_path" ]]; then
      echo "Extra plugin-only file: plugins/thousandeyes/skills/${source_dir##*/}/${relative_path#./}" >&2
      has_diff=1
    fi
  done < <(list_files "$target_dir")

  if [[ "$has_diff" -ne 0 ]]; then
    return 1
  fi

  echo "Codex plugin skill copy is in sync for $(basename "$source_dir")."
}

sync_skills() {
  local source_root="$1"
  local target_root="$2"
  local scope="$3"
  shift 3

  local skill_name

  mkdir -p "$target_root"

  for skill_name in "$@"; do
    sync_skill_dir "$source_root/$skill_name" "$target_root/$skill_name"
  done

  if [[ "$scope" == "all" ]]; then
    while IFS= read -r skill_name; do
      [[ -n "$skill_name" ]] || continue
      if [[ ! -d "$source_root/$skill_name" ]]; then
        rm -rf "$target_root/$skill_name"
        echo "Removed stale Codex plugin skill: $skill_name"
      fi
    done < <(list_skill_dirs "$target_root")
  fi
}

check_skills() {
  local source_root="$1"
  local target_root="$2"
  local scope="$3"
  shift 3

  local skill_name
  local has_diff=0

  for skill_name in "$@"; do
    if ! check_skill_dir "$source_root/$skill_name" "$target_root/$skill_name"; then
      has_diff=1
    fi
  done

  if [[ "$scope" == "all" ]]; then
    while IFS= read -r skill_name; do
      [[ -n "$skill_name" ]] || continue
      if [[ ! -d "$source_root/$skill_name" ]]; then
        echo "Extra plugin-only skill directory: plugins/thousandeyes/skills/$skill_name" >&2
        has_diff=1
      fi
    done < <(list_skill_dirs "$target_root")
  fi
  if [[ "$has_diff" -ne 0 ]]; then
    echo "Codex plugin skill copies are out of sync. Run: bash scripts/sync_codex_skill.sh sync" >&2
    exit 1
  fi
}

main "$@"
