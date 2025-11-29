package io.temporal.hello;

import io.temporal.hello.workflows.HelloWorldWorkflow;
import io.temporal.client.WorkflowClient;
import io.temporal.client.WorkflowOptions;
import io.temporal.serviceclient.WorkflowServiceStubs;
import java.util.UUID;

public class HelloWorldClient {

    public static void main(String[] args) {
        // Get name from args or use default
        String name = args.length > 0 ? args[0] : "Temporal";

        // Create connection to Temporal service
        WorkflowServiceStubs service = WorkflowServiceStubs.newLocalServiceStubs();

        // Create workflow client
        WorkflowClient client = WorkflowClient.newInstance(service);

        // Configure workflow options
        WorkflowOptions options = WorkflowOptions.newBuilder()
            .setTaskQueue(HelloWorldWorker.TASK_QUEUE)
            .setWorkflowId("hello-world-" + UUID.randomUUID())
            .build();

        // Create workflow stub
        HelloWorldWorkflow workflow = client.newWorkflowStub(HelloWorldWorkflow.class, options);

        // Execute workflow synchronously
        System.out.println("Starting workflow for: " + name);
        String result = workflow.sayHello(name);
        System.out.println("Workflow completed with result: " + result);

        System.exit(0);
    }
}
