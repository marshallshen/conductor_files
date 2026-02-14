# Hooks Guide

Hooks are shell commands that execute automatically in response to Claude Code tool events. They're one of the most powerful features for customizing your conductor workflow.

## What Are Hooks?

Hooks let you:
- **Auto-format code** after editing (Prettier, Black, rustfmt)
- **Block dangerous operations** (prevent editing .env files)
- **Enforce quality gates** (run linters, type checkers)
- **Notify your team** (Slack/Discord when tests fail)
- **Automate workflows** (git add after edits, update docs)

Hooks transform Claude Code from a powerful tool into a **personalized engineering assistant** that enforces your standards automatically.

## Hook Types

### PostToolUse

Runs **after** a tool completes successfully.

**Common uses:**
- Format code after editing
- Run linters/type checkers
- Update generated files (package-lock.json, etc.)
- Notify on completion

**Example:**
```json
{
  "matcher": "Edit:**/*.ts",
  "hooks": [
    {
      "type": "command",
      "command": "prettier --write {file_path}",
      "description": "Format TypeScript files"
    }
  ]
}
```

### PreToolUse

Runs **before** a tool executes (can block the operation).

**Common uses:**
- Block edits to sensitive files (.env, secrets)
- Warn before destructive operations
- Check permissions
- Validate file paths

**Example:**
```json
{
  "matcher": "Edit:.env*",
  "hooks": [
    {
      "type": "block",
      "message": "⚠️ Don't edit .env files. Use .env.example instead."
    }
  ]
}
```

### Notification

Runs when specific events occur (for external notifications).

**Common uses:**
- Slack/Discord messages
- Email notifications
- System notifications
- Logging to external systems

## Matchers

Matchers determine when hooks run. They follow this pattern:

```
<ToolName>:<pattern>
```

### Tool Names

- `Edit`: File edits
- `Write`: File creation
- `Read`: File reads
- `Bash`: Shell commands
- `Glob`: File pattern searches
- `Grep`: Content searches

### Patterns

**Glob patterns:**
- `**/*.ts` - All TypeScript files
- `*.py` - Python files in current directory
- `src/**/*.{js,jsx}` - JavaScript/JSX in src/
- `.env*` - All .env files

**Examples:**
```json
// Match TypeScript edits
"matcher": "Edit:**/*.ts"

// Match Python file writes
"matcher": "Write:**/*.py"

// Match any .env file edit
"matcher": "Edit:.env*"

// Match files with "secret" in name
"matcher": "Edit:**/*secret*"

// Match specific directory
"matcher": "Edit:src/components/**"
```

## Hook Actions

### Command Hook

Runs a shell command.

**Available variables:**
- `{file_path}` - The file being operated on
- `{tool}` - The tool name (Edit, Write, etc.)
- `{project_root}` - The project root directory

**Example:**
```json
{
  "type": "command",
  "command": "prettier --write {file_path}",
  "description": "Format file with Prettier"
}
```

**Multi-command:**
```json
{
  "type": "command",
  "command": "prettier --write {file_path} && eslint --fix {file_path}",
  "description": "Format and lint"
}
```

### Block Hook

Prevents the tool from executing and shows a message.

**Example:**
```json
{
  "type": "block",
  "message": "⚠️ This file contains secrets. Edit .env.example instead."
}
```

**When to use:**
- Protect sensitive files (.env, credentials)
- Prevent accidental deletions
- Enforce file naming conventions
- Block operations in protected directories

## Configuration

### Global Hooks

Edit `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit:**/*.ts",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write {file_path}",
            "description": "Format TypeScript"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit:.env*",
        "hooks": [
          {
            "type": "block",
            "message": "Don't edit .env files directly"
          }
        ]
      }
    ]
  }
}
```

### Project-Specific Hooks

Create `.claude/settings.json` in your project:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit:src/**/*.tsx",
        "hooks": [
          {
            "type": "command",
            "command": "npm run type-check",
            "description": "Type check after React edits"
          }
        ]
      }
    ]
  }
}
```

Project hooks **merge** with global hooks (both run).

## Common Patterns

### Auto-Formatting

**TypeScript/JavaScript:**
```json
{
  "matcher": "Edit:**/*.{ts,tsx,js,jsx}",
  "hooks": [
    {
      "type": "command",
      "command": "prettier --write {file_path}",
      "description": "Format with Prettier"
    }
  ]
}
```

**Python:**
```json
{
  "matcher": "Edit:**/*.py",
  "hooks": [
    {
      "type": "command",
      "command": "black {file_path}",
      "description": "Format with Black"
    }
  ]
}
```

**Rust:**
```json
{
  "matcher": "Edit:**/*.rs",
  "hooks": [
    {
      "type": "command",
      "command": "rustfmt {file_path}",
      "description": "Format with rustfmt"
    }
  ]
}
```

### Security Blocks

**Prevent .env edits:**
```json
{
  "matcher": "Edit:.env*",
  "hooks": [
    {
      "type": "block",
      "message": "⚠️ Don't edit .env files. Use .env.example instead."
    }
  ]
}
```

**Block files with "secret" in name:**
```json
{
  "matcher": "Edit:**/*secret*",
  "hooks": [
    {
      "type": "block",
      "message": "⚠️ Blocked: File name contains 'secret'"
    }
  ]
}
```

**Protect credentials:**
```json
{
  "matcher": "Edit:**/*credential*",
  "hooks": [
    {
      "type": "block",
      "message": "⚠️ Don't edit credential files directly"
    }
  ]
}
```

### Linting and Type Checking

**ESLint:**
```json
{
  "matcher": "Edit:**/*.{ts,tsx,js,jsx}",
  "hooks": [
    {
      "type": "command",
      "command": "eslint --fix {file_path}",
      "description": "Lint and auto-fix"
    }
  ]
}
```

**TypeScript:**
```json
{
  "matcher": "Edit:**/*.{ts,tsx}",
  "hooks": [
    {
      "type": "command",
      "command": "tsc --noEmit",
      "description": "Type check project"
    }
  ]
}
```

**Python mypy:**
```json
{
  "matcher": "Edit:**/*.py",
  "hooks": [
    {
      "type": "command",
      "command": "mypy {file_path}",
      "description": "Type check with mypy"
    }
  ]
}
```

### Git Automation

**Auto-stage edits:**
```json
{
  "matcher": "Edit:**/*",
  "hooks": [
    {
      "type": "command",
      "command": "git add {file_path}",
      "description": "Stage edited file"
    }
  ]
}
```

**Update package lock after package.json:**
```json
{
  "matcher": "Edit:package.json",
  "hooks": [
    {
      "type": "command",
      "command": "npm install",
      "description": "Update package-lock.json"
    }
  ]
}
```

### Notifications

**Slack notification on test edit:**
```json
{
  "matcher": "Edit:**/*.test.ts",
  "hooks": [
    {
      "type": "command",
      "command": "curl -X POST -H 'Content-Type: application/json' -d '{\"text\":\"Tests updated: {file_path}\"}' $SLACK_WEBHOOK_URL",
      "description": "Notify Slack"
    }
  ]
}
```

## Example Configurations

See the `examples/` directory for ready-to-use configurations:

- **[typescript.json](./examples/typescript.json)** - Prettier formatting, ESLint, type checking
- **[python.json](./examples/python.json)** - Black formatting, isort, mypy
- **[security.json](./examples/security.json)** - Block .env edits, protect secrets

### Using Examples

1. Choose an example configuration
2. Copy the hooks from the example
3. Merge into your `~/.claude/settings.json`

**Example merge:**

```bash
# Your current ~/.claude/settings.json
{
  "hooks": {
    "PostToolUse": []
  }
}

