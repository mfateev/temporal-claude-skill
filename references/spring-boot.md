# Temporal Spring Boot Integration Reference

This reference provides detailed information about using Temporal with Spring Boot integration.

## Overview

Temporal provides a Spring Boot Starter for Spring applications (currently in Public Preview status).

## When to Use Spring Boot Integration

Use Spring Boot integration when:
- You're building a Spring Boot application
- You want autoconfiguration of Temporal components
- You want Spring dependency injection for workflows/activities
- You need Spring Boot Actuator metrics integration
- You prefer YAML-based configuration
- You want to leverage existing Spring infrastructure

## When to Use Standard SDK

Use the standard Temporal Java SDK when:
- You're building a standalone Java application
- You want more explicit control over Temporal configuration
- You don't need Spring framework features
- Your project doesn't use Spring Boot

## Dependencies

### Spring Boot Starter Dependency

**Maven:**
```xml
<dependency>
    <groupId>io.temporal</groupId>
    <artifactId>temporal-spring-boot-starter</artifactId>
    <version>[latest-version]</version>
</dependency>
```

**Gradle:**
```gradle
implementation 'io.temporal:temporal-spring-boot-starter:[latest-version]'
```

Find the latest version at: https://central.sonatype.com/artifact/io.temporal/temporal-spring-boot-starter

### Spring Boot Parent

Include Spring Boot parent in your pom.xml:
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>[latest-spring-boot-version]</version>
</parent>
```

## Key Features

### Autoconfiguration
- Automatic setup of `WorkflowClient`
- Automatic setup of `WorkerFactory`
- Automatic worker registration and startup
- Connection management

### Spring Annotations
- `@WorkflowImpl` - Mark workflow implementation classes
- `@ActivityImpl` - Mark activity beans
- Component scanning for workflows and activities

### Configuration
- YAML-based configuration via `application.yml`
- Property-based configuration via `application.properties`
- Profile-specific configurations

### Dependency Injection
- Inject services into activities
- Use standard Spring dependency injection
- Access Spring beans from activities

### Observability
- Built-in Spring Boot Actuator integration
- Metrics and health endpoints
- Integration with Spring Cloud Sleuth for tracing

### Testing
- Spring Boot test support
- Integration with `TestWorkflowEnvironment`
- Test-specific configurations

## Configuration

### Basic Configuration (application.yml)

```yaml
spring:
  temporal:
    connection:
      target: localhost:7233  # Temporal server address (or "local" for default)
    namespace: default        # Temporal namespace
    workers:
      - task-queue: my-task-queue
        workflow-classes:
          - com.example.workflows.MyWorkflowImpl
        activity-beans:
          - myActivitiesBean
```

### Configuration Properties

**Connection Settings:**
```yaml
spring:
  temporal:
    connection:
      target: temporal.example.com:7233
      enable-https: true
```

**Namespace Configuration:**
```yaml
spring:
  temporal:
    namespace: my-namespace
```

**Worker Configuration:**
```yaml
spring:
  temporal:
    workers:
      - task-queue: queue-1
        workflow-classes:
          - com.example.WorkflowA
          - com.example.WorkflowB
        activity-beans:
          - activitiesBean1
          - activitiesBean2
```

### Temporal Cloud Configuration

For Temporal Cloud with mTLS:
```yaml
spring:
  temporal:
    connection:
      target: your-namespace.tmprl.cloud:7233
      enable-https: true
      mtls:
        cert-path: /path/to/client.pem
        key-path: /path/to/client-key.pem
```

## Annotations

### @WorkflowImpl

Mark workflow implementation classes:
```java
@WorkflowImpl(taskQueues = "my-task-queue")
public class MyWorkflowImpl implements MyWorkflow {
    // Workflow implementation
}
```

### @ActivityImpl

Mark activity beans (must also use `@Component`):
```java
@Component("myActivities")
@ActivityImpl(taskQueues = "my-task-queue")
public class MyActivitiesImpl implements MyActivities {
    // Activity implementation
}
```

### Spring Standard Annotations

Use standard Spring annotations:
- `@Component` - Mark as Spring bean
- `@Service` - Mark as service bean
- `@Autowired` - Inject dependencies
- `@Value` - Inject property values

## Application Structure

### Spring Boot Application Class

```java
@SpringBootApplication
public class TemporalApplication {
    public static void main(String[] args) {
        SpringApplication.run(TemporalApplication.class, args);
    }
}
```

### Workflow Implementation

```java
package com.example.workflows;

import io.temporal.spring.boot.WorkflowImpl;

@WorkflowImpl(taskQueues = "my-queue")
public class MyWorkflowImpl implements MyWorkflow {

    private final MyActivities activities = Workflow.newActivityStub(
        MyActivities.class,
        ActivityOptions.newBuilder()
            .setStartToCloseTimeout(Duration.ofMinutes(5))
            .build()
    );

    @Override
    public String execute(String input) {
        return activities.process(input);
    }
}
```

### Activity Implementation with Dependency Injection

```java
package com.example.activities;

import io.temporal.spring.boot.ActivityImpl;
import org.springframework.stereotype.Component;

@Component("myActivities")
@ActivityImpl(taskQueues = "my-queue")
public class MyActivitiesImpl implements MyActivities {

