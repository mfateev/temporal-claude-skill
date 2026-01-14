# Temporal.io Skill

This skill provides comprehensive guidance on working with [Temporal.io](https://temporal.io) - a platform for building reliable, distributed applications.

## What is Temporal?

Temporal is a durable execution platform that enables developers to build scalable and reliable applications. It provides:

- **Durable Execution**: Workflows that survive process failures and restarts
- **Reliability**: Built-in retries, timeouts, and error handling
- **Scalability**: Handles millions of concurrent workflows
- **Visibility**: Complete execution history and state inspection
- **Multiple SDKs**: Support for Java, Python, TypeScript, Go, .NET, and PHP

## Official Documentation

- **Main Documentation**: https://docs.temporal.io/
- **Concepts**: https://docs.temporal.io/concepts
- **Development Guides**: https://docs.temporal.io/develop
- **Community**: https://community.temporal.io/

## SDK-Specific Resources

This skill includes detailed resources for each Temporal SDK. Choose the SDK that matches your project's language:

### Java SDK
**Resource**: `sdks/java/java.md`
**Status**: ✅ Complete
**Best for**: Enterprise applications, Spring Boot integration, existing Java codebases

**What's included**:
- Complete SDK reference guide
- Maven/Gradle dependency management
- Spring Boot integration patterns
- Comprehensive samples catalog
- Testing strategies

**Official docs**: https://docs.temporal.io/develop/java

### Python SDK
**Resource**: `sdks/python/python.md`
**Status**: ✅ Complete
**Best for**: Data pipelines, ML workflows, async operations

**What's included**:
- Complete SDK reference guide
- Poetry/pip dependency management
- FastAPI/Django/Flask integration patterns
- Comprehensive samples catalog
- Testing strategies with pytest
- Async/await patterns and best practices

**Official docs**: https://docs.temporal.io/develop/python

### TypeScript SDK
**Resource**: `sdks/typescript/typescript.md` *(Coming soon)*
**Status**: 🚧 Planned
**Best for**: Node.js applications, microservices, full-stack development

**Official docs**: https://docs.temporal.io/develop/typescript

### Go SDK
**Resource**: `sdks/go/go.md`
**Status**: ✅ Complete
**Best for**: High-performance services, infrastructure tools, system programming

**What's included**:
- Complete SDK reference guide
- Go module dependency management
- Workflow determinism rules and alternatives
- Activity registration with prefixes
- Versioning patterns and cleanup process
- Comprehensive samples catalog
- Testing strategies with testsuite
- Production best practices from real-world usage

**Official docs**: https://docs.temporal.io/develop/go

### .NET SDK
**Resource**: `sdks/dotnet/dotnet.md` *(Coming soon)*
**Status**: 🚧 Planned
**Best for**: Windows services, enterprise .NET applications, Azure integration

**Official docs**: https://docs.temporal.io/develop/dotnet

### PHP SDK
**Resource**: `sdks/php/php.md` *(Coming soon)*
**Status**: 🚧 Planned
**Best for**: Web applications, Laravel integration, WordPress workflows

**Official docs**: https://docs.temporal.io/develop/php

## How to Use This Skill

When asking about Temporal development:

1. **Specify your SDK** (if known):
   ```
   "Create a Temporal workflow in Java that processes orders"
   "How do I implement signals in Python Temporal?"
   ```

2. **General questions** (skill will help you choose):
   ```
   "What's the best way to handle retries in Temporal?"
   "How do I test Temporal workflows?"
   ```

The skill will:
- Reference the appropriate SDK-specific resource
- Fetch latest SDK versions from package repositories
- Provide code examples in your language
- Guide you through best practices
- Help with framework integrations (e.g., Spring Boot for Java)

## Core Concepts

Understanding these concepts applies across all SDKs:

### Workflows
- **What**: Durable function that orchestrates activities
- **Key feature**: Deterministic execution, survives failures
- **Documentation**: https://docs.temporal.io/workflows
- **When to use**: Multi-step business logic, long-running processes

### Activities
- **What**: Single, well-defined action (API call, database operation)
- **Key feature**: Can fail and retry independently
- **Documentation**: https://docs.temporal.io/activities
- **When to use**: Non-deterministic operations, external interactions

### Workers
- **What**: Service that executes workflows and activities
- **Key feature**: Polls task queues, processes work
- **Documentation**: https://docs.temporal.io/workers
- **When to use**: Required to run any Temporal application

### Signals and Queries
- **Signals**: Send data to running workflow (async, changes state)
- **Queries**: Read workflow state (sync, read-only)
- **Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing

### Schedules and Cron
- **What**: Run workflows on a schedule
- **Documentation**: https://docs.temporal.io/workflows#schedule
- **When to use**: Periodic tasks, scheduled jobs, recurring workflows

## Common Patterns

These patterns work across all SDKs (syntax varies by language):

### Child Workflows
Break complex workflows into smaller, reusable pieces
- **Docs**: https://docs.temporal.io/encyclopedia/child-workflows

### Saga Pattern
Implement distributed transactions with compensation
- **Docs**: https://docs.temporal.io/encyclopedia/saga-pattern

### Continue-As-New
Prevent history from growing too large in long-running workflows
- **Docs**: https://docs.temporal.io/workflows#continue-as-new

### Async Activity Completion
Activities that complete outside the worker process
- **Docs**: https://docs.temporal.io/activities#asynchronous-activity-completion

## Getting Started

1. **Choose your SDK** (see SDK-specific resources above)
2. **Install Temporal Server** (for local development):
   ```bash
   # Using Docker
   docker run -p 7233:7233 -p 8233:8233 temporalio/auto-setup:latest

   # Or using Temporal CLI
   brew install temporal
   temporal server start-dev
   ```

3. **Set up your project** with SDK-specific dependencies
4. **Create your first workflow** using SDK guides
5. **Run a worker** to execute workflows
6. **Start a workflow** from a client

Each SDK resource provides detailed, language-specific instructions for these steps.

## Best Practices

Universal best practices across all SDKs:

1. **Workflow Determinism**: Workflows must be deterministic
   - No random numbers, current time, or UUIDs in workflow code
   - Use activities for non-deterministic operations
   - Docs: https://docs.temporal.io/workflows#deterministic-constraints

2. **Idempotency**: Design activities to be idempotent
   - Safe to retry without side effects
   - Critical for reliability

3. **Timeouts**: Set appropriate timeouts
   - Workflow execution timeout
   - Activity start-to-close timeout
   - Activity schedule-to-close timeout

4. **Retries**: Configure retry policies
   - Transient failures should retry
   - Permanent failures should not

5. **Versioning**: Plan for workflow code changes
   - Use SDK versioning features
   - Docs: https://docs.temporal.io/workflows#versions

6. **Testing**: Write comprehensive tests
   - Test workflows in isolation
   - Mock activities
   - Test with TestWorkflowEnvironment

## Temporal Cloud

For production deployments, consider Temporal Cloud:
- **Website**: https://temporal.io/cloud
- **Pricing**: https://temporal.io/pricing
- **Documentation**: https://docs.temporal.io/cloud

Benefits:
- Fully managed service
- Multi-region support
- Enterprise SLAs
- Advanced security features

## Getting Help

- **Community Forum**: https://community.temporal.io/
- **GitHub Discussions**: https://github.com/orgs/temporalio/discussions
- **Slack**: https://temporal.io/slack
- **Office Hours**: https://temporal.io/events

## Additional Resources

- **Temporal Learn**: https://learn.temporal.io/ (Interactive tutorials)
- **Blog**: https://temporal.io/blog
- **YouTube**: https://www.youtube.com/c/Temporalio
- **Awesome Temporal**: https://github.com/temporalio/awesome-temporal

## Working with Claude

When working with this skill, Claude can:

✅ **Help you choose the right SDK** based on your project
✅ **Generate workflow and activity code** in your language
✅ **Explain Temporal concepts** with examples
✅ **Debug issues** in your Temporal applications
✅ **Suggest best practices** for your use case
✅ **Find relevant examples** from official samples
✅ **Fetch latest SDK versions** from package repositories
✅ **Guide framework integration** (Spring Boot, etc.)

Simply describe what you're trying to build, and Claude will reference the appropriate SDK-specific resources and official documentation to help you.
