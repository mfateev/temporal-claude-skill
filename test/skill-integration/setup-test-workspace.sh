#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Setting up Temporal Java Skill Test Workspace ===${NC}\n"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_FILE="$SCRIPT_DIR/../../temporal-java.md"
WORKSPACE_DIR="$SCRIPT_DIR/test-workspace"

# Clean up old workspace if it exists
if [ -d "$WORKSPACE_DIR" ]; then
    echo -e "${YELLOW}Cleaning up old workspace...${NC}"
    rm -rf "$WORKSPACE_DIR"
fi

# Create test workspace directory
echo -e "${YELLOW}Creating test workspace at: ${WORKSPACE_DIR}${NC}"
mkdir -p "$WORKSPACE_DIR/.claude/skills"
mkdir -p "$WORKSPACE_DIR/src"

# Copy the skill file to the workspace
echo -e "${YELLOW}Installing temporal-java.md skill...${NC}"
cp "$SKILL_FILE" "$WORKSPACE_DIR/.claude/skills/"

# Create a .claude/settings.json for the workspace
cat > "$WORKSPACE_DIR/.claude/settings.json" <<'EOF'
{
  "name": "temporal-java-test",
  "description": "Test workspace for Temporal Java skill validation"
}
EOF

# Create a prompt file that will trigger the skill
cat > "$WORKSPACE_DIR/test-prompt.txt" <<'EOF'
Create a Temporal workflow that executes two activities. After the first activity the workflow awaits a signal. When the signal is received it executes the second activity.

Use the temporal-java skill.

Requirements:
- Create a workflow with a signal method
- First activity processes initial data
- Workflow waits for a signal after first activity
- Second activity processes final data after signal received
- Create a Worker that registers the workflow and activities
- Create a Client that starts the workflow and sends the signal
- Use Maven for dependency management
- Use the latest Temporal Java SDK version

Package: io.temporal.hello
EOF

# Create README for the workspace
cat > "$WORKSPACE_DIR/README.md" <<'EOF'
# Temporal Java Skill Test Workspace

This workspace is set up to test the temporal-java.md skill.

## What's Here

- `.claude/skills/temporal-java.md` - The skill being tested
- `test-prompt.txt` - The prompt to send to Claude Code
- `validate.sh` - Script to validate the generated application

## How to Run the Test

### Option 1: Manual Testing with Claude Code

1. Open this workspace in Claude Code:
   ```bash
   cd test-workspace
   code .
   ```

2. Start Claude Code session and send the prompt from `test-prompt.txt`

3. After Claude generates the application, run validation:
   ```bash
   ./validate.sh
   ```

### Option 2: Automated Testing (if Claude Code CLI is available)

Run the automated test from the parent directory:
```bash
cd ..
./run-integration-test.sh
```

## Expected Generated Structure

```
src/main/java/io/temporal/hello/
├── HelloWorldWorker.java
├── HelloWorldClient.java
├── workflows/
│   ├── HelloWorldWorkflow.java
│   └── HelloWorldWorkflowImpl.java
└── activities/
    ├── HelloWorldActivities.java
    └── HelloWorldActivitiesImpl.java
pom.xml
```
EOF

# Create validation script for the workspace
cat > "$WORKSPACE_DIR/validate.sh" <<'VALIDATION_SCRIPT'
#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Validating Generated Temporal Application ===${NC}\n"

# Check if pom.xml exists
if [ ! -f "pom.xml" ]; then
    echo -e "${RED}✗ pom.xml not found - application not generated${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found pom.xml${NC}"

# Check if required Java files exist
# Look for workflow/activity files (names may vary based on generation)
WORKFLOW_FILES=$(find src/main/java/io/temporal/hello/workflows -name "*Workflow*.java" 2>/dev/null | wc -l)
ACTIVITY_FILES=$(find src/main/java/io/temporal/hello/activities -name "*Activities*.java" 2>/dev/null | wc -l)
WORKER_FILES=$(find src/main/java/io/temporal/hello -maxdepth 1 -name "*Worker*.java" 2>/dev/null | wc -l)
CLIENT_FILES=$(find src/main/java/io/temporal/hello -maxdepth 1 -name "*Client*.java" 2>/dev/null | wc -l)

