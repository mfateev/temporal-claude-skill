# Temporal Java SDK Skill Validation Test

This test validates the `temporal-java.md` skill by:
1. Reading the skill file
2. Fetching the latest Temporal SDK version from Maven Central
3. Generating a complete working application based on skill patterns
4. Building and running the generated application
5. Verifying end-to-end workflow execution

## What This Test Does

This is a **meta-test** that validates the skill itself, not just an application created with it. The test:

- ✅ Parses the skill markdown file
- ✅ Fetches the latest Temporal SDK version dynamically
- ✅ Generates a complete Hello World application following skill patterns
- ✅ Creates proper Maven project structure
- ✅ Includes workflow interface and implementation (based on skill)
- ✅ Includes activity interface and implementation (based on skill)
- ✅ Includes worker and client (based on skill)
- ✅ Uses activity options with timeouts and retries (from skill)
- ✅ Uses Workflow.getLogger() for deterministic logging (from skill)
- ✅ Configures proper logging with logback (from skill)
- ✅ Builds the generated project
- ✅ Runs worker and client
- ✅ Verifies workflow completes successfully

## Prerequisites

### 1. Python 3
```bash
python3 --version
```

### 2. pip3 (for installing dependencies)
```bash
pip3 --version
```

### 3. Java 11+
```bash
java -version
```

### 4. Maven
```bash
mvn -version
```

### 5. Temporal Server Running
Start Temporal server before running the test:

#### Using Docker (Recommended):
```bash
docker run -p 7233:7233 -p 8233:8233 temporalio/auto-setup:latest
```

#### Using Temporal CLI:
```bash
temporal server start-dev
```

## Running the Test

```bash
cd test/skill-validation
./run-test.sh
```

The test script will:
1. Install required Python dependencies (`requests`)
2. Run the validation script
3. Report success or failure

## Test Flow

```
┌─────────────────────────────────────┐
│  1. Read temporal-java.md skill     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. Fetch latest Temporal SDK       │
│     version from Maven Central      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  3. Generate complete application   │
│     - Workflow interface/impl       │
│     - Activity interface/impl       │
│     - Worker (with registration)    │
│     - Client (with options)         │
│     - pom.xml with latest version   │
│     - logback.xml configuration     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  4. Check Temporal server           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  5. Build with Maven                │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  6. Start worker in background      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  7. Execute workflow via client     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  8. Verify "Hello, World!" output   │
└──────────────┬──────────────────────┘
               │
               ▼
         ✓ PASS / ✗ FAIL
```

## Expected Output

```
==================================================
Temporal Java SDK Skill Validation Test
==================================================

==> Fetching latest Temporal SDK version...
✓ Latest Temporal SDK version: 1.32.0

==> Reading skill file: /path/to/temporal-java.md
✓ Skill file loaded

==> Extracting code examples from skill...
✓ Found 25 code blocks

==> Generating Hello World project...
✓ Project generated at: generated-app

==> Checking Temporal server...
✓ Temporal server is running

==> Building project...
✓ Build successful

==> Starting worker...
==> Waiting for worker to initialize...
✓ Worker started

==> Executing workflow...
✓ Workflow executed successfully!

==================================================
✓ SKILL VALIDATION PASSED
==================================================

Validation summary:
  ✓ Skill file parsed successfully
  ✓ Latest Temporal SDK version used (1.32.0)
  ✓ Project generated from skill patterns
  ✓ Code compiled successfully
  ✓ Worker started and registered components
  ✓ Workflow executed end-to-end
  ✓ Activity invoked and completed
```

## What Gets Validated

### Skill File Structure
- ✅ Skill file exists and is readable
- ✅ Contains valid code examples
- ✅ Code blocks are properly formatted

### Version Management
- ✅ Can fetch latest version from Maven Central
- ✅ Skill instruction to use latest version works

### Project Generation
- ✅ Maven project structure is correct
- ✅ Dependencies are properly declared
- ✅ Latest Temporal SDK version is used

### Code Patterns (from skill)
- ✅ Workflow interface pattern
- ✅ Workflow implementation with activity stubs
- ✅ Activity options configuration
- ✅ Retry policies
- ✅ Activity interface and implementation
- ✅ Worker registration pattern
- ✅ Client workflow invocation pattern
- ✅ Workflow.getLogger() usage
- ✅ Activity heartbeat pattern

### Build & Execution
- ✅ Code compiles without errors
- ✅ Worker starts successfully
- ✅ Workflow executes end-to-end
- ✅ Activities are invoked
- ✅ Results are returned correctly

## Troubleshooting

### "Temporal server is not running"
Ensure Temporal is running on `localhost:7233`:
```bash
curl http://localhost:7233
```

### "ModuleNotFoundError: No module named 'requests'"
Install the required Python package:
```bash
pip3 install requests
# or
pip3 install --user requests
```

### "Build failed"
- Check Java version (must be 11+)
- Check Maven is installed
- Check internet connection (Maven downloads dependencies)

### "Workflow execution failed"
- Check worker logs
- Verify task queue name matches between worker and client
- Check Temporal Web UI at http://localhost:8233

## Generated Application

The test generates a complete application in `generated-app/` with:

```
generated-app/
├── pom.xml
└── src/main/
    ├── java/io/temporal/hello/
    │   ├── HelloWorldWorker.java
    │   ├── HelloWorldClient.java
    │   ├── workflows/
    │   │   ├── HelloWorldWorkflow.java
    │   │   └── HelloWorldWorkflowImpl.java
    │   └── activities/
    │       ├── HelloWorldActivities.java
    │       └── HelloWorldActivitiesImpl.java
    └── resources/
        └── logback.xml
```

This directory is automatically cleaned up by `.gitignore`.

## CI/CD Integration

```bash
# Start Temporal
docker run -d -p 7233:7233 temporalio/auto-setup:latest

# Wait for startup
sleep 10

# Run validation
cd test/skill-validation && ./run-test.sh
```

## Why This Test is Important

This test ensures that:
1. **The skill file is correct** - All code examples compile and work
2. **The skill is up-to-date** - Uses latest Temporal SDK versions
3. **The patterns are valid** - Generated code follows best practices
4. **The skill is usable** - Can generate working applications
5. **Documentation is accurate** - Code examples match descriptions

If this test passes, you can be confident that the `temporal-java.md` skill will help users create correct, working Temporal applications.
