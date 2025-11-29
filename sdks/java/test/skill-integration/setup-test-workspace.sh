#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Setting up Temporal Java Skill Test Workspace ===${NC}\n"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_FILE="$SCRIPT_DIR/../../../../../temporal.md"
SDK_DIR="$SCRIPT_DIR/../../"
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

# Copy the main skill file
echo -e "${YELLOW}Installing temporal.md skill...${NC}"
cp "$SKILL_FILE" "$WORKSPACE_DIR/.claude/skills/"

# Copy SDK resources
echo -e "${YELLOW}Installing SDK resources...${NC}"
cp -r "$(dirname "$SDK_DIR")/sdks" "$WORKSPACE_DIR/.claude/skills/"

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

Use the temporal skill with Java SDK.

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

## How to Run the Test

### Option 1: Manual Testing with Claude Code

1. Open this workspace in Claude Code:
   ```bash
   cd test-workspace
   code .
   ```

2. Start Claude Code session and send the prompt from `test-prompt.txt`

3. After Claude generates the application, validate it:
   ```bash
   cd ../.. && python3 claude_validate.py test-workspace
   ```

### Option 2: Automated Testing

Run the automated test from the parent directory:
```bash
cd ..
./run-integration-test.sh
```

## Expected Generated Structure

The generated structure will vary but should include:
- pom.xml with Temporal SDK dependency
- Workflow interface and implementation
- Activity interface and implementation
- Worker class to register workflows/activities
- Client class to start workflows

The exact directory structure (e.g., workflow/ vs workflows/) and file names
may vary. Claude validation will intelligently analyze the structure.
EOF

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
