#!/usr/bin/env bash
# Conductor Files Installation Script
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/marshallshen/conductor_files/main/install.sh)
#
# Or run locally:
#   bash install.sh
#
# This script will:
#   1. Clean up existing ~/.conductor_files and symlinks
#   2. Clone fresh repository
#   3. Create symlinks to ~/.claude/

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONDUCTOR_DIR="${HOME}/.conductor_files"
CLAUDE_DIR="${HOME}/.claude"
REPO_URL="https://github.com/marshallshen/conductor_files.git"

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  🎵 Conductor Files Installation${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"

    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -p "$prompt" -n 1 -r
    echo

    if [ "$default" = "y" ]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Main installation steps
print_header

# Step 1: Cleanup existing installation
echo "Step 1: Cleanup existing installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

NEEDS_CLEANUP=false

# Check for existing conductor_files
if [ -d "$CONDUCTOR_DIR" ]; then
    print_warning "Found existing conductor_files at $CONDUCTOR_DIR"
    NEEDS_CLEANUP=true
fi

# Check for existing symlinks
if [ -L "${CLAUDE_DIR}/skills" ]; then
    print_warning "Found existing skills symlink at ~/.claude/skills"
    NEEDS_CLEANUP=true
fi

if [ -L "${CLAUDE_DIR}/agents" ]; then
    print_warning "Found existing agents symlink at ~/.claude/agents"
    NEEDS_CLEANUP=true
fi

# Check for non-symlink directories that need backup
SKILLS_DIR="${CLAUDE_DIR}/skills"
AGENTS_DIR="${CLAUDE_DIR}/agents"
SKILLS_BACKUP=""
AGENTS_BACKUP=""

if [ -e "$SKILLS_DIR" ] && [ ! -L "$SKILLS_DIR" ]; then
    SKILLS_BACKUP="${CLAUDE_DIR}/skills.backup.$(date +%s)"
    print_warning "Found existing skills directory (not a symlink)"
    NEEDS_CLEANUP=true
fi

if [ -e "$AGENTS_DIR" ] && [ ! -L "$AGENTS_DIR" ]; then
    AGENTS_BACKUP="${CLAUDE_DIR}/agents.backup.$(date +%s)"
    print_warning "Found existing agents directory (not a symlink)"
    NEEDS_CLEANUP=true
fi

if [ "$NEEDS_CLEANUP" = true ]; then
    echo ""
    if ask_yes_no "Remove existing installation and install fresh?"; then
        # Backup non-symlink directories
        if [ -n "$SKILLS_BACKUP" ]; then
            mv "$SKILLS_DIR" "$SKILLS_BACKUP"
            print_success "Backed up skills to $SKILLS_BACKUP"
        fi

        if [ -n "$AGENTS_BACKUP" ]; then
            mv "$AGENTS_DIR" "$AGENTS_BACKUP"
            print_success "Backed up agents to $AGENTS_BACKUP"
        fi

        # Remove symlinks
        [ -L "${CLAUDE_DIR}/skills" ] && rm "${CLAUDE_DIR}/skills"
        [ -L "${CLAUDE_DIR}/agents" ] && rm "${CLAUDE_DIR}/agents"

        # Remove conductor_files
        if [ -d "$CONDUCTOR_DIR" ]; then
            rm -rf "$CONDUCTOR_DIR"
            print_success "Removed existing conductor_files"
        fi
    else
        print_error "Installation cancelled"
        exit 1
    fi
else
    print_info "No existing installation found"
fi

echo ""

# Step 2: Clone fresh repository
echo "Step 2: Clone conductor_files repository"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if git clone "$REPO_URL" "$CONDUCTOR_DIR"; then
    print_success "Successfully cloned conductor_files to $CONDUCTOR_DIR"
else
    print_error "Failed to clone repository"
    exit 1
fi

echo ""

# Step 3: Create ~/.claude directory if needed
echo "Step 3: Preparing Claude Code directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    print_success "Created $CLAUDE_DIR"
else
    print_info "Claude directory already exists"
fi

echo ""

# Step 4: Create symlinks
echo "Step 4: Creating symlinks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ln -s "${CONDUCTOR_DIR}/skills" "${CLAUDE_DIR}/skills"
print_success "Created symlink: ~/.claude/skills → ~/.conductor_files/skills"

ln -s "${CONDUCTOR_DIR}/agents" "${CLAUDE_DIR}/agents"
print_success "Created symlink: ~/.claude/agents → ~/.conductor_files/agents"

echo ""

# Step 5: Configure hooks (optional)
echo "Step 5: Configuring hooks (optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
HOOKS_SETTINGS="${CONDUCTOR_DIR}/hooks/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    print_info "Found existing settings.json at $SETTINGS_FILE"
    print_info "You can manually merge hooks from:"
    print_info "  - ${CONDUCTOR_DIR}/hooks/settings.json"
    print_info "  - ${CONDUCTOR_DIR}/hooks/examples/*.json"
    print_info "See ${CONDUCTOR_DIR}/hooks/README.md for details"
else
    if ask_yes_no "Create default hooks configuration?"; then
        cp "$HOOKS_SETTINGS" "$SETTINGS_FILE"
        print_success "Created ~/.claude/settings.json with hooks configuration"
        print_info "You can add more hooks from ${CONDUCTOR_DIR}/hooks/examples/"
    else
        print_info "Skipping hooks configuration"
        print_info "You can set up hooks later by copying ${HOOKS_SETTINGS}"
    fi
fi

echo ""

# Step 6: Success message
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_info "What's installed:"
echo "  - conductor_files: ~/.conductor_files/"
echo "  - skills symlink: ~/.claude/skills/ → ~/.conductor_files/skills/"
echo "  - agents symlink: ~/.claude/agents/ → ~/.conductor_files/agents/"
if [ -f "$SETTINGS_FILE" ]; then
    echo "  - hooks config: ~/.claude/settings.json"
fi
if [ -n "$SKILLS_BACKUP" ]; then
    echo "  - skills backup: $SKILLS_BACKUP"
fi
if [ -n "$AGENTS_BACKUP" ]; then
    echo "  - agents backup: $AGENTS_BACKUP"
fi
echo ""

print_info "Next steps:"
echo ""
echo "  1. Read the philosophy:"
echo -e "     ${BLUE}cat ~/.conductor_files/WHY.md${NC}"
echo ""
echo "  2. Launch Claude Code and try the skills:"
echo -e "     ${BLUE}/save-context${NC} - Save your work session"
echo -e "     ${BLUE}/resume-context${NC} - Resume where you left off"
echo -e "     ${BLUE}/git-worktree create feature-name \"description\"${NC} - Parallel development"
echo ""
echo "  3. Use a role-based agent:"
echo -e "     ${BLUE}\"Use the blog-writer agent to create a post...\"${NC}"
echo ""
echo "  4. Explore hooks:"
echo -e "     ${BLUE}cat ~/.conductor_files/hooks/README.md${NC}"
echo ""
echo "  5. Update conductor_files:"
echo -e "     ${BLUE}cd ~/.conductor_files && git pull${NC}"
echo ""

print_success "Happy conducting! 🎵"
echo ""
