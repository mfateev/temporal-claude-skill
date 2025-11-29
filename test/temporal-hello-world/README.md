# Temporal Hello World Test

This is an automated test for the Temporal.io Java SDK skill. It generates a simple "Hello World" application and executes it to verify the skill works correctly.

## What This Test Does

1. **Checks** if a Temporal server is running
2. **Builds** the Maven project
3. **Starts** a Temporal worker
4. **Executes** a workflow that:
   - Calls an activity to format a greeting
   - Calls an activity to print the greeting
   - Returns the result
5. **Verifies** the workflow completes successfully
6. **Cleans up** by stopping the worker

## Prerequisites

Before running the test, you need:

1. **Java 11 or higher**
   ```bash
   java -version
   ```

2. **Maven**
   ```bash
   mvn -version
   ```

3. **Temporal Server** running locally

### Starting Temporal Server

Choose one of these options:

#### Option 1: Using Docker (Recommended)
```bash
docker run -p 7233:7233 -p 8233:8233 temporalio/auto-setup:latest
```

#### Option 2: Using Temporal CLI
```bash
# Install Temporal CLI first
brew install temporal

# Start local dev server
temporal server start-dev
```

The server should be accessible at `localhost:7233`.

## Running the Test

### Quick Test
```bash
cd test/temporal-hello-world
./run-test.sh
```

### Manual Testing

If you prefer to run components separately:

#### 1. Build the project
```bash
mvn clean compile
```

#### 2. Start the worker (in one terminal)
```bash
mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldWorker"
```

#### 3. Run the client (in another terminal)
```bash
mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldClient" -Dexec.args="World"
```

You can replace "World" with any name you want to greet.

## Expected Output

When the test runs successfully, you should see:

```
=== Temporal Hello World Test ===

Checking if Temporal server is running...
✓ Temporal server is running

Building the project...
✓ Build successful

Starting worker...
✓ Worker started (PID: xxxxx)

Waiting for worker to initialize...
✓ Worker ready

Executing workflow...
Starting workflow for: World

=================================
Hello, World!
=================================

Workflow completed with result: Hello, World!

✓ Workflow executed successfully!

Cleaning up...
✓ Worker stopped

=== Test PASSED ===
```

## Project Structure

```
temporal-hello-world/
├── pom.xml                          # Maven configuration
├── run-test.sh                      # Automated test script
├── README.md                        # This file
└── src/main/java/io/temporal/hello/
    ├── HelloWorldWorker.java        # Worker that polls for tasks
    ├── HelloWorldClient.java        # Client that starts workflows
    ├── workflows/
    │   ├── HelloWorldWorkflow.java      # Workflow interface
    │   └── HelloWorldWorkflowImpl.java  # Workflow implementation
    └── activities/
        ├── HelloWorldActivities.java      # Activity interface
        └── HelloWorldActivitiesImpl.java  # Activity implementation
```

## Troubleshooting

### Test fails with "Temporal server is not running"
- Make sure Temporal server is started (see Prerequisites)
- Verify it's accessible: `curl http://localhost:7233`

### Build fails with compilation errors
- Check Java version: `java -version` (must be 11+)
- Clean Maven cache: `mvn clean`

### Worker doesn't start
- Check if port 7233 is accessible
- Look at `worker.log` for error messages
- Ensure no other workers are running on the same task queue

### Workflow times out
- Check worker logs to see if it's polling the task queue
- Verify task queue name matches between worker and client
- Check Temporal Web UI at http://localhost:8233

## Verification

To verify the test covers the skill requirements:

- ✅ Uses latest Temporal Java SDK (1.32.0)
- ✅ Defines workflow interface and implementation
- ✅ Defines activity interface and implementation
- ✅ Configures activity options with timeouts and retries
- ✅ Creates and runs a worker
- ✅ Starts a workflow from a client
- ✅ Uses proper logging with Workflow.getLogger()
- ✅ Demonstrates end-to-end workflow execution

## CI/CD Integration

To run this test in CI/CD:

```bash
# Start Temporal in background
docker run -d -p 7233:7233 temporalio/auto-setup:latest

# Wait for Temporal to be ready
sleep 10

# Run test
cd test/temporal-hello-world && ./run-test.sh
```
