# Temporal Java Skill Integration Test

This test validates that the `temporal-java.md` skill works correctly when **actually used in Claude Code** to generate a Temporal application.

## What This Test Does

This is a **real integration test** that:

1. ✅ **Installs the skill** in a test workspace (`.claude/skills/temporal-java.md`)
2. ✅ **Uses Claude Code** to process a prompt that triggers the skill
3. ✅ **Generates a complete application** using Claude Code with the skill
4. ✅ **Validates the generated code**:
   - Correct file structure
   - All required files present
   - Code compiles successfully
   - Uses latest Temporal SDK version
5. ✅ **Optionally runs the application** if Temporal server is available

## Why This Test is Important

Unlike a simple code validation test, this integration test:

- **Tests the actual user workflow** - how the skill will really be used
- **Validates skill installation** - ensures the skill file is correctly formatted
- **Tests Claude Code integration** - verifies Claude can parse and use the skill
- **Validates end-to-end flow** - from prompt to working application
- **Catches skill formatting issues** - ensures markdown is properly structured

## Test Structure

```
test/skill-integration/
├── setup-test-workspace.sh      # Creates test workspace with skill
├── run-integration-test.sh      # Runs the full integration test
├── .gitignore                   # Ignores generated workspace
└── README.md                    # This file

Generated during test:
test-workspace/
├── .claude/
│   └── skills/
│       └── temporal-java.md     # The skill being tested
├── test-prompt.txt              # Prompt that triggers the skill
├── validate.sh                  # Validates generated application
└── [generated code here]        # Application created by Claude
```

## Prerequisites

### Required
- **Claude Code** installed and configured
- **Java 11+** and **Maven** (for validation and building)

### Optional (for execution test)
- **Temporal Server** running:
  ```bash
  docker run -p 7233:7233 -p 8233:8233 temporalio/auto-setup:latest
  ```

## Running the Test

### Option 1: Automated Test (Recommended)

```bash
cd test/skill-integration
./run-integration-test.sh
```

This will:
1. Set up the test workspace
2. Check if Claude Code is available
3. Provide instructions for using Claude Code
4. Validate the generated application

### Option 2: Manual Step-by-Step

#### Step 1: Set up the workspace
```bash
cd test/skill-integration
./setup-test-workspace.sh
```

#### Step 2: Open workspace in Claude Code
```bash
cd test-workspace
# Open in your IDE with Claude Code, or use CLI:
claude-code .
```

#### Step 3: Send the prompt to Claude Code

In Claude Code, send the content from `test-prompt.txt`:

```
Create a Temporal workflow that executes two activities. After the first activity
the workflow awaits a signal. When the signal is received it executes the second activity.

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
```

#### Step 4: Wait for Claude to generate the application

Claude Code will:
- Read the `temporal-java.md` skill
- Fetch the latest Temporal SDK version
- Generate all required files following skill patterns

#### Step 5: Validate the generated application
```bash
./validate.sh
```

This validates:
- ✅ All required files are present
- ✅ Code structure matches expected layout
- ✅ pom.xml contains Temporal SDK dependency
- ✅ Project compiles successfully
- ✅ (Optional) Application runs if Temporal server is available

## Expected Generated Structure

After Claude Code processes the prompt, you should see:

```
test-workspace/
├── pom.xml
└── src/main/java/io/temporal/hello/
    ├── Worker.java (or *Worker.java)
    ├── Client.java (or *Client.java)
    ├── workflows/
    │   ├── [Workflow interface with @SignalMethod]
    │   └── [Workflow implementation with signal handling]
    └── activities/
        ├── [Activity interface with 2 activities]
        └── [Activity implementation]
```

**Key Features to Validate:**
- Workflow has `@SignalMethod` annotation
- Workflow waits for signal between activities
- Client sends signal to workflow
- Activities are executed before and after signal

## What Gets Validated

### 1. Skill Installation
- ✅ Skill file is correctly placed in `.claude/skills/`
- ✅ Skill file is readable by Claude Code
- ✅ Skill metadata is correct

### 2. Code Generation
- ✅ Claude Code successfully uses the skill
- ✅ All required files are generated
- ✅ File structure matches conventions
- ✅ Package names are correct

