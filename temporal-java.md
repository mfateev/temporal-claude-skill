# Temporal.io Java SDK Application Skill

This skill helps create Temporal.io applications using the Java SDK with workflows, activities, workers, and clients.

## Project Setup

### Maven Dependencies (pom.xml)
```xml
<dependencies>
    <!-- Temporal SDK -->
    <dependency>
        <groupId>io.temporal</groupId>
        <artifactId>temporal-sdk</artifactId>
        <version>1.23.0</version>
    </dependency>

    <!-- Testing -->
    <dependency>
        <groupId>io.temporal</groupId>
        <artifactId>temporal-testing</artifactId>
        <version>1.23.0</version>
        <scope>test</scope>
    </dependency>

    <!-- Logging -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>2.0.9</version>
    </dependency>
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.4.11</version>
    </dependency>
</dependencies>
```

### Gradle Dependencies (build.gradle)
```groovy
dependencies {
    implementation 'io.temporal:temporal-sdk:1.23.0'
    testImplementation 'io.temporal:temporal-testing:1.23.0'
    implementation 'org.slf4j:slf4j-api:2.0.9'
    implementation 'ch.qos.logback:logback-classic:1.4.11'
}
```

## Workflow Interface

Workflows define the orchestration logic. They must be deterministic.

```java
package com.example.workflows;

import io.temporal.workflow.WorkflowInterface;
import io.temporal.workflow.WorkflowMethod;
import io.temporal.workflow.QueryMethod;
import io.temporal.workflow.SignalMethod;

@WorkflowInterface
public interface MyWorkflow {

    @WorkflowMethod
    String execute(String input);

    @QueryMethod
    String getStatus();

    @SignalMethod
    void updateState(String state);
}
```

## Workflow Implementation

```java
package com.example.workflows;

import io.temporal.activity.ActivityOptions;
import io.temporal.workflow.Workflow;
import io.temporal.common.RetryOptions;
import java.time.Duration;
import org.slf4j.Logger;

public class MyWorkflowImpl implements MyWorkflow {

    private static final Logger logger = Workflow.getLogger(MyWorkflowImpl.class);
    private String status = "RUNNING";

    // Configure activity options
    private final ActivityOptions activityOptions = ActivityOptions.newBuilder()
        .setStartToCloseTimeout(Duration.ofMinutes(5))
        .setRetryOptions(RetryOptions.newBuilder()
            .setMaximumAttempts(3)
            .setInitialInterval(Duration.ofSeconds(1))
            .setMaximumInterval(Duration.ofSeconds(10))
            .setBackoffCoefficient(2.0)
            .build())
        .build();

    // Create activity stub
    private final MyActivities activities = Workflow.newActivityStub(
        MyActivities.class,
        activityOptions
    );

    @Override
    public String execute(String input) {
        logger.info("Workflow started with input: {}", input);

        // Execute activities
        String result1 = activities.processData(input);
        logger.info("Activity 1 completed: {}", result1);

        // Temporal timer (use instead of Thread.sleep)
        Workflow.sleep(Duration.ofSeconds(10));

        String result2 = activities.sendNotification(result1);
        logger.info("Activity 2 completed: {}", result2);

        status = "COMPLETED";
        return result2;
    }

    @Override
    public String getStatus() {
        return status;
    }

    @Override
    public void updateState(String state) {
        this.status = state;
        logger.info("Status updated to: {}", state);
    }
}
```

## Activity Interface

Activities contain non-deterministic code like API calls, database operations, etc.

```java
package com.example.activities;

import io.temporal.activity.ActivityInterface;
import io.temporal.activity.ActivityMethod;

@ActivityInterface
public interface MyActivities {

    @ActivityMethod
    String processData(String data);

    @ActivityMethod
    String sendNotification(String message);
}
```

## Activity Implementation

