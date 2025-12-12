# Go SDK Resource

This resource provides guidance on working with Temporal.io using the Go SDK by pointing you to official documentation and key APIs, along with production-tested best practices.

## Official Documentation

**Primary Resources:**
- **Main Documentation**: https://docs.temporal.io/
- **Go SDK Documentation**: https://docs.temporal.io/develop/go
- **Go SDK API Reference**: https://pkg.go.dev/go.temporal.io/sdk
- **GitHub Repository**: https://github.com/temporalio/sdk-go
- **Samples Repository**: https://github.com/temporalio/samples-go

## Go Module Information

```
Module: go.temporal.io/sdk
```

Find the latest version at: https://pkg.go.dev/go.temporal.io/sdk

**Installation:**
```bash
go get go.temporal.io/sdk
```

**Import Paths:**
```go
import (
    "go.temporal.io/sdk/activity"
    "go.temporal.io/sdk/client"
    "go.temporal.io/sdk/temporal"
    "go.temporal.io/sdk/worker"
    "go.temporal.io/sdk/workflow"
)
```

## Core Concepts & Where to Find Them

### Workflows
- **What**: Orchestration logic, must be deterministic
- **Key Identifier**: First parameter is `workflow.Context`
- **Documentation**: https://docs.temporal.io/workflows
- **Go Guide**: https://docs.temporal.io/develop/go/core-application#develop-workflows

**Key Concepts:**
- Workflow functions take `workflow.Context` as first parameter
- Must be deterministic (no random, time.Now, UUID, etc.)
- Use `workflow.*` functions for time, sleep, goroutines, channels

### Activities
- **What**: Non-deterministic operations (API calls, database operations)
- **Key Identifier**: First parameter is `context.Context`
- **Documentation**: https://docs.temporal.io/activities
- **Go Guide**: https://docs.temporal.io/develop/go/core-application#develop-activities

**Key Concepts:**
- Activity functions take `context.Context` as first parameter
- Can perform I/O, use random numbers, call external services
- Should be idempotent when possible

### Workers
- **What**: Services that poll task queues and execute workflows/activities
- **Key Package**: `go.temporal.io/sdk/worker`
- **Documentation**: https://docs.temporal.io/workers
- **Go Guide**: https://docs.temporal.io/develop/go/core-application#run-a-dev-worker

**Basic Worker Setup:**
```go
import (
    "go.temporal.io/sdk/client"
    "go.temporal.io/sdk/worker"
)

c, err := client.Dial(client.Options{})
if err != nil {
    log.Fatalln("Unable to create client", err)
}
defer c.Close()

w := worker.New(c, "task-queue-name", worker.Options{})
w.RegisterWorkflow(MyWorkflow)
w.RegisterActivity(MyActivity)

err = w.Run(worker.InterruptCh())
```

### Clients
- **What**: Initiate and interact with workflows
- **Key Package**: `go.temporal.io/sdk/client`
- **Documentation**: https://docs.temporal.io/encyclopedia/temporal-sdks#temporal-client
- **Go Guide**: https://docs.temporal.io/develop/go/core-application#connect-to-a-cluster

**Basic Client Usage:**
```go
import "go.temporal.io/sdk/client"

c, err := client.Dial(client.Options{})
if err != nil {
    log.Fatalln("Unable to create client", err)
}
defer c.Close()

workflowOptions := client.StartWorkflowOptions{
    ID:        "my-workflow-id",
    TaskQueue: "my-task-queue",
}

we, err := c.ExecuteWorkflow(context.Background(), workflowOptions, MyWorkflow, "input")
if err != nil {
    log.Fatalln("Unable to execute workflow", err)
}

var result string
err = we.Get(context.Background(), &result)
```

## Workflow Determinism Rules

**CRITICAL**: Workflows must be deterministic. Use these Temporal-provided alternatives:

| Don't Use | Use Instead | Why |
|-----------|-------------|-----|
| `time.Now()` | `workflow.Now(ctx)` | Time must be replay-safe |
| `time.Sleep()` | `workflow.Sleep(ctx, duration)` | Sleep must be replay-safe |
| `go func()` | `workflow.Go(ctx, func(ctx workflow.Context))` | Goroutines must be tracked |
| `chan` | `workflow.Channel` | Channels must be replay-safe |
| `select` | `workflow.Selector` | Select must be replay-safe |
| `context.Context` | `workflow.Context` | Different context for workflows |
| `uuid.New()` | `workflow.SideEffect()` or activity | UUIDs must be deterministic |
| `rand.*` | `workflow.SideEffect()` or activity | Random must be deterministic |
| `range map` | Sorted iteration | Map order is non-deterministic |
| `log.*` | `workflow.GetLogger(ctx)` | Prevents duplicate logs during replay |

