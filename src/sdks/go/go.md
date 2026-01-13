# Go SDK Resource

<quick-reference>
## Quick Reference

| Task | Code/Command |
|------|--------------|
| Install SDK | `go get go.temporal.io/sdk` |
| Workflow signature | `func MyWorkflow(ctx workflow.Context, input T) (R, error)` |
| Activity signature | `func MyActivity(ctx context.Context, input T) (R, error)` |
| Execute activity | `workflow.ExecuteActivity(ctx, MyActivity, input).Get(ctx, &result)` |
| Execute child workflow | `workflow.ExecuteChildWorkflow(ctx, ChildWorkflow, input).Get(ctx, &result)` |
| Get current time | `workflow.Now(ctx)` |
| Sleep in workflow | `workflow.Sleep(ctx, duration)` |
| Spawn goroutine | `workflow.Go(ctx, func(ctx workflow.Context) { ... })` |
| Get logger | `workflow.GetLogger(ctx)` |
| Version gate | `workflow.GetVersion(ctx, "change-id", workflow.DefaultVersion, 1)` |

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
</quick-reference>

<official-docs>
## Official Documentation

- **Go SDK Docs**: https://docs.temporal.io/develop/go
- **API Reference**: https://pkg.go.dev/go.temporal.io/sdk
- **GitHub**: https://github.com/temporalio/sdk-go
- **Samples**: https://github.com/temporalio/samples-go
</official-docs>

<determinism-rules>
## CRITICAL: Workflow Determinism Rules

Workflows MUST be deterministic. Use Temporal alternatives:

| DONT USE | USE INSTEAD |
|----------|-------------|
| `time.Now()` | `workflow.Now(ctx)` |
| `time.Sleep()` | `workflow.Sleep(ctx, d)` |
| `go func()` | `workflow.Go(ctx, fn)` |
| `chan T` | `workflow.Channel` |
| `select {}` | `workflow.Selector` |
| `context.Context` | `workflow.Context` |
| `uuid.New()` | `workflow.SideEffect()` |
| `rand.*` | `workflow.SideEffect()` |
| `range map` | sort keys first |
| `log.*` | `workflow.GetLogger(ctx)` |

<example name="deterministic-map-iteration">
```go
// WRONG - non-deterministic
for k, v := range myMap { }

// CORRECT - manually sort keys
keys := make([]string, 0, len(myMap))
for k := range myMap {
    keys = append(keys, k)
}
sort.Strings(keys)
for _, k := range keys {
    v := myMap[k]
}

// BETTER - use determinism helpers (if available)
// Some codebases provide helper packages for deterministic operations
import "your-project/internal/determinism"

for _, item := range determinism.IterMap(myMap) {
    k, v := item.Key, item.Value
    // Process k, v
}
```

**Note:** The determinism helper pattern is used in production codebases like Temporal's SaaS Control Plane to make deterministic iteration easier and less error-prone.
</example>
</determinism-rules>

<patterns>
## Code Patterns

<pattern name="workflow-definition">
### Workflow Definition
```go
func ProcessOrder(ctx workflow.Context, orderID string) (string, error) {
    ao := workflow.ActivityOptions{
        StartToCloseTimeout: 10 * time.Minute,
    }
    ctx = workflow.WithActivityOptions(ctx, ao)

    var result string
    err := workflow.ExecuteActivity(ctx, ProcessPayment, orderID).Get(ctx, &result)
    if err != nil {
        return "", err
    }
    return result, nil
}
```
</pattern>

<pattern name="activity-definition">
### Activity Definition
```go
func ProcessPayment(ctx context.Context, orderID string) (string, error) {
    // Can use I/O, random, time.Now(), etc.
    return fmt.Sprintf("processed-%s", orderID), nil
}
```
</pattern>

<pattern name="worker-setup">
### Worker Setup
```go
func main() {
    c, err := client.Dial(client.Options{})
    if err != nil {
        log.Fatalln("Unable to create client", err)
    }
    defer c.Close()

    w := worker.New(c, "task-queue-name", worker.Options{})
    w.RegisterWorkflow(ProcessOrder)
    w.RegisterActivity(ProcessPayment)

    err = w.Run(worker.InterruptCh())
    if err != nil {
        log.Fatalln("Unable to start worker", err)
    }
}
```
</pattern>

<pattern name="client-invocation">
### Start Workflow from Client
```go
func main() {
    c, err := client.Dial(client.Options{})
    if err != nil {
        log.Fatalln("Unable to create client", err)
    }
    defer c.Close()

    options := client.StartWorkflowOptions{
        ID:        "order-123",
        TaskQueue: "task-queue-name",
    }

    we, err := c.ExecuteWorkflow(context.Background(), options, ProcessOrder, "order-123")
    if err != nil {
        log.Fatalln("Unable to execute workflow", err)
    }

    var result string
    err = we.Get(context.Background(), &result)
    if err != nil {
        log.Fatalln("Workflow failed", err)
    }
    log.Println("Result:", result)
}
```
</pattern>

