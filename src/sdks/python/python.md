# Python SDK Resource

This resource provides guidance on working with Temporal.io using the Python SDK by pointing you to official documentation and key APIs.

## Official Documentation

**Primary Resources:**
- **Main Documentation**: https://docs.temporal.io/
- **Python SDK Documentation**: https://docs.temporal.io/develop/python
- **Python SDK API Reference**: https://python.temporal.io/
- **GitHub Repository**: https://github.com/temporalio/sdk-python
- **Samples Repository**: https://github.com/temporalio/samples-python

## PyPI Package Information

```
Package Name: temporalio
```

Find the latest version at: https://pypi.org/project/temporalio/

**Installation:**
```bash
pip install temporalio
```

**Optional Dependencies:**
```bash
# For OpenTelemetry support
pip install temporalio[opentelemetry]

# For Pydantic support
pip install temporalio[pydantic]

# For OpenAI agents support
pip install temporalio[openai-agents]
```

**Requirements:**
- Python 3.10 or newer (supports 3.10, 3.11, 3.12, 3.13, 3.14)

## Package Management Options

### Poetry (Recommended for Modern Projects)
```bash
poetry add temporalio
```

### pip with requirements.txt
```txt
temporalio>=1.20.0
```

### pip with pyproject.toml
```toml
[project]
dependencies = [
    "temporalio>=1.20.0",
]
```

## Framework Integration (Optional)

**IMPORTANT: Ask the developer if they want to use a framework integration before proceeding.**

Temporal works well with popular Python frameworks for building web applications and services.

### Quick Decision Guide

**Use FastAPI Integration if:**
- Building async web APIs or microservices
- Want modern async/await patterns
- Need automatic API documentation
- Building REST APIs alongside Temporal workflows

**Use Django Integration if:**
- Building full-featured web applications with ORM
- Using Django's admin interface and ecosystem
- Need traditional request/response web patterns
- Have existing Django infrastructure

**Use Standard SDK if:**
- Building standalone Python application
- Want explicit control over configuration
- Not using a web framework
- Building CLI tools or background services

### For Framework Integration

**Detailed Reference Available:**
The file `references/framework-integration.md` contains comprehensive information including:
- FastAPI integration patterns and examples
- Django setup and configuration
- Flask basic integration
- Dependency injection approaches
- Configuration for each framework
- Testing with frameworks
- Best practices and troubleshooting

**Key Documentation:**
- **Detailed Reference**: See `references/framework-integration.md` in this skill package
- **FastAPI Example**: https://github.com/temporalio/samples-python (FastAPI samples)

**Quick Summary:**
- FastAPI: Use dependency injection for activities, integrate with async endpoints
- Django: Use Django's app structure, configure in settings.py
- Flask: Basic integration for simpler use cases

## Core Concepts & Where to Find Them

### Workflows
- **What**: Orchestration logic, must be deterministic
- **Key Decorator**: `@workflow.defn`
- **Key Methods Decorator**: `@workflow.run` (main workflow method)
- **Documentation**: https://docs.temporal.io/workflows
- **Python Guide**: https://docs.temporal.io/develop/python/core-application#develop-workflows

**Key Classes:**
- `workflow.defn` - Decorator for workflow class
- `workflow.run` - Decorator for workflow entry point method
- `workflow.signal` - Decorator for signal handlers
- `workflow.query` - Decorator for query handlers
- `workflow.update` - Decorator for update handlers

### Activities
- **What**: Non-deterministic operations (API calls, database operations)
- **Key Decorator**: `@activity.defn`
- **Documentation**: https://docs.temporal.io/activities
- **Python Guide**: https://docs.temporal.io/develop/python/core-application#develop-activities

**Implementation Styles:**
- Async activities (recommended): Use `async def` for I/O-bound operations
- Sync activities: Use regular `def` for CPU-bound or blocking operations
- Threading: Sync activities run in thread pool
- Multiprocess: Available for CPU-intensive work

### Workers
- **What**: Services that poll task queues and execute workflows/activities
- **Key Class**: `Worker`
- **Documentation**: https://docs.temporal.io/workers
- **Python Guide**: https://docs.temporal.io/develop/python/core-application#run-a-dev-worker

**Usage:**
```python
from temporalio.client import Client
from temporalio.worker import Worker

client = await Client.connect("localhost:7233")
worker = Worker(
    client,
    task_queue="my-task-queue",
    workflows=[MyWorkflow],
    activities=[my_activity],
)
await worker.run()
```

### Clients
- **What**: Initiate and interact with workflows
- **Key Class**: `Client`
- **Documentation**: https://docs.temporal.io/encyclopedia/temporal-sdks#temporal-client
- **Python Guide**: https://docs.temporal.io/develop/python/core-application#connect-to-a-cluster

**Usage:**
```python
from temporalio.client import Client

client = await Client.connect("localhost:7233")
handle = await client.start_workflow(
    MyWorkflow.run,
    "argument",
    id="my-workflow-id",
    task_queue="my-task-queue",
)
result = await handle.result()
```

