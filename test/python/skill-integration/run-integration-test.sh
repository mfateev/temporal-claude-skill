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

# Check API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    print_error "ANTHROPIC_API_KEY environment variable not set"
    echo ""
    echo "Set it with: export ANTHROPIC_API_KEY='your-key-here'"
    exit 1
fi

print_success "API key found"

# Step 1: Setup workspace
print_step "Setting up test workspace..."
"${SCRIPT_DIR}/setup-test-workspace.sh"

if [ $? -ne 0 ]; then
    print_error "Workspace setup failed"
    exit 1
fi

print_success "Workspace setup complete"
echo ""

# Step 2: Check Python and install anthropic package if needed
print_step "Checking Python environment..."

if ! command -v python3 &> /dev/null; then
    print_error "python3 not found"
    echo "Install Python 3.10 or later"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
print_success "Python $PYTHON_VERSION found"

# Check if anthropic package is installed
if ! python3 -c "import anthropic" 2>/dev/null; then
    print_step "Installing anthropic package..."
    pip3 install anthropic --quiet
    print_success "Installed anthropic package"
else
    print_success "anthropic package already installed"
fi

echo ""

# Step 3: Generate code using Claude API
print_step "Generating code using Claude API..."
echo ""

python3 "${SCRIPT_DIR}/automate_test.py"

if [ $? -ne 0 ]; then
    print_error "Code generation failed"
    exit 1
fi

echo ""
print_success "Code generation complete"
echo ""

# Step 4: Validate generated code
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

# Final summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║             ${GREEN}✅ TEST PASSED${BLUE}                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo "Summary:"
echo "  ✓ Skill files loaded successfully"
echo "  ✓ Claude generated Python code"
echo "  ✓ Generated code validated successfully"
echo ""
echo "Generated files location:"
echo "  ${WORKSPACE_DIR}"
echo ""
echo "To inspect the generated code:"
echo "  cd ${WORKSPACE_DIR}"
echo "  ls -la"
echo ""
echo "To run the application (requires Temporal server):"
echo "  cd ${WORKSPACE_DIR}"
echo "  pip install -r requirements.txt  # or poetry install"
echo "  python3 worker.py  # in one terminal"
echo "  python3 client.py  # in another terminal"
