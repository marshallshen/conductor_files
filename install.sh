#!/usr/bin/env bash
# Conductor Files Installation Script
#
# Usage:
#   1. Clone the repository:
#      git clone https://github.com/marshallshen/conductor_files.git ~/.conductor_files
#
#   2. Run the installer:
#      ~/.conductor_files/install.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONDUCTOR_DIR="${HOME}/.conductor_files"
CLAUDE_DIR="${HOME}/.claude"

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

# Step 1: Verify conductor_files directory exists
echo "Step 1: Verifying conductor_files installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "$CONDUCTOR_DIR" ]; then
    print_error "conductor_files not found at $CONDUCTOR_DIR"
    echo ""
    echo "Please clone the repository first:"
    echo "  ${BLUE}git clone https://github.com/marshallshen/conductor_files.git ~/.conductor_files${NC}"
    echo ""
    exit 1
fi

print_success "Found conductor_files at $CONDUCTOR_DIR"

echo ""

# Step 2: Create ~/.claude directory if it doesn't exist
echo "Step 2: Preparing Claude Code directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    print_success "Created $CLAUDE_DIR"
else
    print_info "Claude directory already exists"
fi

echo ""

# Step 3: Backup and symlink skills
echo "Step 3: Configuring skills"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SKILLS_DIR="${CLAUDE_DIR}/skills"
SKILLS_BACKUP="${CLAUDE_DIR}/skills.backup.$(date +%s)"

if [ -e "$SKILLS_DIR" ] && [ ! -L "$SKILLS_DIR" ]; then
    # Skills directory exists and is not a symlink - backup
    print_warning "Found existing skills directory"

    if ask_yes_no "Backup existing skills to $SKILLS_BACKUP?"; then
        mv "$SKILLS_DIR" "$SKILLS_BACKUP"
        print_success "Backed up skills to $SKILLS_BACKUP"
    else
        print_error "Cannot proceed without backing up existing skills"
        exit 1
    fi
elif [ -L "$SKILLS_DIR" ]; then
    # Already a symlink - remove it
    rm "$SKILLS_DIR"
    print_info "Removed existing skills symlink"
fi

# Create symlink
ln -s "${CONDUCTOR_DIR}/skills" "$SKILLS_DIR"
print_success "Symlinked skills: ~/.claude/skills → ~/.conductor_files/skills"

echo ""

# Step 4: Backup and symlink agents
echo "Step 4: Configuring agents"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

AGENTS_DIR="${CLAUDE_DIR}/agents"
AGENTS_BACKUP="${CLAUDE_DIR}/agents.backup.$(date +%s)"

if [ -e "$AGENTS_DIR" ] && [ ! -L "$AGENTS_DIR" ]; then
    # Agents directory exists and is not a symlink - backup
    print_warning "Found existing agents directory"

    if ask_yes_no "Backup existing agents to $AGENTS_BACKUP?"; then
        mv "$AGENTS_DIR" "$AGENTS_BACKUP"
        print_success "Backed up agents to $AGENTS_BACKUP"
    else
        print_error "Cannot proceed without backing up existing agents"
        exit 1
    fi
elif [ -L "$AGENTS_DIR" ]; then
    # Already a symlink - remove it
    rm "$AGENTS_DIR"
    print_info "Removed existing agents symlink"
fi

# Create symlink
ln -s "${CONDUCTOR_DIR}/agents" "$AGENTS_DIR"
print_success "Symlinked agents: ~/.claude/agents → ~/.conductor_files/agents"

echo ""

# Step 5: Optionally configure hooks
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
        print_success "Created ~/.claude/settings.json with base hooks configuration"
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
echo "  - Shared skills: ~/.claude/skills/ → ~/.conductor_files/skills/"
echo "  - Shared agents: ~/.claude/agents/ → ~/.conductor_files/agents/"
if [ -f "$SETTINGS_FILE" ]; then
    echo "  - Hooks config: ~/.claude/settings.json"
fi
echo ""

print_info "Next steps:"
echo ""
echo "  1. Read the philosophy:"
echo "     ${BLUE}cat ~/.conductor_files/WHY.md${NC}"
echo ""
echo "  2. Launch Claude Code and try the skills:"
echo "     ${BLUE}/save-context${NC} - Save your work session"
echo "     ${BLUE}/resume-context${NC} - Resume where you left off"
echo ""
echo "  3. Use a role-based agent:"
echo "     ${BLUE}\"Use the unit-tester agent to create tests for...\"${NC}"
echo ""
echo "  4. Explore hooks:"
echo "     ${BLUE}cat ~/.conductor_files/hooks/README.md${NC}"
echo ""
echo "  5. Update conductor_files:"
echo "     ${BLUE}cd ~/.conductor_files && git pull${NC}"
echo ""

print_success "Happy conducting! 🎵"
echo ""
