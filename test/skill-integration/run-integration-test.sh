#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}╔════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  Temporal Java Skill Integration Test         ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════╝${NC}\n"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Step 1: Setup workspace
echo -e "${YELLOW}[1/4] Setting up test workspace...${NC}"
./setup-test-workspace.sh
echo -e "${GREEN}✓ Workspace ready${NC}\n"

# Step 2: Check if Claude Code is available
echo -e "${YELLOW}[2/4] Checking for Claude Code...${NC}"

WORKSPACE_DIR="$SCRIPT_DIR/test-workspace"

# Check if we're already in a Claude Code session
if [ -n "$CLAUDE_SESSION" ] || [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "${GREEN}✓ Running in Claude Code environment${NC}\n"
    CLAUDE_AVAILABLE=true
else
    # Try to find claude command
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓ Claude CLI found${NC}\n"
        CLAUDE_AVAILABLE=true
    else
        echo -e "${YELLOW}! Claude Code CLI not found${NC}"
        echo -e "${YELLOW}! This test requires manual interaction with Claude Code${NC}\n"
        CLAUDE_AVAILABLE=false
    fi
fi

if [ "$CLAUDE_AVAILABLE" = false ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Manual Test Instructions:${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "1. Open the test workspace in Claude Code:"
    echo -e "   ${YELLOW}cd $WORKSPACE_DIR${NC}"
    echo -e "   ${YELLOW}claude-code .${NC}  (or open in your IDE with Claude Code)\n"
    echo -e "2. In Claude Code, send this prompt:"
    echo -e "   ${YELLOW}cat test-prompt.txt${NC} and send the content to Claude\n"
    echo -e "3. After Claude generates the code, validate it:"
    echo -e "   ${YELLOW}./validate.sh${NC}\n"
    echo -e "4. If validation passes, the test is successful!\n"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    echo -e "Test workspace is ready at: ${GREEN}$WORKSPACE_DIR${NC}"
    exit 0
fi

# Step 3: Generate application using Claude Code (if available)
echo -e "${YELLOW}[3/4] Generating application with Claude Code...${NC}"

cd "$WORKSPACE_DIR"

# Read the prompt
PROMPT=$(cat test-prompt.txt)

# Try to invoke Claude Code
# Note: This is a placeholder - actual implementation depends on Claude Code CLI interface
echo -e "${YELLOW}Invoking Claude Code...${NC}"
echo -e "${YELLOW}(This step requires Claude Code CLI with API access)${NC}\n"

# If you have Claude Code CLI, you could do something like:
# claude-code --workspace . --prompt "$PROMPT" --output generated-app

echo -e "${RED}Automated invocation not yet implemented.${NC}"
echo -e "${YELLOW}Please manually run Claude Code in the workspace directory.${NC}\n"

# Step 4: Validate (will be manual for now)
echo -e "${YELLOW}[4/4] After Claude generates the code, run:${NC}"
echo -e "   cd $WORKSPACE_DIR"
echo -e "   ./validate.sh"
echo -e ""

exit 0
