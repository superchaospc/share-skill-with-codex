---
name: share-skill-with-codex
description: >-
  Give newly written Claude Code skills the ability to ALSO auto-trigger inside Codex, by symlinking
  them into Codex's skill directories. Use this WHENEVER a skill has just been created or finished in
  the Claude Code skills dir (including right after the skill-creator workflow), or when the user says
  things like "让这个 skill 在 codex 也能用", "share/link this skill with codex", "make this skill
  cross-tool", "两边都能用", "为什么 codex 看不到我新写的 skill", or asks how to make Claude Code and
  Codex share skills. Claude Code and Codex use the IDENTICAL skill format, so the fix is always a
  symlink — NEVER rewrite the skill into AGENTS.md (that strips the frontmatter and breaks Codex
  auto-discovery). Trigger proactively right after authoring any skill even if the user doesn't ask,
  since a Claude-Code-only skill is invisible to Codex until it is linked.
---

# Share a skill with Codex

Claude Code and Codex use the **exact same skill format** — a `SKILL.md` entry file with `name:` +
`description:` YAML frontmatter for auto-discovery. They differ only in which directories they scan:

- Claude Code: `~/.claude/skills/`
- Codex: `~/.codex/skills/` and `~/.agents/skills/`

So a skill authored in `~/.claude/skills/` is invisible to Codex until it also exists in Codex's
dirs. The correct, zero-maintenance fix is a **symlink**, giving both tools one source of truth that
never forks. **Do not** "port"/"rewrite" a skill into an `AGENTS.md`: that drops the frontmatter
Codex needs to auto-trigger and spawns a second copy that drifts out of sync.

## The capability this skill provides

Once this skill is installed and bootstrapped (see below), the workflow becomes automatic: whenever
a new skill is written, this skill should fire and link it into Codex's dirs — so the skill
auto-triggers in **both** tools with no extra effort from the user.

## How to link a skill

Run the bundled script (it lives next to this SKILL.md, in `scripts/`). From the skill's own
directory:

```bash
scripts/link-skill <skill-name>
```

The script:
1. Resolves the source (defaults to `~/.claude/skills/<skill-name>`; an explicit path also works).
2. **Validates** it — confirms `SKILL.md` exists and its frontmatter carries both `name:` and
   `description:`. If validation fails, fix the skill first; an unparseable skill won't trigger in
   either tool.
3. Symlinks the skill dir into each installed agent dir (`~/.codex/skills/`, `~/.agents/skills/`).

It is **portable and safe**: agent dirs that don't exist on this machine are skipped (no littering),
it's idempotent (re-linking is a no-op), and it refuses to overwrite a real non-symlink directory.

## Installing this skill (one-time bootstrap)

When this skill is first dropped into `~/.claude/skills/`, Codex can't see it yet — and it's the
thing that does the linking (chicken-and-egg). Resolve it once by having the script link itself:

```bash
~/.claude/skills/share-skill-with-codex/scripts/link-skill --bootstrap
```

After that, both tools have this skill, and every future skill gets linked automatically. Tell the
user to **restart Codex / open a new Codex session** so it rescans its skill dirs.

To retrofit skills that already existed before installing this one:

```bash
scripts/link-skill --all      # link every skill in the Claude Code dir into the agent dirs
```

## Useful flags

```bash
scripts/link-skill -n <name>       # dry-run: validate + preview, change nothing
scripts/link-skill -u <name>       # unlink from the agent dirs (Claude Code source untouched)
scripts/link-skill <path/to/skill> # link a skill that lives outside ~/.claude/skills/
scripts/link-skill --bootstrap     # link this very skill (first-time install)
scripts/link-skill --all           # link every Claude Code skill
scripts/link-skill -h
```

Env overrides (rarely needed): `CLAUDE_SKILLS_DIR` for the source dir, `AGENT_SKILL_DIRS` for a
custom space/colon-separated list of target dirs (e.g. another agent that reads SKILL.md skills).

## When NOT to use this

- The skill is meant to stay Claude-Code-only (the user says so).
- The thing being created isn't a skill (a plain script, a plugin, an MCP server) — this skill is
  specifically about the shared `SKILL.md` discovery mechanism.
