# Temporal Python Skill Integration Test

This test validates that the `temporal-python.md` skill works correctly when **actually used in Claude Code** to generate a Temporal Python application.

## What This Test Does

This is a **real integration test** that:

1. ✅ **Installs the skill** in a test workspace (`.claude/skills/temporal-python.md`)
2. ✅ **Uses claude-code CLI** to process a prompt that triggers the skill
3. ✅ **Generates a complete application** using claude-code with the skill
4. ✅ **Validates the generated code**:
   - Correct file structure
   - All required files present
   - Code has valid Python syntax
   - Uses latest Temporal Python SDK version
   - Proper async/await patterns
5. ✅ **Runs the application** with real Temporal workflows (optional, can be skipped with SKIP_EXECUTION=true)

## Why This Test is Important

Unlike a simple code validation test, this integration test:

- **Tests the actual user workflow** - how the skill will really be used
- **Validates skill installation** - ensures the skill file is correctly formatted
- **Tests Claude integration** - verifies Claude can parse and use the skill
- **Validates end-to-end flow** - from prompt to working application
- **Catches skill formatting issues** - ensures markdown is properly structured
- **Validates Python-specific patterns** - async/await, type hints, decorators

## Test Structure

```
test/python/skill-integration/
├── setup-test-workspace.sh         # Creates test workspace with skill
├── run-integration-test.sh         # Runs full integration test
├── test-execution.sh               # Tests application execution
├── test-prompt.txt                 # Prompt for standard test
├── run_claude_code.py              # Invokes claude-code CLI for automation
├── automate_test.py.deprecated     # Old API-based script (deprecated)
├── .gitignore                      # Ignores generated workspaces
└── README.md                       # This file

Generated during test:
test-workspace/
├── .claude/
│   └── skills/
│       └── temporal-python.md      # The skill being tested
├── test-prompt.txt                 # Prompt that triggers the skill
├── validate.sh                     # Validates structure and syntax
└── [generated code here]           # Application created by Claude
```

## Test Components

### 1. `validate.sh` - Structure & Syntax Validation
- Checks all required Python files exist
- Validates `@workflow.defn` and `@activity.defn` patterns
- Verifies temporalio dependency
- Checks Python syntax with `python -m py_compile`
- Validates async/await usage

### 2. `test-execution.sh` - Application Execution Test

This optional test validates that the generated code actually runs correctly with a real Temporal server:

- **Temporal Management**:
  - Checks if Temporal is running on port 7233
  - Starts with `temporal server start-dev` if not running
  - Only stops Temporal if we started it
- **Dependency Check**:
  - Verifies temporalio package is installed
  - Auto-installs from requirements.txt if needed
- **Worker**:
  - Starts worker.py in background
  - Monitors startup and validates it stays running
- **Client**:
  - Executes workflow via client.py with test data
  - Validates workflow completes successfully
- **Cleanup**:
  - Stops worker process
  - Stops Temporal only if we started it
  - Removes log files

**How to skip execution test:**
```bash
SKIP_EXECUTION=true ./run-integration-test.sh
```

This is useful when:
- Temporal CLI is not installed
- You only want to validate code structure/syntax
- Running in CI/CD without Temporal setup

## Prerequisites

### For Automated Testing
- **claude-code CLI** - Install with `npm install -g @anthropic-ai/claude-code`
- **Anthropic API Key** - Set as `ANTHROPIC_API_KEY` environment variable
- **Python 3.10+** (for test orchestration scripts)

### For Validation
- **Python 3.10+** (for syntax checking)
- **pip** or **Poetry** or **uv** (for dependency management)

### For Execution Testing (Optional)
- **Temporal CLI** installed:
  ```bash
  brew install temporal  # macOS
  ```
  Or follow: https://docs.temporal.io/cli

The execution test will automatically start Temporal if it's not running.

## Running the Tests

### Quick Start (Automated)

**Prerequisites:**
1. Install claude-code: `npm install -g @anthropic-ai/claude-code`
2. Set API key: `export ANTHROPIC_API_KEY='your-api-key-here'`
3. (Optional) Install Temporal CLI for execution tests: `brew install temporal`

**Run the full test (with execution):**
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
cd test/python/skill-integration
./run-integration-test.sh
```

**Run validation-only test (skip execution):**
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
cd test/python/skill-integration
SKIP_EXECUTION=true ./run-integration-test.sh
```

The full test will:
1. Set up a test workspace with the skill installed
2. Invoke claude-code CLI with the test prompt
3. claude-code auto-loads the skill and generates a complete application
4. Validate the generated code (syntax, structure, dependencies)
5. Start Temporal server (if not running)
6. Execute the worker and client to run a real workflow
7. Verify workflow completes successfully
8. Report results

