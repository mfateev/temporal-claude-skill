# Temporal Python SDK Samples Reference

This reference lists available samples from the official Temporal Python SDK samples repository to help you find relevant examples for your use case.

**Repository**: https://github.com/temporalio/samples-python

**Note**: The repository uses `uv` for dependency management. Most samples can be run with `uv run [sample_path]`.

## Quick Links by Use Case

| Use Case | Recommended Sample |
|----------|-------------------|
| Getting started with Temporal | `hello/hello_activity.py` |
| FastAPI integration | Framework integration samples |
| Signals and queries | `hello/hello_signal.py`, `hello/hello_query.py` |
| Child workflows | `hello/hello_child_workflow.py` |
| Cron/scheduled workflows | `hello/hello_cron.py`, `schedules/` |
| Error handling and retries | `hello/hello_exception.py` |
| Testing workflows | Test files in `tests/` directory |
| Long-running activities | `polling/` (with heartbeating) |
| Async completion | `hello/hello_async_activity_completion.py` |
| Encryption | `encryption/` |
| OpenTelemetry integration | `open_telemetry/` |

## Hello Samples (Getting Started)

Basic examples demonstrating fundamental Temporal concepts in the `/hello` directory:

### **hello_activity.py**
- **Path**: `hello/hello_activity.py`
- **What it shows**: Simplest workflow with a single activity
- **Use when**: Learning Temporal basics, first example to start with
- **Key concepts**: `@workflow.defn`, `@activity.defn`, worker setup, client invocation
- **Pattern**: Async workflow with async activity

### **hello_activity_retry.py**
- **Path**: `hello/hello_activity_retry.py`
- **What it shows**: Activity retry configuration with RetryPolicy
- **Use when**: Need to handle transient failures with retries
- **Key concepts**: `RetryPolicy`, configurable retry attempts and intervals

### **hello_activity_choice.py**
- **Path**: `hello/hello_activity_choice.py`
- **What it shows**: Conditional activity execution based on input
- **Use when**: Workflow logic branches based on conditions
- **Key concepts**: Conditional execution, activity selection

### **hello_activity_method.py**
- **Path**: `hello/hello_activity_method.py`
- **What it shows**: Activities defined as class methods
- **Use when**: Activities need shared state or class-based organization
- **Key concepts**: Class-based activities, instance methods

### **hello_parallel_activity.py**
- **Path**: `hello/hello_parallel_activity.py`
- **What it shows**: Executing multiple activities in parallel using asyncio
- **Use when**: Need to run independent operations concurrently
- **Key concepts**: `asyncio.gather()`, parallel execution, concurrent activities

### **hello_activity_multiprocess.py**
- **Path**: `hello/hello_activity_multiprocess.py`
- **What it shows**: CPU-intensive activities using multiprocessing
- **Use when**: Activities require CPU-bound processing
- **Key concepts**: Multiprocess executor, CPU-intensive work

### **hello_async_activity_completion.py**
- **Path**: `hello/hello_async_activity_completion.py`
- **What it shows**: Asynchronous activity completion from external systems
- **Use when**: Activity completion happens outside the activity function
- **Key concepts**: `activity.async_completion()`, manual completion

### **hello_child_workflow.py**
- **Path**: `hello/hello_child_workflow.py`
- **What it shows**: Parent workflow spawning child workflows
- **Use when**: Breaking down complex workflows into smaller, reusable pieces
- **Key concepts**: `workflow.execute_child_workflow()`, parent-child relationships

### **hello_signal.py**
- **Path**: `hello/hello_signal.py`
- **What it shows**: Sending and handling signals in workflows
- **Use when**: External events need to trigger workflow actions
- **Key concepts**: `@workflow.signal`, `workflow.wait_condition()`, signal handling

### **hello_query.py**
- **Path**: `hello/hello_query.py`
- **What it shows**: Querying workflow state without modifying it
- **Use when**: Need to read workflow status/data while it's running
- **Key concepts**: `@workflow.query`, read-only state access

### **hello_update.py**
- **Path**: `hello/hello_update.py`
- **What it shows**: Synchronous workflow updates with validation
- **Use when**: Need to modify workflow state and wait for result
- **Key concepts**: `@workflow.update`, synchronous state updates, validators

### **hello_cron.py**
- **Path**: `hello/hello_cron.py`
- **What it shows**: Scheduled workflow execution with cron expressions
- **Use when**: Workflows need to run on a regular schedule
- **Key concepts**: Cron schedules, periodic execution

### **hello_continue_as_new.py**
- **Path**: `hello/hello_continue_as_new.py`
- **What it shows**: Continue-As-New pattern for long-running workflows
- **Use when**: Workflow history could grow too large
- **Key concepts**: `workflow.continue_as_new()`, history management

### **hello_exception.py**
- **Path**: `hello/hello_exception.py`
- **What it shows**: Exception handling and propagation in workflows
- **Use when**: Need to understand error handling patterns
- **Key concepts**: Exception catching, error propagation

