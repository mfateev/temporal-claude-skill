# Temporal Java SDK Samples Reference

This reference lists available samples from the official Temporal Java SDK samples repository to help you find relevant examples for your use case.

**Repository**: https://github.com/temporalio/samples-java

## Quick Links by Use Case

| Use Case | Recommended Sample |
|----------|-------------------|
| Getting started with Temporal | `core/src/main/java/io/temporal/samples/hello/HelloActivity.java` |
| Spring Boot integration | `springboot/` directory |
| Signals and queries | `core/src/main/java/io/temporal/samples/hello/HelloSignal.java`, `HelloQuery.java` |
| Child workflows | `core/src/main/java/io/temporal/samples/hello/HelloChild.java` |
| Cron/scheduled workflows | `core/src/main/java/io/temporal/samples/hello/HelloCron.java` |
| Error handling (SAGA pattern) | `core/src/main/java/io/temporal/samples/hello/HelloSaga.java` |
| Testing workflows | `core/src/test/java/` directory |
| Long-running activities | `core/src/main/java/io/temporal/samples/batch/` (heartbeating) |
| Worker versioning | `core/src/main/java/io/temporal/samples/workerversioning/` |

## Core Samples (`/core`)

The core samples directory contains the most comprehensive collection of examples.

### Hello Samples (Getting Started)

Basic examples demonstrating fundamental Temporal concepts:

#### **HelloActivity**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloActivity.java`
- **What it shows**: Simplest workflow with a single activity
- **Use when**: Learning Temporal basics, first example to start with
- **Key concepts**: Workflow interface, activity interface, worker setup, client invocation

#### **HelloAsync**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloAsync.java`
- **What it shows**: Asynchronous activity execution using Promises
- **Use when**: Activities can be executed concurrently but you need results
- **Key concepts**: `Async.function()`, `Promise<T>`, non-blocking execution

#### **HelloParallelActivity**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloParallelActivity.java`
- **What it shows**: Executing multiple activities in parallel
- **Use when**: Need to run independent operations concurrently
- **Key concepts**: `Promise.allOf()`, parallel execution patterns

#### **HelloChild**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloChild.java`
- **What it shows**: Parent workflow spawning child workflows
- **Use when**: Breaking down complex workflows into smaller, reusable pieces
- **Key concepts**: `Workflow.newChildWorkflowStub()`, parent-child relationships

#### **HelloSignal**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloSignal.java`
- **What it shows**: Sending and handling signals in workflows
- **Use when**: External events need to trigger workflow actions
- **Key concepts**: `@SignalMethod`, `Workflow.await()`, signal handling

#### **HelloQuery**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloQuery.java`
- **What it shows**: Querying workflow state without modifying it
- **Use when**: Need to read workflow status/data while it's running
- **Key concepts**: `@QueryMethod`, read-only state access

#### **HelloCron**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloCron.java`
- **What it shows**: Scheduled workflow execution with cron expressions
- **Use when**: Workflows need to run on a regular schedule
- **Key concepts**: Cron schedules, periodic execution

#### **HelloSaga**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloSaga.java`
- **What it shows**: SAGA pattern for distributed transactions with compensation
- **Use when**: Need to rollback/compensate failed multi-step transactions
- **Key concepts**: `Saga`, compensation logic, transaction patterns

#### **HelloLocalActivity**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloLocalActivity.java`
- **What it shows**: Using local activities for fast, short operations
- **Use when**: Activity is fast (<seconds) and doesn't need retries
- **Key concepts**: Local activities, performance optimization

#### **HelloUpdate**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloUpdate.java`
- **What it shows**: Synchronous workflow updates
- **Use when**: Need to modify workflow state and wait for result
- **Key concepts**: `@UpdateMethod`, synchronous state updates

#### **HelloSchedules**
- **Path**: `core/src/main/java/io/temporal/samples/hello/HelloSchedules.java`
- **What it shows**: Creating and interacting with schedules
- **Use when**: Managing scheduled workflow executions programmatically
- **Key concepts**: Schedule API, schedule management

### Scenario-Based Samples (Real-World Patterns)

Practical examples demonstrating common production patterns:

#### **File Processing**
- **Path**: `core/src/main/java/io/temporal/samples/fileprocessing/`
- **What it shows**: Task routing to specific workers based on file type
- **Use when**: Different tasks need different worker capabilities
- **Key concepts**: Task routing, worker specialization, file handling

