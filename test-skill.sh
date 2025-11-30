#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Display usage information
show_usage() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Temporal Skill Test Runner           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Usage: $0 <SDK> [OPTIONS]"
    echo ""
    echo "Supported SDKs:"
    echo "  Java              - Test Java SDK integration"
    echo "  Python            - Test Python SDK integration"
    echo ""
    echo "Options:"
    echo "  --variant <name>  - Specify SDK variant (Java only)"
    echo "                      Values: standard, spring-boot (default: standard)"
    echo "  --skip-execution  - Skip execution tests (validation only)"
    echo "  --help, -h        - Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  ANTHROPIC_API_KEY - Required for running tests"
    echo "  SKIP_EXECUTION    - Alternative to --skip-execution flag"
    echo ""
    echo "Examples:"
    echo "  $0 Java"
    echo "  $0 Java --variant spring-boot"
    echo "  $0 Python"
    echo "  SKIP_EXECUTION=true $0 Java"
    echo ""
    echo "SDK-specific test scripts can still be run directly:"
    echo "  test/java/skill-integration/run-integration-test.sh"
    echo "  test/java/skill-integration/run-spring-boot-test.sh"
    echo "  test/python/skill-integration/run-integration-test.sh"
    echo ""
}

# Print error message and exit
error_exit() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    echo ""
    exit "${2:-1}"
}

# Check if script is run from repository root
if [ ! -f "$SCRIPT_DIR/test-skill.sh" ]; then
    error_exit "This script must be run from the repository root directory" 1
fi

# Parse command line arguments
SDK=""
VARIANT="standard"
SKIP_EXECUTION_FLAG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        --variant)
            VARIANT="$2"
            shift 2
            ;;
        --skip-execution)
            SKIP_EXECUTION_FLAG="true"
            shift
            ;;
        *)
            if [ -z "$SDK" ]; then
                SDK="$1"
            else
                error_exit "Unknown argument: $1" 1
            fi
            shift
            ;;
    esac
done

# Check if SDK argument is provided
if [ -z "$SDK" ]; then
    echo -e "${RED}✗ Error: SDK argument is required${NC}" >&2
    echo ""
    show_usage
    exit 1
fi

# Normalize SDK name to lowercase for path matching
SDK_LOWER=$(echo "$SDK" | tr '[:upper:]' '[:lower:]')

# Map SDK to test script path
# Pattern for SDK test scripts: test/<sdk-lowercase>/skill-integration/run-integration-test.sh
# To add a new SDK (e.g., TypeScript, Go, .NET, PHP):
# 1. Create directory: test/<sdk-lowercase>/skill-integration/
# 2. Add run-integration-test.sh script to that directory
# 3. Add case statement below mapping the SDK name
# 4. Update show_usage() to list the new SDK
# 5. Add validation command examples in the README

TEST_SCRIPT=""
case "$SDK_LOWER" in
    java)
        if [ "$VARIANT" = "spring-boot" ]; then
            TEST_SCRIPT="$SCRIPT_DIR/test/java/skill-integration/run-spring-boot-test.sh"
        elif [ "$VARIANT" = "standard" ]; then
            TEST_SCRIPT="$SCRIPT_DIR/test/java/skill-integration/run-integration-test.sh"
        else
            error_exit "Unknown Java variant: $VARIANT. Use 'standard' or 'spring-boot'" 1
        fi
        ;;
    python)
        TEST_SCRIPT="$SCRIPT_DIR/test/python/skill-integration/run-integration-test.sh"
        if [ "$VARIANT" != "standard" ]; then
            echo -e "${YELLOW}⚠ Warning: Python SDK does not support variants. Ignoring --variant flag.${NC}"
        fi
        ;;
    # Add new SDKs here:
    # typescript)
    #     TEST_SCRIPT="$SCRIPT_DIR/test/typescript/skill-integration/run-integration-test.sh"
    #     ;;
    # go)
    #     TEST_SCRIPT="$SCRIPT_DIR/test/go/skill-integration/run-integration-test.sh"
    #     ;;
    # dotnet)
    #     TEST_SCRIPT="$SCRIPT_DIR/test/dotnet/skill-integration/run-integration-test.sh"
    #     ;;
    # php)
    #     TEST_SCRIPT="$SCRIPT_DIR/test/php/skill-integration/run-integration-test.sh"
    #     ;;
    *)
        error_exit "Unsupported SDK: $SDK. Run '$0 --help' to see supported SDKs." 1
        ;;
esac

# Verify test script exists
if [ ! -f "$TEST_SCRIPT" ]; then
    error_exit "Test script not found: $TEST_SCRIPT\nThe SDK '$SDK' is recognized but its test script does not exist." 1
fi

# Verify test script is executable
if [ ! -x "$TEST_SCRIPT" ]; then
    echo -e "${YELLOW}⚠ Warning: Test script is not executable. Making it executable...${NC}"
    chmod +x "$TEST_SCRIPT"
fi

# Export environment variables for SDK test scripts
if [ -n "$SKIP_EXECUTION_FLAG" ]; then
    export SKIP_EXECUTION="$SKIP_EXECUTION_FLAG"
fi

# Print test summary
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Temporal Skill Test Runner           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Testing Configuration:${NC}"
echo -e "  SDK:      ${GREEN}$SDK${NC}"
if [ "$SDK_LOWER" = "java" ]; then
    echo -e "  Variant:  ${GREEN}$VARIANT${NC}"
fi
if [ -n "$SKIP_EXECUTION" ]; then
    echo -e "  Mode:     ${GREEN}Validation only (execution skipped)${NC}"
else
    echo -e "  Mode:     ${GREEN}Full test (validation + execution)${NC}"
fi
echo ""

# Run the SDK-specific test script
echo -e "${YELLOW}Starting SDK test...${NC}"
echo ""

# Change to test script directory and execute
TEST_SCRIPT_DIR=$(dirname "$TEST_SCRIPT")
cd "$TEST_SCRIPT_DIR"

# Execute the test script
if bash "$(basename "$TEST_SCRIPT")"; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Test Passed ✓                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    exit 0
else
    TEST_EXIT_CODE=$?
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              Test Failed ✗                     ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
    exit $TEST_EXIT_CODE
fi