# Add TypeScript hooks from examples/typescript.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit:**/*.{ts,tsx,js,jsx}",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write {file_path}",
            "description": "Format with Prettier"
          }
        ]
      }
    ]
  }
}
```

## Best Practices

### Performance

**❌ Don't run slow commands on every edit:**
```json
// This will slow down every edit!
{
  "matcher": "Edit:**/*.ts",
  "hooks": [
    {
      "type": "command",
      "command": "npm test",  // Runs entire test suite
      "description": "Run tests"
    }
  ]
}
```

**✅ Keep hooks fast:**
```json
// Only format the edited file
{
  "matcher": "Edit:**/*.ts",
  "hooks": [
    {
      "type": "command",
      "command": "prettier --write {file_path}",
      "description": "Format file"
    }
  ]
}
```

### Specificity

**❌ Too broad:**
```json
{
  "matcher": "Edit:**/*",  // Matches everything!
  "hooks": [...]
}
```

**✅ Specific matchers:**
```json
{
  "matcher": "Edit:**/*.{ts,tsx}",  // Only TypeScript
  "hooks": [...]
}
```

### Error Handling

**Hooks that fail will show errors but won't block the tool.** If a hook must succeed:

```json
{
  "type": "command",
  "command": "prettier --write {file_path} || (echo 'Prettier failed!' && exit 1)",
  "description": "Format (required)"
}
```

### Testing Hooks

Test hooks before committing:

1. Add a hook to `~/.claude/settings.json`
2. Use Claude Code to trigger it (e.g., edit a file)
3. Verify the command runs as expected
4. Check for errors in Claude Code output

## Troubleshooting

### Hook Not Running

1. **Check matcher syntax**: Make sure pattern matches your file
2. **Check tool name**: `Edit`, `Write`, `Read`, etc. (case-sensitive)
3. **Check JSON syntax**: Validate with `jq` or a JSON linter
4. **Check command**: Test the command manually in terminal

### Command Fails

1. **Check command exists**: `which prettier`, `which black`
2. **Check file path**: Use `echo {file_path}` to debug
3. **Check working directory**: Commands run from project root
4. **Check permissions**: Ensure command has necessary permissions

### Performance Issues

1. **Identify slow hooks**: Check which commands take long
2. **Limit scope**: Use specific matchers to reduce hook frequency
3. **Optimize commands**: Use `--only-changed` flags if available
4. **Run async**: Some tools support background processing

## Advanced Examples

### Conditional Execution

```json
{
  "matcher": "Edit:**/*.ts",
  "hooks": [
    {
      "type": "command",
      "command": "[ -f .prettierrc ] && prettier --write {file_path}",
      "description": "Format if prettier config exists"
    }
  ]
}
```

### Multiple Commands

```json
{
  "matcher": "Edit:**/*.ts",
  "hooks": [
    {
      "type": "command",
      "command": "prettier --write {file_path} && eslint --fix {file_path} && tsc --noEmit",
      "description": "Format, lint, and type check"
    }
  ]
}
```

### Project-Specific Scripts

```json
{
  "matcher": "Edit:src/**/*.tsx",
  "hooks": [
    {
      "type": "command",
      "command": "npm run validate",
      "description": "Run project validation script"
    }
  ]
}
```

## Summary

**Hooks are powerful** because they:
- Automate repetitive tasks
- Enforce quality standards
- Protect against mistakes
- Integrate with your existing tools

**Start simple:**
1. Pick one formatting hook (Prettier, Black, rustfmt)
2. Add one security block (.env protection)
3. Test and iterate

**Expand gradually:**
- Add linting/type checking
- Set up notifications
- Create project-specific workflows

---

**Remember:** Hooks turn Claude Code into an extension of your engineering judgment, automatically enforcing standards you'd otherwise have to remember and apply manually.
