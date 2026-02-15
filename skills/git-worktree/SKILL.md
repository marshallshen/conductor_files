---
name: git-worktree
description: Create and manage git worktrees for parallel feature development with multiple agents
tools: Bash, Read, Write, Glob
user-invocable: true
---

You are managing git worktrees to enable parallel development across multiple Claude Code sessions.

## Purpose

**Git worktrees** allow you to work on multiple branches simultaneously without switching contexts. Each worktree is an isolated workspace with its own working directory.

### Why This Matters for Parallel Agent Work

- **Isolation**: Each agent works in its own directory without interfering with others
- **No branch switching**: No need to stash changes or switch branches
- **Parallel development**: Run multiple Claude Code sessions simultaneously on different features
- **Supervisor visibility**: Track progress across all parallel workstreams
- **Clean separation**: Keep experimental work isolated from stable branches

### Key Benefits

- Create new worktrees with one command
- Track all parallel work in one supervisor view
- Update status/progress across all worktrees
- Safe cleanup with uncommitted change detection
- Automatic metadata management

## Commands

This skill supports the following commands (invoked as `/git-worktree $COMMAND`):

- **create** `$FEATURE_NAME ["$TASK_DESCRIPTION"]` - Create new worktree with optional task
- **list** - Show all worktrees (basic git list)
- **status** - Supervisor view: show all worktrees with progress/status
- **update** `$FEATURE_NAME $STATUS` - Update progress status
- **cleanup** `$FEATURE_NAME` - Remove specific worktree
- **cleanup-all** - Remove all skill-created worktrees

## Process for CREATE Command

When user invokes `/git-worktree create $FEATURE_NAME ["$TASK_DESCRIPTION"]`:

### 1. Validate Environment

```bash
# Ensure we're in a git repository
git rev-parse --git-dir 2>/dev/null || echo "Error: Not a git repository"

# Get repository name for path generation
basename $(git rev-parse --show-toplevel)
```

If not in a git repo, show error and exit.

### 2. Parse Arguments

- **$FEATURE_NAME** (required): Short identifier for the feature (e.g., `user-auth`, `blog-feature`)
- **$TASK_DESCRIPTION** (optional): What this worktree is for (e.g., "Implement JWT authentication")

Validate $FEATURE_NAME:
- No spaces (use hyphens or underscores)
- No special characters except `-` and `_`
- Not empty

### 3. Generate Paths and Branch Name

```bash
# Get repo name and current location
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
REPO_DIR=$(git rev-parse --show-toplevel)

# Generate worktree path: ../repo-name-feature-name/
WORKTREE_PATH="${REPO_DIR}/../${REPO_NAME}-${FEATURE_NAME}"

# Generate branch name: feature/feature-name
BRANCH_NAME="feature/${FEATURE_NAME}"
```

### 4. Check for Conflicts

```bash
# Check if path already exists
test -e "$WORKTREE_PATH" && echo "Path exists"

# Check if branch already exists
git rev-parse --verify "$BRANCH_NAME" 2>/dev/null && echo "Branch exists"
```

Handle conflicts:
- **Path exists**: Ask user if they want to use existing directory or choose different name
- **Branch exists**: Offer to use existing branch or create with different name

### 5. Create Worktree

```bash
# Create worktree with new branch
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"

# Or use existing branch
git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
```

### 6. Create Skill Marker

Mark this worktree as created by the skill:

```bash
# Create marker file in git's worktree metadata
WORKTREE_NAME=$(basename "$WORKTREE_PATH")
mkdir -p ".git/worktrees/${WORKTREE_NAME}"
touch ".git/worktrees/${WORKTREE_NAME}/skill-created"
```

### 7. Update Supervisor Metadata

Load or create `.git/worktree-supervisor.json`:

```json
{
  "worktrees": {
    "feature-name": {
      "task": "Implement JWT authentication",
      "path": "../conductor_files-feature-name/",
      "branch": "feature/feature-name",
      "status": "not_started",
      "created": "2026-02-14T10:30:00Z",
      "updated": "2026-02-14T10:30:00Z"
    }
  }
}
```

Use the Write tool to update this file.

### 8. Show Success Message

```
✅ Created worktree: feature-name

📁 Location: /Users/mshen/Projects/conductor_files-feature-name/
🌿 Branch: feature/feature-name
📋 Task: Implement JWT authentication
📊 Status: not_started

Next steps:
1. Open a new terminal or Claude Code session
2. cd /Users/mshen/Projects/conductor_files-feature-name/
3. Start working on the feature in isolation

Track progress with: /git-worktree status
Update status with: /git-worktree update feature-name <status>
```