<pattern name="activity-registration-with-prefix">
### Activity Registration with Prefix
Use prefixes to avoid naming collisions in multi-package projects:

```go
// WRONG - potential collision
w.RegisterActivity(myActivities)

// CORRECT - prefixed
w.RegisterActivityWithOptions(myActivities, activity.RegisterOptions{
    Name: "mypackage.",
})
```
</pattern>

<pattern name="workflow-versioning">
### Workflow Versioning
For backward-compatible changes to running workflows:

```go
v := workflow.GetVersion(ctx, "add-notification-2024-01-15", workflow.DefaultVersion, 1)
if v == workflow.DefaultVersion {
    // Old logic for existing workflows
} else {
    // New logic for new workflows
}
```

**Cleanup after your namespace's retention period:**

Check your namespace's retention period setting (configured in namespace settings, commonly 30, 60, or 90 days). Once this period passes, all workflow histories using the old code will be purged, making it safe to remove the versioning code.

The cleanup is done in 2 steps:

```go
// Step 1: Keep GetVersion, remove old branch (first PR)
_ = workflow.GetVersion(ctx, "add-notification-2024-01-15", workflow.DefaultVersion, 1)
newLogic()

// Step 2: Remove GetVersion entirely (separate PR after deployment)
newLogic()
```

Why 2 steps? To avoid non-determinism in new workflows if the first PR has to be rolled back.
</pattern>

<pattern name="workflow-name-strings">
### Using Workflow Name Strings
When executing child workflows or starting workflows, use the **registered workflow name string** instead of the function reference:

```go
// WRONG - function reference
workflow.ExecuteChildWorkflow(ctx, MyChildWorkflow, input)

// CORRECT - registered workflow name string
workflow.ExecuteChildWorkflow(ctx, MyChildWorkflowName, input)
```

Why this matters:
1. Matches how workflows are registered with `workflow.RegisterOptions{Name: workflowName}`
2. Avoids potential issues with function references across packages
3. Makes workflow invocation consistent and explicit

**Pattern:**
```go
// Define workflow name constant
const MyChildWorkflowName = "MyChildWorkflow"

// Register with name
w.RegisterWorkflowWithOptions(MyChildWorkflow, workflow.RegisterOptions{
    Name: MyChildWorkflowName,
})

// Execute using name string
workflow.ExecuteChildWorkflow(ctx, MyChildWorkflowName, input)
```
</pattern>

<pattern name="signals">
### Signals (Send Data to Running Workflow)
```go
// In workflow - receive signal
signalChan := workflow.GetSignalChannel(ctx, "approve-order")
var approved bool
signalChan.Receive(ctx, &approved)

// From client - send signal
err := c.SignalWorkflow(ctx, workflowID, runID, "approve-order", true)
```
</pattern>

<pattern name="queries">
### Queries (Read Workflow State)
```go
// In workflow - define query handler
var status string
err := workflow.SetQueryHandler(ctx, "get-status", func() (string, error) {
    return status, nil
})

// From client - send query
response, err := c.QueryWorkflow(ctx, workflowID, runID, "get-status")
var result string
err = response.Get(&result)
```
</pattern>

<pattern name="child-workflow">
### Child Workflow
```go
cwo := workflow.ChildWorkflowOptions{
    WorkflowID: "child-" + workflow.GetInfo(ctx).WorkflowExecution.ID,
}
ctx = workflow.WithChildOptions(ctx, cwo)

var result string
err := workflow.ExecuteChildWorkflow(ctx, ChildWorkflow, input).Get(ctx, &result)
```
</pattern>

<pattern name="continue-as-new">
### Continue-As-New (Prevent History Growth)
```go
if workflow.GetInfo(ctx).GetCurrentHistoryLength() > 10000 {
    return workflow.NewContinueAsNewError(ctx, MyWorkflow, newInput)
}
```
</pattern>

<pattern name="saga-compensation">
### Saga Pattern (Distributed Transaction with Compensation)
```go
var compensations []func(workflow.Context) error

// Step 1
err := workflow.ExecuteActivity(ctx, ChargeCard, amount).Get(ctx, nil)
if err != nil {
    return err
}
compensations = append(compensations, func(ctx workflow.Context) error {
    return workflow.ExecuteActivity(ctx, RefundCard, amount).Get(ctx, nil)
})

// Step 2
err = workflow.ExecuteActivity(ctx, ReserveInventory, itemID).Get(ctx, nil)
if err != nil {
    // Compensate in reverse order
    for i := len(compensations) - 1; i >= 0; i-- {
        compensations[i](ctx)
    }
    return err
}
```
</pattern>

