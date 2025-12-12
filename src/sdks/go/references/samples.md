# Temporal Go SDK Samples Reference

This reference lists available samples from the official Temporal Go SDK samples repository to help you find relevant examples for your use case.

**Repository**: https://github.com/temporalio/samples-go

## Quick Links by Use Case

| Use Case | Recommended Sample |
|----------|-------------------|
| Getting started with Temporal | `helloworld/` |
| Signals and queries | `signals/`, `query/` |
| Child workflows | `child-workflow/` |
| Cron/scheduled workflows | `schedule/`, `cron/` |
| Error handling (SAGA pattern) | `expense/` |
| Testing workflows | `helloworld/helloworld_test.go` |
| Long-running activities | `heartbeat/` |
| Worker versioning | `worker-versioning/` |
| Encryption | `encryption/` |
| Context propagation | `ctxpropagation/` |

## Hello World & Getting Started

### **helloworld/**
- **What it shows**: Simplest workflow with a single activity
- **Use when**: Learning Temporal basics, first example to start with
- **Key concepts**: Workflow definition, activity definition, worker setup, client invocation

### **greetings/**
- **What it shows**: Multiple activities in sequence
- **Use when**: Understanding activity chaining
- **Key concepts**: Sequential activity execution, passing data between activities

### **choice-exclusive/** and **choice-multi/**
- **What it shows**: Conditional workflow logic
- **Use when**: Workflows need branching based on input or activity results
- **Key concepts**: Workflow branching, conditional execution

## Signals and Queries

### **signals/**
- **What it shows**: Sending and handling signals in workflows
- **Use when**: External events need to trigger workflow actions
- **Key concepts**: `workflow.GetSignalChannel()`, signal handling, workflow updates

### **query/**
- **What it shows**: Querying workflow state without modifying it
- **Use when**: Need to read workflow status/data while it's running
- **Key concepts**: `workflow.SetQueryHandler()`, read-only state access

### **update/**
- **What it shows**: Synchronous workflow updates with validation
- **Use when**: Need to modify workflow state and wait for confirmation
- **Key concepts**: Workflow updates, validators, synchronous state changes

### **accumulator/**
- **What it shows**: Accumulating signals over time with batching
- **Use when**: Collecting multiple events before processing
- **Key concepts**: Signal batching, time-based accumulation

### **await-signals/**
- **What it shows**: Waiting for multiple signals
- **Use when**: Workflow needs multiple external inputs
- **Key concepts**: Multiple signal channels, workflow.Await

## Child Workflows

### **child-workflow/**
- **What it shows**: Parent workflow spawning child workflows
- **Use when**: Breaking down complex workflows into smaller, reusable pieces
- **Key concepts**: `workflow.ExecuteChildWorkflow()`, parent-child relationships

### **child-workflow-continue-as-new/**
- **What it shows**: Child workflow using continue-as-new
- **Use when**: Long-running child workflows need history management
- **Key concepts**: Continue-as-new in child context

### **cancelation/**
- **What it shows**: Canceling child workflows and activities
- **Use when**: Parent needs to cancel child operations
- **Key concepts**: Workflow cancellation, cleanup handlers

## Scheduling and Cron

### **schedule/**
- **What it shows**: Creating and managing schedules programmatically
- **Use when**: Managing scheduled workflow executions via API
- **Key concepts**: Schedule API, schedule management, pause/resume

### **cron/**
- **What it shows**: Cron-style scheduled workflow execution
- **Use when**: Workflows need to run on a regular schedule
- **Key concepts**: Cron expressions, periodic execution

## Error Handling and Compensation

### **expense/**
- **What it shows**: SAGA pattern for distributed transactions with compensation
- **Use when**: Need to rollback/compensate failed multi-step transactions
- **Key concepts**: Saga pattern, compensation logic, transaction rollback

### **retryactivity/**
- **What it shows**: Activity retry configuration and handling
- **Use when**: Understanding retry behavior for transient failures
- **Key concepts**: RetryPolicy, retry configuration, non-retryable errors

### **recovery/**
- **What it shows**: Workflow recovery patterns
- **Use when**: Handling workflow failures and recovery scenarios
- **Key concepts**: Workflow recovery, error handling strategies

## Long-Running Operations

### **heartbeat/**
- **What it shows**: Activity heartbeating for long-running operations
- **Use when**: Activities run for extended periods and need progress tracking
- **Key concepts**: `activity.RecordHeartbeat()`, cancellation detection, progress reporting

### **batch/**
- **What it shows**: Processing large batches of work
- **Use when**: Need to process many items with controlled concurrency
- **Key concepts**: Batch processing, sliding windows, pagination