## Process for LIST Command

When user invokes `/git-worktree list`:

### 1. Get All Worktrees

```bash
# Get structured worktree information
git worktree list --porcelain
```

### 2. Parse Output

Parse the porcelain output:
- `worktree <path>` - Worktree directory
- `branch <branch>` - Current branch
- `HEAD <sha>` - Current commit

### 3. Identify Skill-Created Worktrees

```bash
# Check for our marker file
test -f ".git/worktrees/<name>/skill-created" && echo "skill-created"
```

### 4. Display List

Show worktrees in readable format:

```
📂 Git Worktrees

Main:
  /Users/mshen/Projects/conductor_files (branch: main)

Worktrees:
  ⭐ /Users/mshen/Projects/conductor_files-user-auth (feature/user-auth)
  ⭐ /Users/mshen/Projects/conductor_files-blog-feature (feature/blog-feature)
     /Users/mshen/Projects/manual-worktree (hotfix/bug-123)

⭐ = created by git-worktree skill

Use /git-worktree status for detailed progress view
```

## Process for STATUS Command (Supervisor View)

When user invokes `/git-worktree status`:

### 1. Load Supervisor Metadata

```bash
# Check if metadata file exists
test -f ".git/worktree-supervisor.json" || echo "No tracked worktrees"
```

Use Read tool to load `.git/worktree-supervisor.json`.

### 2. Gather Git Status for Each Worktree

For each worktree in metadata:

```bash
# Check if worktree still exists
test -d "$WORKTREE_PATH" || echo "Missing"

# Get git status
git -C "$WORKTREE_PATH" status --porcelain 2>/dev/null

# Count commits ahead/behind
git -C "$WORKTREE_PATH" rev-list --left-right --count origin/main...HEAD 2>/dev/null
```

### 3. Calculate Time Ago

Parse timestamps and convert to human-readable format:
- "2m ago"
- "1h ago"
- "3d ago"

### 4. Display Status Table

Show comprehensive supervisor view:

```
📊 Worktree Supervisor Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature          Status        Task                        Updated
──────────────────────────────────────────────────────────────────
user-auth        in_progress   Implement JWT auth...       5m ago
blog-feature     not_started   Add blog post UI...         1h ago
api-refactor     review        Refactor endpoints...       2d ago
security-fix     completed     Fix XSS vulnerability       3d ago
──────────────────────────────────────────────────────────────────

Summary: 4 worktrees tracked | 1 in_progress | 1 review | 1 completed | 1 not_started

Status Legend:
  not_started  - Created but no work done yet
  in_progress  - Actively being worked on
  review       - Ready for review/testing
  completed    - Done (ready to cleanup)

Use /git-worktree update $FEATURE_NAME $STATUS to update progress
```

Color coding (using terminal colors):
- Green: completed
- Yellow: in_progress, review
- Gray: not_started
- Red: error/missing path

### 5. Show Warnings

If any worktrees have issues:
- Path no longer exists
- Uncommitted changes
- Significantly behind main branch

## Process for UPDATE Command

When user invokes `/git-worktree update $FEATURE_NAME $STATUS`:

### 1. Validate Arguments

- **$FEATURE_NAME**: Must exist in supervisor metadata
- **$STATUS**: Must be one of: `not_started`, `in_progress`, `review`, `completed`

### 2. Load Current Metadata

Use Read tool to load `.git/worktree-supervisor.json`.

### 3. Update Status

Update the status and timestamp:

```json
{
  "worktrees": {
    "feature-name": {
      "task": "...",
      "status": "in_progress",
      "updated": "2026-02-14T11:45:00Z"
    }
  }
}
```

### 4. Save Updated Metadata

Use Write tool to save `.git/worktree-supervisor.json`.

### 5. Confirm Update

```
✅ Updated status: user-auth

  Status: not_started → in_progress
  Updated: just now

View all status with: /git-worktree status
```

## Process for CLEANUP Command

When user invokes `/git-worktree cleanup $FEATURE_NAME`:

### 1. Validate Feature Exists

Check that feature-name exists in supervisor metadata.

### 2. Get Worktree Path

Load path from metadata file.

### 3. Safety Checks

