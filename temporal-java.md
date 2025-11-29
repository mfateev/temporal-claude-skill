# Temporal.io Java SDK Reference Guide

This skill provides guidance on working with Temporal.io using the Java SDK by pointing you to official documentation and key APIs.

## Official Documentation

**Primary Resources:**
- **Main Documentation**: https://docs.temporal.io/
- **Java SDK Documentation**: https://docs.temporal.io/dev-guide/java
- **Java SDK API Reference**: https://www.javadoc.io/doc/io.temporal/temporal-sdk/latest/index.html
- **GitHub Repository**: https://github.com/temporalio/sdk-java
- **Samples Repository**: https://github.com/temporalio/samples-java

## Maven Central Coordinates

```
Group ID: io.temporal
Artifact IDs:
  - temporal-sdk (main SDK)
  - temporal-testing (testing utilities)
```

Find the latest version at: https://search.maven.org/artifact/io.temporal/temporal-sdk

## Core Concepts & Where to Find Them

### Workflows
- **What**: Orchestration logic, must be deterministic
- **Key Annotations**: `@WorkflowInterface`, `@WorkflowMethod`, `@QueryMethod`, `@SignalMethod`
- **Documentation**: https://docs.temporal.io/workflows
- **Java Guide**: https://docs.temporal.io/dev-guide/java/foundations#develop-workflows

### Activities
- **What**: Non-deterministic operations (API calls, database operations)
- **Key Annotations**: `@ActivityInterface`, `@ActivityMethod`
- **Documentation**: https://docs.temporal.io/activities
- **Java Guide**: https://docs.temporal.io/dev-guide/java/foundations#develop-activities

### Workers
- **What**: Services that poll task queues and execute workflows/activities
- **Key Classes**: `Worker`, `WorkerFactory`
- **Documentation**: https://docs.temporal.io/workers
- **Java Guide**: https://docs.temporal.io/dev-guide/java/foundations#run-a-dev-worker

### Clients
- **What**: Initiate and interact with workflows
- **Key Classes**: `WorkflowClient`, `WorkflowStub`
- **Documentation**: https://docs.temporal.io/encyclopedia/temporal-sdks#temporal-client
- **Java Guide**: https://docs.temporal.io/dev-guide/java/foundations#connect-to-a-cluster

## Key API Packages

Search the JavaDoc for these packages:
- `io.temporal.workflow` - Workflow development APIs
- `io.temporal.activity` - Activity development APIs
- `io.temporal.client` - Client APIs for starting/querying workflows
- `io.temporal.worker` - Worker configuration
- `io.temporal.common` - Common types (RetryOptions, etc.)
- `io.temporal.testing` - Testing utilities

## Configuration Options

### Activity Options
- **Class**: `ActivityOptions`
- **Documentation**: https://docs.temporal.io/dev-guide/java/foundations#activity-timeouts
- **Key Settings**: StartToCloseTimeout, ScheduleToCloseTimeout, RetryOptions

### Workflow Options
- **Class**: `WorkflowOptions`
- **Documentation**: https://docs.temporal.io/dev-guide/java/foundations#workflow-timeouts
- **Key Settings**: WorkflowId, TaskQueue, WorkflowExecutionTimeout, WorkflowRunTimeout

### Retry Options
- **Class**: `RetryOptions`
- **Documentation**: https://docs.temporal.io/encyclopedia/retry-policies

## Advanced Patterns

### Child Workflows
- **Documentation**: https://docs.temporal.io/encyclopedia/child-workflows
- **Class**: `ChildWorkflowOptions`, use `Workflow.newChildWorkflowStub()`

### Saga Pattern (Compensation)
- **Documentation**: https://docs.temporal.io/dev-guide/java/features#saga-pattern
- **Class**: `Saga`

### Async Activity Completion
- **Documentation**: https://docs.temporal.io/activities#asynchronous-activity-completion
- **Key API**: `ActivityExecutionContext.doNotCompleteOnReturn()`

### Continue-As-New
- **Documentation**: https://docs.temporal.io/workflows#continue-as-new
- **Use Case**: Prevent workflow history from growing too large in long-running workflows
- **API**: `Workflow.newContinueAsNewStub()`

### Signals and Queries
- **Signals Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-signals
- **Queries Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-queries
- **Annotations**: `@SignalMethod`, `@QueryMethod`

### Versioning
- **Documentation**: https://docs.temporal.io/workflows#version
- **API**: `Workflow.getVersion()` - For safe workflow code updates

### Schedules and Cron
- **Documentation**: https://docs.temporal.io/workflows#schedule
- **Guide**: https://docs.temporal.io/dev-guide/java/features#schedule-a-workflow

## Testing

### Test Framework
- **Documentation**: https://docs.temporal.io/dev-guide/java/testing
- **Key Classes**:
  - `TestWorkflowEnvironment` - In-memory test environment
  - `TestWorkflowExtension` - JUnit 5 extension
  - `TestActivityEnvironment` - For testing activities in isolation

## Connection Configuration

### Service Stubs
- **Class**: `WorkflowServiceStubs`, `WorkflowServiceStubsOptions`
- **Documentation**: https://docs.temporal.io/dev-guide/java/foundations#connect-to-a-cluster

### Namespaces
- **Class**: `WorkflowClientOptions`
- **Documentation**: https://docs.temporal.io/namespaces

## Best Practices

Refer to the official best practices guide:
https://docs.temporal.io/dev-guide/java/best-practices

**Key Points:**
1. Workflows must be deterministic: https://docs.temporal.io/develop/java/core-application#workflow-logic-requirements
2. Use `Workflow.getLogger()` for workflow logging (replay-safe)
3. Set appropriate timeouts for workflows and activities
4. Configure retry policies for transient failures
5. Use activity heartbeats for long-running operations
6. Design activities to be idempotent
7. Use Continue-As-New for long-running workflows
8. Use versioning for safe workflow updates

## Common Questions

**Finding Examples:**
- Official samples: https://github.com/temporalio/samples-java
- Documentation tutorials: https://learn.temporal.io/

**API Questions:**
- Search the JavaDoc: https://www.javadoc.io/doc/io.temporal/temporal-sdk/latest/index.html
- Look for specific classes or methods in the appropriate package

**Troubleshooting:**
- Community forum: https://community.temporal.io/
- GitHub issues: https://github.com/temporalio/sdk-java/issues

## Project Structure

Standard Maven/Gradle Java project structure:
```
src/
├── main/java/
│   ├── workflows/     # Workflow interfaces and implementations
│   ├── activities/    # Activity interfaces and implementations
│   └── [Main classes] # Worker and Client classes
└── test/java/         # JUnit tests using TestWorkflowEnvironment
```

Refer to the samples repository for concrete examples: https://github.com/temporalio/samples-java
