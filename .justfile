# Cross-platform (Windows git-bash / Linux/macOS). Uses bash as the shell.
set shell := ["bash", "-uc"]

py := if os() == "windows" { "python" } else { "python3" }

# Build one song: medias+assets -> typ -> pdf -> jpg -> mp4.
# Reuses an existing hand-tuned .typ; use `regen` for a fresh one.
add $name:
	{{py}} scripts/gen.py add "{{name}}"

# Regenerate the .typ from the template, then rebuild.
regen $name:
	{{py}} scripts/gen.py regen "{{name}}"

# Remove generated outputs (pdf/jpg/mp4) for one song. Keeps the .typ.
clean $name:
	{{py}} scripts/gen.py clean "{{name}}"

# Build songs in medias/ without an mp4 (default). Flags:
#   -- --force   overwrite existing mp4
#   -- --only X  only songs matching fnmatch pattern X
#   -- --dry-run list actions without running
all *args:
	{{py}} scripts/gen_all.py {{args}}

# Report media/assets readiness for every song
check:
	{{py}} scripts/check.py
