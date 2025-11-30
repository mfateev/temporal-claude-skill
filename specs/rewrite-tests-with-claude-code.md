# Chore: Rewrite Integration Tests to Use Claude Code Instead of Claude API

## Chore Description

Currently, the integration tests (`automate_test.py`) use the Anthropic Claude API directly to generate code. The tests manually:
1. Load skill files and construct system prompts
2. Call the Claude API with the skill content embedded
3. Parse Claude's text response to extract code blocks
4. Write extracted code to files based on regex pattern matching

This approach has several limitations:
- **Not representative of real usage**: Real users use Claude Code, which handles skill loading, file operations, and context management automatically
- **Fragile code extraction**: Regex-based extraction of code blocks from markdown responses is error-prone
- **Manual file writing**: The test has to infer file paths and handle file creation, which Claude Code does automatically
- **Missing Claude Code features**: Doesn't test Claude Code's skill loading, permission system, or interactive workflow

**The Goal**: Rewrite tests to use `claude-code` CLI directly, letting it:
- Load skills from `.claude/skills/` naturally
- Generate files directly in the workspace
- Handle all file operations through its built-in tools
- Provide a more realistic integration test that matches actual user workflows

This will make tests more robust, realistic, and easier to maintain.

## Relevant Files

Use these files to resolve the chore:

- **test/java/skill-integration/automate_test.py** - Current test that uses Claude API and extracts code from responses. Needs to be replaced with claude-code CLI invocation.
- **test/python/skill-integration/automate_test.py** - Same as above for Python SDK tests.
- **test/java/skill-integration/run-integration-test.sh** - Orchestrates the Java test workflow. May need adjustments for claude-code invocation.
- **test/python/skill-integration/run-integration-test.sh** - Orchestrates the Python test workflow. May need adjustments.
- **test/java/skill-integration/setup-test-workspace.sh** - Sets up workspace with skills. Already creates proper `.claude/skills/` structure, should continue working.
- **test/python/skill-integration/setup-test-workspace.sh** - Same as above for Python.
- **test/java/skill-integration/test-prompt.txt** - Prompt sent to Claude. May need adjustment for non-interactive claude-code usage.
- **test/python/skill-integration/test-prompt.txt** - Same as above for Python.
- **test/java/skill-integration/README.md** - Documents the test process. Needs updates to reflect claude-code usage.
- **test/python/skill-integration/README.md** - Same as above for Python.
- **test/java/skill-integration/VALIDATION.md** - Documents validation approach. May need updates.
- **README.md** - Root README mentions testing approach. Needs minor updates.

### New Files

- **test/java/skill-integration/run_claude_code.py** - Python script to invoke claude-code CLI non-interactively with a prompt
- **test/python/skill-integration/run_claude_code.py** - Same as above for Python tests

## Step by Step Tasks

### Step 1: Research Claude Code CLI Non-Interactive Usage

- Verify how to run claude-code non-interactively with a prompt from stdin or file
- Understand how to set working directory for claude-code
- Document environment variables needed (ANTHROPIC_API_KEY, ANTHROPIC_MODEL)
- Test basic claude-code invocation: `echo "Create a hello.txt file" | claude-code --cwd /path/to/workspace`
- Verify claude-code can load skills from `.claude/skills/` in the workspace
- Document how to capture claude-code output for validation

### Step 2: Create New Claude Code Invocation Scripts

- Create `test/java/skill-integration/run_claude_code.py`:
  - Accept workspace directory path as argument
  - Read test prompt from `test-prompt.txt` in workspace
  - Invoke `claude-code` CLI with prompt using subprocess
  - Set working directory to workspace so skills are auto-loaded
  - Stream output to console for visibility
  - Return exit code (0 for success, non-zero for failure)
  - Handle edge cases: claude-code not installed, API key not set

- Create `test/python/skill-integration/run_claude_code.py`:
  - Same structure as Java version
  - Adjust for Python-specific workspace structure if needed

### Step 3: Update Java Integration Test Script

- Modify `test/java/skill-integration/run-integration-test.sh`:
  - Replace step that calls `python3 automate_test.py` with `python3 run_claude_code.py "$WORKSPACE_DIR"`
  - Remove fallback to manual mode if API key not set (claude-code requires it anyway)
  - Add check that `claude-code` CLI is installed
  - Add informative error message if claude-code not found with installation instructions
  - Keep all other validation steps unchanged (claude_validate.py, test-execution.sh)
  - Update status messages to reflect claude-code usage

### Step 4: Update Python Integration Test Script

- Modify `test/python/skill-integration/run-integration-test.sh`:
  - Same changes as Java version
  - Replace `automate_test.py` with `run_claude_code.py`
  - Add claude-code CLI availability check
  - Keep validation logic unchanged

### Step 5: Update Test Documentation