```bash
# Prevent removing main worktree
CURRENT_DIR=$(pwd)
test "$WORKTREE_PATH" = "$CURRENT_DIR" && echo "Error: Cannot remove current worktree"

# Check for uncommitted changes
CHANGES=$(git -C "$WORKTREE_PATH" status --porcelain)
test -n "$CHANGES" && echo "Warning: Uncommitted changes exist"

# Check for unpushed commits
UNPUSHED=$(git -C "$WORKTREE_PATH" log origin/main..HEAD --oneline 2>/dev/null)
test -n "$UNPUSHED" && echo "Warning: Unpushed commits exist"
```

### 4. Warn User if Changes Exist

If uncommitted changes or unpushed commits:

```
⚠️  Warning: Uncommitted changes detected in user-auth

Changed files:
  M  src/auth.ts
  A  src/login.ts

Uncommitted changes will be lost. Continue? (y/N)
```

Ask user for confirmation before proceeding.

### 5. Remove Worktree

```bash
# Remove worktree (force if user confirmed)
git worktree remove "$WORKTREE_PATH" --force

# Remove branch if orphaned (optional, ask user)
git branch -d "$BRANCH_NAME"
```

### 6. Update Supervisor Metadata

Remove the feature from `.git/worktree-supervisor.json`:

```json
{
  "worktrees": {
    // Remove the feature-name entry
  }
}
```

Use Write tool to save updated metadata.

### 7. Confirm Cleanup

```
✅ Removed worktree: user-auth

  Path: /Users/mshen/Projects/conductor_files-user-auth/ (deleted)
  Branch: feature/user-auth (kept - run 'git branch -d feature/user-auth' to remove)

Remaining worktrees: 2

View with: /git-worktree status
```

## Process for CLEANUP-ALL Command

When user invokes `/git-worktree cleanup-all`:

### 1. Load All Tracked Worktrees

Read `.git/worktree-supervisor.json` to get all features.

### 2. Show Summary

```
⚠️  This will remove ALL skill-created worktrees:

  - user-auth (in_progress, uncommitted changes)
  - blog-feature (not_started, clean)
  - api-refactor (completed, clean)

Total: 3 worktrees

This action cannot be undone. Continue? (y/N)
```

### 3. Confirm with User

Require explicit confirmation.

### 4. Remove Each Worktree

For each worktree, follow the same process as CLEANUP command:
- Check for uncommitted changes
- Warn for each worktree with changes
- Remove worktrees one by one
- Log results

### 5. Clear Supervisor Metadata

Reset `.git/worktree-supervisor.json`:

```json
{
  "worktrees": {}
}
```

### 6. Show Results

```
✅ Cleanup complete

Removed: 3 worktrees
  ✓ user-auth
  ✓ blog-feature
  ✓ api-refactor

Branches kept (delete manually if needed):
  - feature/user-auth
  - feature/blog-feature
  - feature/api-refactor
```

## Safety Checks

Always enforce these safety measures:

### Prevent Removing Current Directory
```bash
# Never remove the worktree you're currently in
test "$WORKTREE_PATH" = "$(pwd)" && exit 1
```

### Warn for Uncommitted Changes
```bash
# Check for any changes
git -C "$WORKTREE_PATH" status --porcelain | grep -q . && echo "Changes exist"
```

### Validate Paths
```bash
# Ensure path exists before removing
test -d "$WORKTREE_PATH" || echo "Path doesn't exist"
```

### Handle Locked Worktrees
```bash
# Git may lock worktrees during operations
git worktree remove "$PATH" 2>&1 | grep -q "locked" && echo "Worktree is locked"
```

If worktree is locked, inform user and suggest:
```bash
git worktree unlock "$WORKTREE_PATH"
```

## Error Handling

Handle common errors gracefully:

### Not in Git Repository
```
❌ Error: Not in a git repository

This command must be run from within a git repository.

Current directory: /Users/mshen/Projects/non-git-folder/
```

### Worktree Path Already Exists
```
❌ Error: Path already exists

The path already exists: /Users/mshen/Projects/conductor_files-user-auth/

Options:
  1. Use a different feature name
  2. Remove the existing directory manually
  3. Use /git-worktree list to see existing worktrees
```

### Feature Name Doesn't Exist
```
❌ Error: Feature not found

No worktree tracked with name: user-authen

Did you mean?
  - user-auth
  - user-profile

Use /git-worktree status to see all tracked worktrees
```

### Worktree Doesn't Exist
```
⚠️  Warning: Worktree path not found

The tracked worktree doesn't exist at: /Users/mshen/Projects/conductor_files-user-auth/

This may have been removed manually. Clean up metadata? (y/N)
```

## Best Practices

### Naming Conventions
- **Use descriptive names**: `user-authentication` not `ua`
- **Use kebab-case**: `blog-post-feature` not `blog_post_feature`
- **Be specific**: `fix-login-validation` not `fix-stuff`