**Example - Deterministic Map Iteration:**
```go
// Bad - non-deterministic order
for k, v := range myMap {
    // order varies between runs
}

// Good - deterministic order
keys := make([]string, 0, len(myMap))
for k := range myMap {
    keys = append(keys, k)
}
sort.Strings(keys)
for _, k := range keys {
    v := myMap[k]
    // consistent order
}
```

## Activity Registration Best Practices

**Register activities with a prefix** to avoid naming collisions in multi-package projects:

```go
// Bad - potential naming collision
w.RegisterActivity(myActivities)

// Good - prefixed registration
w.RegisterActivityWithOptions(myActivities, activity.RegisterOptions{
    Name: "mypackage.",
})
```

This allows multiple packages to have activities with the same function names without collision.

## Workflow Versioning

Use versioning for workflow changes to ensure backward compatibility with running workflows.

**Basic Version Pattern:**
```go
v := workflow.GetVersion(ctx, "change-description-YYYY-MM-DD", workflow.DefaultVersion, 1)
if v == workflow.DefaultVersion {
    // Execute old logic (for workflows started before the change)
} else {
    // Execute new logic (for new workflows)
}
```

**Version Cleanup Process** (typically safe after workflow retention period, e.g., 90 days):

**Step 1**: Remove versioned code but keep GetVersion call:
```go
// Before cleanup
if workflow.GetVersion(ctx, "my-change", workflow.DefaultVersion, 1) == workflow.DefaultVersion {
    oldLogic()
} else {
    newLogic()
}

// After Step 1
_ = workflow.GetVersion(ctx, "my-change", workflow.DefaultVersion, 1)
newLogic()
```
Step 1 preserves replay safety if the PR needs to be rolled back.

**Step 2**: Remove GetVersion call entirely (separate PR/release):
```go
// After Step 2
newLogic()
```

## Configuration Options

### Activity Options
- **Type**: `workflow.ActivityOptions`
- **Documentation**: https://docs.temporal.io/develop/go/core-application#activity-timeouts
- **Key Settings**: StartToCloseTimeout, ScheduleToCloseTimeout, RetryPolicy

**Usage:**
```go
ao := workflow.ActivityOptions{
    StartToCloseTimeout: 10 * time.Minute,
    RetryPolicy: &temporal.RetryPolicy{
        InitialInterval:    time.Second,
        BackoffCoefficient: 2.0,
        MaximumInterval:    time.Minute,
        MaximumAttempts:    5,
    },
}
ctx = workflow.WithActivityOptions(ctx, ao)

var result string
err := workflow.ExecuteActivity(ctx, MyActivity, "input").Get(ctx, &result)
```

### Workflow Options
- **Type**: `client.StartWorkflowOptions`
- **Documentation**: https://docs.temporal.io/develop/go/core-application#workflow-timeouts
- **Key Settings**: ID, TaskQueue, WorkflowExecutionTimeout, WorkflowRunTimeout

### Retry Policy
- **Type**: `temporal.RetryPolicy`
- **Documentation**: https://docs.temporal.io/encyclopedia/retry-policies

## Advanced Patterns

### Child Workflows
- **Documentation**: https://docs.temporal.io/encyclopedia/child-workflows
- **Function**: `workflow.ExecuteChildWorkflow()`

**Usage:**
```go
cwo := workflow.ChildWorkflowOptions{
    WorkflowID: "child-workflow-id",
}
ctx = workflow.WithChildOptions(ctx, cwo)

var result string
err := workflow.ExecuteChildWorkflow(ctx, ChildWorkflow, "input").Get(ctx, &result)
```

### Signals and Queries
- **Signals Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-signals
- **Queries Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-queries

**Signal Example:**
```go
// In workflow - receiving signal
signalChan := workflow.GetSignalChannel(ctx, "my-signal")
var signalVal string
signalChan.Receive(ctx, &signalVal)

// From client - sending signal
err := c.SignalWorkflow(ctx, workflowID, runID, "my-signal", signalValue)
```

**Query Example:**
```go
// In workflow - define query handler
err := workflow.SetQueryHandler(ctx, "get-status", func() (string, error) {
    return currentStatus, nil
})

// From client - send query
response, err := c.QueryWorkflow(ctx, workflowID, runID, "get-status")
var status string
err = response.Get(&status)
```

