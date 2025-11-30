# Chore: Add test-execution to Python Integration Tests

## Chore Description

Add an execution test stage to the Python skill integration tests, matching the functionality that already exists in the Java integration tests. Currently, the Python integration test only validates code structure and syntax, but does not actually execute the generated Temporal workflow application. The Java integration test has a complete execution test (`test-execution.sh`) that:

1. Checks if Temporal server is running (or starts it)
2. Starts the worker in the background
3. Executes the client to run a workflow
4. Validates the workflow completes successfully
5. Cleans up resources

We need to implement the same functionality for Python, adapting the script to work with Python's execution model (python3 worker.py, python3 client.py) and ensuring proper process management, output validation, and cleanup.

## Relevant Files

Use these files to resolve the chore:

### Existing Files

- **`test/java/skill-integration/test-execution.sh`** - Reference implementation for Java execution tests
  - Shows how to check/start Temporal server
  - Demonstrates worker/client process management
  - Contains proper cleanup and error handling patterns
  - Has clear success/failure reporting

- **`test/java/skill-integration/run-integration-test.sh`** (lines 81-112) - Integration of execution test
  - Shows how execution test is called from main test script
  - Demonstrates SKIP_EXECUTION environment variable usage
  - Contains proper success/failure messaging
  - Handles optional execution test (exits gracefully if execution fails)

- **`test/python/skill-integration/run-integration-test.sh`** - Main Python test script to be updated
  - Currently only runs setup, code generation, and validation
  - Needs to add execution test stage after validation

- **`test/python/skill-integration/README.md`** - Documentation to be updated
  - Already mentions execution testing as "(Optional)" in line 18
  - Describes execution testing in lines 62-70 but it's not implemented
  - Needs to reflect the new execution test capability

### New Files

- **`test/python/skill-integration/test-execution.sh`** - New execution test script for Python
  - Adapt from Java version but use Python-specific commands
  - Use `python3 worker.py` instead of `mvn exec:java`
  - Use `python3 client.py` instead of Maven execution
  - Find Python files using `find . -name "*worker.py"` pattern
  - Handle Python process management and output validation

## Step by Step Tasks

### Step 1: Create test-execution.sh for Python

- Create `test/python/skill-integration/test-execution.sh` based on Java version
- Replace Java-specific commands with Python equivalents:
  - Replace `mvn exec:java -Dexec.mainClass` with `python3`
  - Replace Java class finding logic with Python file finding
  - Use `find . -name "*worker.py"` and `find . -name "*client.py"`
  - Remove requirement for `pom.xml` (check for Python files instead)
- Adapt process management for Python:
  - Use `python3 worker.py > worker.log 2>&1 &` for worker
  - Use `python3 client.py > client.log 2>&1` for client execution
  - Keep the same PID tracking and process monitoring logic
- Keep identical Temporal server management logic (works across languages)
- Adapt output validation for Python patterns:
  - Look for Python-specific success indicators in output
  - Check for workflow completion messages
  - Validate proper shutdown
- Use same cleanup patterns (log files, processes, Temporal server)
- Keep same color coding and user messaging
- Ensure script has executable permissions

### Step 2: Update run-integration-test.sh

- Add Step 6 (execution test) after the validation step (after line 114)
- Follow the exact pattern from Java version (lines 81-112 of Java script)
- Add environment variable check for `SKIP_EXECUTION`
- Call `test-execution.sh` from workspace directory
- Handle three outcomes:
  1. SKIP_EXECUTION=true → validation-only success message
  2. Execution test passes → full integration test success
  3. Execution test fails → partial success (structure + validation passed)
- Update step numbers in print_step calls (currently goes to step 5, add step 6)
- Ensure proper working directory when calling test-execution.sh

### Step 3: Update README.md

- Update line 18 to change "✅ **Optionally runs the application**" to reflect it's now implemented
- Update the "Test Components" section (around line 62) to add full execution test details
- Add a new subsection "### 3. test-execution.sh - Application Execution Test" with:
  - What it does (starts Temporal, worker, client)
  - How to skip it (SKIP_EXECUTION=true)
  - Prerequisites (Temporal CLI)
- Update "Running the Tests" section to mention the SKIP_EXECUTION option
- Add example of running with SKIP_EXECUTION=true:
  ```bash
  SKIP_EXECUTION=true ./run-integration-test.sh
  ```
- Update troubleshooting section with execution-specific issues
- Ensure consistency with Java test README structure

### Step 4: Verify setup-test-workspace.sh compatibility

- Confirm that setup-test-workspace.sh creates workspace in expected location
- Verify test-execution.sh will be copied to workspace if needed
- Check that no changes are needed to setup script (likely already correct)

### Step 5: Run validation commands

- Execute all validation commands listed below
- Ensure zero regressions in existing functionality
- Validate execution test works end-to-end
- Confirm SKIP_EXECUTION flag works correctly

## Validation Commands

Execute every command to validate the chore is complete with zero regressions.

**Prerequisites:**
```bash
# Ensure Temporal CLI is installed
temporal --version

# Ensure Python environment is ready
python3 --version

# Set API key
export ANTHROPIC_API_KEY='your-api-key-here'
```

**Test Commands:**

```bash
# Test 1: Run Python integration test with execution (full test)
cd /Users/maxim/ai/skills/test/python/skill-integration
./run-integration-test.sh
# Expected: Full test passes including execution stage

# Test 2: Run Python integration test without execution (validation only)
cd /Users/maxim/ai/skills/test/python/skill-integration
SKIP_EXECUTION=true ./run-integration-test.sh
# Expected: Test passes with validation-only message

# Test 3: Verify Java tests still work (no regression)
cd /Users/maxim/ai/skills/test/java/skill-integration
./run-integration-test.sh
# Expected: Java test continues to work as before

# Test 4: Test execution script directly (after generating code)
cd /Users/maxim/ai/skills/test/python/skill-integration
./setup-test-workspace.sh
cd test-workspace
# Generate code manually or with run_claude_code.py
../test-execution.sh
# Expected: Execution test runs independently

# Test 5: Verify test-execution.sh has correct permissions
ls -la /Users/maxim/ai/skills/test/python/skill-integration/test-execution.sh
# Expected: Should show executable permissions (-rwxr-xr-x)
```

## Notes

### Key Differences Between Java and Python Execution

- **Dependency Installation**: Python may need `pip install -r requirements.txt` before execution
  - Consider adding a check or auto-install in test-execution.sh
  - Or document as prerequisite in output messages

- **Process Names**: Python processes will show as "python3" not class names
  - Worker/client identification relies on script names not class names
  - Simpler to find: just look for *worker.py and *client.py files

- **Output Patterns**: Python applications may have different log formats
  - Adapt grep patterns in output validation
  - Look for both Python logging and Temporal SDK messages

- **Virtual Environments**: Users might have venv/poetry environments
  - Script should work without activating venv (using system python3)
  - Document that temporalio must be installed globally or in active env

### Success Criteria

- Python execution test works end-to-end with real Temporal server
- SKIP_EXECUTION flag allows validation-only testing
- Error messages are clear and actionable
- Cleanup is thorough (no orphaned processes or files)
- Documentation accurately reflects new capabilities
- No regressions in existing Java or Python tests

### Optional Enhancements (Not Required for This Chore)

- Add execution test to Spring Boot integration test (Java)
- Add execution timeout limits
- Add more detailed output parsing for better failure messages
- Support for poetry/uv instead of just pip
