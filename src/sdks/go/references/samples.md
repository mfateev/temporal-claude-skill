# Go SDK Samples Reference

<samples-index>
## Samples Index

| Use Case | Sample Directory | Key Concepts |
|----------|------------------|--------------|
| Hello World | `helloworld/` | Basic workflow, activity, worker, client |
| Signals | `signals/` | `workflow.GetSignalChannel()`, signal handling |
| Queries | `query/` | `workflow.SetQueryHandler()`, state queries |
| Child Workflows | `child-workflow/` | `workflow.ExecuteChildWorkflow()` |
| SAGA/Compensation | `expense/` | Distributed transactions, rollback |
| Schedules | `schedule/` | Schedule API, periodic execution |
| Cron | `cron/` | Cron expressions |
| Heartbeat | `heartbeat/` | `activity.RecordHeartbeat()`, long-running |
| Continue-As-New | `continue-as-new/` | History management |
| Encryption | `encryption/` | Custom DataConverter |
| Interceptors | `interceptor/` | Cross-cutting concerns |
| Worker Versioning | `worker-versioning/` | Safe deployments, build IDs |
| Async Activity | `async-activity-completion/` | External completion |
| Context Propagation | `ctxpropagation/` | Tracing IDs, metadata |
| OpenTelemetry | `opentelemetry/` | Distributed tracing |
| Metrics | `metrics/` | Prometheus metrics |
| Sessions | `sessions/` | Worker affinity |

**Repository**: https://github.com/temporalio/samples-go
</samples-index>

<sample-details>
## Sample Details

<sample name="helloworld">
### helloworld/
**Use When**: Learning Temporal basics, first example
**Key Files**: `workflow.go`, `activity.go`, `worker/main.go`, `starter/main.go`
**Concepts**: Workflow definition, activity execution, worker setup, client invocation
</sample>

<sample name="signals">
### signals/
**Use When**: External events need to modify running workflow
**Key API**: `workflow.GetSignalChannel(ctx, "signal-name")`
**Pattern**:
```go
signalChan := workflow.GetSignalChannel(ctx, "my-signal")
var value string
signalChan.Receive(ctx, &value)
```
</sample>

<sample name="query">
### query/
**Use When**: Read workflow state without modifying it
**Key API**: `workflow.SetQueryHandler(ctx, "query-name", handler)`
**Pattern**:
```go
workflow.SetQueryHandler(ctx, "get-status", func() (string, error) {
    return currentStatus, nil
})
```
</sample>

<sample name="child-workflow">
### child-workflow/
**Use When**: Break complex workflows into smaller, reusable pieces
**Key API**: `workflow.ExecuteChildWorkflow()`
**Pattern**:
```go
var result string
err := workflow.ExecuteChildWorkflow(ctx, ChildWorkflow, input).Get(ctx, &result)
```
</sample>

<sample name="expense">
### expense/
**Use When**: Distributed transactions requiring rollback on failure
**Pattern**: SAGA with compensation
**Key Concept**: Track compensations, execute in reverse on failure
</sample>

<sample name="schedule">
### schedule/
**Use When**: Programmatic schedule management via API
**Key API**: `client.ScheduleClient()`
</sample>

<sample name="cron">
### cron/
**Use When**: Periodic workflow execution
**Key Config**: `CronSchedule` in `StartWorkflowOptions`
</sample>

<sample name="heartbeat">
### heartbeat/
**Use When**: Activities running > 30 seconds need progress tracking
**Key API**: `activity.RecordHeartbeat(ctx, progress)`
**Pattern**:
```go
for i, item := range items {
    activity.RecordHeartbeat(ctx, i)
    process(item)
}
```
</sample>

<sample name="continue-as-new">
### continue-as-new/
**Use When**: Workflow history grows too large (>10k events)
**Key API**: `workflow.NewContinueAsNewError()`
**Pattern**:
```go
if workflow.GetInfo(ctx).GetCurrentHistoryLength() > 10000 {
    return workflow.NewContinueAsNewError(ctx, MyWorkflow, newState)
}
```
</sample>

<sample name="async-activity-completion">
### async-activity-completion/
**Use When**: Activity completes outside worker (human approval, external callback)
**Key API**: `activity.GetInfo(ctx).TaskToken`
**Pattern**: Return `activity.ErrResultPending`, complete later with token
</sample>

<sample name="encryption">
### encryption/
**Use When**: Sensitive data needs end-to-end encryption
**Key Concept**: Custom `DataConverter` wrapping payloads
</sample>

<sample name="interceptor">
### interceptor/
**Use When**: Add cross-cutting concerns (logging, metrics, auth)
**Key Types**: `WorkflowInterceptor`, `ActivityInterceptor`
</sample>

<sample name="ctxpropagation">
### ctxpropagation/
**Use When**: Pass tracing IDs, auth tokens across workflow/activity boundaries
**Key Concept**: Custom context propagators
</sample>

<sample name="opentelemetry">
### opentelemetry/
**Use When**: Distributed tracing integration
**Key Concept**: OpenTelemetry spans for workflows/activities
</sample>

<sample name="metrics">
### metrics/
**Use When**: Monitor workflow/activity performance
**Key Concept**: Prometheus metrics export
</sample>

<sample name="worker-versioning">
### worker-versioning/
**Use When**: Safe deployment of workflow code changes
**Key Concept**: Build IDs, version sets
</sample>

<sample name="sessions">
### sessions/
**Use When**: Activities need same worker (local file access, in-memory state)
**Key API**: `workflow.CreateSession()`
</sample>
</sample-details>

<running-samples>
## Running Samples

```bash
# Clone
git clone https://github.com/temporalio/samples-go.git
cd samples-go

# Start Temporal (if not running)
temporal server start-dev

# Run a sample
cd helloworld
go run worker/main.go &   # Start worker
go run starter/main.go    # Start workflow
```
</running-samples>

<common-patterns>
## Common Patterns Across Samples

### Workflow Pattern
```go
func MyWorkflow(ctx workflow.Context, input string) (string, error) {
    ao := workflow.ActivityOptions{
        StartToCloseTimeout: 10 * time.Second,
    }
    ctx = workflow.WithActivityOptions(ctx, ao)

    var result string
    err := workflow.ExecuteActivity(ctx, MyActivity, input).Get(ctx, &result)
    return result, err
}
```

### Activity Pattern
```go
func MyActivity(ctx context.Context, input string) (string, error) {
    return fmt.Sprintf("processed: %s", input), nil
}
```

### Worker Pattern
```go
func main() {
    c, _ := client.Dial(client.Options{})
    defer c.Close()

    w := worker.New(c, "task-queue", worker.Options{})
    w.RegisterWorkflow(MyWorkflow)
    w.RegisterActivity(MyActivity)
    w.Run(worker.InterruptCh())
}
```

### Starter Pattern
```go
func main() {
    c, _ := client.Dial(client.Options{})
    defer c.Close()

    we, _ := c.ExecuteWorkflow(context.Background(),
        client.StartWorkflowOptions{
            ID:        "workflow-id",
            TaskQueue: "task-queue",
        },
        MyWorkflow, "input")

    var result string
    we.Get(context.Background(), &result)
    fmt.Println(result)
}
```
</common-patterns>
