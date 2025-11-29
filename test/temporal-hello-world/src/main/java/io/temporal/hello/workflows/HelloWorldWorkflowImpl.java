package io.temporal.hello.workflows;

import io.temporal.activity.ActivityOptions;
import io.temporal.hello.activities.HelloWorldActivities;
import io.temporal.workflow.Workflow;
import io.temporal.common.RetryOptions;
import java.time.Duration;
import org.slf4j.Logger;

public class HelloWorldWorkflowImpl implements HelloWorldWorkflow {

    private static final Logger logger = Workflow.getLogger(HelloWorldWorkflowImpl.class);

    // Configure activity options
    private final ActivityOptions activityOptions = ActivityOptions.newBuilder()
        .setStartToCloseTimeout(Duration.ofMinutes(2))
        .setRetryOptions(RetryOptions.newBuilder()
            .setMaximumAttempts(3)
            .setInitialInterval(Duration.ofSeconds(1))
            .setMaximumInterval(Duration.ofSeconds(10))
            .setBackoffCoefficient(2.0)
            .build())
        .build();

    // Create activity stub
    private final HelloWorldActivities activities = Workflow.newActivityStub(
        HelloWorldActivities.class,
        activityOptions
    );

    @Override
    public String sayHello(String name) {
        logger.info("Workflow started for: {}", name);

        // Call activity to format the greeting
        String greeting = activities.formatGreeting(name);
        logger.info("Greeting formatted: {}", greeting);

        // Call activity to print the greeting
        activities.printGreeting(greeting);

        logger.info("Workflow completed");
        return greeting;
    }
}
