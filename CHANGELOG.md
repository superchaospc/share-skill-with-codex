# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] — 2026-06-11

### Added
- **`install.sh`** — one-shot setup that runs `--bootstrap` then `--all` in a single command.
- **`--all`** flag — bulk-link every skill in the Claude Code dir into the agent dirs.
- **`--bootstrap`** flag — link the skill itself (resolves the chicken-and-egg first install).
- **Bilingual README** (中文 / English) with badges, directory-comparison tables, command
  reference, features, and FAQ.
- **Automation docs** — a *SessionStart hook* that runs `link-skill --all` on every Claude Code
  launch, for deterministic, hands-off syncing. Promoted to install step 4.

### Changed
- `link-skill` is now **portable**: agent dirs that aren't installed are skipped (safe no-op, no
  littering), with an optional `AGENT_SKILL_DIRS` / `CLAUDE_SKILLS_DIR` override.

## [1.0.0] — 2026-06-11

### Added
- Initial release.
- **`link-skill`** — validates a skill's `SKILL.md` frontmatter (`name:` + `description:`) and
  symlinks it into Codex's skill dirs (`~/.codex/skills`, `~/.agents/skills`) so a single source of
  truth auto-triggers in both Claude Code and Codex — no `AGENTS.md` rewrite.
- Idempotent re-linking; refuses to overwrite a real (non-symlink) directory.
- Flags: `-n` (dry-run), `-u` (unlink).
- `SKILL.md` describing when to trigger, MIT `LICENSE`, README.

[Unreleased]: https://github.com/superchaospc/share-skill-with-codex/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/superchaospc/share-skill-with-codex/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/superchaospc/share-skill-with-codex/releases/tag/v1.0.0
