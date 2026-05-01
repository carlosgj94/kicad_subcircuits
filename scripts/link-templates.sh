#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/link-templates.sh [options]

Create symlinks from this repository's templates/ directory into KiCad's
default user template directory.

Options:
  --dry-run             Show what would be changed without changing anything.
  --force               Replace existing symlinks. Real files/directories are never replaced.
  --kicad-version VER   Use a specific KiCad version directory, for example 10.0.
  -h, --help            Show this help.
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

info() {
  printf '%s\n' "$*"
}

dry_run=false
force=false
kicad_version=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    --force)
      force=true
      ;;
    --kicad-version)
      [[ $# -ge 2 ]] || die "--kicad-version requires a value"
      kicad_version="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
  shift
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
source_templates_dir="$repo_root/templates"

[[ -d "$source_templates_dir" ]] || die "template source directory not found: $source_templates_dir"

case "$(uname -s)" in
  Linux)
    data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    kicad_data_root="$data_home/kicad"
    ;;
  Darwin)
    kicad_data_root="$HOME/Library/Application Support/kicad"
    ;;
  *)
    die "unsupported OS for automatic KiCad template detection: $(uname -s)"
    ;;
esac

[[ -d "$kicad_data_root" ]] || die "KiCad data directory not found: $kicad_data_root. Start KiCad once, then rerun this script."

if [[ -n "$kicad_version" ]]; then
  kicad_version_dir="$kicad_data_root/$kicad_version"
  [[ -d "$kicad_version_dir" ]] || die "KiCad version directory not found: $kicad_version_dir"
else
  versions=()
  for dir in "$kicad_data_root"/*; do
    [[ -d "$dir" ]] || continue
    version="${dir##*/}"
    if [[ "$version" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
      versions+=("$version")
    fi
  done

  [[ ${#versions[@]} -gt 0 ]] || die "no KiCad version directories found under: $kicad_data_root"

  latest_version=""
  while IFS= read -r version; do
    latest_version="$version"
  done < <(printf '%s\n' "${versions[@]}" | sort -t. -k1,1n -k2,2n -k3,3n)

  kicad_version_dir="$kicad_data_root/$latest_version"
fi

target_templates_dir="$kicad_version_dir/template"

run() {
  if [[ "$dry_run" == true ]]; then
    printf 'dry-run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

info "Source templates: $source_templates_dir"
info "KiCad template directory: $target_templates_dir"

run mkdir -p "$target_templates_dir"

linked=0
skipped=0

for template_dir in "$source_templates_dir"/*; do
  [[ -d "$template_dir" ]] || continue

  template_name="${template_dir##*/}"
  target_path="$target_templates_dir/$template_name"

  if [[ ! -f "$template_dir/meta/info.html" ]]; then
    warn "skipping $template_name: missing meta/info.html"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ -L "$target_path" ]]; then
    existing_target="$(readlink "$target_path")"
    if [[ "$existing_target" == "$template_dir" ]]; then
      info "already linked: $template_name"
      skipped=$((skipped + 1))
      continue
    fi

    if [[ "$force" == true ]]; then
      run rm "$target_path"
    else
      warn "skipping $template_name: target symlink already exists: $target_path"
      warn "use --force to replace existing symlinks"
      skipped=$((skipped + 1))
      continue
    fi
  elif [[ -e "$target_path" ]]; then
    warn "skipping $template_name: target already exists and is not a symlink: $target_path"
    skipped=$((skipped + 1))
    continue
  fi

  run ln -s "$template_dir" "$target_path"
  if [[ "$dry_run" == true ]]; then
    info "would link: $template_name"
  else
    info "linked: $template_name"
  fi
  linked=$((linked + 1))
done

if [[ "$dry_run" == true ]]; then
  info "Done. Would link: $linked. Skipped: $skipped."
else
  info "Done. Linked: $linked. Skipped: $skipped."
fi
info "If KiCad is already open, reopen the New Project dialog or restart KiCad."