```java
package com.example.activities;

import io.temporal.activity.Activity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MyActivitiesImpl implements MyActivities {

    private static final Logger logger = LoggerFactory.getLogger(MyActivitiesImpl.class);

    @Override
    public String processData(String data) {
        logger.info("Processing data: {}", data);

        // Send heartbeat at least each heartbeatTimeout interval for long-running activities
        Activity.getExecutionContext().heartbeat("processing");

        // Actual processing logic (API calls, DB operations, etc.)
        String processed = data.toUpperCase() + "_PROCESSED";

        return processed;
    }

    @Override
    public String sendNotification(String message) {
        logger.info("Sending notification: {}", message);

        // External service call
        // notificationService.send(message);

        return "NOTIFICATION_SENT";
    }
}
```

## Worker Setup

Workers poll task queues and execute workflows and activities.

```java
package com.example;

import com.example.workflows.MyWorkflowImpl;
import com.example.activities.MyActivitiesImpl;
import io.temporal.client.WorkflowClient;
import io.temporal.serviceclient.WorkflowServiceStubs;
import io.temporal.worker.Worker;
import io.temporal.worker.WorkerFactory;

public class TemporalWorker {

    public static final String TASK_QUEUE = "my-task-queue";

    public static void main(String[] args) {
        // Create connection to Temporal service
        WorkflowServiceStubs service = WorkflowServiceStubs.newLocalServiceStubs();

        // Create workflow client
        WorkflowClient client = WorkflowClient.newInstance(service);

        // Create worker factory
        WorkerFactory factory = WorkerFactory.newInstance(client);

        // Create worker that listens on task queue
        Worker worker = factory.newWorker(TASK_QUEUE);

        // Register workflow implementations
        worker.registerWorkflowImplementationTypes(MyWorkflowImpl.class);

        // Register activity implementations
        worker.registerActivitiesImplementations(new MyActivitiesImpl());

        // Start worker
        factory.start();

        System.out.println("Worker started for task queue: " + TASK_QUEUE);
    }
}
```

## Client - Starting Workflows

```java
package com.example;

import com.example.workflows.MyWorkflow;
import io.temporal.client.WorkflowClient;
import io.temporal.client.WorkflowOptions;
import io.temporal.serviceclient.WorkflowServiceStubs;
import java.util.UUID;

public class TemporalClient {

    public static void main(String[] args) {
        // Create connection to Temporal service
        WorkflowServiceStubs service = WorkflowServiceStubs.newLocalServiceStubs();

        // Create workflow client
        WorkflowClient client = WorkflowClient.newInstance(service);

        // Configure workflow options
        WorkflowOptions options = WorkflowOptions.newBuilder()
            .setTaskQueue(TemporalWorker.TASK_QUEUE)
            .setWorkflowId("my-workflow-" + UUID.randomUUID())
            .build();

        // Create workflow stub
        MyWorkflow workflow = client.newWorkflowStub(MyWorkflow.class, options);

        // Start workflow asynchronously
        String input = "test-data";
        WorkflowClient.start(workflow::execute, input);

        System.out.println("Workflow started with ID: " + options.getWorkflowId());

        // Query workflow state
        String status = workflow.getStatus();
        System.out.println("Current status: " + status);

        // Send signal to workflow
        workflow.updateState("PAUSED");

        // Wait for result (blocking)
        // String result = workflow.execute(input);
        // System.out.println("Result: " + result);
    }
}
```

## Testing Workflows

```java
package com.example.workflows;

import com.example.activities.MyActivities;
import io.temporal.testing.TestWorkflowEnvironment;
import io.temporal.testing.TestWorkflowExtension;
import io.temporal.worker.Worker;
import io.temporal.client.WorkflowOptions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class MyWorkflowTest {

    @RegisterExtension
    public static final TestWorkflowExtension testWorkflow =
        TestWorkflowExtension.newBuilder()
            .setWorkflowTypes(MyWorkflowImpl.class)
            .setDoNotStart(true)
            .build();

    @Test
    void testWorkflowExecution(TestWorkflowEnvironment testEnv, Worker worker, MyWorkflow workflow) {
        // Mock activities
        MyActivities activities = mock(MyActivities.class);
        when(activities.processData(anyString())).thenReturn("PROCESSED");
        when(activities.sendNotification(anyString())).thenReturn("SENT");

        worker.registerActivitiesImplementations(activities);
        testEnv.start();

        // Execute workflow
        String result = workflow.execute("test-input");

        // Verify
        assertEquals("SENT", result);
        verify(activities).processData("test-input");
        verify(activities).sendNotification("PROCESSED");
    }
}
```