#### **Booking SAGA**
- **Path**: `core/src/main/java/io/temporal/samples/bookingsaga/`
- **What it shows**: Complex multi-step booking with compensations
- **Use when**: Building reservation/booking systems with rollback
- **Key concepts**: SAGA pattern, complex compensation logic, booking flows

#### **Money Transfer**
- **Path**: `core/src/main/java/io/temporal/samples/moneytransfer/`
- **What it shows**: Dedicated activity workers for different services
- **Use when**: Activities require different infrastructure/dependencies
- **Key concepts**: Activity worker pools, service separation

#### **Money Batch**
- **Path**: `core/src/main/java/io/temporal/samples/moneybatch/`
- **What it shows**: Signal-with-start pattern for batching operations
- **Use when**: Grouping multiple requests into batches
- **Key concepts**: `signalWithStart()`, batching patterns

#### **Batch Processing**
- **Path**: `core/src/main/java/io/temporal/samples/batch/`
- **What it shows**: Heartbeating activities, iterator pattern, sliding window
- **Use when**: Processing large datasets, long-running activities
- **Key concepts**: Heartbeats, activity cancellation, sliding windows

#### **Worker Versioning**
- **Path**: `core/src/main/java/io/temporal/samples/workerversioning/`
- **What it shows**: Managing workflow code changes safely
- **Use when**: Deploying new workflow versions without breaking running workflows
- **Key concepts**: `Workflow.getVersion()`, version management, safe deployments

### API Demonstrations (Advanced Features)

Advanced SDK capabilities and integrations:

#### **Custom Interceptors**
- **Path**: `core/src/main/java/io/temporal/samples/countinterceptor/`, `retryonsignalinterceptor/`
- **What it shows**: Building custom workflow and activity interceptors
- **Use when**: Need to add cross-cutting concerns (logging, metrics, retries)
- **Key concepts**: Interceptors, AOP patterns, custom behavior injection

#### **Payload Converters**
- **Path**: `core/src/main/java/io/temporal/samples/cloudevents/`, `payloadconverter/`
- **What it shows**: Custom data serialization (CloudEvents, encryption)
- **Use when**: Need special data format or encryption
- **Key concepts**: Custom serialization, data converters, CloudEvents

#### **mTLS Configuration**
- **Path**: `core/src/main/java/io/temporal/samples/ssl/`
- **What it shows**: Secure client-server communication setup
- **Use when**: Connecting to Temporal Cloud or securing self-hosted
- **Key concepts**: Mutual TLS, security, certificate management

#### **Search Attributes**
- **Path**: `core/src/main/java/io/temporal/samples/dsl/`
- **What it shows**: Custom workflow querying and visibility
- **Use when**: Need to search/filter workflows by custom attributes
- **Key concepts**: Search attributes, workflow visibility

#### **SDK Metrics**
- **Path**: `core/src/main/java/io/temporal/samples/metrics/`
- **What it shows**: Collecting and exporting SDK metrics
- **Use when**: Monitoring workflow and activity performance
- **Key concepts**: Metrics collection, monitoring, observability

#### **OpenTelemetry/Jaeger**
- **Path**: `core/src/main/java/io/temporal/samples/tracing/`
- **What it shows**: Distributed tracing with OpenTelemetry
- **Use when**: Need detailed execution tracing across services
- **Key concepts**: Distributed tracing, OpenTelemetry, observability

#### **Encryption**
- **Path**: `core/src/main/java/io/temporal/samples/encryptedpayloads/`
- **What it shows**: End-to-end payload encryption (including AWS KMS)
- **Use when**: Sensitive data needs encryption at rest
- **Key concepts**: Encryption, data security, AWS KMS integration

#### **Nexus Samples**
- **Path**: `core/src/main/java/io/temporal/samples/nexus/`
- **What it shows**: Cross-namespace workflow communication
- **Use when**: Workflows in different namespaces need to interact
- **Key concepts**: Nexus protocol, cross-namespace calls

## Spring Boot Samples (`/springboot`)

Examples demonstrating Spring Boot integration with Temporal:

### **Hello SpringBoot**
- **Path**: `springboot/`
- **What it shows**: Basic Spring Boot integration with REST endpoint
- **Use when**: Building Spring Boot apps with Temporal
- **Key concepts**: Spring Boot starter, REST API, workflow invocation

### **Metrics with SpringBoot**
- **Path**: `springboot/springboot-metrics/`
- **What it shows**: SDK metrics configuration in Spring Boot
- **Use when**: Monitoring Temporal in Spring Boot apps
- **Key concepts**: Spring Boot Actuator, metrics integration