### **continue-as-new/**
- **What it shows**: Preventing workflow history growth
- **Use when**: Long-running workflows accumulate too much history
- **Key concepts**: `workflow.NewContinueAsNewError()`, history management

## Async Patterns

### **async-activity/**
- **What it shows**: Executing activities asynchronously
- **Use when**: Activities can run concurrently
- **Key concepts**: `workflow.ExecuteActivity()` with Future, parallel execution

### **async-activity-completion/**
- **What it shows**: Activities that complete outside the worker
- **Use when**: Activity completion happens asynchronously (e.g., human approval)
- **Key concepts**: Task tokens, async completion, `activity.ErrResultPending`

### **pickfirst/**
- **What it shows**: Racing multiple activities, taking first result
- **Use when**: Multiple ways to get result, want fastest
- **Key concepts**: `workflow.Selector`, racing activities

## Advanced Features

### **encryption/**
- **What it shows**: End-to-end payload encryption
- **Use when**: Sensitive data needs encryption at rest
- **Key concepts**: Custom DataConverter, encryption, data security

### **codec-server/**
- **What it shows**: Codec server for Web UI payload decryption
- **Use when**: Need to view encrypted payloads in Temporal Web UI
- **Key concepts**: Codec server, payload encoding/decoding

### **interceptor/**
- **What it shows**: Building custom workflow and activity interceptors
- **Use when**: Need to add cross-cutting concerns (logging, metrics, auth)
- **Key concepts**: WorkflowInterceptor, ActivityInterceptor, middleware

### **ctxpropagation/**
- **What it shows**: Propagating context values across workflow/activity boundaries
- **Use when**: Need to pass tracing IDs, auth tokens, or metadata
- **Key concepts**: Context propagation, custom propagators

### **opentelemetry/**
- **What it shows**: Distributed tracing with OpenTelemetry
- **Use when**: Need detailed execution tracing across services
- **Key concepts**: OpenTelemetry, distributed tracing, observability

### **metrics/**
- **What it shows**: Collecting and exporting SDK metrics
- **Use when**: Monitoring workflow and activity performance
- **Key concepts**: Prometheus metrics, observability, monitoring

### **searchattributes/**
- **What it shows**: Custom workflow search and filtering
- **Use when**: Need to search/filter workflows by custom attributes
- **Key concepts**: Search attributes, workflow visibility, custom indexing

### **temporal-fixtures/**
- **What it shows**: Test fixtures and utilities
- **Use when**: Setting up test environments
- **Key concepts**: Test setup, fixtures, test utilities

## Dynamic Workflows

### **dynamic/**
- **What it shows**: Dynamically registered workflows and activities
- **Use when**: Workflow/activity types not known at compile time
- **Key concepts**: Dynamic workflows, dynamic activities, runtime registration

### **dsl/**
- **What it shows**: DSL-driven workflow execution
- **Use when**: Workflow logic defined in external configuration
- **Key concepts**: Domain-specific languages, configurable workflows

## Specialized Patterns

### **nexus/**
- **What it shows**: Cross-namespace workflow communication
- **Use when**: Workflows in different namespaces need to interact
- **Key concepts**: Nexus protocol, cross-namespace calls, service mesh

### **pso/**
- **What it shows**: Particle Swarm Optimization using Temporal
- **Use when**: Distributed optimization algorithms
- **Key concepts**: Scientific computing, parallel optimization

### **mutex/**
- **What it shows**: Distributed mutex implementation
- **Use when**: Need distributed locking across workflows
- **Key concepts**: Distributed locking, mutex patterns

### **polling/**
- **What it shows**: Polling external services
- **Use when**: Need to poll until condition is met
- **Key concepts**: Polling patterns, exponential backoff

### **reqrespactivity/** and **reqrespquery/**
- **What it shows**: Request-response patterns
- **Use when**: Synchronous-style communication with workflows
- **Key concepts**: Request-response, synchronous workflow communication

### **safe-message-handler/**
- **What it shows**: Safe handling of workflow messages
- **Use when**: Need guaranteed message processing
- **Key concepts**: Message handling, signal safety

### **saga/**
- **What it shows**: Saga pattern implementation
- **Use when**: Distributed transactions with compensation
- **Key concepts**: Saga, compensation, distributed transactions

### **sessions/**
- **What it shows**: Activity sessions for worker affinity
- **Use when**: Activities need to run on same worker (e.g., local file access)
- **Key concepts**: Worker sessions, affinity, stateful activities

