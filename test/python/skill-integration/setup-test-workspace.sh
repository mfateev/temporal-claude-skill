#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
DIST_ZIP="$REPO_ROOT/dist/temporal-skill-latest.zip"
WORKSPACE_DIR="${SCRIPT_DIR}/test-workspace"

echo -e "${YELLOW}Setting up test workspace for Python skill integration test...${NC}"

# Check if dist zip exists
if [ ! -f "$DIST_ZIP" ]; then
    echo -e "${RED}✗ Skill package not found: $DIST_ZIP${NC}"
    echo -e "Please build the skill package first:"
    echo -e "  ${YELLOW}cd $REPO_ROOT && ./build-skill-package.sh${NC}"
    exit 1
fi

# Clean and create workspace
rm -rf "${WORKSPACE_DIR}"
mkdir -p "${WORKSPACE_DIR}/.claude/skills"

echo -e "${GREEN}✓ Created test workspace${NC}"

# Extract the skill from dist zip
echo -e "${YELLOW}Installing temporal skill from dist package...${NC}"
unzip -q "$DIST_ZIP" -d "$WORKSPACE_DIR/.claude/skills/"

# Move files from temporal-skill subdirectory to skills directory
mv "$WORKSPACE_DIR/.claude/skills/temporal-skill/"* "$WORKSPACE_DIR/.claude/skills/"
rmdir "$WORKSPACE_DIR/.claude/skills/temporal-skill"

echo -e "${GREEN}✓ Installed skill files from dist package${NC}"

# Copy test prompt
cp "${SCRIPT_DIR}/test-prompt.txt" "${WORKSPACE_DIR}/"

echo -e "${GREEN}✓ Copied test prompt${NC}"

# Create validation script
cat > "${WORKSPACE_DIR}/validate.sh" << 'EOF'
#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Validating Generated Python Application"
echo "========================================="
echo ""

# Check required files
echo "Checking file structure..."
REQUIRED_FILES=("workflows.py" "activities.py" "worker.py" "client.py")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    else
        echo -e "${GREEN}✓${NC} $file exists"
    fi
done

# Check for dependency file
if [ ! -f "requirements.txt" ] && [ ! -f "pyproject.toml" ]; then
    echo -e "${RED}✗${NC} Missing dependency file (requirements.txt or pyproject.toml)"
    MISSING_FILES+=("requirements.txt or pyproject.toml")
else
    if [ -f "requirements.txt" ]; then
        echo -e "${GREEN}✓${NC} requirements.txt exists"
    fi
    if [ -f "pyproject.toml" ]; then
        echo -e "${GREEN}✓${NC} pyproject.toml exists"
    fi
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Missing required files:${NC}"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
    exit 1
fi

echo ""
echo "Checking code patterns..."

# Check for workflow decorator
if ! grep -q "@workflow.defn" workflows.py; then
    echo -e "${RED}✗${NC} Missing @workflow.defn decorator in workflows.py"
    exit 1
else
    echo -e "${GREEN}✓${NC} Contains @workflow.defn decorator"
fi

# Check for activity decorator
if ! grep -q "@activity.defn" activities.py; then
    echo -e "${RED}✗${NC} Missing @activity.defn decorator in activities.py"
    exit 1
else
    echo -e "${GREEN}✓${NC} Contains @activity.defn decorator"
fi

# Check for @workflow.run
if ! grep -q "@workflow.run" workflows.py; then
    echo -e "${RED}✗${NC} Missing @workflow.run decorator in workflows.py"
    exit 1
else
    echo -e "${GREEN}✓${NC} Contains @workflow.run decorator"
fi

# Check for async/await
if ! grep -q "async def" workflows.py || ! grep -q "await" workflows.py; then
    echo -e "${RED}✗${NC} Missing async/await syntax in workflows.py"
    exit 1
else
    echo -e "${GREEN}✓${NC} Uses async/await syntax"
fi

# Check for temporalio imports
if ! grep -q "from temporalio" *.py 2>/dev/null && ! grep -q "import temporalio" *.py 2>/dev/null; then
    echo -e "${RED}✗${NC} Missing temporalio imports"
    exit 1
else
    echo -e "${GREEN}✓${NC} Has temporalio imports"
fi

# Check for signal decorator (optional but expected)
if grep -q "@workflow.signal" workflows.py; then
    echo -e "${GREEN}✓${NC} Contains @workflow.signal decorator"
fi

# Check for query decorator (optional but expected)
if grep -q "@workflow.query" workflows.py; then
    echo -e "${GREEN}✓${NC} Contains @workflow.query decorator"
fi

echo ""
echo "Checking Python syntax..."

# Validate Python syntax for all .py files
SYNTAX_ERRORS=0
for file in *.py; do
    if [ -f "$file" ]; then
        if python3 -m py_compile "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $file syntax is valid"
        else
            echo -e "${RED}✗${NC} $file has syntax errors"
            python3 -m py_compile "$file"
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    fi
done

if [ $SYNTAX_ERRORS -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Found syntax errors in $SYNTAX_ERRORS file(s)${NC}"
    exit 1
fi

echo ""
echo "Checking dependencies..."

# Check temporalio dependency
if [ -f "requirements.txt" ]; then
    if ! grep -q "temporalio" requirements.txt; then
        echo -e "${RED}✗${NC} temporalio not found in requirements.txt"
        exit 1
    else
        echo -e "${GREEN}✓${NC} temporalio dependency specified"
    fi
fi

if [ -f "pyproject.toml" ]; then
    if ! grep -q "temporalio" pyproject.toml; then
        echo -e "${RED}✗${NC} temporalio not found in pyproject.toml"
        exit 1
    else
        echo -e "${GREEN}✓${NC} temporalio dependency specified"
    fi
fi

echo ""
echo "========================================="
echo -e "${GREEN}✅ ALL VALIDATIONS PASSED${NC}"
echo "========================================="
EOF

chmod +x "${WORKSPACE_DIR}/validate.sh"

echo -e "${GREEN}✓ Created validation script${NC}"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Test workspace setup complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Workspace location: ${WORKSPACE_DIR}"
echo ""
echo "Next steps:"
echo "1. cd ${WORKSPACE_DIR}"
echo "2. Use Claude to process test-prompt.txt"
echo "3. Run ./validate.sh to check the generated code"