<pattern name="retry-policy">
### Retry Policy Configuration
```go
ao := workflow.ActivityOptions{
    StartToCloseTimeout: 10 * time.Minute,
    RetryPolicy: &temporal.RetryPolicy{
        InitialInterval:        time.Second,
        BackoffCoefficient:     2.0,
        MaximumInterval:        time.Minute,
        MaximumAttempts:        5,
        NonRetryableErrorTypes: []string{"InvalidInputError"},
    },
}
ctx = workflow.WithActivityOptions(ctx, ao)
```
</pattern>

<pattern name="heartbeat">
### Activity Heartbeat (Long-Running Activities)
```go
func LongRunningActivity(ctx context.Context, items []string) error {
    for i, item := range items {
        // Check for cancellation
        if ctx.Err() != nil {
            return ctx.Err()
        }

        // Report progress
        activity.RecordHeartbeat(ctx, i)

        // Do work
        processItem(item)
    }
    return nil
}
```

Configure heartbeat timeout in workflow:
```go
ao := workflow.ActivityOptions{
    StartToCloseTimeout: time.Hour,
    HeartbeatTimeout:    time.Minute,
}
```
</pattern>
</patterns>

<testing>
## Testing

<pattern name="workflow-test">
### Workflow Unit Test
```go
func TestProcessOrder(t *testing.T) {
    testSuite := &testsuite.WorkflowTestSuite{}
    env := testSuite.NewTestWorkflowEnvironment()

    // Mock activity - use explicit expectations
    env.OnActivity(ProcessPayment, mock.Anything, "order-123").Return("success", nil)

    env.ExecuteWorkflow(ProcessOrder, "order-123")

    require.True(t, env.IsWorkflowCompleted())
    require.NoError(t, env.GetWorkflowError())

    var result string
    require.NoError(t, env.GetWorkflowResult(&result))
    require.Equal(t, "success", result)
}
```
</pattern>

<pattern name="activity-test">
### Activity Unit Test
```go
func TestProcessPayment(t *testing.T) {
    testSuite := &testsuite.WorkflowTestSuite{}
    env := testSuite.NewTestActivityEnvironment()
    env.RegisterActivity(ProcessPayment)

    result, err := env.ExecuteActivity(ProcessPayment, "order-123")
    require.NoError(t, err)

    var output string
    require.NoError(t, result.Get(&output))
    require.Contains(t, output, "order-123")
}
```
</pattern>

<pattern name="table-driven-test">
### Table-Driven Tests
**Use named structs and snake_case for test names:**

```go
func TestValidateOrder(t *testing.T) {
    type testCase struct {
        name     string
        input    string
        expected error
        wantErr  bool
    }

    tests := []testCase{
        {
            name:     "valid_order",  // Use snake_case
            input:    "order-123",
            expected: nil,
            wantErr:  false,
        },
        {
            name:     "empty_order",  // Not "empty order"
            input:    "",
            expected: ErrEmptyInput,
            wantErr:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateOrder(tt.input)

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

**Why snake_case?** Go's test runner converts spaces to underscores in output, so using snake_case keeps test names consistent and searchable.
</pattern>

<pattern name="test-mock-expectations">
### Mock Expectations Best Practices
**Avoid using `mock.Anything` - be explicit:**

```go
// WRONG - too permissive
env.OnActivity(ProcessPayment, mock.Anything, mock.Anything).Return("success", nil)

// CORRECT - explicit expectations
env.OnActivity(ProcessPayment, mock.Anything, "order-123").Return("success", nil)
//                              ^^^^^^^^^^^^  ^^^^^^^^^^^^^
//                              context OK    explicit input
```

**Exception:** Use `mock.Anything` only for:
1. `context.Context` parameters (timing/values vary)
2. Complex inputs that need custom matchers with `mock.MatchedBy()`

```go
// Custom matcher for complex validation
env.OnActivity(
    ProcessPayment,
    mock.Anything, // context
    mock.MatchedBy(func(req *PaymentRequest) bool {
        return req.Amount > 0 && req.Currency == "USD"
    }),
).Return("success", nil)
```

This ensures tests catch regressions and are explicit about expectations.
</pattern>

<pattern name="test-workflow-time">
### Mock Workflow Start Time
Control `workflow.Now(ctx)` in tests:

```go
func TestTimeBasedWorkflow(t *testing.T) {
    testSuite := &testsuite.WorkflowTestSuite{}
    env := testSuite.NewTestWorkflowEnvironment()

    // Set specific start time
    startTime := time.Date(2024, 1, 15, 10, 0, 0, 0, time.UTC)
    env.SetStartTime(startTime)

    // Now workflow.Now(ctx) returns this time
    env.ExecuteWorkflow(TimeBasedWorkflow)

    // Test time-dependent logic
    require.True(t, env.IsWorkflowCompleted())
}
```
</pattern>

<pattern name="workflow-replay-testing">
### Workflow Replay Testing (Catch Non-Determinism)
**Use workflow history replay to catch determinism issues in production code:**

Replay testing executes a workflow using recorded history to ensure the code produces the same decisions. This catches non-determinism bugs that would break running workflows.

**Step 1: Export workflow history from Temporal**
```bash
# Get workflow history as JSON
temporal workflow show \
  --workflow-id <workflow-id> \
  --namespace <namespace> \
  --output json > workflow-history.json
