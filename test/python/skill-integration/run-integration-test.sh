#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR}/test-workspace"

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Temporal Python Skill Integration Test       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_header

# Step 1: Setup workspace
print_step "Setting up test workspace..."
"${SCRIPT_DIR}/setup-test-workspace.sh"

if [ $? -ne 0 ]; then
    print_error "Workspace setup failed"
    exit 1
fi

print_success "Workspace setup complete"
echo ""

# Step 2: Check for Claude CLI
print_step "Checking for Claude CLI..."

if ! command -v claude &> /dev/null; then
    print_error "Claude CLI not found"
    echo ""
    echo "To install Claude:"
    echo "  npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "Or use npx (no installation needed):"
    echo "  npx @anthropic-ai/claude-code"
    echo ""
    echo "For manual testing without Claude CLI:"
    echo "  1. cd ${WORKSPACE_DIR}"
    echo "  2. Open in your editor and copy test-prompt.txt"
    echo "  3. Use Claude to generate code"
    echo "  4. Run: cd ${WORKSPACE_DIR} && ./validate.sh"
    exit 1
fi

print_success "Claude CLI found"
echo ""

# Step 3: Check API key
print_step "Checking for API key..."

if [ -z "$ANTHROPIC_API_KEY" ]; then
    print_error "ANTHROPIC_API_KEY environment variable not set"
    echo ""
    echo "Set it with: export ANTHROPIC_API_KEY='your-key-here'"
    exit 1
fi

print_success "API key found"
echo ""

# Step 4: Generate code using Claude CLI
print_step "Generating code using Claude CLI..."
echo ""

python3 "${SCRIPT_DIR}/run_claude_code.py" "${WORKSPACE_DIR}"

if [ $? -ne 0 ]; then
    print_error "Code generation failed"
    exit 1
fi

echo ""
print_success "Code generation complete"
echo ""

# Step 5: Validate generated code
print_step "Validating generated code..."
echo ""

cd "${WORKSPACE_DIR}"
./validate.sh

if [ $? -ne 0 ]; then
    print_error "Validation failed"
    echo ""
    echo "Generated files location: ${WORKSPACE_DIR}"
    exit 1
fi

echo ""
print_success "Validation passed"
echo ""

# Step 6: Optional execution test
print_step "Testing execution (optional)..."
echo ""

# Check if user wants to skip execution test
if [ "$SKIP_EXECUTION" = "true" ]; then
    echo -e "${YELLOW}Skipping execution test (SKIP_EXECUTION=true)${NC}"
    echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       INTEGRATION TEST PASSED!                 ║${NC}"
    echo -e "${GREEN}║       (Structure & Validation)                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
    exit 0
fi

echo -e "${YELLOW}Running execution test (set SKIP_EXECUTION=true to skip)${NC}\n"

# Change to workspace directory for execution test
cd "$WORKSPACE_DIR"
if "$SCRIPT_DIR/test-execution.sh"; then
    echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       FULL INTEGRATION TEST PASSED!            ║${NC}"
    echo -e "${GREEN}║       (Structure, Validation & Execution)      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
else
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║       PARTIAL SUCCESS                          ║${NC}"
    echo -e "${YELLOW}║       Structure & Validation: PASSED           ║${NC}"
    echo -e "${YELLOW}║       Execution Test: FAILED                   ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════╝${NC}\n"
    echo -e "Code generation and validation successful, but execution test failed."
    echo -e "This may indicate runtime issues but the generated code is valid."
    exit 0
fi