### Continue-As-New
- **Documentation**: https://docs.temporal.io/workflows#continue-as-new
- **Use Case**: Prevent workflow history from growing too large in long-running workflows
- **Function**: `workflow.NewContinueAsNewError()`

**Usage:**
```go
if workflow.GetInfo(ctx).GetCurrentHistoryLength() > 10000 {
    return "", workflow.NewContinueAsNewError(ctx, MyWorkflow, newInput)
}
```

### Async Activity Completion
- **Documentation**: https://docs.temporal.io/activities#asynchronous-activity-completion
- **Use Case**: Activity completes outside the worker process

**Usage:**
```go
// In activity
info := activity.GetInfo(ctx)
taskToken := info.TaskToken
// Store taskToken, return activity.ErrResultPending

// Later, complete asynchronously
c.CompleteActivity(ctx, taskToken, result, nil)
```

### Saga Pattern (Compensation)
- **Documentation**: https://docs.temporal.io/encyclopedia/saga-pattern

**Usage:**
```go
var compensations []func(context.Context) error

// Step 1
err := workflow.ExecuteActivity(ctx, Step1Activity).Get(ctx, nil)
if err != nil {
    return err
}
compensations = append(compensations, CompensateStep1)

// Step 2
err = workflow.ExecuteActivity(ctx, Step2Activity).Get(ctx, nil)
if err != nil {
    // Compensate in reverse order
    for i := len(compensations) - 1; i >= 0; i-- {
        workflow.ExecuteActivity(ctx, compensations[i]).Get(ctx, nil)
    }
    return err
}
```

## Testing

### Test Framework
- **Documentation**: https://docs.temporal.io/develop/go/testing
- **Key Package**: `go.temporal.io/sdk/testsuite`

**Workflow Unit Test:**
```go
import (
    "testing"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/require"
    "go.temporal.io/sdk/testsuite"
)

func TestMyWorkflow(t *testing.T) {
    testSuite := &testsuite.WorkflowTestSuite{}
    env := testSuite.NewTestWorkflowEnvironment()

    // Mock activity
    env.OnActivity(MyActivity, mock.Anything, "input").Return("output", nil)

    env.ExecuteWorkflow(MyWorkflow, "input")

    require.True(t, env.IsWorkflowCompleted())
    require.NoError(t, env.GetWorkflowError())

    var result string
    require.NoError(t, env.GetWorkflowResult(&result))
    require.Equal(t, "expected", result)
}
```

**Activity Unit Test:**
```go
func TestMyActivity(t *testing.T) {
    testSuite := &testsuite.WorkflowTestSuite{}
    env := testSuite.NewTestActivityEnvironment()

    env.RegisterActivity(MyActivity)

    result, err := env.ExecuteActivity(MyActivity, "input")
    require.NoError(t, err)

    var output string
    require.NoError(t, result.Get(&output))
    require.Equal(t, "expected", output)
}
```

**Testing Time-Dependent Logic:**
```go
// Control workflow.Now(ctx) in tests
env.SetStartTime(time.Date(2024, 1, 15, 10, 0, 0, 0, time.UTC))
```

### Table-Driven Tests

Use table-driven tests for comprehensive coverage:

```go
func TestValidateInput(t *testing.T) {
    type testCase struct {
        name     string
        input    string
        expected error
        wantErr  bool
    }

    tests := []testCase{
        {
            name:     "valid input",
            input:    "valid@example.com",
            expected: nil,
            wantErr:  false,
        },
        {
            name:     "empty input",
            input:    "",
            expected: ErrEmptyInput,
            wantErr:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateInput(tt.input)
            if tt.wantErr {
                require.Error(t, err)
                require.Equal(t, tt.expected, err)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

### Mock Best Practices

**Prefer explicit mock expectations over permissive matchers:**

```go
// Bad - too permissive
env.OnActivity(MyActivity, mock.Anything, mock.Anything).Return("result", nil)

// Good - explicit expectations (mock.Anything acceptable for context)
env.OnActivity(MyActivity, mock.Anything, "expected-input").Return("result", nil)

// Good - custom matcher for complex cases
env.OnActivity(MyActivity, mock.Anything, mock.MatchedBy(func(req *Request) bool {
    return req.Name == "test" && req.ID > 0
})).Return("result", nil)
```

## Connection Configuration

### Local Development
```go
c, err := client.Dial(client.Options{
    HostPort: "localhost:7233",
})
```

### Temporal Cloud
```go
cert, err := tls.LoadX509KeyPair(clientCertPath, clientKeyPath)
if err != nil {
    log.Fatalln("Unable to load cert", err)
}