### **Update with SpringBoot**
- **Path**: `springboot/springboot-update/`
- **What it shows**: Synchronous workflow updates in Spring context
- **Use when**: Need updates in Spring Boot application
- **Key concepts**: Spring Boot, workflow updates, synchronous operations

### **Kafka Integration**
- **Path**: `springboot/springboot-kafka/`
- **What it shows**: Integrating Temporal workflows with Kafka streams
- **Use when**: Event streaming with Kafka and Temporal
- **Key concepts**: Kafka integration, event-driven workflows

### **Custom Actuator Endpoint**
- **Path**: `springboot/springboot-customactuator/`
- **What it shows**: Exposing worker task queue info via Actuator
- **Use when**: Need visibility into worker state
- **Key concepts**: Spring Boot Actuator, custom endpoints, monitoring

### **Apache Camel Route**
- **Path**: `springboot/springboot-camel/`
- **What it shows**: Orchestrating workflows from Apache Camel routes
- **Use when**: Integrating Temporal with Apache Camel
- **Key concepts**: Apache Camel, route orchestration, integration patterns

## Spring Boot Basic (`/springboot-basic`)

Minimal Spring Boot integration example without external dependencies. Use when you want the simplest possible Spring Boot + Temporal setup.

## Testing Samples

Test examples are located throughout the repository:

### **Unit Testing**
- **Path**: `core/src/test/java/io/temporal/samples/hello/`
- **What it shows**: Testing workflows in isolation with mocked activities
- **Use when**: Writing unit tests for workflow logic
- **Key concepts**: `TestWorkflowEnvironment`, mocking, unit tests

### **Integration Testing**
- **Path**: Various `*Test.java` files throughout samples
- **What it shows**: Full integration tests with real activities
- **Use when**: Testing complete workflow execution
- **Key concepts**: Integration testing, test environments

## How to Use These Samples

### Finding the Right Sample

1. **Start with Hello samples** if you're new to Temporal
2. **Look at scenario samples** for real-world patterns
3. **Check Spring Boot samples** if using Spring framework
4. **Explore API samples** for advanced features

### Running a Sample

```bash
# Clone the repository
git clone https://github.com/temporalio/samples-java.git
cd samples-java

# Build the project
./gradlew build

# Run a specific sample (example: HelloActivity)
./gradlew -q execute -PmainClass=io.temporal.samples.hello.HelloActivity
```

### Sample Structure

Each sample typically includes:
- **Workflow interface**: Defines workflow methods
- **Workflow implementation**: Contains workflow logic
- **Activity interface**: Defines activity methods
- **Activity implementation**: Contains activity logic
- **Worker**: Registers and runs workflows/activities
- **Starter/Client**: Initiates workflow execution
- **Test**: Unit/integration tests

## Common Patterns Across Samples

### Workflow Pattern
```java
@WorkflowInterface
public interface MyWorkflow {
    @WorkflowMethod
    String execute(String input);
}
```

### Activity Pattern
```java
@ActivityInterface
public interface MyActivities {
    @ActivityMethod
    String processData(String data);
}
```

### Worker Setup Pattern
```java
WorkflowServiceStubs service = WorkflowServiceStubs.newLocalServiceStubs();
WorkflowClient client = WorkflowClient.newInstance(service);
WorkerFactory factory = WorkerFactory.newInstance(client);
Worker worker = factory.newWorker(TASK_QUEUE);
worker.registerWorkflowImplementationTypes(MyWorkflowImpl.class);
worker.registerActivitiesImplementations(new MyActivitiesImpl());
factory.start();
```

### Client Invocation Pattern
```java
WorkflowOptions options = WorkflowOptions.newBuilder()
    .setTaskQueue(TASK_QUEUE)
    .setWorkflowId("my-workflow-id")
    .build();
MyWorkflow workflow = client.newWorkflowStub(MyWorkflow.class, options);
String result = workflow.execute("input");
```

## Additional Resources

- **Repository README**: https://github.com/temporalio/samples-java/blob/main/README.md
- **Sample-specific READMEs**: Each sample directory contains its own README with details
- **Official Documentation**: https://docs.temporal.io/dev-guide/java
- **Temporal Learn**: https://learn.temporal.io/ (interactive tutorials)

## Contributing

If you have a sample that would benefit others, consider contributing to the samples repository. See the repository's contribution guidelines for details.

## Sample Updates

Samples are actively maintained and updated with new Temporal features. Check the repository's commit history and releases for the latest updates and new samples.
