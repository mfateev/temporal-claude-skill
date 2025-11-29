package io.temporal.hello.activities;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloWorldActivitiesImpl implements HelloWorldActivities {

    private static final Logger logger = LoggerFactory.getLogger(HelloWorldActivitiesImpl.class);

    @Override
    public String formatGreeting(String name) {
        logger.info("Formatting greeting for: {}", name);
        return "Hello, " + name + "!";
    }

    @Override
    public void printGreeting(String greeting) {
        logger.info("Printing greeting: {}", greeting);
        System.out.println("\n=================================");
        System.out.println(greeting);
        System.out.println("=================================\n");
    }
}
