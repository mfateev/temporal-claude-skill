package io.temporal.hello;

import io.temporal.hello.workflows.HelloWorldWorkflowImpl;
import io.temporal.hello.activities.HelloWorldActivitiesImpl;
import io.temporal.client.WorkflowClient;
import io.temporal.serviceclient.WorkflowServiceStubs;
import io.temporal.worker.Worker;
import io.temporal.worker.WorkerFactory;

public class HelloWorldWorker {

    public static final String TASK_QUEUE = "hello-world-task-queue";

    public static void main(String[] args) {
        // Create connection to Temporal service (assumes local development server)
        WorkflowServiceStubs service = WorkflowServiceStubs.newLocalServiceStubs();

        // Create workflow client
        WorkflowClient client = WorkflowClient.newInstance(service);

        // Create worker factory
        WorkerFactory factory = WorkerFactory.newInstance(client);

        // Create worker that listens on task queue
        Worker worker = factory.newWorker(TASK_QUEUE);

        // Register workflow implementations
        worker.registerWorkflowImplementationTypes(HelloWorldWorkflowImpl.class);

        // Register activity implementations
        worker.registerActivitiesImplementations(new HelloWorldActivitiesImpl());

        // Start worker
        factory.start();

        System.out.println("Worker started for task queue: " + TASK_QUEUE);
        System.out.println("Listening for workflows...");
    }
}