```

**Step 2: Create replay test**
```go
func TestWorkflowReplay(t *testing.T) {
    replayer := worker.NewWorkflowReplayer()

    // Register the workflow to test
    replayer.RegisterWorkflow(MyWorkflow)

    // Replay from exported history file
    err := replayer.ReplayWorkflowHistoryFromJSONFile(nil, "testdata/workflow-history.json")

    // If workflow is non-deterministic, this will error with:
    // "nondeterministic workflow definition"
    require.NoError(t, err, "Workflow replay should succeed")
}
```

**Step 3: Add to CI/CD**
```go
// Test multiple production histories
func TestProductionWorkflowReplays(t *testing.T) {
    replayer := worker.NewWorkflowReplayer()
    replayer.RegisterWorkflow(ProcessOrder)
    replayer.RegisterWorkflow(HandleRefund)

    histories := []string{
        "testdata/order-success.json",
        "testdata/order-with-retry.json",
        "testdata/refund-flow.json",
    }

    for _, history := range histories {
        t.Run(history, func(t *testing.T) {
            err := replayer.ReplayWorkflowHistoryFromJSONFile(nil, history)
            require.NoError(t, err)
        })
    }
}
```

**Use Case:** Run replay tests in CI to catch determinism bugs before deploying workflow code changes.

**Advanced: Partial replay to specific event**
```go
// Replay only up to event ID 16 (useful for debugging)
err := replayer.ReplayPartialWorkflowHistoryFromJSONFile(nil, "history.json", 16)
```
</pattern>
</testing>

<connection>
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
</connection>

<best-practices>
## Best Practices

1. **Workflows must be deterministic** - use `workflow.*` alternatives
2. **Use `workflow.GetLogger(ctx)`** - prevents duplicate logs during replay
3. **Set appropriate timeouts** - StartToCloseTimeout, HeartbeatTimeout
4. **Configure retry policies** - for transient failures
5. **Use heartbeats** - for activities > 30 seconds
6. **Design idempotent activities** - safe to retry
7. **Use Continue-As-New** - for workflows with large history
8. **Use versioning** - for backward-compatible workflow changes
9. **Register activities with prefixes** - avoid naming collisions
10. **Prefer regular functions** - over receiver methods for workflows

### Workflow Function Style

```go
// PREFERRED: Regular function (easier to test)
func ProcessOrder(ctx workflow.Context, orderID string) error {
    return nil
}

// USE ONLY when injected dependencies needed
type OrderWorkflow struct {
    notifier NotificationService
}

func (w *OrderWorkflow) Process(ctx workflow.Context, orderID string) error {
    return w.notifier.Send(ctx, "done")
}
```

### Serialization Requirements
- Inputs/outputs must be serializable (JSON by default)
- Use structs with exported fields
- Avoid: channels, functions, interfaces
</best-practices>

<project-structure>
## Project Structure

### Standard Structure
```
my-temporal-project/
├── go.mod
├── cmd/
│   ├── worker/main.go
│   └── client/main.go
├── internal/
│   ├── workflows/
│   │   ├── order.go
│   │   └── order_test.go
│   └── activities/
│       ├── payment.go
│       └── payment_test.go
└── pkg/
```

### Entity-Driven Structure
```
my-temporal-project/
├── entities/
│   ├── account/
│   │   ├── workflows.go
│   │   ├── activities.go
│   │   └── fx.go
│   └── order/
│       ├── workflows.go
│       ├── activities.go
│       └── fx.go
├── cmd/worker/main.go
└── internal/common/workflowutil/
```
</project-structure>

<samples-reference>
## Samples Quick Reference

| Use Case | Sample |
|----------|--------|
| Getting started | `helloworld/` |
| Signals | `signals/` |
| Queries | `query/` |
| Child workflows | `child-workflow/` |
| SAGA/compensation | `expense/` |
| Cron/schedules | `schedule/`, `cron/` |
| Long-running activities | `heartbeat/` |
| Encryption | `encryption/` |
| Interceptors | `interceptor/` |
| Worker versioning | `worker-versioning/` |

**Full samples**: https://github.com/temporalio/samples-go

**Detailed samples guide**: See `references/samples.md`
</samples-reference>
