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

// CORRECT - deterministic
keys := make([]string, 0, len(myMap))
for k := range myMap {
    keys = append(keys, k)
}
sort.Strings(keys)
for _, k := range keys {
    v := myMap[k]
}
```
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

**Cleanup after retention period (e.g., 90 days):**
```go
// Step 1: Keep GetVersion, remove old branch
_ = workflow.GetVersion(ctx, "add-notification-2024-01-15", workflow.DefaultVersion, 1)
newLogic()

// Step 2 (separate PR): Remove GetVersion entirely
newLogic()
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

<pattern name="test-time-control">
### Control Time in Tests
```go
env.SetStartTime(time.Date(2024, 1, 15, 10, 0, 0, 0, time.UTC))
```
</pattern>

<pattern name="table-driven-test">
### Table-Driven Tests
```go
func TestValidateOrder(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {"valid order", "order-123", false},
        {"empty order", "", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateOrder(tt.input)
            if tt.wantErr {
                require.Error(t, err)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
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
