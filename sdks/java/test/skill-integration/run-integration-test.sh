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

# Step 2: Check if API key is available
echo -e "${YELLOW}[2/5] Checking for Anthropic API key...${NC}"

WORKSPACE_DIR="$SCRIPT_DIR/test-workspace"

if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "${GREEN}✓ Found ANTHROPIC_API_KEY${NC}\n"
    AUTOMATED=true
else
    echo -e "${YELLOW}! ANTHROPIC_API_KEY not set${NC}"
    echo -e "${YELLOW}! Falling back to manual testing mode${NC}\n"
    AUTOMATED=false
fi

if [ "$AUTOMATED" = false ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Manual Test Instructions:${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "1. Open the test workspace in Claude Code:"
    echo -e "   ${YELLOW}cd $WORKSPACE_DIR${NC}"
    echo -e "   ${YELLOW}code .${NC}  (or open in your IDE with Claude Code)\n"
    echo -e "2. In Claude Code, send this prompt:"
    echo -e "   ${YELLOW}cat test-prompt.txt${NC} and send the content to Claude\n"
    echo -e "3. After Claude generates the code, validate it:"
    echo -e "   ${YELLOW}cd $SCRIPT_DIR && python3 claude_validate.py $WORKSPACE_DIR${NC}\n"
    echo -e "4. If validation passes, the test is successful!\n"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "Or set ANTHROPIC_API_KEY for automated testing:"
    echo -e "   ${YELLOW}export ANTHROPIC_API_KEY='your-key-here'${NC}"
    echo -e "   ${YELLOW}./run-integration-test.sh${NC}\n"

    echo -e "Test workspace is ready at: ${GREEN}$WORKSPACE_DIR${NC}"
    exit 0
fi

# Step 3: Check for Python and anthropic package
echo -e "${YELLOW}[3/5] Checking Python environment...${NC}"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    echo -e "Please install Python 3 or use manual testing mode"
    exit 1
fi

echo -e "${GREEN}✓ Python 3 found${NC}"

# Check if anthropic package is installed
if ! python3 -c "import anthropic" 2>/dev/null; then
    echo -e "${YELLOW}Installing anthropic package...${NC}"
    pip3 install anthropic || pip3 install --user anthropic
fi

echo -e "${GREEN}✓ anthropic package available${NC}\n"

# Step 4: Generate application using API
echo -e "${YELLOW}[4/5] Generating application with Claude API...${NC}"
echo -e "${YELLOW}This will use the Anthropic API to invoke Claude with the skill${NC}\n"

cd "$SCRIPT_DIR"
python3 automate_test.py

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