### **hello_cancellation.py**
- **Path**: `hello/hello_cancellation.py`
- **What it shows**: Handling workflow and activity cancellation
- **Use when**: Need to gracefully handle cancellation requests
- **Key concepts**: Cancellation handling, cleanup logic

### **hello_local_activity.py**
- **Path**: `hello/hello_local_activity.py`
- **What it shows**: Using local activities for fast, short operations
- **Use when**: Activity is fast (<seconds) and doesn't need full durability
- **Key concepts**: Local activities, performance optimization

### **hello_mtls.py**
- **Path**: `hello/hello_mtls.py`
- **What it shows**: Mutual TLS connection to Temporal server
- **Use when**: Connecting to secure Temporal Cloud or mTLS-enabled clusters
- **Key concepts**: TLS configuration, secure connections

### **hello_search_attributes.py**
- **Path**: `hello/hello_search_attributes.py`
- **What it shows**: Using search attributes for workflow visibility
- **Use when**: Need to search/filter workflows in Temporal Web UI
- **Key concepts**: Search attributes, workflow metadata

## Integration Samples

Framework and service integrations:

### **LangChain Integration**
- **Path**: `langchain/`
- **What it shows**: Orchestrating LangChain workflows with Temporal
- **Use when**: Building AI/ML pipelines with LangChain
- **Key concepts**: LangChain integration, AI workflow orchestration

### **Amazon Bedrock Chatbot**
- **Path**: `bedrock_chatbot/`
- **What it shows**: Building chatbots with Amazon Bedrock
- **Use when**: Creating conversational AI applications
- **Key concepts**: AWS Bedrock integration, chatbot patterns

### **OpenAI Agents**
- **Path**: `openai_agents/`
- **What it shows**: Agent-based workflow execution with OpenAI
- **Use when**: Building AI agent workflows
- **Key concepts**: OpenAI integration, agent orchestration

### **Nexus Operations**
- **Path**: `hello_nexus/`, `nexus_multiple_args/`, `nexus_sync_operations/`
- **What it shows**: Multi-service communication with Temporal Nexus
- **Use when**: Need durable cross-namespace operations
- **Key concepts**: Nexus operations, service-to-service communication

## Scenario-Based Samples (Real-World Patterns)

Practical examples demonstrating common production patterns:

### **Batch Processing**
- **Path**: `batch/`
- **What it shows**: Sliding window child workflow orchestration for batch processing
- **Use when**: Processing large datasets in batches
- **Key concepts**: Child workflows, sliding window pattern, batch coordination

### **Polling**
- **Path**: `polling/`
- **What it shows**: Polling external resources with heartbeating
- **Use when**: Monitoring external systems or waiting for external events
- **Key concepts**: Polling pattern, activity heartbeats, long-running activities

### **Schedules**
- **Path**: `schedules/`
- **What it shows**: Creating and managing scheduled workflows
- **Use when**: Need programmatic control over scheduled executions
- **Key concepts**: Schedule API, schedule management, backfills

### **DSL Workflow**
- **Path**: `dsl/`
- **What it shows**: YAML-driven workflow execution
- **Use when**: Building configurable workflows from external definitions
- **Key concepts**: Dynamic workflows, DSL interpretation

### **Updatable Timer**
- **Path**: `updatable_timer/`
- **What it shows**: Dynamic timer modifications via updates
- **Use when**: Timers need to be adjusted during execution
- **Key concepts**: Workflow updates, dynamic timers

### **Sleep For Days**
- **Path**: `sleep_for_days/`
- **What it shows**: Extended timer demonstrations
- **Use when**: Long-running timers (days/weeks)
- **Key concepts**: Long timers, workflow durability

### **Eager Workflow Start**
- **Path**: `eager_workflow_start/`
- **What it shows**: Immediate workflow execution mode
- **Use when**: Reducing latency for quick workflows
- **Key concepts**: Eager start, latency optimization

### **Activity Worker**
- **Path**: `activity_worker/`
- **What it shows**: Cross-language Python activity integration
- **Use when**: Running Python activities from non-Python workflows
- **Key concepts**: Activity-only workers, polyglot workflows

### **Cloud Export**
- **Path**: `cloud_export/`
- **What it shows**: Parquet file processing on schedule
- **Use when**: Processing Temporal Cloud export data
- **Key concepts**: Scheduled processing, file handling

## Advanced Features

Sophisticated patterns for production use:

### **Encryption**
- **Path**: `encryption/`
- **What it shows**: End-to-end encryption for all input/output
- **Use when**: Sensitive data requires encryption at rest
- **Key concepts**: Custom data converters, payload encryption

### **Custom Converters**
- **Path**: `pydantic_converter/`, `custom_converter/`
- **What it shows**: Pydantic model support and custom serialization
- **Use when**: Need custom data serialization or Pydantic integration
- **Key concepts**: Data converters, Pydantic models, custom serialization

### **Patching (Versioning)**
- **Path**: `patching/`
- **What it shows**: Safe workflow code modifications
- **Use when**: Deploying new workflow versions without breaking running workflows
- **Key concepts**: `workflow.patched()`, version management, safe deployments

