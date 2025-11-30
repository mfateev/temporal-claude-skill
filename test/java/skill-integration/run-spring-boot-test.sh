#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR}/test-workspace-spring"

print_header() {
    echo -e "${YELLOW}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  Temporal Java Spring Boot Integration Test   ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 1: Setup workspace
setup_workspace() {
    print_step "[1/6] Setting up Spring Boot test workspace..."

    rm -rf "${WORKSPACE_DIR}"
    mkdir -p "${WORKSPACE_DIR}"
    mkdir -p "${WORKSPACE_DIR}/.claude/skills"

    # Copy main skill file
    cp "${SCRIPT_DIR}/../../../../../temporal.md" "${WORKSPACE_DIR}/.claude/skills/"

    # Copy SDK resources
    local sdks_src="${SCRIPT_DIR}/../../../../"
    if [ -d "$sdks_src" ]; then
        cp -r "$sdks_src" "${WORKSPACE_DIR}/.claude/skills/sdks"
    fi

    # Copy Spring Boot prompt
    cp "${SCRIPT_DIR}/test-spring-boot-prompt.txt" "${WORKSPACE_DIR}/test-prompt.txt"

    # Note: Validation will be done by claude_validate.py, no need to create validate.sh

    # Create placeholder validation info (optional)
    cat > "${WORKSPACE_DIR}/VALIDATION.md" << 'EOF'
# Spring Boot Temporal Application Validation

This workspace uses Claude-powered validation to intelligently analyze
the generated Spring Boot Temporal application.

## What Claude Validates

- **Structure**: pom.xml with Spring Boot parent and temporal-spring-boot-starter
- **Workflows**: @WorkflowInterface, @WorkflowImpl annotations
- **Activities**: @ActivityInterface, @ActivityImpl annotations
- **Application**: Spring Boot @SpringBootApplication class
- **Configuration**: application.yml (optional)
- **Advanced Features**: Signals, queries, tests

## Run Validation

```bash
cd ../.. && python3 claude_validate.py test-workspace-spring
```

Claude will provide detailed feedback on structure, patterns, and code quality.
EOF

    print_success "Workspace ready at: ${WORKSPACE_DIR}"
}

# Step 2: Check API key
check_api_key() {
    print_step "[2/6] Checking for Anthropic API key..."
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        print_error "ANTHROPIC_API_KEY not set"
        echo ""
        echo "To run automated test, set your API key:"
        echo "  export ANTHROPIC_API_KEY='your-key-here'"
        echo ""
        echo "Or run manually:"
        echo "  cd ${WORKSPACE_DIR}"
        echo "  # Use Claude Code to process test-prompt.txt"
        exit 1
    fi
    print_success "Found ANTHROPIC_API_KEY"
}

# Step 3: Check Python
check_python() {
    print_step "[3/6] Checking Python environment..."
    if ! command -v python3 &> /dev/null; then
        print_error "python3 not found"
        exit 1
    fi
    print_success "Python 3 found"

    if python3 -c "import anthropic" 2>/dev/null; then
        print_success "anthropic package available"
    else
        print_error "anthropic package not found"
        echo "Installing anthropic package..."
        pip3 install anthropic --quiet
        print_success "anthropic package installed"
    fi
}

# Step 4: Generate application
generate_application() {
    print_step "[4/6] Generating Spring Boot application with Claude API..."

    cd "${WORKSPACE_DIR}"
    python3 "${SCRIPT_DIR}/automate_test.py" "${WORKSPACE_DIR}"

    if [ $? -eq 0 ]; then
        print_success "Application generated successfully"
    else
        print_error "Failed to generate application"
        exit 1
    fi
}

# Step 5: Validate with Claude
validate_application() {
    print_step "[5/6] Validating generated Spring Boot application with Claude AI..."

    cd "${SCRIPT_DIR}"
    if python3 claude_validate.py "${WORKSPACE_DIR}"; then
        print_success "Validation passed"
    else
        print_error "Validation failed"
        exit 1
    fi
}

# Step 6: Test execution (optional)
test_execution() {
    if [ "$SKIP_EXECUTION" = "true" ]; then
        print_step "[6/6] Skipping execution test (SKIP_EXECUTION=true)"
        return 0
    fi

    print_step "[6/6] Testing Spring Boot application execution..."
    print_step "Note: Spring Boot applications with workers run continuously"
    print_step "For full execution testing, run manually:"
    echo "  cd ${WORKSPACE_DIR}"
    echo "  mvn spring-boot:run"
    echo ""
    print_success "Spring Boot application ready to run"
}

# Main
main() {
    print_header

    setup_workspace
    check_api_key
    check_python
    generate_application
    validate_application
    test_execution

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   SPRING BOOT INTEGRATION TEST PASSED!         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  cd ${WORKSPACE_DIR}"
    echo "  mvn spring-boot:run"
    echo ""
}

main "$@"
