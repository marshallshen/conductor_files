---
name: save-context
description: Save a compact context window of current work to TASK.md for later resumption
tools: Bash, Read, Write, Glob, Grep
user-invocable: true
---

You are saving the current work context so it can be resumed later.

## Purpose

This skill creates a compact snapshot of:
- What you're currently working on
- Progress made so far
- Important decisions and context
- Next steps to take
- Relevant file paths and code locations

This allows another AI session (or the same session later) to pick up exactly where you left off.

## Process

### 1. Gather Context

Collect information about the current work:

```bash
# Check git status to see what's changed
git status

# See recent changes
git diff --stat

# Check recent bash history if relevant
# Look at task list if tasks were created
```

### 2. Identify Key Information

Determine:
- **Task description**: What problem are you solving?
- **Current state**: What's been completed? What's in progress?
- **Important context**: Key decisions, architectural choices, dependencies
- **File locations**: Which files are being modified or are relevant
- **Next steps**: What needs to happen next (specific and actionable)
- **Blockers**: Any issues or open questions

### 3. Create Compact Summary

Write a concise but complete context document. Use this structure:

```markdown
# Task Context

## Objective
[One sentence: What is being built/fixed/improved]

## Current Status
- ✅ Completed: [List completed items]
- 🔄 In Progress: [Current work]
- ⏳ Next Steps: [Specific next actions]

## Key Context
[Important background, decisions, or constraints]

## Files Modified/Relevant
- `path/to/file.ts:42` - [Brief note about why this matters]
- `path/to/other.py` - [Brief note]

## Technical Notes
[Any important technical decisions, patterns being used, or gotchas]

## Questions/Blockers
[Any open questions or blockers, if applicable]

---
Last updated: [Current date/time]
```

### 4. Write to TASK.md

Save the context to `TASK.md` in the current working directory:

```bash
# Get current directory
pwd
```

Then use the Write tool to create `./TASK.md` with your summary.

### 5. Confirm with User

Show the user what was saved and confirm:
- File location (full path to TASK.md)
- Brief summary of what was captured
- Reminder that they can use `/resume-context` to load this later

## Best Practices

**Be concise but complete:**
- Don't include unnecessary details
- Focus on what's needed to resume work
- Be specific (file paths, line numbers, function names)

**Make next steps actionable:**
- ❌ Bad: "Continue working on authentication"
- ✅ Good: "Implement password reset flow in `auth/reset.ts`, following OAuth pattern from `auth/login.ts:42-78`"

**Capture decisions:**
- Document why certain approaches were chosen
- Note any trade-offs or alternatives considered
- Include relevant context from CLAUDE.md or discussions

**Keep it current:**
- Update TASK.md as work progresses
- Don't let stale context accumulate

## Example Output

```markdown
# Task Context

## Objective
Add user authentication with JWT tokens to the Express API

## Current Status
- ✅ Completed:
  - Set up JWT library and middleware
  - Created User model with password hashing
  - Implemented /register endpoint
- 🔄 In Progress:
  - Working on /login endpoint validation
- ⏳ Next Steps:
  1. Complete login endpoint with proper error handling
  2. Add refresh token mechanism
  3. Write tests for auth endpoints

## Key Context
- Using bcrypt for password hashing (cost factor 12)
- JWT secret stored in .env (not committed)
- Following REST API patterns from existing /users endpoints
- Auth middleware should be reusable for all protected routes

## Files Modified/Relevant
- `src/routes/auth.ts:1-45` - Auth endpoints (register complete, login in progress)
- `src/models/User.ts:12-34` - Password hashing methods
- `src/middleware/auth.ts:1-28` - JWT verification middleware
- `.env.example:8-9` - JWT_SECRET configuration

## Technical Notes
- Using jsonwebtoken library (already in package.json)
- Tokens expire after 24 hours
- Password must be min 8 chars, validated in User model
- Following existing error response format: { error: "message" }

## Questions/Blockers
- Should we implement refresh tokens now or in a follow-up?
- Need to confirm if we want rate limiting on login attempts

---
Last updated: 2026-02-14 15:30
```

## Important Notes

- **Privacy**: Don't save sensitive data (passwords, API keys, secrets)
- **Location**: Always save to `./TASK.md` in the current working directory
- **Version control**: Users may want to add TASK.md to .gitignore if it's personal notes
- **Overwriting**: Warn user if TASK.md already exists before overwriting

---

**Remember:** Good context saves time. Make it easy for future you (or another AI) to jump right back in.