### 3. Code Quality
- ✅ Generated code compiles without errors
- ✅ Uses latest Temporal SDK version
- ✅ Follows patterns from the skill:
  - Workflow interface/implementation
  - Activity interface/implementation
  - Activity options with timeouts/retries
  - Worker registration
  - Client invocation
  - Proper logging configuration

### 4. Functionality (Optional)
- ✅ Worker starts successfully
- ✅ Workflow executes end-to-end
- ✅ Activities are invoked
- ✅ Results are correct

## Validation Script Details

The `validate.sh` script checks:

```bash
# Structure validation
✓ Found pom.xml
✓ Found: src/main/java/io/temporal/hello/workflows/HelloWorldWorkflow.java
✓ Found: src/main/java/io/temporal/hello/workflows/HelloWorldWorkflowImpl.java
✓ Found: src/main/java/io/temporal/hello/activities/HelloWorldActivities.java
✓ Found: src/main/java/io/temporal/hello/activities/HelloWorldActivitiesImpl.java
✓ Found: src/main/java/io/temporal/hello/HelloWorldWorker.java
✓ Found: src/main/java/io/temporal/hello/HelloWorldClient.java

# Dependency validation
✓ pom.xml contains Temporal SDK dependency
✓ Using Temporal SDK version: 1.32.0

# Build validation
✓ Build successful!

# Optional: Execution test (if Temporal running)
✓ Temporal server is running
You can now test the application:
  1. Start worker: mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldWorker"
  2. Run client: mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldClient" -Dexec.args="YourName"
```

## Troubleshooting

### "Claude Code not found"
- Install Claude Code CLI
- Or manually open the workspace in your IDE with Claude Code plugin

### "Skill not being used"
- Verify skill file is in `.claude/skills/temporal-java.md`
- Check skill file format (must be valid markdown)
- Try mentioning the skill explicitly in your prompt

### "Generated code doesn't compile"
- Check if Java 11+ is installed
- Verify Maven can download dependencies
- Review Claude's output for any errors

### "Validation fails - missing files"
- Ensure Claude completed generating all files
- Check if any errors occurred during generation
- Try regenerating with a more explicit prompt

## Testing the Generated Application

Once validation passes, you can test the actual application:

### 1. Start Temporal Server
```bash
docker run -p 7233:7233 -p 8233:8233 temporalio/auto-setup:latest
```

### 2. In one terminal, start the worker:
```bash
cd test-workspace
mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldWorker"
```

### 3. In another terminal, run the client:
```bash
cd test-workspace
mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldClient" -Dexec.args="World"
```

You should see:
```
=================================
Hello, World!
=================================
```

## CI/CD Integration

For automated testing in CI/CD:

```yaml
# Example GitHub Actions workflow
steps:
  - name: Set up test workspace
    run: |
      cd test/skill-integration
      ./setup-test-workspace.sh

  - name: Install Claude Code
    run: |
      # Install Claude Code CLI
      # (implementation depends on your setup)

  - name: Generate application
    run: |
      cd test/skill-integration/test-workspace
      claude-code --prompt "$(cat test-prompt.txt)"

  - name: Validate generated code
    run: |
      cd test/skill-integration/test-workspace
      ./validate.sh

  - name: Start Temporal and test
    run: |
      docker run -d -p 7233:7233 temporalio/auto-setup:latest
      sleep 10
      cd test/skill-integration/test-workspace
      # Run worker and client tests
```

## Success Criteria

The test passes if:

1. ✅ Skill installs correctly in test workspace
2. ✅ Claude Code successfully processes the prompt
3. ✅ All required files are generated
4. ✅ Generated code compiles without errors
5. ✅ Code follows patterns from the skill
6. ✅ (Optional) Application runs successfully

## What This Test Proves

If this test passes, it proves:

- ✅ **The skill file is correctly formatted** for Claude Code
- ✅ **Claude can parse and use the skill** effectively
- ✅ **The skill generates working code** not just documentation
- ✅ **The patterns in the skill are correct** and compilable
- ✅ **The skill is production-ready** for real users
- ✅ **The user workflow works end-to-end** from skill to running app

This is the gold standard for skill validation!
