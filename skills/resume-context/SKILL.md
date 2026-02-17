---
name: resume-context
description: Load saved context from TASK.md to resume previous work
tools: Bash, Read, Glob
user-invocable: true
---

You are resuming work from a previously saved context.

## Purpose

This skill checks for a `TASK.md` file in the current working directory and loads the saved context, allowing you to seamlessly continue previous work.

## Process

### 1. Check for TASK.md

First, verify if TASK.md exists in the current directory:

```bash
# Check if TASK.md exists
ls -la TASK.md 2>/dev/null || echo "No TASK.md found"
```

### 2. Handle Two Scenarios

#### Scenario A: TASK.md Found

If TASK.md exists:

1. **Ensure TASK.md is in .gitignore** to prevent accidental commits:
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

2. **Read the file** using the Read tool
3. **Parse the content** to understand:
   - What was being worked on
   - Current progress status
   - Next steps planned
   - Relevant files and locations
   - Important context and decisions
   - Any blockers or questions

4. **Present summary to user** in a clear format:

```
📋 Resuming Previous Work

Objective: [What was being built]

Progress:
  ✅ Completed: [List]
  🔄 In Progress: [Current work]

Next Steps:
  1. [First action]
  2. [Second action]

Key Files:
  - path/to/file.ts:42
  - path/to/other.py

[Any important context, decisions, or blockers]

Ready to continue? Let me know which next step to tackle first.
```

5. **Offer to start** on the next step or ask user what they want to focus on

6. **Verify context is current** by checking:
   - Do the mentioned files still exist?
   - Has git state changed significantly?
   - Is the context still relevant?

If context seems stale (e.g., many days old, files changed drastically):
- Inform the user
- Suggest updating TASK.md with `/save-context`

#### Scenario B: No TASK.md Found

If TASK.md doesn't exist:

1. **Inform the user** that no saved context was found
2. **Offer alternatives**:
   - "Would you like to describe what you're working on?"
   - "I can help you get started - what would you like to build?"
   - "You can use `/save-context` later to save your progress"

3. **Check for other context clues**:
   - Recent git commits (what was worked on recently)
   - Modified files (git status)
   - CLAUDE.md in the project (project-level context)
   - README.md (project description)

### 3. Validate Saved Context

Before proceeding, verify the saved context is actionable:

- **Check file paths**: Do the mentioned files exist?
  ```bash
  # Verify key files exist
  test -f path/to/file.ts && echo "✓ Found" || echo "✗ Missing: path/to/file.ts"
  ```

- **Check git state**: Has the repository changed significantly?
  ```bash
  git status
  git log --oneline -5
  ```

- **Check timestamps**: How old is the context?
  ```bash
  ls -lh TASK.md
  ```

If there are discrepancies:
- Inform the user
- Ask if they want to update the context
- Suggest using `/save-context` to refresh

### 4. Ready to Resume

Once context is loaded and validated:

1. **Summarize the situation** clearly
2. **Highlight the immediate next step** from the saved context
3. **Ask user** which direction to take:
   - Continue with planned next steps
   - Pivot to something else
   - Update the context first

## Example Interaction

### When TASK.md Exists:

```
📋 Resuming Previous Work

I found saved context from earlier work!

Objective: Add user authentication with JWT tokens to the Express API

Progress:
  ✅ Completed:
    - Set up JWT library and middleware
    - Created User model with password hashing
    - Implemented /register endpoint

  🔄 In Progress:
    - Working on /login endpoint validation

Next Steps:
  1. Complete login endpoint with proper error handling
  2. Add refresh token mechanism
  3. Write tests for auth endpoints

Key Files:
  - src/routes/auth.ts:1-45 (login endpoint in progress)
  - src/models/User.ts:12-34 (password hashing)
  - src/middleware/auth.ts:1-28 (JWT verification)

Important Context:
  - Using bcrypt (cost factor 12)
  - JWT secret in .env
  - Following REST patterns from /users endpoints

Open Question: Should we implement refresh tokens now or later?

Last saved: 2 hours ago

✓ All mentioned files verified to exist
✓ Git state unchanged since save

Ready to continue! Should I:
1. Complete the /login endpoint with error handling (next step)
2. Address the refresh token question first
3. Something else?
```

### When TASK.md Doesn't Exist:

```
📋 No Saved Context Found

I don't see a TASK.md file in this directory.

However, I can see:
  - Recent commit: "Add User model and registration" (3 hours ago)
  - Modified files: src/routes/auth.ts, src/models/User.ts
  - This appears to be an Express API project

Would you like to:
1. Tell me what you're working on, and I'll help you continue
2. Review recent changes to understand the current state
3. Start something new

(Tip: Use /save-context when you want to save your progress for later!)
```

## Best Practices

**Always validate:**
- Check that files mentioned in TASK.md still exist
- Verify the context is current (not weeks old)
- Confirm git state hasn't diverged significantly

**Be helpful:**
- If context is stale, offer to update it
- If files are missing, help user understand what changed
- If blockers are listed, offer to help resolve them

**Don't assume:**
- Always confirm with user before taking action
- Ask which next step they want to tackle
- Respect that plans may have changed

**Keep context fresh:**
- Suggest updating TASK.md as work progresses
- Remind user to save context before ending session

## Important Notes

- **TASK.md location**: Always in current working directory (`./TASK.md`)
- **Multiple projects**: Each project can have its own TASK.md
- **Privacy**: TASK.md might contain sensitive notes - don't share externally
- **Git tracking**: TASK.md is automatically added to .gitignore to prevent accidental commits

---

**Remember:** The goal is to eliminate "What was I working on?" friction and make context switching seamless.
