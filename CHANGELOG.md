# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-06-24

### Added
- `--dry-run` / `-n` flag to preview changes without touching files
- `--verbose` / `-v` flag for detailed stderr logging
- `--quiet` / `-q` flag to suppress stdout
- `--log-dir` / `-l` flag for custom log directory
- Environment variable configuration (`SFO_DRY_RUN`, `SFO_LOG_DIR`, `SFO_VERBOSE`, `SFO_QUIET`)
- `set -euo pipefail` and `trap` for fail-fast error handling
- Modular function decomposition (`main`, `parse_args`, `organize_by_category`, etc.)
- Colour output to stderr (Unix-philosophy compliant)
- Absolute path resolution for target directories
- CI/CD pipeline (GitHub Actions): lint, test, Docker, security, release
- Multi-stage Docker image (distroless base, ~5MB)
- `docker-compose.yml` for dev and test workflows
- BATS test suite with 20+ test cases
- ShellCheck linting via pre-commit hooks
- `Makefile` with lint/test/docker/install targets
- `.editorconfig` for cross-editor consistency
- `CHANGELOG.md` (keepachangelog format)
- `CONTRIBUTING.md` contribution guide
- Dependabot configuration for GitHub Actions

### Changed
- Complete rewrite of `fixfolder.sh` with production-grade CLI argument parsing
- `install.sh` now copies `fixfolder.sh` directly instead of embedding as heredoc
- `install.sh` supports `DESTDIR` and `PREFIX` for packaged/staged installs
- Exit codes: 0 (success), 1 (error), 2 (usage error)

### Removed
- Heredoc embedding of main script in installer
- Hardcoded `HOME` in log path (now uses `$HOME` properly)

## [2.0.0] - 2026-01-25

### Added
- Enhanced logging with detailed file tracking
- 100+ file extensions across 17 categories

## [1.0.0] - 2026-01-20

### Added
- Initial release with basic file organisation
- 17 category folders
- Installation script with system-wide and user installs
- MIT License
