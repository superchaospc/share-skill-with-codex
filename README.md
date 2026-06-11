<h1 align="center">share-skill-with-codex</h1>

<p align="center">
  🔗 一个让你所有 Claude Code skill 同时在 Codex 自动触发的 skill —— 软链共享，而非重写<br>
  <i>Install once — make all your Claude Code skills auto-trigger in Codex too, via symlink not <code>AGENTS.md</code> rewrite.</i>
</p>

<p align="center">
  <a href="https://github.com/superchaospc/share-skill-with-codex/releases"><img src="https://img.shields.io/github/v/release/superchaospc/share-skill-with-codex?sort=semver" alt="release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <img src="https://img.shields.io/badge/Claude%20Code-skill-d97757" alt="Claude Code skill">
  <img src="https://img.shields.io/badge/Codex-skill-412991" alt="Codex skill">
  <img src="https://img.shields.io/badge/shell-bash-4EAA25?logo=gnu-bash&logoColor=white" alt="bash">
  <br>
  <img src="https://img.shields.io/github/last-commit/superchaospc/share-skill-with-codex" alt="last commit">
  <img src="https://img.shields.io/github/stars/superchaospc/share-skill-with-codex?style=social" alt="stars">
  <img src="https://img.shields.io/github/issues/superchaospc/share-skill-with-codex" alt="issues">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs welcome">
</p>

<p align="center"><b><a href="#中文">中文</a> · <a href="#english">English</a></b></p>

---

## 中文

### 这是什么