- Update `test/java/skill-integration/README.md`:
  - Change "How Automation Works" section to describe claude-code usage instead of API
  - Update prerequisites to mention `claude-code` CLI installation
  - Remove references to "Anthropic Python SDK" and "extracting code blocks"
  - Add section on installing claude-code: `npm install -g @anthropic-ai/claude-code`
  - Update examples and troubleshooting for claude-code
  - Document that claude-code needs to be available in PATH

- Update `test/python/skill-integration/README.md`:
  - Same changes as Java README
  - Emphasize that this tests the actual Claude Code workflow users experience

- Update root `README.md`:
  - Change "Testing" section to mention claude-code CLI requirement
  - Update prerequisites to include claude-code installation
  - Update "What the Tests Do" to describe claude-code invocation

### Step 6: Archive or Remove Old API-Based Scripts

- Move `test/java/skill-integration/automate_test.py` to `test/java/skill-integration/automate_test.py.deprecated`
- Move `test/python/skill-integration/automate_test.py` to `test/python/skill-integration/automate_test.py.deprecated`
- Add comments at top explaining they're deprecated and pointing to new approach
- Alternative: Delete them entirely if we're confident in the new approach

### Step 7: Test the New Workflow End-to-End

- Set ANTHROPIC_API_KEY environment variable
- Ensure claude-code is installed and in PATH
- Run Java integration test: `cd test/java/skill-integration && ./run-integration-test.sh`
- Verify:
  - claude-code loads skills automatically
  - Files are generated directly by claude-code
  - Generated code compiles
  - Validation script passes
  - No manual code extraction needed
- Run Python integration test: `cd test/python/skill-integration && ./run-integration-test.sh`
- Verify same success criteria
- Run Spring Boot test: `cd test/java/skill-integration && ./run-spring-boot-test.sh`
- Verify it also works with new approach

### Step 8: Update Validation Scripts (If Needed)

- Review `test/java/skill-integration/claude_validate.py` (if exists):
  - Ensure it still works with files generated by claude-code
  - Update any references to the old automation approach
  - Keep validation logic unchanged (structure checks, compilation)

- Review `test/python/skill-integration/validate.sh`:
  - Ensure it works with claude-code generated files
  - No changes needed unless validation assumptions changed

## Validation Commands

Execute every command to validate the chore is complete with zero regressions.

- `command -v claude-code` - Verify claude-code CLI is installed and accessible
- `cd test/java/skill-integration && ./setup-test-workspace.sh` - Setup Java test workspace
- `cd test/java/skill-integration && python3 run_claude_code.py test-workspace` - Test Java claude-code invocation
- `cd test/java/skill-integration && ./run-integration-test.sh` - Run full Java integration test
- `cd test/java/skill-integration && ./run-spring-boot-test.sh` - Run Spring Boot integration test
- `cd test/python/skill-integration && ./setup-test-workspace.sh` - Setup Python test workspace
- `cd test/python/skill-integration && python3 run_claude_code.py test-workspace` - Test Python claude-code invocation
- `cd test/python/skill-integration && ./run-integration-test.sh` - Run full Python integration test
- `grep -r "automate_test.py" test/ --exclude="*.deprecated"` - Verify old scripts aren't referenced (except deprecated files)
- `grep -r "run_claude_code.py" test/` - Verify new scripts are referenced in test runners

## Notes

### Why This Is Better

1. **Tests Real User Experience**: Users interact with claude-code CLI, not the raw API
2. **No Fragile Parsing**: claude-code handles file creation directly, no regex extraction needed
3. **Proper Skill Loading**: Tests the actual skill loading mechanism Claude Code uses
4. **Simpler Test Code**: Less code to maintain, fewer edge cases to handle
5. **Better Error Messages**: Claude Code provides user-friendly errors
6. **Permission System Testing**: Tests Claude Code's permission system for file operations

### Claude Code CLI Installation

For users running tests:
```bash
# Install claude-code globally
npm install -g @anthropic-ai/claude-code

# Or use npx (no installation needed)
npx @anthropic-ai/claude-code --help
```

### Non-Interactive Invocation Pattern

```bash
# Pipe prompt to claude-code
echo "Your prompt here" | claude-code --cwd /path/to/workspace

# Or from file
claude-code --cwd /path/to/workspace < prompt.txt

# With environment variables
ANTHROPIC_API_KEY=your-key claude-code --cwd /path/to/workspace
```

### Fallback Plan

If claude-code doesn't support non-interactive mode well:
- Use `expect` or similar tool to automate interactions
- Or use subprocess with stdin piping
- Document any workarounds in the README

### Compatibility Notes

- Ensure tests work on macOS, Linux, and Windows (if applicable)
- Document Node.js version requirement for claude-code
- Provide alternative if npm/Node.js not available (e.g., manual test instructions)

### Migration Path

1. Keep old `automate_test.py` as `.deprecated` initially
2. Run both approaches in parallel for a few test cycles
3. Once confident, remove deprecated files
4. Update CI/CD pipelines if they reference old scripts