c, err := client.Dial(client.Options{
    HostPort:  "namespace.account.tmprl.cloud:7233",
    Namespace: "namespace.account",
    ConnectionOptions: client.ConnectionOptions{
        TLS: &tls.Config{
            Certificates: []tls.Certificate{cert},
        },
    },
})
```

## Best Practices

**Key Points:**
1. **Workflows must be deterministic**: https://docs.temporal.io/develop/go/core-application#workflow-logic-requirements
2. Use `workflow.GetLogger(ctx)` for workflow logging (replay-safe)
3. Set appropriate timeouts for workflows and activities
4. Configure retry policies for transient failures
5. Use activity heartbeats for long-running operations: `activity.RecordHeartbeat(ctx, details)`
6. Design activities to be idempotent
7. Use Continue-As-New for long-running workflows
8. Use versioning for safe workflow updates
9. Register activities with name prefixes to avoid collisions
10. Prefer regular functions over receiver methods for workflows (unless dependencies needed)

**Workflow Function Style:**

```go
// Preferred - regular function (easier to test, no hidden state)
func ProcessOrder(ctx workflow.Context, orderID string) error {
    // workflow logic
}

// Use receiver method only when injected dependencies are needed
type OrderWorkflow struct {
    notifier NotificationService // injected dependency
}

func (w *OrderWorkflow) Process(ctx workflow.Context, orderID string) error {
    return w.notifier.Send(ctx, "order processed")
}
```

**Serialization Requirements:**
- Workflow/Activity inputs and outputs must be serializable
- Avoid channels, functions, or interfaces in parameters/return values
- Use structs with exported fields for complex data

## Code Style Guidelines

**Go Conventions:**
```go
// Group const, type, and var declarations at file top
const (
    TaskQueueName = "my-task-queue"
    DefaultTimeout = 10 * time.Minute
)

type (
    OrderID   string
    AccountID string
)

var (
    ErrNotFound = errors.New("not found")
)
```

**Avoid name stuttering:**
```go
// Bad
type Order struct {
    OrderID     string
    OrderStatus string
}

// Good
type Order struct {
    ID     string
    Status string
}
```

## Code Examples and Samples

**Comprehensive Sample Reference:**
- **Detailed Sample Guide**: See `references/samples.md` for categorized samples with descriptions
  - Hello samples (getting started)
  - Scenario-based samples (real-world patterns)
  - Advanced features (interceptors, encryption, metrics)
  - Testing examples

**Direct Links:**
- **Samples Repository**: https://github.com/temporalio/samples-go
- **Interactive Tutorials**: https://learn.temporal.io/

**Quick Sample Lookup by Use Case:**
- Getting started: `helloworld/`
- Signals/Queries: `signals/`, `query/`
- Child workflows: `child-workflow/`
- SAGA pattern: `expense/`
- See `references/samples.md` for complete categorized list

## Common Questions

**API Questions:**
- Search the API docs: https://pkg.go.dev/go.temporal.io/sdk
- Look for specific types in the appropriate package

**Troubleshooting:**
- Community forum: https://community.temporal.io/
- GitHub issues: https://github.com/temporalio/sdk-go/issues
- Slack: https://temporal.io/slack

## Project Structure

Standard Go project structure:
```
my-temporal-project/
├── go.mod
├── go.sum
├── cmd/
│   ├── worker/
│   │   └── main.go          # Worker entry point
│   └── client/
│       └── main.go          # Client/starter
├── internal/
│   ├── workflows/
│   │   ├── order.go         # Workflow definitions
│   │   └── order_test.go    # Workflow tests
│   └── activities/
│       ├── payment.go       # Activity definitions
│       └── payment_test.go  # Activity tests
└── pkg/                     # Shared packages
```

**Alternative Structure (Entity-Driven):**
```
my-temporal-project/
├── entities/
│   ├── account/
│   │   ├── workflows.go
│   │   ├── activities.go
│   │   └── fx.go            # Dependency injection setup
│   └── order/
│       ├── workflows.go
│       ├── activities.go
│       └── fx.go
├── cmd/
│   └── worker/
│       └── main.go
└── internal/
    └── common/
        └── workflowutil/    # Shared workflow utilities
```

Refer to the samples repository for concrete examples: https://github.com/temporalio/samples-go