### Worktree Organization
- **One feature per worktree**: Keep worktrees focused
- **Regular cleanup**: Remove completed worktrees to avoid clutter
- **Update status**: Keep supervisor metadata current for visibility

### Task Descriptions
- **Be specific**: "Implement JWT auth with refresh tokens"
- **Not generic**: "Work on auth"
- **Include context**: "Refactor API to use GraphQL (following Apollo docs)"

### Collaboration
- **Communicate status**: Update status when starting/finishing work
- **Check supervisor**: Before creating new worktrees, check what's already in progress
- **Coordinate merges**: Avoid conflicts by knowing what others are working on

### When to Use Worktrees
✅ **Good use cases:**
- Parallel feature development
- Experimental/proof-of-concept work
- Hotfixes while working on features
- Code review (checkout PR in separate worktree)
- Running tests on different branches simultaneously

❌ **Not ideal for:**
- Quick branch switches (just use `git checkout`)
- Single-developer, single-feature work
- Very small, single-file changes

## Example Workflow

### Scenario: Parallel Development on Multiple Features

```bash
# Create worktrees for three separate features
/git-worktree create user-auth "Implement JWT authentication with refresh tokens"
/git-worktree create blog-posts "Add blog post CRUD endpoints and UI"
/git-worktree create analytics "Integrate Google Analytics tracking"

# Check supervisor status
/git-worktree status

# Output:
# 📊 Worktree Supervisor Status
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Feature        Status        Task                        Updated
# ──────────────────────────────────────────────────────────────
# user-auth      not_started   Implement JWT auth...       30s ago
# blog-posts     not_started   Add blog post CRUD...       20s ago
# analytics      not_started   Integrate Google An...      10s ago
# ──────────────────────────────────────────────────────────────
# Summary: 3 worktrees tracked | 0 in_progress | 0 completed

# Open terminal 1: Work on user-auth
cd ../conductor_files-user-auth/
# Use Claude Code to implement authentication
# ... agent works, makes commits ...

# Back in main terminal: Update status
/git-worktree update user-auth in_progress

# Open terminal 2: Work on blog-posts
cd ../conductor_files-blog-posts/
# Use Claude Code to build blog features
# ... agent works ...

/git-worktree update blog-posts in_progress

# Check progress from main worktree
/git-worktree status

# Output:
# 📊 Worktree Supervisor Status
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Feature        Status        Task                        Updated
# ──────────────────────────────────────────────────────────────
# user-auth      in_progress   Implement JWT auth...       5m ago
# blog-posts     in_progress   Add blog post CRUD...       2m ago
# analytics      not_started   Integrate Google An...      6m ago
# ──────────────────────────────────────────────────────────────
# Summary: 3 worktrees tracked | 2 in_progress | 0 completed

# When user-auth is complete
/git-worktree update user-auth completed

# Merge to main (from user-auth worktree)
cd ../conductor_files-user-auth/
git push origin feature/user-auth
# Create PR, get reviewed, merge...

# Clean up completed worktree
cd ../conductor_files/  # Back to main
/git-worktree cleanup user-auth

# Continue with other features...
```

## Important Notes

### Git Behavior
- **Worktrees share .git directory**: All worktrees share the same repository metadata
- **Cannot checkout same branch twice**: Each worktree must have a unique branch
- **Submodules work**: Submodules are supported but need separate `git submodule update` in each worktree

### File System
- **Disk space**: Each worktree is a full checkout (uses disk space)
- **Location**: Worktrees are created at `../<repo-name>-<feature-name>/`
- **Absolute paths**: Git stores absolute paths, so don't move worktrees

### Metadata Management
- **Supervisor file**: Stored at `.git/worktree-supervisor.json`
- **Not in version control**: This file is local to your machine
- **Marker files**: Skill-created worktrees have `.git/worktrees/<name>/skill-created`
- **Manual edits**: You can manually edit the supervisor JSON if needed

### Limitations
- **Local only**: Worktrees are local; other developers won't see them
- **Shared config**: Git config is shared across all worktrees
- **Index locks**: Only one git operation at a time per repository

### Integration with Other Tools
- **IDEs**: Open each worktree as a separate window/project
- **Claude Code**: Run separate Claude Code sessions in different worktrees
- **CI/CD**: Worktrees don't affect CI/CD (branches are what matter)

---

**Remember:** Worktrees enable true parallel development. Each agent gets isolated workspace, and the supervisor view keeps everything organized.