    private final MyService myService;

    // Spring dependency injection
    public MyActivitiesImpl(MyService myService) {
        this.myService = myService;
    }

    @Override
    public String process(String input) {
        return myService.processData(input);
    }
}
```

### Client Component

```java
package com.example.client;

import io.temporal.client.WorkflowClient;
import io.temporal.client.WorkflowOptions;
import org.springframework.stereotype.Component;

@Component
public class WorkflowStarter {

    private final WorkflowClient workflowClient;

    public WorkflowStarter(WorkflowClient workflowClient) {
        this.workflowClient = workflowClient;
    }

    public String startWorkflow(String input) {
        MyWorkflow workflow = workflowClient.newWorkflowStub(
            MyWorkflow.class,
            WorkflowOptions.newBuilder()
                .setTaskQueue("my-queue")
                .setWorkflowId("my-workflow-" + UUID.randomUUID())
                .build()
        );

        return workflow.execute(input);
    }
}
```

## Project Structure

Recommended Spring Boot project structure:
```
src/
├── main/
│   ├── java/
│   │   └── com/example/
│   │       ├── TemporalApplication.java      # Spring Boot main class
│   │       ├── workflows/
│   │       │   ├── MyWorkflow.java           # Workflow interface
│   │       │   └── MyWorkflowImpl.java       # Workflow impl with @WorkflowImpl
│   │       ├── activities/
│   │       │   ├── MyActivities.java         # Activity interface
│   │       │   └── MyActivitiesImpl.java     # Activity impl with @ActivityImpl
│   │       ├── services/
│   │       │   └── MyService.java            # Spring service beans
│   │       └── client/
│   │           └── WorkflowStarter.java      # Client component
│   └── resources/
│       ├── application.yml                    # Spring Boot configuration
│       └── logback-spring.xml                # Logging configuration
└── test/
    └── java/
        └── com/example/
            └── workflows/
                └── MyWorkflowTest.java        # Spring Boot tests
```

## Important Notes

### No Manual Component Creation

When using Spring Boot integration, you **do not need** to manually create:
- `WorkflowServiceStubs`
- `WorkflowClient`
- `WorkerFactory`
- `Worker` instances

Spring Boot autoconfigures these components based on your `application.yml` configuration.

### Worker Lifecycle

Workers are automatically started when the Spring Boot application starts and stopped when it shuts down. The application will continue running to keep workers polling for tasks.

### Configuration Over Code

Prefer YAML configuration over programmatic configuration for:
- Connection settings
- Namespace
- Task queue registration
- Worker options

## Documentation Links

**Official Documentation:**
- **Integration Guide**: https://docs.temporal.io/develop/java/spring-boot-integration
- **Configuration Reference**: https://docs.temporal.io/develop/java/spring-boot-integration#configuration
- **Main Temporal Docs**: https://docs.temporal.io/

**Code Examples:**
- **Samples Repository**: https://github.com/temporalio/samples-java
  - Look for Spring Boot examples in the repository

**Dependencies:**
- **Spring Boot Starter**: https://central.sonatype.com/artifact/io.temporal/temporal-spring-boot-starter
- **Main SDK**: https://central.sonatype.com/artifact/io.temporal/temporal-sdk

## Testing

### Spring Boot Test Configuration

```java
@SpringBootTest
@TestPropertySource(properties = {
    "spring.temporal.connection.target=local",
    "spring.temporal.namespace=test"
})
public class MyWorkflowTest {

    @Autowired
    private WorkflowClient workflowClient;

    @Test
    public void testWorkflow() {
        MyWorkflow workflow = workflowClient.newWorkflowStub(
            MyWorkflow.class,
            WorkflowOptions.newBuilder()
                .setTaskQueue("test-queue")
                .build()
        );

        String result = workflow.execute("test-input");
        assertEquals("expected-result", result);
    }
}
```

## Best Practices

1. **Use YAML Configuration**: Keep configuration in `application.yml` rather than code
2. **Leverage Dependency Injection**: Inject services into activities for better testability
3. **Profile-Specific Config**: Use Spring profiles for different environments
4. **Actuator Metrics**: Enable Spring Boot Actuator for monitoring
5. **Proper Annotations**: Always use both `@Component` and `@ActivityImpl` for activities
6. **Task Queue Organization**: Use separate task queues for different workflow types
7. **Connection Pooling**: Spring Boot handles connection management automatically

## Troubleshooting

### Workers Not Starting
- Verify `application.yml` configuration
- Check that workflow and activity classes are properly annotated
- Ensure task queues match between config and annotations

### Dependency Injection Not Working
- Verify `@Component` annotation on activity implementations
- Check Spring component scanning configuration
- Ensure Spring Boot application class has `@SpringBootApplication`

### Connection Issues
- Verify Temporal server is running and accessible
- Check connection target in configuration
- For Temporal Cloud, verify mTLS certificates

## Migration from Standard SDK

If migrating from standard Temporal Java SDK:
1. Add Spring Boot Starter dependency
2. Add `@SpringBootApplication` main class
3. Convert manual worker setup to YAML configuration
4. Add `@WorkflowImpl` and `@ActivityImpl` annotations
5. Remove manual `WorkflowClient`, `WorkerFactory` creation
6. Move to `application.yml` for configuration