[Claude Code](https://claude.com/claude-code) 和 Codex 用的是**完全相同的 skill 格式**：一个带 `name:` + `description:` frontmatter 的 `SKILL.md`，靠 description 做自动发现与触发。它们唯一的区别是**扫描的目录不一样**：

| 工具 | skill 目录 |
|------|-----------|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/`、`~/.agents/skills/` |

所以你为其中一个写的 skill，在另一个里**看不到、也不会触发**——直到它也出现在对方的目录里。

`share-skill-with-codex` 就是来解决这件事的：装上它之后，你写的每个 skill 都能被自动接到 Codex 的目录，从而在**两边都自动触发**，一次编写、处处可用。

### 为什么用软链，而不是改写成 AGENTS.md

因为两边格式本来就一样，**软链是唯一正确做法**：

- ✅ **单一源头**——一份文件,两个工具都读它,永不分叉。
- ✅ 改一次，两边同步。
- ❌ 如果把 skill「移植/改写」成 `AGENTS.md`，会**丢掉 `name`/`description` frontmatter**，破坏 Codex 的自动发现，还多出一份会逐渐走样的副本。

### 安装

**一键安装**（推荐）：

```bash
git clone https://github.com/superchaospc/share-skill-with-codex \
  ~/.claude/skills/share-skill-with-codex
~/.claude/skills/share-skill-with-codex/install.sh
```

`install.sh` 会自动完成「自举本 skill + 接上全部已有 skill」。等价于手动三步：

```bash
# 1. 放进 Claude Code 的 skills 目录
git clone https://github.com/superchaospc/share-skill-with-codex \
  ~/.claude/skills/share-skill-with-codex
# 2. 自举：把本 skill 自己先接进 Codex（解决「鸡和蛋」，只需一次）
~/.claude/skills/share-skill-with-codex/scripts/link-skill --bootstrap
# 3. 把你已有的全部旧 skill 一次性接上
~/.claude/skills/share-skill-with-codex/scripts/link-skill --all
```

完成后**重开一个 Codex 会话**让它重新扫描目录即可。

#### 4.（推荐）开启全自动 —— 配 SessionStart hook

上面的步骤仍要手动跑一次。想**彻底免手动**（以后写/装任何 skill 都自动同步到 Codex），给 Claude Code 加一个 **SessionStart hook**，每次启动自动跑 `link-skill --all`。编辑 `~/.claude/settings.json`，把下面的 `SessionStart` 并入已有的 `hooks`（**不要覆盖其它 hook**）：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/skills/share-skill-with-codex/scripts/link-skill --all >/dev/null 2>&1 || true"
          }
        ]
      }
    ]
  }
}
```

配好后**重启 Claude Code**（或打开一次 `/hooks` 重载配置）即可生效。命令幂等、静默、失败也不会卡住启动。详见下方 [自动化](#自动化无人值守)。

之后再写新 skill，启动时自动同步、零手动。临时想手动接单个也行：

```bash
~/.claude/skills/share-skill-with-codex/scripts/link-skill <skill-name>
```

### 命令一览

| 命令 | 作用 |
|------|------|
| `link-skill <名称\|路径>` | 把某个 skill 接进各个 agent 目录 |
| `link-skill --all` | 把 Claude Code 目录下所有 skill 全部接上 |
| `link-skill --bootstrap` | 接入本 skill 自身（首次安装用） |
| `link-skill -n <名称>` | 预演（dry-run）：只校验 + 预览，不改动 |
| `link-skill -u <名称>` | 解除链接（不动 Claude Code 源文件） |
| `link-skill -h` | 帮助 |

环境变量（一般用不到）：`CLAUDE_SKILLS_DIR` 改源目录，`AGENT_SKILL_DIRS` 自定义目标目录（空格/冒号分隔，可适配其他读 `SKILL.md` 的 agent）。

### 特性

- **可移植**：没装 Codex 的机器会被安全跳过，不会乱建目录。
- **幂等**：重复执行无副作用。
- **安全**：目标处若已是**真实目录**（非软链），跳过并告警，绝不覆盖。
- **零依赖**：纯 bash，无需 Python/Node。

### 常见问题

**Q：跑 `--all` 时一堆红色 ✗ 是报错吗？**
不是。那表示目标目录里已存在同名的**真实目录**（之前实体拷贝进去的），脚本选择跳过而非覆盖——它们本来就能被 Codex 发现，无需再软链。

**Q：链接完 Codex 还是看不到？**
Codex 在**启动时**扫描 skill 目录。重开一个新会话即可。

**Q：这能保证「每次存盘自动链接」吗？**
单靠 skill 不能——skill 是「agent 决定参考时」才触发的。要做到**确定性、无人值守**，用下面的 hook。

### 自动化（无人值守）

`install.sh` 仍要手动跑一次。若想**完全免手动**——任何 skill 一出现就自动同步到 Codex——给 Claude Code 配一个 **SessionStart hook**，每次启动自动跑 `link-skill --all`。编辑 `~/.claude/settings.json`：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/skills/share-skill-with-codex/scripts/link-skill --all >/dev/null 2>&1 || true"
          }
        ]
      }
    ]
  }
}
```

这样存量 + 新增 skill 都会在每次会话启动时自动接好，你再不用手动跑。hook 由 harness 确定性执行，不依赖 agent 是否「想起来」。脚本本身幂等，重复跑无副作用。

> 注：这是 **Claude Code 侧**的 hook，覆盖「在 Claude Code 里写/装 skill」这个最常见场景。在 Codex 里新建的 skill，可在 Codex 侧配类似 hook，或在下次 Claude Code 启动时被 `--all` 一并补上。

---

## English

### What it is

[Claude Code](https://claude.com/claude-code) and Codex use the **identical skill format**: a `SKILL.md` with `name:` + `description:` frontmatter, auto-discovered by that description. They differ only in which directories they scan:

| Tool | Skill dir(s) |
|------|--------------|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/`, `~/.agents/skills/` |

A skill written for one is **invisible** to the other until it also lives in the other's dir.

`share-skill-with-codex` fixes that: install it once, and every skill you write gets linked into Codex's dirs — so it auto-triggers in **both** tools. Write once, run anywhere.

### Why symlink, not AGENTS.md

Because the format is already identical, a **symlink is the correct fix**:

- ✅ **One source of truth** — one file, both tools read it, never forks.
- ✅ Edit once, both stay in sync.
- ❌ Rewriting a skill into `AGENTS.md` **strips the `name`/`description` frontmatter**, breaks Codex auto-discovery, and spawns a second copy that drifts.

### Install

**One-liner** (recommended):