## Key API Modules

Search the API reference for these modules:
- `temporalio.workflow` - Workflow development APIs
- `temporalio.activity` - Activity development APIs
- `temporalio.client` - Client APIs for starting/querying workflows
- `temporalio.worker` - Worker configuration
- `temporalio.common` - Common types (RetryPolicy, etc.)
- `temporalio.testing` - Testing utilities
- `temporalio.exceptions` - Exception types

## Configuration Options

### Activity Options
- **Class**: `ActivityOptions`
- **Documentation**: https://docs.temporal.io/develop/python/core-application#activity-timeouts
- **Key Settings**: start_to_close_timeout, schedule_to_close_timeout, retry_policy

**Usage:**
```python
from datetime import timedelta
from temporalio.workflow import start_activity

result = await workflow.execute_activity(
    my_activity,
    args=["arg"],
    start_to_close_timeout=timedelta(minutes=5),
    retry_policy=RetryPolicy(maximum_attempts=3),
)
```

### Workflow Options
- **Class**: `WorkflowOptions` (passed to `start_workflow`)
- **Documentation**: https://docs.temporal.io/develop/python/core-application#workflow-timeouts
- **Key Settings**: id, task_queue, execution_timeout, run_timeout

### Retry Policy
- **Class**: `RetryPolicy`
- **Documentation**: https://docs.temporal.io/encyclopedia/retry-policies

**Usage:**
```python
from temporalio.common import RetryPolicy

retry_policy = RetryPolicy(
    initial_interval=timedelta(seconds=1),
    maximum_interval=timedelta(seconds=100),
    maximum_attempts=5,
    backoff_coefficient=2.0,
)
```

## Advanced Patterns

### Child Workflows
- **Documentation**: https://docs.temporal.io/encyclopedia/child-workflows
- **API**: `workflow.start_child_workflow()` or `workflow.execute_child_workflow()`

**Usage:**
```python
result = await workflow.execute_child_workflow(
    ChildWorkflow.run,
    args=["arg"],
    id="child-workflow-id",
)
```

### Async Activity Completion
- **Documentation**: https://docs.temporal.io/activities#asynchronous-activity-completion
- **Key API**: `activity.async_completion()`

**Usage:**
```python
from temporalio import activity

@activity.defn
async def my_activity() -> str:
    # Get completion handle
    completion = activity.async_completion()
    # Do async work elsewhere, complete later
    # Return no value here
    raise activity.NotCompleteError()
```

### Continue-As-New
- **Documentation**: https://docs.temporal.io/workflows#continue-as-new
- **Use Case**: Prevent workflow history from growing too large in long-running workflows
- **API**: `workflow.continue_as_new()`

**Usage:**
```python
from temporalio import workflow

if workflow.info().get_current_history_length() > 1000:
    workflow.continue_as_new(args=["new_args"])
```

### Signals and Queries
- **Signals Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-signals
- **Queries Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-queries
- **Decorators**: `@workflow.signal`, `@workflow.query`

**Usage:**
```python
@workflow.defn
class MyWorkflow:
    def __init__(self) -> None:
        self._state = ""

    @workflow.signal
    def my_signal(self, value: str) -> None:
        self._state = value

    @workflow.query
    def my_query(self) -> str:
        return self._state

    @workflow.run
    async def run(self) -> str:
        await workflow.wait_condition(lambda: self._state != "")
        return self._state
```

### Updates
- **Documentation**: https://docs.temporal.io/encyclopedia/workflow-message-passing#sending-updates
- **Decorator**: `@workflow.update`
- **Use Case**: Synchronous workflow state modifications with validation

### Versioning (Patching)
- **Documentation**: https://docs.temporal.io/workflows#version
- **API**: `workflow.patched()` - For safe workflow code updates

**Usage:**
```python
from temporalio import workflow

if workflow.patched("my-patch"):
    # New code path
    result = await new_activity()
else:
    # Old code path for replay
    result = await old_activity()
```

### Schedules and Cron
- **Documentation**: https://docs.temporal.io/workflows#schedule
- **Guide**: https://docs.temporal.io/develop/python/schedules

**Usage:**
```python
from temporalio.client import ScheduleActionStartWorkflow, ScheduleSpec

await client.create_schedule(
    "my-schedule-id",
    ScheduleActionStartWorkflow(
        MyWorkflow.run,
        args=["arg"],
        id="scheduled-workflow",
        task_queue="my-task-queue",
    ),
    spec=ScheduleSpec(cron_expressions=["0 12 * * *"]),
)
```

## Testing

### Test Framework
- **Documentation**: https://docs.temporal.io/develop/python/testing
- **Key Classes**:
  - `WorkflowEnvironment` - Test environment context manager
  - `Worker` with test environment
  - Activity and workflow testing utilities

