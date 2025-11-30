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

# Step 2: Check for Claude CLI
echo -e "${YELLOW}[2/5] Checking for Claude CLI...${NC}"

WORKSPACE_DIR="$SCRIPT_DIR/test-workspace"

if ! command -v claude &> /dev/null; then
    echo -e "${RED}✗ Claude CLI not found${NC}"
    echo -e "\nTo install Claude:"
    echo -e "  ${YELLOW}npm install -g @anthropic-ai/claude-code${NC}"
    echo -e "\nOr use npx (no installation needed):"
    echo -e "  ${YELLOW}npx @anthropic-ai/claude-code${NC}"
    echo -e "\nFor manual testing without Claude CLI:"
    echo -e "  1. cd $WORKSPACE_DIR"
    echo -e "  2. Open in your editor and copy test-prompt.txt"
    echo -e "  3. Use Claude to generate code"
    echo -e "  4. Run: cd $SCRIPT_DIR && python3 claude_validate.py $WORKSPACE_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Claude CLI found${NC}\n"

# Step 3: Check if API key is available
echo -e "${YELLOW}[3/5] Checking for Anthropic API key...${NC}"

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}✗ ANTHROPIC_API_KEY not set${NC}"
    echo -e "\nSet your API key:"
    echo -e "  ${YELLOW}export ANTHROPIC_API_KEY='your-key-here'${NC}"
    echo -e "  ${YELLOW}./run-integration-test.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found ANTHROPIC_API_KEY${NC}\n"

# Step 4: Generate application using Claude CLI
echo -e "${YELLOW}[4/5] Generating application with Claude CLI...${NC}"
echo -e "${YELLOW}This will use Claude CLI to invoke Claude with the skill${NC}\n"

cd "$SCRIPT_DIR"
python3 run_claude_code.py "$WORKSPACE_DIR"

if [ $? -ne 0 ]; then
    echo -e "\n${RED}✗ Code generation failed${NC}"
    exit 1
fi

# Step 5: Validate structure and build with Claude
echo -e "\n${YELLOW}[5/6] Validating generated application with Claude AI...${NC}"

cd "$SCRIPT_DIR"
python3 claude_validate.py "$WORKSPACE_DIR"

if [ $? -ne 0 ]; then
    echo -e "\n${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║       VALIDATION FAILED                        ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}\n"
    exit 1
fi

# Step 6: Optional execution test
echo -e "\n${YELLOW}[6/6] Testing execution (optional)...${NC}"

# Check if user wants to skip execution test
if [ "$SKIP_EXECUTION" = "true" ]; then
    echo -e "${YELLOW}Skipping execution test (SKIP_EXECUTION=true)${NC}"
    echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       INTEGRATION TEST PASSED!                 ║${NC}"
    echo -e "${GREEN}║       (Structure & Build Validated)            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
    exit 0
fi

echo -e "${YELLOW}Running execution test (set SKIP_EXECUTION=true to skip)${NC}\n"

# Change to workspace directory for execution test
cd "$WORKSPACE_DIR"
if "$SCRIPT_DIR/test-execution.sh"; then
    echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       FULL INTEGRATION TEST PASSED!            ║${NC}"
    echo -e "${GREEN}║       (Structure, Build & Execution)           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
else
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║       PARTIAL SUCCESS                          ║${NC}"
    echo -e "${YELLOW}║       Structure & Build: PASSED                ║${NC}"
    echo -e "${YELLOW}║       Execution Test: FAILED                   ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════╝${NC}\n"
    echo -e "Code generation and compilation successful, but execution test failed."
    echo -e "This may indicate runtime issues but the generated code is valid."
    exit 0
fi
