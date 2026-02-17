---
name: clear-context
description: Delete TASK.md to clear saved context and start fresh
tools: Bash
user-invocable: true
---

You are clearing the saved work context by deleting TASK.md.

## Purpose

This skill removes the `TASK.md` file from the current working directory, allowing you to:
- Start a fresh context without old notes
- Clean up completed work
- Remove stale or outdated context

## Process

### 1. Ensure TASK.md is in .gitignore

Before deleting, ensure TASK.md won't accidentally get committed in the future:

```bash
# Check if .gitignore exists and if TASK.md is already in it
if [ -f .gitignore ]; then
  if ! grep -q "^TASK\.md$" .gitignore; then
    echo "TASK.md" >> .gitignore
    echo "✓ Added TASK.md to .gitignore"
  fi
else
  echo "TASK.md" > .gitignore
  echo "✓ Created .gitignore and added TASK.md"
fi
```

### 2. Check if TASK.md Exists

Verify if there's a TASK.md file to delete:

```bash
ls -lh TASK.md 2>/dev/null
```

### 3. Handle Two Scenarios

#### Scenario A: TASK.md Found

If TASK.md exists:

1. **Show what will be deleted** (file size, last modified date)
2. **Delete the file**:
   ```bash
   rm TASK.md
   ```
3. **Confirm deletion**:
   ```bash
   ls TASK.md 2>/dev/null || echo "✓ TASK.md has been deleted"
   ```
4. **Inform user**:
   ```
   ✓ Context cleared

   TASK.md has been deleted. You're starting with a clean slate.

   Use /save-context anytime to save your progress.
   ```

#### Scenario B: TASK.md Not Found

If TASK.md doesn't exist:

1. **Inform user** that there's nothing to clear:
   ```
   No TASK.md found

   There's no saved context to clear in this directory.

   Use /save-context to create one when you're ready to save progress.
   ```

### 4. Verify .gitignore Status

After deletion, confirm .gitignore is properly configured:

```bash
# Verify TASK.md is in .gitignore
grep "^TASK\.md$" .gitignore && echo "✓ TASK.md is in .gitignore"
```

## Example Interaction

### When TASK.md Exists:

```
✓ Context cleared

TASK.md has been deleted (was 2.4 KB, last modified 2 hours ago)

You're starting with a clean slate.

Use /save-context anytime to save your progress.
```

### When TASK.md Doesn't Exist:

```
No TASK.md found

There's no saved context to clear in this directory.

Use /save-context to create one when you're ready to save progress.
```

## Best Practices

**Be clear about deletion:**
- Show file size/timestamp before deleting
- Confirm successful deletion
- Let user know they can recreate with /save-context

**Protect from accidental commits:**
- Always ensure TASK.md is in .gitignore before deleting
- This prevents future accidental commits

**Keep it simple:**
- No confirmation prompt needed (user explicitly invoked /clear-context)
- Quick and straightforward operation
- Clear success/failure messaging

## Safety Notes

- **No recovery**: Once deleted, TASK.md cannot be recovered (it's not version controlled)
- **Local only**: Only affects the current working directory
- **Git safety**: Ensures TASK.md is in .gitignore to prevent accidental commits

---

**Remember:** Use this when you want to start fresh or clean up completed work. You can always create a new context with `/save-context`.