if [ "$WORKFLOW_FILES" -lt 2 ]; then
    echo -e "${RED}✗ Expected at least 2 workflow files (interface + impl)${NC}"
    exit 1
fi

if [ "$ACTIVITY_FILES" -lt 2 ]; then
    echo -e "${RED}✗ Expected at least 2 activity files (interface + impl)${NC}"
    exit 1
fi

if [ "$WORKER_FILES" -lt 1 ]; then
    echo -e "${RED}✗ Expected at least 1 worker file${NC}"
    exit 1
fi

if [ "$CLIENT_FILES" -lt 1 ]; then
    echo -e "${RED}✗ Expected at least 1 client file${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found workflow files: $WORKFLOW_FILES${NC}"
echo -e "${GREEN}✓ Found activity files: $ACTIVITY_FILES${NC}"
echo -e "${GREEN}✓ Found worker file(s): $WORKER_FILES${NC}"
echo -e "${GREEN}✓ Found client file(s): $CLIENT_FILES${NC}"

# Check for signal method in workflow (advanced feature)
if grep -r "@SignalMethod" src/main/java/io/temporal/hello/workflows/ > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Found @SignalMethod annotation (signal pattern implemented)${NC}"
else
    echo -e "${YELLOW}! Warning: No @SignalMethod found - signal pattern may not be implemented${NC}"
fi

REQUIRED_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ Missing: $file${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Found: $file${NC}"
done

# Validate pom.xml contains Temporal SDK
if ! grep -q "io.temporal" pom.xml; then
    echo -e "${RED}✗ pom.xml doesn't contain Temporal SDK dependency${NC}"
    exit 1
fi
echo -e "${GREEN}✓ pom.xml contains Temporal SDK dependency${NC}"

# Extract version from pom.xml
TEMPORAL_VERSION=$(grep -A 1 "temporal-sdk" pom.xml | grep "<version>" | sed 's/.*<version>\(.*\)<\/version>.*/\1/' | head -1)
if [ -z "$TEMPORAL_VERSION" ]; then
    echo -e "${YELLOW}! Warning: Could not extract Temporal SDK version${NC}"
else
    echo -e "${GREEN}✓ Using Temporal SDK version: $TEMPORAL_VERSION${NC}"
fi

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo -e "${YELLOW}! Maven not found - skipping build test${NC}"
    echo -e "\n${GREEN}=== Structure Validation PASSED ===${NC}"
    exit 0
fi

# Try to build the project
echo -e "\n${YELLOW}Building project...${NC}"
if mvn clean compile > build.log 2>&1; then
    echo -e "${GREEN}✓ Build successful!${NC}"
else
    echo -e "${RED}✗ Build failed - check build.log for details${NC}"
    tail -20 build.log
    exit 1
fi

echo -e "\n${GREEN}=== Structure & Build Validation PASSED ===${NC}"
echo -e "\nTo test execution, run: ${YELLOW}./test-execution.sh${NC}"
VALIDATION_SCRIPT

chmod +x "$WORKSPACE_DIR/validate.sh"

# Copy the execution test script to workspace
echo -e "${YELLOW}Installing execution test script...${NC}"
cp "$SCRIPT_DIR/test-execution.sh" "$WORKSPACE_DIR/"
chmod +x "$WORKSPACE_DIR/test-execution.sh"
echo -e "${GREEN}✓ Execution test script installed${NC}"

echo -e "${GREEN}✓ Test workspace created successfully!${NC}\n"
echo -e "Workspace location: ${YELLOW}$WORKSPACE_DIR${NC}"
echo -e "\nNext steps:"
echo -e "  1. cd $WORKSPACE_DIR"
echo -e "  2. Use Claude Code to process test-prompt.txt"
echo -e "  3. Run ./validate.sh to verify the generated application"