### **Worker Versioning**
- **Path**: `worker_versioning/`
- **What it shows**: Worker build ID versioning for deployments
- **Use when**: Managing multiple worker versions
- **Key concepts**: Worker versioning, deployment strategies

### **Custom Interceptors**
- **Path**: `interceptor/`
- **What it shows**: Building custom workflow and activity interceptors
- **Use when**: Need to add cross-cutting concerns (logging, auth, metrics)
- **Key concepts**: Interceptors, request/response interception

### **Context Propagation**
- **Path**: `context_propagation/`
- **What it shows**: Interceptor-based request context propagation
- **Use when**: Need to pass context across workflow/activity boundaries
- **Key concepts**: Context propagation, interceptors, request IDs

### **Worker-Specific Task Queues**
- **Path**: `worker_specific_task_queues/`
- **What it shows**: Routing activities to specific workers
- **Use when**: Activities require specific worker capabilities
- **Key concepts**: Task routing, worker specialization

### **Resource Pool**
- **Path**: `activity_resources/`
- **What it shows**: Efficient resource management across activities
- **Use when**: Managing limited resources (connections, credentials)
- **Key concepts**: Resource pooling, activity resources

## Observability & Monitoring

### **OpenTelemetry**
- **Path**: `open_telemetry/`
- **What it shows**: Distributed tracing integration
- **Use when**: Need observability and tracing
- **Key concepts**: OpenTelemetry, tracing, distributed systems observability

### **Prometheus**
- **Path**: `prometheus/`
- **What it shows**: Metrics collection and configuration
- **Use when**: Monitoring with Prometheus
- **Key concepts**: Prometheus metrics, monitoring

### **Sentry**
- **Path**: `sentry/`
- **What it shows**: Error reporting with Sentry
- **Use when**: Need error tracking and reporting
- **Key concepts**: Sentry integration, error tracking

### **Custom Metrics**
- **Path**: `custom_metric/`
- **What it shows**: Application-specific telemetry
- **Use when**: Need custom business metrics
- **Key concepts**: Custom metrics, telemetry

## Configuration & Architecture

### **Environment Configuration**
- **Path**: `env_configuration/`
- **What it shows**: TOML-based settings with environment overrides
- **Use when**: Managing configuration across environments
- **Key concepts**: Configuration management, environment variables

## Async Frameworks

### **Gevent**
- **Path**: `gevent/`
- **What it shows**: Green thread integration
- **Use when**: Using gevent for concurrency
- **Key concepts**: Gevent compatibility, green threads

### **Trio**
- **Path**: `trio/`
- **What it shows**: Alternative async runtime support
- **Use when**: Using Trio instead of asyncio
- **Key concepts**: Trio integration, alternative async runtimes

## Testing

### **Replay Testing**
- **Path**: `replay/`
- **What it shows**: Workflow event history replay testing
- **Use when**: Validating workflow changes against historical executions
- **Key concepts**: Replay testing, workflow history, determinism validation

### **Test Utilities**
All samples include tests demonstrating:
- `WorkflowEnvironment` for time-skipping tests
- Activity mocking and testing
- Integration testing patterns
- pytest-asyncio usage

**Example Test Pattern:**
```python
@pytest.mark.asyncio
async def test_workflow():
    async with await WorkflowEnvironment.start_time_skipping() as env:
        # Setup worker
        # Execute workflow
        # Assert results
```

## Common Patterns Across Samples

### Async/Await Patterns
Most samples demonstrate:
- Async workflow definitions (`async def run`)
- Async activity execution (`await workflow.execute_activity`)
- Proper async/await usage throughout
- asyncio utilities (`asyncio.gather`, `asyncio.sleep`)

### Type Hints
All samples use:
- Type hints for function signatures
- Generic types where applicable
- mypy-compatible code

### Error Handling
Common patterns:
- Try/except blocks in activities
- Retry policies for transient failures
- Graceful degradation

### Configuration
Common approaches:
- Environment variables
- TOML configuration files
- Command-line arguments

## Running Samples

### Prerequisites
- Python 3.10 or newer
- `uv` package manager (or Poetry/pip)
- Temporal server running (use `temporal server start-dev`)

### Quick Start
```bash
# Clone the repository
git clone https://github.com/temporalio/samples-python
cd samples-python

# Run a sample with uv
uv run hello/hello_activity.py

# Or install dependencies first
uv sync
python hello/hello_activity.py
```

### With Poetry
```bash
poetry install
poetry run python hello/hello_activity.py
```

### With pip
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python hello/hello_activity.py
```

## Additional Resources

- **Repository**: https://github.com/temporalio/samples-python
- **Documentation**: https://docs.temporal.io/develop/python
- **API Reference**: https://python.temporal.io/
- **Community**: https://community.temporal.io/
- **Interactive Tutorials**: https://learn.temporal.io/

## Sample Statistics

The repository contains:
- 42 sample directories
- Comprehensive test coverage
- Examples for all major SDK features
- Integration examples for popular frameworks and services
- Production-ready patterns and best practices
