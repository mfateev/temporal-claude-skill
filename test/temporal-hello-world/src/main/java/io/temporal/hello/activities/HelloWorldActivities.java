package io.temporal.hello.activities;

import io.temporal.activity.ActivityInterface;
import io.temporal.activity.ActivityMethod;

@ActivityInterface
public interface HelloWorldActivities {

    @ActivityMethod
    String formatGreeting(String name);

    @ActivityMethod
    void printGreeting(String greeting);
}
