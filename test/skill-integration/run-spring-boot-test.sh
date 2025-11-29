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

    # Copy skill
    cp "${SCRIPT_DIR}/../../src/temporal-java.md" "${WORKSPACE_DIR}/.claude/skills/"

    # Copy references directory
    if [ -d "${SCRIPT_DIR}/../../src/references" ]; then
        cp -r "${SCRIPT_DIR}/../../src/references" "${WORKSPACE_DIR}/.claude/skills/"
    fi

    # Copy Spring Boot prompt
    cp "${SCRIPT_DIR}/test-spring-boot-prompt.txt" "${WORKSPACE_DIR}/test-prompt.txt"

    # Create validation script
    cat > "${WORKSPACE_DIR}/validate.sh" << 'EOF'
#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Validating Spring Boot Temporal Application ===${NC}"
echo ""

# Check for pom.xml
if [ ! -f "pom.xml" ]; then
    echo -e "${RED}✗ pom.xml not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found pom.xml${NC}"

# Check Spring Boot parent
if grep -q "spring-boot-starter-parent" pom.xml; then
    echo -e "${GREEN}✓ Found Spring Boot parent in pom.xml${NC}"
else
    echo -e "${RED}✗ Spring Boot parent not found in pom.xml${NC}"
    exit 1
fi

# Check Spring Boot Temporal starter
if grep -q "temporal-spring-boot-starter" pom.xml; then
    echo -e "${GREEN}✓ Found temporal-spring-boot-starter dependency${NC}"
else
    echo -e "${RED}✗ temporal-spring-boot-starter dependency not found${NC}"
    exit 1
fi

# Check for application.yml
if [ -f "src/main/resources/application.yml" ] || [ -f "src/main/resources/application.yaml" ]; then
    echo -e "${GREEN}✓ Found application.yml configuration${NC}"
else
    echo -e "${YELLOW}⚠ No application.yml found (may use defaults)${NC}"
fi

# Check for workflow files
WORKFLOW_COUNT=$(find src/main/java -name "*Workflow*.java" 2>/dev/null | wc -l)
echo -e "${GREEN}✓ Found workflow files:        ${WORKFLOW_COUNT}${NC}"

# Check for activity files
ACTIVITY_COUNT=$(find src/main/java -name "*Activit*.java" 2>/dev/null | wc -l)
echo -e "${GREEN}✓ Found activity files:        ${ACTIVITY_COUNT}${NC}"

# Check for Spring Boot application
APP_COUNT=$(find src/main/java -name "*Application.java" 2>/dev/null | wc -l)
if [ $APP_COUNT -gt 0 ]; then
    echo -e "${GREEN}✓ Found Spring Boot application: ${APP_COUNT}${NC}"
else
    echo -e "${RED}✗ No Spring Boot application class found${NC}"
    exit 1
fi

# Check for @WorkflowImpl annotation
if grep -r "@WorkflowImpl" src/main/java 2>/dev/null | grep -q "io.temporal.spring.boot"; then
    echo -e "${GREEN}✓ Found @WorkflowImpl annotation (Spring Boot)${NC}"
else
    echo -e "${YELLOW}⚠ @WorkflowImpl annotation not found${NC}"
fi

# Check for @ActivityImpl annotation
if grep -r "@ActivityImpl" src/main/java 2>/dev/null | grep -q "io.temporal.spring.boot"; then
    echo -e "${GREEN}✓ Found @ActivityImpl annotation (Spring Boot)${NC}"
else
    echo -e "${YELLOW}⚠ @ActivityImpl annotation not found${NC}"
fi

# Check for signal method
if grep -r "@SignalMethod" src/main/java 2>/dev/null | grep -q "SignalMethod"; then
    echo -e "${GREEN}✓ Found @SignalMethod annotation (signal pattern implemented)${NC}"
else
    echo -e "${YELLOW}⚠ @SignalMethod annotation not found${NC}"
fi

# Build the project
echo ""
echo -e "${YELLOW}Building project...${NC}"
if mvn clean compile -q; then
    echo -e "${GREEN}✓ Build successful!${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Spring Boot Application Validation PASSED ===${NC}"
echo ""
echo "To run the application:"
echo -e "  ${YELLOW}mvn spring-boot:run${NC}"
EOF
    chmod +x "${WORKSPACE_DIR}/validate.sh"

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

# Step 5: Validate
validate_application() {
    print_step "[5/6] Validating generated Spring Boot application..."

    cd "${WORKSPACE_DIR}"
    if ./validate.sh; then
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
