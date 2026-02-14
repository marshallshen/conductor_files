# Conductor Files

**Dotfiles for AI Conductors**

> You are not a software engineer anymore. You are a conductor. The keyboard is no longer your instrument. It's your baton.

**Tailored specifically for [Claude Code](https://www.anthropic.com/claude/code)** - Anthropic's official CLI for Claude.

## Philosophy

Software engineering is experiencing a fundamental identity shift: from **problem solvers who write code** to **business conductors who orchestrate AI agents**.

Just as a conductor doesn't play instruments but shapes how an orchestra performs, you don't write every line of code—you define what should be built, how it should work, and whether it meets quality standards.

**Read the full philosophy:** [WHY.md](./WHY.md)

## Installation

Install with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/marshalshen/conductor_files/main/install.sh | bash
```

This installs:
- **Skills**: `/save-context`, `/resume-context` - Save and resume work sessions
- **Agents**: `unit-tester`, `security-reviewer`, `ui-ux-reviewer`
- **Hooks**: Auto-formatting, security blocks, quality gates

Everything symlinks to `~/.claude/` and works immediately with Claude Code

## What's Next

After installation:

1. **Try the skills**: `/save-context` and `/resume-context` in Claude Code
2. **Use an agent**: "Use the security-reviewer agent to audit this code"
3. **Explore hooks**: See `~/.conductor_files/hooks/examples/`
4. **Customize**: Fork this repo and make it yours

**Learn more:**
- Full philosophy: [WHY.md](./WHY.md)
- Hooks guide: [hooks/README.md](./hooks/README.md)
- Claude Code docs: [docs.anthropic.com/claude/docs/claude-code](https://docs.anthropic.com/claude/docs/claude-code)

---

**You are not a software engineer anymore. You are a conductor.**

Pick up the baton. Start conducting.

---

MIT License - See [LICENSE](./LICENSE)