### Manual Testing with Claude Code

```bash
# 1. Set up test workspace
./setup-test-workspace.sh

# 2. Use Claude Code in the test workspace
cd test-workspace
# Ask Claude to create a Temporal workflow application

# 3. Validate the generated code
./validate.sh
```

## What Gets Generated

The skill should guide Claude to generate:

### Python Files
- **workflows.py** - Workflow definitions with `@workflow.defn`
- **activities.py** - Activity definitions with `@activity.defn`
- **worker.py** - Worker startup code
- **client.py** - Client code to start workflows

### Configuration Files
- **requirements.txt** or **pyproject.toml** - Dependencies
- **README.md** - Usage instructions (optional)

### Expected Patterns
- ✅ Async/await syntax throughout
- ✅ Type hints on function signatures
- ✅ Proper decorator usage (`@workflow.defn`, `@activity.defn`, `@workflow.run`)
- ✅ Latest temporalio package version
- ✅ Proper imports from temporalio modules

## Validation Checks

### Structure Validation
```bash
✓ workflows.py exists
✓ activities.py exists
✓ worker.py exists
✓ client.py exists
✓ requirements.txt or pyproject.toml exists
```

### Code Pattern Validation
```bash
✓ Contains @workflow.defn decorator
✓ Contains @activity.defn decorator
✓ Contains @workflow.run decorator
✓ Uses async/await syntax
✓ Has temporalio imports
✓ Python syntax is valid
```

### Dependency Validation
```bash
✓ temporalio package specified
✓ Version is reasonable (>= 1.0.0)
```

## Troubleshooting

### "claude-code CLI not found"
Install claude-code:
```bash
npm install -g @anthropic-ai/claude-code
```

Or use npx without installation:
```bash
npx @anthropic-ai/claude-code
```

### "ANTHROPIC_API_KEY not set"
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

### "Code generation failed"
- Check that claude-code CLI is working: `claude-code --help`
- Verify your API key is valid
- Check console output for claude-code errors
- Try running claude-code manually in the workspace directory

### "Python syntax errors"
- Check that generated code uses proper async/await
- Verify decorators are correctly applied
- Ensure imports are correct

### "temporalio not found"
```bash
cd test-workspace
pip install temporalio
# or
poetry install
# or
uv sync
```

### "Connection refused to localhost:7233"
The execution test will automatically start Temporal for you. If this fails:
```bash
# Install Temporal CLI
brew install temporal  # macOS
# Or follow: https://docs.temporal.io/cli

# Or skip execution test
SKIP_EXECUTION=true ./run-integration-test.sh
```

### "Execution test failed but validation passed"
This is treated as a partial success. It means:
- ✅ Generated code structure is correct
- ✅ Python syntax is valid
- ❌ Runtime execution had issues

Check the output for specific errors (missing dependencies, workflow logic issues, etc.)

### Test fails but code looks correct?
- Review the validation script output
- Check `test.log` for detailed error messages
- Verify skill file is correctly formatted markdown
- Ensure Python 3.10+ is being used

## Interpreting Results

### ✅ Success
```
========================================
✅ ALL TESTS PASSED
========================================
```
The skill correctly guides Claude to generate valid Temporal Python code.

### ❌ Failure
```
❌ Test failed: [specific error]
```
Review the error message and generated code to identify issues:
- Syntax errors → Check skill examples use correct Python
- Missing files → Verify skill mentions all required files
- Wrong patterns → Update skill to show correct decorator usage
- Import errors → Check skill shows correct module imports

## CI/CD Integration

This test can be integrated into CI/CD. For CI environments, you may want to skip the execution test:

```yaml
name: Test Python Skill
on: [push, pull_request]
jobs:
  test-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      - name: Run validation test
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          SKIP_EXECUTION: true
        run: |
          cd test/python/skill-integration
          ./run-integration-test.sh

  test-full:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      - name: Install Temporal CLI
        run: |
          brew install temporal
      - name: Run full integration test
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          cd test/python/skill-integration
          ./run-integration-test.sh
```

## Next Steps

After successful testing:
1. Build the skill package: `./build-skill-package.sh`
2. Deploy to Claude Code or Claude Cloud
3. Test with real user prompts

## Related Documentation

- **Build Documentation**: See `BUILD.md` in repository root
- **Skill Documentation**: See `src/sdks/python/python.md`
- **Java Tests**: See `test/java/skill-integration/` for comparison
