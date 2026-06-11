# share-skill-with-codex

A Claude Code / Codex skill that makes **your other skills cross-tool**. Install it once and any
skill you write becomes auto-discoverable — and therefore auto-triggerable — in **both** Claude Code
and Codex.

## Why

Claude Code and Codex use the **identical skill format**: a `SKILL.md` file with `name:` +
`description:` frontmatter. They only scan different directories:

| Tool | Skill dir(s) |
|------|--------------|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/`, `~/.agents/skills/` |

A skill written for one is invisible to the other until it's also present in the other's dir. The
right fix is a **symlink** (one source of truth, no fork) — *not* rewriting it into `AGENTS.md`,
which strips the frontmatter and breaks auto-discovery.

This skill bundles `scripts/link-skill`, which validates a skill's frontmatter and symlinks it into
every installed agent's skill dir. It's portable (skips agents that aren't installed), idempotent,
and refuses to clobber real directories.

## Install

```bash
# 1. Put the skill in Claude Code's skills dir
git clone https://github.com/<you>/share-skill-with-codex \
  ~/.claude/skills/share-skill-with-codex

# 2. Bootstrap: link this skill itself into Codex's dirs (chicken-and-egg one-time step)
~/.claude/skills/share-skill-with-codex/scripts/link-skill --bootstrap

# 3. (optional) Retrofit every skill you already have
~/.claude/skills/share-skill-with-codex/scripts/link-skill --all
```

Restart Codex (new session) so it rescans. Done — from now on, write a skill and it gets linked to
both tools automatically (the agent fires this skill after authoring), or link manually:

```bash
scripts/link-skill <skill-name>
```

## CLI

```
link-skill <skill-name|path>   link one skill into the agent dirs
link-skill --all               link every skill in the Claude Code dir
link-skill --bootstrap         link this skill itself (first-time install)
link-skill -n <name>           dry-run (validate + preview)
link-skill -u <name>           unlink (Claude Code source untouched)
link-skill -h
```

Env: `CLAUDE_SKILLS_DIR` (source dir), `AGENT_SKILL_DIRS` (custom target dirs).

## License

MIT