**Usage:**
```python
import pytest
from temporalio.testing import WorkflowEnvironment
from temporalio.worker import Worker

@pytest.mark.asyncio
async def test_workflow():
    async with await WorkflowEnvironment.start_time_skipping() as env:
        worker = Worker(
            env.client,
            task_queue="test-queue",
            workflows=[MyWorkflow],
            activities=[my_activity],
        )
        async with worker:
            result = await env.client.execute_workflow(
                MyWorkflow.run,
                "input",
                id="test-workflow",
                task_queue="test-queue",
            )
            assert result == "expected"
```

### Testing with pytest-asyncio
Install: `pip install pytest-asyncio`

Configure in `pyproject.toml`:
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

## Connection Configuration

### Client Configuration
- **Class**: `Client.connect()`
- **Documentation**: https://docs.temporal.io/develop/python/core-application#connect-to-a-cluster

**Local Development:**
```python
client = await Client.connect("localhost:7233")
```

**Temporal Cloud:**
```python
from temporalio.client import Client, TLSConfig

client = await Client.connect(
    "namespace.account.tmprl.cloud:7233",
    namespace="namespace.account",
    tls=TLSConfig(
        client_cert=client_cert,
        client_private_key=client_key,
    ),
)
```

### Namespaces
- **Configuration**: Pass `namespace` parameter to `Client.connect()`
- **Documentation**: https://docs.temporal.io/namespaces

## Type Hints and Type Safety

The Python SDK uses type hints extensively and is fully compatible with mypy type checking.

**Best Practices:**
- Use type hints for all workflow and activity signatures
- Enable mypy in your project for type safety
- The SDK provides generic types for type-safe workflow handles

**Example:**
```python
from typing import TypeVar

@workflow.defn
class MyWorkflow:
    @workflow.run
    async def run(self, name: str) -> str:
        result = await workflow.execute_activity(
            my_activity,
            args=[name],
            start_to_close_timeout=timedelta(minutes=5),
        )
        return result

@activity.defn
async def my_activity(name: str) -> str:
    return f"Hello, {name}!"
```

## Best Practices

**Key Points:**
1. Workflows must be deterministic: https://docs.temporal.io/develop/python/core-application#workflow-logic-requirements
2. Use `workflow.logger` for workflow logging (replay-safe)
3. Set appropriate timeouts for workflows and activities
4. Configure retry policies for transient failures
5. Use activity heartbeats for long-running operations: `activity.heartbeat()`
6. Design activities to be idempotent
7. Use Continue-As-New for long-running workflows
8. Use versioning (patching) for safe workflow updates
9. Use async/await for I/O-bound activities
10. Use type hints for better IDE support and type safety

**Async/Await Best Practices:**
- Always use `async def` for I/O-bound activities
- Use regular `def` only for CPU-bound operations
- Workflows are always async (`async def run`)
- Properly await all async operations in workflows

**Virtual Environments:**
- Always use virtual environments (venv, virtualenv, or Poetry)
- Keep dependencies isolated per project
- Use `requirements.txt` or `pyproject.toml` for dependency management

## Code Examples and Samples

**Comprehensive Sample Reference:**
- **Detailed Sample Guide**: See `references/samples.md` for categorized samples with descriptions
  - Hello samples (getting started)
  - Scenario-based samples (real-world patterns)
  - Framework integration samples
  - Advanced features (interceptors, encryption, OpenTelemetry)
  - Testing examples

**Direct Links:**
- **Samples Repository**: https://github.com/temporalio/samples-python
- **Interactive Tutorials**: https://learn.temporal.io/

**Quick Sample Lookup by Use Case:**
- Getting started: `hello/hello_activity.py`
- Signals/Queries: `hello/hello_signal.py`, `hello/hello_query.py`
- Child workflows: `hello/hello_child_workflow.py`
- Async patterns: `hello/hello_async_activity_completion.py`
- See `references/samples.md` for complete categorized list

## Common Questions

**API Questions:**
- Search the API docs: https://python.temporal.io/
- Look for specific classes or methods in the appropriate module

**Troubleshooting:**
- Community forum: https://community.temporal.io/
- GitHub issues: https://github.com/temporalio/sdk-python/issues
- Slack: https://temporal.io/slack

## Project Structure

Standard Python project structure:
```
my-temporal-project/
├── pyproject.toml          # Poetry configuration
├── requirements.txt        # pip dependencies
├── src/
│   ├── workflows/          # Workflow definitions
│   ├── activities/         # Activity definitions
│   ├── worker.py           # Worker startup
│   └── client.py           # Client/starter
└── tests/                  # pytest tests
```

**Alternative Structure (Package-based):**
```
my-temporal-project/
├── setup.py or pyproject.toml
├── my_package/
│   ├── __init__.py
│   ├── workflows.py        # All workflows
│   ├── activities.py       # All activities
│   ├── worker.py
│   └── client.py
└── tests/
```

Refer to the samples repository for concrete examples: https://github.com/temporalio/samples-python