## Advanced Patterns

### Child Workflows
```java
// In parent workflow
private final ChildWorkflowOptions childOptions = ChildWorkflowOptions.newBuilder()
    .setWorkflowId("child-workflow-id")
    .build();

ChildWorkflow child = Workflow.newChildWorkflowStub(ChildWorkflow.class, childOptions);
String result = child.execute("input");
```

### Saga Pattern (Compensation)
```java
@Override
public String execute(String input) {
    Saga saga = new Saga(new Saga.Options.Builder().setParallelCompensation(false).build());

    try {
        String result1 = activities.step1(input);
        saga.addCompensation(activities::compensateStep1, result1);

        String result2 = activities.step2(result1);
        saga.addCompensation(activities::compensateStep2, result2);

        return result2;
    } catch (Exception e) {
        saga.compensate();
        throw e;
    }
}
```

### Async Activity Completion
```java
// In activity
@Override
public void asyncActivity(String input) {
    ActivityExecutionContext context = Activity.getExecutionContext();
    byte[] taskToken = context.getTaskToken();

    // Pass token to external system
    externalService.processAsync(input, taskToken);

    // Throw to indicate async completion
    context.doNotCompleteOnReturn();
}

// External system completes using:
// client.completeActivityById(taskToken, result);
```

### Continue-As-New (Long-running workflows)
```java
@Override
public void execute(int iteration) {
    if (iteration > 100) {
        // Continue as new to prevent history from growing too large
        MyWorkflow continueWorkflow = Workflow.newContinueAsNewStub(MyWorkflow.class);
        continueWorkflow.execute(0);
    }

    // Process iteration
    activities.process(iteration);

    // Continue
    MyWorkflow continueWorkflow = Workflow.newContinueAsNewStub(MyWorkflow.class);
    continueWorkflow.execute(iteration + 1);
}
```

## Connection Configuration

### Custom Service Connection
```java
WorkflowServiceStubsOptions options = WorkflowServiceStubsOptions.newBuilder()
    .setTarget("temporal.example.com:7233")
    .build();

WorkflowServiceStubs service = WorkflowServiceStubs.newServiceStubs(options);
```

### Namespace Configuration
```java
WorkflowClient client = WorkflowClient.newInstance(
    service,
    WorkflowClientOptions.newBuilder()
        .setNamespace("my-namespace")
        .build()
);
```

## Best Practices

1. **Determinism**: Workflows must be deterministic - no random numbers, current time, or Thread.sleep
2. **Use Workflow.getLogger()**: For workflow logging that's replay-safe
3. **Activity Heartbeats**: For long-running activities to detect failures
4. **Timeouts**: Always set appropriate timeouts for activities and workflows
5. **Retry Policies**: Configure retries for transient failures
6. **Task Queue Separation**: Use different task queues for different worker pools
7. **Version Workflows**: Use Workflow.getVersion() for safe workflow code updates
8. **Continue-As-New**: For long-running workflows to prevent history bloat
9. **Testing**: Use TestWorkflowEnvironment for unit testing
10. **Idempotency**: Design activities to be idempotent for safe retries

## Common Workflow Patterns

- **Request-Response**: Simple synchronous workflow
- **Async Activity**: Long-running external operations
- **Entity Workflow**: Stateful workflow with signals and queries
- **Saga**: Distributed transactions with compensation
- **Cron**: Scheduled recurring workflows
- **Parent-Child**: Workflow orchestration hierarchy
- **Signal-with-Start**: Create or update workflow atomically
