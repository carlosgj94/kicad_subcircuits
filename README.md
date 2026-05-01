# KiCad Subcircuits

This repository is a personal KiCad starter kit. Its goal is to collect the
templates, subcircuits, reusable components, and project defaults that make a
new KiCad installation useful immediately.

The practical motivation is simple: when setting up KiCad on a new desktop, or
when starting a new board, I want to begin from known-good material instead of
rediscovering paths, design rules, library setup, and manufacturer-specific
details each time.

This is also a learning repository. Some parts may start as experiments or
rough drafts while I learn how to build proper KiCad symbols, footprints,
templates, and reusable circuit blocks. The point is to make that learning
visible and reusable instead of leaving it scattered across one-off projects.

## Goals

- Keep useful KiCad project templates in one place.
- Build a library of reusable subcircuits and components.
- Capture manufacturer-specific defaults, starting with JLCPCB.
- Make new KiCad installations easier to bootstrap.
- Avoid relying on memory for KiCad's many configuration and library paths.
- Eventually provide a setup script that installs or links everything into the
  right KiCad locations automatically.

## Current Contents

```text
templates/
  JLCPCB_1-2Layer_Template/
```

`JLCPCB_1-2Layer_Template` is a starting point for 1-2 layer boards intended
for JLCPCB manufacturing. It includes template metadata and board defaults
based on the upstream KiCad template from Seth Hillbrand's `kicad_templates`
repository.

Before relying on any manufacturer template for production, verify the current
manufacturer capabilities and design rules. Fabrication rules can change, and
older templates may need updates for newer KiCad versions.

## Intended Structure

The repository will likely grow toward this shape:

```text
templates/        KiCad project templates
subcircuits/      Reusable schematic blocks and reference circuits
symbols/          Custom KiCad symbols
footprints/       Custom KiCad footprints
worksheets/       Drawing sheets and title block layouts
docs/             Notes about design decisions and KiCad setup
scripts/          Future setup/import automation
```

This structure may change as the project becomes more concrete.

## Templates

KiCad only detects templates from its template directories. Templates in this
repository will not automatically appear in KiCad until they are linked into
KiCad's user template directory.

Run the template linker from the repository root:

```sh
./scripts/link-templates.sh --dry-run
./scripts/link-templates.sh
```

The script finds KiCad's default user template directory for the newest
installed KiCad version and creates symlinks from this repository's
`templates/` directory into it. On this Linux setup, that destination is
expected to look like:

```text
~/.local/share/kicad/10.0/template
```

The script intentionally does not edit KiCad configuration files. If a user has
moved KiCad's template directory somewhere custom, this script does not try to
discover that override.

Useful options:

```sh
./scripts/link-templates.sh --kicad-version 10.0
./scripts/link-templates.sh --force
```

`--force` only replaces existing symlinks. It will not replace real files or
directories.

After linking, reopen the New Project dialog or restart KiCad.

## Future Setup Script

KiCad uses several different locations for templates, symbols, footprints,
worksheets, plugins, and configuration. This repository should eventually hide
the remaining complexity behind a broader setup script.

The script should probably:

- Detect the installed KiCad version.
- Locate the user's KiCad configuration directory.
- Register custom symbol and footprint libraries.
- Avoid overwriting existing user configuration without a backup.
- Be repeatable, so it can be run after cloning this repository on a new
  machine.

## Project Philosophy

This is not meant to be a polished public KiCad library from day one. It is a
working collection: useful defaults, notes, experiments, and reusable blocks
that become more reliable over time.

When adding something new, prefer a small useful artifact with clear notes over
a perfect but undocumented one. The repository should explain not only what a
component or template is, but also why it exists and what assumptions it makes.

## Attribution

The `templates/JLCPCB_1-2Layer_Template` template was copied from:

```text
https://github.com/sethhillbrand/kicad_templates/tree/master/JLCPCB_1-2Layer
```

Keep upstream attribution and license requirements in mind when modifying or
redistributing copied templates.
