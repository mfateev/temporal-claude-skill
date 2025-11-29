# Claude-Powered Validation for Temporal Java Skill

This directory contains an intelligent validation system that uses Claude AI to analyze generated Temporal applications.

## Overview

Instead of rigid bash scripts that check for exact directory names and file locations, we now use Claude AI to intelligently validate:

- **Structure**: Project organization, Maven configuration, Temporal dependencies
- **Patterns**: Correct use of @WorkflowInterface, @ActivityInterface, etc.
- **Code Quality**: Proper imports, annotations, and Temporal best practices
- **Flexibility**: Handles variations in naming, structure, and approaches

## Files

### claude_validate.py

Python script that uses the Anthropic API to validate generated applications.

**Features:**
- Collects project structure (files, directories, Java sources)
- Sends structure to Claude for intelligent analysis
- Receives structured validation results (JSON)
- Tests compilation with Maven
- Provides detailed, human-readable feedback

**Usage:**
```bash
export ANTHROPIC_API_KEY='your-key-here'
python3 claude_validate.py /path/to/workspace
```

**Output:**
- Structure validation (pom.xml, workflows, activities, worker, client)
- Code quality assessment
- Advanced feature detection (signals, queries, Spring Boot)
- Issues, warnings, and recommendations
- Compilation test results

### Integration with Tests

The validation is integrated into:

1. **run-integration-test.sh**: Main integration test
   - Generates application with Anthropic API
   - Validates with Claude AI
   - Tests execution (optional)

2. **run-spring-boot-test.sh**: Spring Boot integration test
   - Generates Spring Boot application
   - Validates Spring Boot patterns
   - Tests compilation

## Advantages Over Bash Validation

### Old Approach (Bash)
```bash
# Rigid checks
WORKFLOW_FILES=$(find src/main/java/io/temporal/hello/workflows -name "*Workflow*.java")
if [ "$WORKFLOW_FILES" -lt 2 ]; then
    echo "Expected at least 2 workflow files"
    exit 1
fi
```

**Problems:**
- Fails if directory is named `workflow` instead of `workflows`
- Can't understand if code is actually valid
- No flexibility for different project structures
- Hard to maintain as patterns evolve

### New Approach (Claude)
```python
# Intelligent analysis
result = invoke_claude_validation(structure, api_key)
# Claude understands:
# - "workflow" vs "workflows" is fine
# - What makes a valid Temporal workflow
# - If patterns are correct regardless of names
# - If code will actually work
```

**Benefits:**
- Flexible about naming and structure
- Understands Temporal patterns deeply
- Provides actionable feedback
- Adapts to different approaches (standard Java, Spring Boot, etc.)
- Validates semantic correctness, not just file presence

## Validation Criteria

Claude validates based on Temporal best practices:

### Required Components
- ✅ pom.xml with Temporal SDK dependency
- ✅ Workflow interface with @WorkflowInterface
- ✅ Workflow implementation with @WorkflowMethod
- ✅ Activity interface with @ActivityInterface
- ✅ Activity implementation with @ActivityMethod
- ✅ Worker to register workflows and activities
- ✅ Client to start workflows

### Optional Components
- ⚡ Signal methods (@SignalMethod)
- 🔍 Query methods (@QueryMethod)
- 🌱 Spring Boot integration (@WorkflowImpl, @ActivityImpl)
- 🧪 Test classes

### Code Quality
- Correct annotation usage
- Proper imports
- Reasonable package structure
- Compilation success

## Example Output

```
==> Collecting project structure...
✓ Collected 9 files, 7 Java files

==> Invoking Claude for intelligent validation...
✓ Received validation response (1234 chars)

============================================================
VALIDATION RESULTS
============================================================

✓ PASSED: Well-structured Temporal application with signal pattern

Structure:
  ✓ pom.xml: Contains Temporal SDK 1.25.2
  ✓ Workflows: 2 files - Interface and implementation found
  ✓ Activities: 2 files - Interface and implementation found
  ✓ Worker: Registers workflows and activities correctly
  ✓ Client: Starts workflow and sends signal

Code Quality:
  ✓ All Temporal annotations used correctly

Advanced Features:
  ✓ Signal methods implemented
  (Spring Boot integration not detected)

Warnings:
  ! Test file placed in src/main/java instead of src/test/java

Recommendations:
  → Move test classes to src/test/java
  → Consider adding query methods for workflow state

============================================================

==> Testing compilation with Maven...
  Running: mvn clean compile
✓ Compilation successful

============================================================
✓ VALIDATION PASSED
  Application structure is valid and compiles successfully
============================================================
```

## Running the Tests

### Full Integration Test
```bash
cd test/skill-integration
export ANTHROPIC_API_KEY='your-key-here'
./run-integration-test.sh
```

### Spring Boot Test
```bash
cd test/skill-integration
export ANTHROPIC_API_KEY='your-key-here'
./run-spring-boot-test.sh
```

### Manual Validation
```bash
# Generate code first (with Claude Code or API)
cd test/skill-integration
python3 claude_validate.py test-workspace
```

## Troubleshooting

### "ANTHROPIC_API_KEY not set"
Set your API key:
```bash
export ANTHROPIC_API_KEY='sk-ant-...'
```

### "anthropic package not found"
Install the package:
```bash
pip3 install anthropic
```

### Validation fails but code looks correct
Check the validation-result.json file in the workspace:
```bash
cat test-workspace/validation-result.json
```

This shows Claude's detailed analysis.

### Compilation fails
Claude validation will show compilation errors. Check:
- Maven is installed: `mvn --version`
- Java is installed: `java --version`
- Dependencies can be downloaded

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Integration Test (run-integration-test.sh)              │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│ Setup Workspace (setup-test-workspace.sh)               │
│ - Create test-workspace/                                │
│ - Copy skill files                                      │
│ - Create test prompt                                    │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│ Generate Code (automate_test.py)                        │
│ - Use Anthropic API                                     │
│ - Send skill + prompt to Claude                         │
│ - Extract generated code                                │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│ Validate Code (claude_validate.py) ← NEW                │
│ - Collect project structure                             │
│ - Send to Claude for analysis                           │
│ - Receive structured validation                         │
│ - Test compilation                                      │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│ Execution Test (test-execution.sh)                      │
│ - Start Temporal server                                 │
│ - Run worker and client                                 │
│ - Verify workflow execution                             │
└─────────────────────────────────────────────────────────┘
```

## Future Enhancements

Potential improvements:

1. **Cache validation results** to avoid redundant API calls
2. **Batch validation** for multiple workspaces
3. **Custom validation rules** via configuration
4. **Integration with CI/CD** for automated skill testing
5. **Validation reports** in multiple formats (JSON, HTML, PDF)

## Contributing

When modifying the validation:

1. Update `claude_validate.py` for validation logic
2. Update test scripts that call validation
3. Update this documentation
4. Test with both standard and Spring Boot applications
5. Verify compilation testing works

## Related Files

- `automate_test.py`: Code generation via API
- `run-integration-test.sh`: Main test orchestration
- `run-spring-boot-test.sh`: Spring Boot test
- `test-execution.sh`: Runtime execution tests
- `.claude/commands/run-skill-test.md`: Claude Code command
