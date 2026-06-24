# Contributing

Thanks for your interest in contributing!

## Development setup

```bash
git clone <repo>
cd smart-file-organizer

# Install development dependencies
make install-dev  # currently: pre-commit + bats
pre-commit install
```

## Running tests

```bash
make test        # lint + bats
make lint        # shellcheck only
```

## Code style

- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Run ShellCheck (`make lint`) before pushing
- All scripts must pass `set -euo pipefail`
- Keep functions small and single-purpose
- Use local variables in functions
- Environmental config via `SFO_*` variables

## Pull request checklist

1. Run `make check` — all tests pass
2. New features include tests in `tests/`
3. New file categories added to `FILE_TYPES` in `fixfolder.sh`
4. CHANGELOG updated under `[Unreleased]`
5. ShellCheck reports no warnings at `--severity=style`

## Releasing

Maintainers: push a `v*` tag to trigger the release workflow.

```bash
# Update version in fixfolder.sh and CHANGELOG.md
git tag v<new-version>
git push origin v<new-version>
```

The CI will build the release artifact and create a GitHub Release.