### **splitmerge-future/**
- **What it shows**: Split-merge parallel execution pattern
- **Use when**: Parallel processing with result aggregation
- **Key concepts**: Fan-out/fan-in, parallel execution, result merging

### **timer/**
- **What it shows**: Using workflow timers
- **Use when**: Need delayed execution within workflows
- **Key concepts**: `workflow.NewTimer()`, delayed execution

### **worker-specific-task-queues/**
- **What it shows**: Routing work to specific workers
- **Use when**: Activities need specific worker capabilities
- **Key concepts**: Task queue routing, worker specialization

### **worker-versioning/**
- **What it shows**: Managing workflow code changes safely
- **Use when**: Deploying new workflow versions without breaking running workflows
- **Key concepts**: Worker versioning, safe deployments, build IDs

## Testing Examples

### **Unit Tests**
Most sample directories contain `*_test.go` files demonstrating:
- Workflow unit testing with mocked activities
- Activity unit testing in isolation
- Integration testing patterns

**Key Testing Files:**
- `helloworld/helloworld_test.go` - Basic workflow test
- `child-workflow/child_workflow_test.go` - Child workflow testing
- `signals/signal_test.go` - Signal handling tests

### **Test Patterns**
```go
// Basic workflow test structure
func TestWorkflow(t *testing.T) {
    testSuite := &testsuite.WorkflowTestSuite{}
    env := testSuite.NewTestWorkflowEnvironment()

    // Register activities
    env.RegisterActivity(MyActivity)

    // Or mock activities
    env.OnActivity(MyActivity, mock.Anything, "input").Return("output", nil)

    // Execute workflow
    env.ExecuteWorkflow(MyWorkflow, "input")

    // Verify results
    require.True(t, env.IsWorkflowCompleted())
    require.NoError(t, env.GetWorkflowError())
}
```

## How to Use These Samples

### Finding the Right Sample

1. **Start with helloworld/** if you're new to Temporal
2. **Look at signals/ and query/** for external workflow interaction
3. **Check child-workflow/** for workflow composition
4. **Explore encryption/ and interceptor/** for advanced features

### Running a Sample

```bash
# Clone the repository
git clone https://github.com/temporalio/samples-go.git
cd samples-go

# Start Temporal server (if not running)
temporal server start-dev

# Run a specific sample (example: helloworld)
cd helloworld
go run worker/main.go &  # Start worker in background
go run starter/main.go   # Start workflow
```

### Sample Structure

Each sample typically includes:
- `workflow.go` - Workflow definition
- `activity.go` - Activity definitions (if applicable)
- `worker/main.go` - Worker entry point
- `starter/main.go` - Client/starter entry point
- `*_test.go` - Unit/integration tests

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
    // Non-deterministic operations allowed here
    return fmt.Sprintf("Processed: %s", input), nil
}
```

### Worker Setup Pattern
```go
func main() {
    c, err := client.Dial(client.Options{})
    if err != nil {
        log.Fatalln("Unable to create client", err)
    }
    defer c.Close()

    w := worker.New(c, "task-queue", worker.Options{})
    w.RegisterWorkflow(MyWorkflow)
    w.RegisterActivity(MyActivity)

    err = w.Run(worker.InterruptCh())
    if err != nil {
        log.Fatalln("Unable to start worker", err)
    }
}
```

### Client Invocation Pattern
```go
func main() {
    c, err := client.Dial(client.Options{})
    if err != nil {
        log.Fatalln("Unable to create client", err)
    }
    defer c.Close()

    options := client.StartWorkflowOptions{
        ID:        "my-workflow-id",
        TaskQueue: "task-queue",
    }

    we, err := c.ExecuteWorkflow(context.Background(), options, MyWorkflow, "input")
    if err != nil {
        log.Fatalln("Unable to execute workflow", err)
    }

    var result string
    err = we.Get(context.Background(), &result)
    if err != nil {
        log.Fatalln("Unable to get workflow result", err)
    }

    log.Println("Workflow result:", result)
}
```

## Additional Resources

- **Repository README**: https://github.com/temporalio/samples-go/blob/main/README.md
- **Sample-specific READMEs**: Each sample directory contains its own README
- **Official Documentation**: https://docs.temporal.io/develop/go
- **Temporal Learn**: https://learn.temporal.io/ (interactive tutorials)
- **Go SDK API Reference**: https://pkg.go.dev/go.temporal.io/sdk

## Contributing

If you have a sample that would benefit others, consider contributing to the samples repository. See the repository's contribution guidelines for details.

## Sample Updates

Samples are actively maintained and updated with new Temporal features. Check the repository's commit history and releases for the latest updates and new samples.