```bash
git clone https://github.com/superchaospc/share-skill-with-codex \
  ~/.claude/skills/share-skill-with-codex
~/.claude/skills/share-skill-with-codex/install.sh
```

`install.sh` bootstraps this skill and links all your existing skills. Equivalent manual steps:

```bash
# 1. Put it in Claude Code's skills dir
git clone https://github.com/superchaospc/share-skill-with-codex \
  ~/.claude/skills/share-skill-with-codex
# 2. Bootstrap: link this skill itself into Codex (chicken-and-egg, one-time)
~/.claude/skills/share-skill-with-codex/scripts/link-skill --bootstrap
# 3. Retrofit every skill you already have
~/.claude/skills/share-skill-with-codex/scripts/link-skill --all
```

Restart Codex (new session) so it rescans.

#### 4. (Recommended) Go fully automatic — add a SessionStart hook

The steps above still run once, by hand. To go **fully hands-off** (every skill you write/install syncs to Codex automatically), add a Claude Code **SessionStart hook** that runs `link-skill --all` on every launch. Edit `~/.claude/settings.json` and merge this `SessionStart` into your existing `hooks` (**don't overwrite other hooks**):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/skills/share-skill-with-codex/scripts/link-skill --all >/dev/null 2>&1 || true"
          }
        ]
      }
    ]
  }
}
```

**Restart Claude Code** (or open `/hooks` once to reload config) to activate. The command is idempotent, silent, and `|| true` so it never blocks startup. See [Automation](#automation-hands-off) below for details.

From then on, new skills sync at launch with zero manual steps. To link one ad-hoc:

```bash
~/.claude/skills/share-skill-with-codex/scripts/link-skill <skill-name>
```

…or just let your agent run it — this skill's description nudges it to fire right after you author a new skill.

### Commands

| Command | Does |
|---------|------|
| `link-skill <name\|path>` | Link one skill into the agent dirs |
| `link-skill --all` | Link every skill in the Claude Code dir |
| `link-skill --bootstrap` | Link this skill itself (first-time install) |
| `link-skill -n <name>` | Dry-run: validate + preview, change nothing |
| `link-skill -u <name>` | Unlink (Claude Code source untouched) |
| `link-skill -h` | Help |

Env (rarely needed): `CLAUDE_SKILLS_DIR` for the source dir, `AGENT_SKILL_DIRS` for custom target dirs (space/colon-separated; works for any agent that reads `SKILL.md`).

### Features

- **Portable** — machines without Codex are skipped (safe no-op, no littering).
- **Idempotent** — re-running changes nothing.
- **Safe** — if a real (non-symlink) dir already occupies the target, it warns and skips, never overwrites.
- **Zero deps** — pure bash, no Python/Node.

### FAQ

**Q: `--all` printed lots of red ✗ — are those errors?**
No. They mean a real directory with that name already exists in the target (an earlier physical copy); the script skips rather than clobbering it. Those skills are already discoverable by Codex.

**Q: Codex still doesn't see it after linking.**
Codex scans skill dirs **at startup**. Open a new session.

**Q: Does this guarantee "link on every save"?**
A skill alone can't — it only fires when the agent chooses to consult it. For **deterministic, hands-off** behavior, use the hook below.

### Automation (hands-off)

`install.sh` still runs once, by hand. To make it **fully automatic** — any skill synced to Codex the moment it appears — add a Claude Code **SessionStart hook** that runs `link-skill --all` on every launch. Edit `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/skills/share-skill-with-codex/scripts/link-skill --all >/dev/null 2>&1 || true"
          }
        ]
      }
    ]
  }
}
```

Now existing and new skills both get linked automatically at session start — no manual step. The hook is run deterministically by the harness, regardless of whether an agent "remembers." The script is idempotent, so repeated runs are harmless.

> Note: this is a **Claude-Code-side** hook, covering the common case of authoring/installing skills inside Claude Code. Skills created inside Codex can use a similar Codex-side hook, or get picked up by the next Claude Code launch via `--all`.

---

## License

[MIT](LICENSE) © superchaospc
