# Temporal AI Cookbook - Python Integration Guide

This reference provides comprehensive guidance for integrating AI capabilities (LLMs, agents, and multi-agent systems) into your Temporal Python workflows using patterns from the Temporal AI Cookbook.

## Overview

The Temporal AI Cookbook provides production-ready recipes for building reliable AI systems with Temporal. It demonstrates how to integrate LLM APIs (OpenAI, LiteLLM, etc.) into durable workflows, handle AI-specific challenges like structured outputs and retry management, and build complex multi-agent systems.

**Why use Temporal for AI applications?**

- **Durability**: LLM calls are expensive and slow - Temporal ensures they execute exactly once
- **Retry Management**: Centralized retry logic with exponential backoff for transient failures
- **Observability**: Full execution history and debugging for AI agent decisions
- **Orchestration**: Coordinate multiple AI agents, tools, and external APIs reliably
- **Production Ready**: Battle-tested patterns from companies building AI at scale

## Official Documentation

- **AI Cookbook**: https://docs.temporal.io/ai-cookbook
- **GitHub Repository**: https://github.com/temporalio/ai-cookbook
- **Python SDK Documentation**: https://docs.temporal.io/develop/python
- **Python SDK API Reference**: https://python.temporal.io/

## Quick Links by Use Case

| Use Case | Recommended Example |
|----------|-------------------|
| Getting started with AI/LLM integration | Hello World - Basic LLM Calling |
| Multi-model LLM support (OpenAI, Anthropic, Gemini) | Hello World with LiteLLM |
| Structured data extraction from LLMs | Structured Outputs with OpenAI |
| HTTP rate limit handling | Retry Policy from HTTP Responses |
| AI agents with tool selection | Tool Calling Agent |
| Production AI agents with durability | Durable Agent using OpenAI Agents SDK |
| Research and multi-agent systems | Deep Research System |

## Dependencies

### Core Dependencies

```bash
# Core Temporal SDK
pip install temporalio

# For AI integrations with Pydantic support
pip install temporalio[pydantic]

# For OpenAI Agents SDK integration
pip install temporalio[openai-agents]
```

### LLM Provider Libraries

```bash
# OpenAI SDK
pip install openai

# LiteLLM for multi-model support
pip install litellm
```

### Optional Dependencies

```bash
# For data validation and structured outputs
pip install pydantic

# For web search in Deep Research example
pip install tavily-python
```

## Foundations (LLM Integration)

Basic examples demonstrating LLM integration patterns.

### Hello World - Basic LLM Calling

**Path**: https://docs.temporal.io/ai-cookbook/basic-python

**What it shows**: Simplest LLM invocation using OpenAI Python API in a Temporal activity

**Use when**:
- Learning AI-Temporal integration basics
- First AI example to start with
- Building simple LLM-powered workflows

**Key concepts**:
- Generic reusable activities for LLM calls
- Pydantic data converter for complex AI responses
- Centralized retry management (disable retries in OpenAI client)
- Activity-based separation for durability

**Key pattern**: Activity wraps LLM API call with flexible parameters
```python
@activity.defn
async def call_llm(model: str, instructions: str, inputs: dict) -> str:
    # Generic activity that can be reused across workflows
    openai_client = AsyncOpenAI(
        api_key=os.getenv("OPENAI_API_KEY"),
        max_retries=0,  # Let Temporal handle retries
    )

    response = await openai_client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": instructions},
            {"role": "user", "content": json.dumps(inputs)}
        ]
    )

    return response.choices[0].message.content
```

**Dependencies**: `openai`, `temporalio[pydantic]`

---

### Hello World with LiteLLM

**Path**: https://docs.temporal.io/ai-cookbook (LiteLLM example)

**What it shows**: Multi-model LLM support using LiteLLM library to abstract different providers

**Use when**:
- Need to support multiple LLM providers (OpenAI, Anthropic, Google Gemini, etc.)
- Want flexibility to switch between models without code changes
- Building provider-agnostic AI applications

**Key concepts**:
- Provider abstraction through unified API
- Fallback strategies across different providers
- Cost optimization by model selection
- Single codebase supporting multiple LLMs

**Key pattern**: LiteLLM provides unified interface
```python
import litellm

@activity.defn
async def call_llm_litellm(model: str, prompt: str) -> str:
    # Works with: gpt-4, claude-3-opus, gemini-pro, etc.
    response = await litellm.acompletion(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        max_retries=0,  # Let Temporal handle retries
    )

    return response.choices[0].message.content
```

**Dependencies**: `litellm`, `temporalio[pydantic]`

---

### Structured Outputs with OpenAI

**Path**: https://docs.temporal.io/ai-cookbook/structured-output-openai-responses-python

**What it shows**: Using OpenAI Structured Outputs API for type-safe LLM responses conforming to Pydantic models

**Use when**:
- LLM responses need to conform to specific data structures
- Building data extraction or transformation pipelines
- Need validation and type safety for AI outputs
- Cleaning or normalizing business data

**Key concepts**:
- OpenAI Structured Outputs API (`response_format` parameter)
- Pydantic models for schema definition
- Automatic validation of LLM responses
- Type-safe data extraction

**Key pattern**: Define Pydantic model, use in response_format
```python
from pydantic import BaseModel

class BusinessData(BaseModel):
    company_name: str
    industry: str
    revenue: float

@activity.defn
async def extract_business_data(raw_text: str) -> BusinessData:
    openai_client = AsyncOpenAI(max_retries=0)

    response = await openai_client.beta.chat.completions.parse(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "Extract business data"},
            {"role": "user", "content": raw_text}
        ],
        response_format=BusinessData,
    )

    return response.choices[0].message.parsed
```

**Scenario**: Business data cleaning and normalization

**Dependencies**: `openai`, `pydantic`, `temporalio[pydantic]`

---

### Retry Policy from HTTP Responses

**Path**: https://docs.temporal.io/ai-cookbook/http-retry-enhancement-python

**What it shows**: Extracting retry information from HTTP response headers (e.g., `Retry-After`) and applying dynamic retry policies

**Use when**:
- Need to respect rate limits from HTTP response headers
- LLM provider returns explicit retry guidance
- Optimizing retry behavior based on server feedback
- Building resilient AI applications

**Key concepts**:
- HTTP header parsing (`Retry-After`, `X-RateLimit-Reset`)
- Dynamic retry policy configuration
- Rate limit awareness
- Backoff optimization

**Key pattern**: Parse HTTP headers and configure retry
```python
from temporalio.exceptions import ApplicationError

@activity.defn
async def call_llm_with_rate_limit_handling(prompt: str) -> str:
    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content
    except RateLimitError as e:
        # Extract retry-after from headers
        retry_after = e.response.headers.get("retry-after")
        if retry_after:
            # Raise with retry hint for Temporal
            raise ApplicationError(
                f"Rate limited, retry after {retry_after}s",
                retry_after=int(retry_after)
            )
        raise
```

**Dependencies**: `openai`, `temporalio`

## Agents (Advanced AI Systems)

Advanced examples demonstrating AI agent patterns and multi-agent orchestration.

### Tool Calling Agent

**Path**: https://docs.temporal.io/ai-cookbook/tool-calling-python

**What it shows**: Non-looping agent that gives LLM agency to choose and invoke predefined tools/functions

**Use when**:
- Building AI agents that select and execute functions
- LLM needs to decide which operations to perform
- Creating autonomous decision-making systems
- Agent needs access to external tools or APIs

**Key concepts**:
- Tool/function definitions for LLM
- Function calling with OpenAI API
- Activity-based tool execution (each tool is an activity)
- Workflow orchestration of LLM → tool decision → execution → interpretation

**Architecture**:
1. LLM activity: Presents tools to LLM, gets tool selection
2. Tool activities: Execute selected tools (separate activities per tool)
3. Workflow: Orchestrates LLM invocation → tool execution → result interpretation

**Key pattern**: Workflow coordinates LLM and tool execution
```python
@workflow.defn
class ToolCallingAgentWorkflow:
    @workflow.run
    async def run(self, query: str) -> str:
        # Define tools available to agent
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "get_weather",
                    "description": "Get current weather for a location",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "location": {"type": "string"}
                        }
                    }
                }
            }
        ]

        # 1. LLM decides which tool to use
        tool_call = await workflow.execute_activity(
            llm_with_tools,
            args=[query, tools],
            start_to_close_timeout=timedelta(seconds=30),
        )

        # 2. Execute the tool activity
        if tool_call.function.name == "get_weather":
            result = await workflow.execute_activity(
                get_weather,
                args=[tool_call.function.arguments["location"]],
                start_to_close_timeout=timedelta(seconds=30),
            )

        # 3. Send result back to LLM for interpretation
        final_response = await workflow.execute_activity(
            llm_interpret_result,
            args=[query, result],
            start_to_close_timeout=timedelta(seconds=30),
        )

        return final_response
```

**Benefits**:
- Durability: Each tool execution is recorded and retryable
- Observability: Full audit trail of agent decisions
- Reliability: Temporal handles failures in tool execution

**Dependencies**: `openai`, `temporalio[pydantic]`

---

### Durable Agent using OpenAI Agents SDK

**Path**: https://docs.temporal.io/ai-cookbook (Durable Agents example)

**What it shows**: Combining OpenAI Agents SDK with Temporal for intelligent tool selection and durable execution

**Use when**:
- Building production AI agents with durability guarantees
- Need OpenAI Agents SDK's advanced agent capabilities
- Want looping agents that can iterate on tasks
- Require state management across agent interactions

**Key concepts**:
- OpenAI Agents SDK integration
- Durable execution of agent loops
- State persistence across agent runs
- Tool execution through Temporal activities

**Key pattern**: Agent runs in workflow, tools as activities
```python
from temporalio.contrib.openai import create_workflow_agent

@workflow.defn
class DurableAgentWorkflow:
    @workflow.run
    async def run(self, task: str) -> str:
        # Create agent with Temporal integration
        agent = create_workflow_agent(
            name="research-agent",
            instructions="You are a helpful research assistant",
            tools=[web_search_tool, calculator_tool],
        )

        # Agent execution is durable
        result = await agent.run(task)

        return result
```

**Benefits**:
- Agents can be long-running and interrupted
- Full execution history of agent decisions
- Tool calls are durable and retryable
- Easy debugging of agent behavior

**Dependencies**: `temporalio[openai-agents]`, `openai`

**Installation**: `pip install temporalio[openai-agents]`

---

### Deep Research System

**Path**: https://docs.temporal.io/ai-cookbook/deep-research-python

**What it shows**: Four-phase research pipeline demonstrating complex multi-agent orchestration:
1. **Planning Agent**: Breaks down research topic into subtopics
2. **Query Generation Agent**: Creates search queries for each subtopic
3. **Web Exploration Agent**: Parallel web searches with failure resilience
4. **Report Synthesis Agent**: Compiles findings into final report

**Use when**:
- Building research systems that need comprehensive information gathering
- Creating multi-agent workflows with sequential and parallel execution
- Need resilience strategies for partial failures
- Orchestrating complex AI pipelines

**Key concepts**:
- Sequential agent execution (Planning → Query Gen → Web Search → Synthesis)
- Parallel execution (multiple web searches simultaneously)
- Resilience strategy (continue with partial results if some searches fail)
- Structured outputs for each agent phase
- Timeout configuration for reasoning models

**Architecture**:
```
Research Topic
     ↓
Planning Agent → [subtopic1, subtopic2, subtopic3]
     ↓
Query Generation Agent → [queries for each subtopic]
     ↓
Parallel Web Exploration → [results from multiple searches]
     ↓  (resilient to partial failures)
Report Synthesis Agent → Final Research Report
```

**Key pattern**: Parallel execution with failure resilience
```python
@workflow.defn
class DeepResearchWorkflow:
    @workflow.run
    async def run(self, topic: str) -> str:
        # Phase 1: Planning
        subtopics = await workflow.execute_activity(
            planning_agent,
            topic,
            start_to_close_timeout=timedelta(seconds=300),  # Reasoning model
        )

        # Phase 2: Query Generation
        queries = await workflow.execute_activity(
            query_generation_agent,
            subtopics,
            start_to_close_timeout=timedelta(seconds=300),
        )

        # Phase 3: Parallel Web Exploration (resilient)
        search_tasks = []
        for query in queries:
            task = workflow.execute_activity(
                web_search,
                query,
                start_to_close_timeout=timedelta(seconds=300),
                retry_policy=RetryPolicy(maximum_attempts=2),
            )
            search_tasks.append(task)

        # Wait for all, but continue if some fail
        results = await asyncio.gather(*search_tasks, return_exceptions=True)
        successful_results = [r for r in results if not isinstance(r, Exception)]

        # Phase 4: Synthesis
        report = await workflow.execute_activity(
            synthesis_agent,
            successful_results,
            start_to_close_timeout=timedelta(seconds=300),
        )

        return report
```

**Timeout configuration**:
- Simple LLM calls: 30 seconds
- Reasoning models (o1, o3): 300 seconds
- Web searches: 300 seconds

**Resilience pattern**: Uses `return_exceptions=True` in `asyncio.gather()` to continue with partial results even if some web searches fail

**Industry standard**: This pattern is used by:
- Anthropic Research (Claude-based research)
- OpenAI Deep Research (GPT-4 based research)
- Google Gemini Deep Research (Gemini-based research)

**Dependencies**: `openai`, `temporalio[pydantic]`, `tavily-python` (or other web search API)

## Key Patterns for AI-Temporal Integration

### Generic, Reusable Activities

**Pattern**: Create wrapper activities for LLM API calls with flexible parameters

**Why**: Enable code reuse across workflows, reduce duplication

**Example**:
```python
@activity.defn
async def call_llm_generic(
    model: str,
    system_instructions: str,
    user_input: str,
    tools: Optional[list] = None,
    response_format: Optional[type] = None,
) -> Any:
    """Generic LLM activity that can be reused across workflows"""
    openai_client = AsyncOpenAI(max_retries=0)

    messages = [
        {"role": "system", "content": system_instructions},
        {"role": "user", "content": user_input}
    ]

    kwargs = {"model": model, "messages": messages}
    if tools:
        kwargs["tools"] = tools
    if response_format:
        kwargs["response_format"] = response_format

    response = await openai_client.chat.completions.create(**kwargs)
    return response
```

**Benefits**:
- Single activity handles multiple use cases
- Easy to test and maintain
- Consistent retry and error handling

---

### Serialization Configuration

**Pattern**: Use `pydantic_data_converter` when initializing Temporal client

**Why**: Properly handle complex types (OpenAI SDK response objects, Pydantic models, dataclasses)

**Example**:
```python
from temporalio.client import Client
from temporalio.converter import pydantic_data_converter

# Client initialization
client = await Client.connect(
    "localhost:7233",
    data_converter=pydantic_data_converter(),
)

# Worker initialization
worker = Worker(
    client,
    task_queue="ai-task-queue",
    workflows=[AIWorkflow],
    activities=[llm_activity],
    # Pydantic converter is inherited from client
)
```

**What it handles**:
- Pydantic models (automatic serialization/deserialization)
- OpenAI response objects
- Complex nested structures
- Type validation

---

### Centralized Retry Management

**Pattern**: Disable retries in external libraries, let Temporal handle all retry logic

**Why**:
- Prevent conflicts between Temporal and client library retries
- Durable error recovery through Temporal's retry policies
- Better observability (all retries visible in Temporal UI)
- Consistent retry behavior across all activities

**Example**:
```python
from openai import AsyncOpenAI
from temporalio import activity
from temporalio.common import RetryPolicy

# Disable retries in OpenAI client
openai_client = AsyncOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    max_retries=0,  # CRITICAL: Let Temporal handle retries
)

@activity.defn
async def call_openai(prompt: str) -> str:
    # Activity will retry based on Temporal's retry policy
    response = await openai_client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content

# Configure retry policy in workflow
@workflow.defn
class AIWorkflow:
    @workflow.run
    async def run(self, prompt: str) -> str:
        result = await workflow.execute_activity(
            call_openai,
            prompt,
            start_to_close_timeout=timedelta(seconds=30),
            retry_policy=RetryPolicy(
                initial_interval=timedelta(seconds=1),
                maximum_interval=timedelta(seconds=60),
                backoff_coefficient=2.0,
                maximum_attempts=3,
            ),
        )
        return result
```

**For LiteLLM**:
```python
import litellm
litellm.num_retries = 0  # Disable retries in LiteLLM
```

---

### Activity-Based Separation

**Pattern**: Isolate LLM invocations and function executions in separate activities

**Why**:
- Durability: Each activity execution is recorded
- Retry handling: Activities can retry independently
- Observability: Clear audit trail of what was executed
- Testing: Easy to mock individual activities

**Example**:
```python
# Separate activities for LLM and tool execution
@activity.defn
async def llm_decide_tool(query: str, tools: list) -> dict:
    """Activity: LLM decides which tool to use"""
    response = await openai_client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": query}],
        tools=tools,
    )
    return response.choices[0].message.tool_calls[0]

@activity.defn
async def execute_weather_tool(location: str) -> dict:
    """Activity: Execute weather API call"""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.weather.com/{location}")
        return response.json()

@activity.defn
async def llm_interpret_result(query: str, tool_result: dict) -> str:
    """Activity: LLM interprets tool result"""
    response = await openai_client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "user", "content": query},
            {"role": "function", "content": json.dumps(tool_result)}
        ],
    )
    return response.choices[0].message.content

# Workflow orchestrates all activities
@workflow.defn
class AgentWorkflow:
    @workflow.run
    async def run(self, query: str) -> str:
        # Each step is durable
        tool_call = await workflow.execute_activity(
            llm_decide_tool, query, tools, start_to_close_timeout=timedelta(seconds=30)
        )

        tool_result = await workflow.execute_activity(
            execute_weather_tool,
            tool_call.arguments["location"],
            start_to_close_timeout=timedelta(seconds=30)
        )

        final_answer = await workflow.execute_activity(
            llm_interpret_result,
            query, tool_result,
            start_to_close_timeout=timedelta(seconds=30)
        )

        return final_answer
```

---

### Timeout Configuration

**Pattern**: Set appropriate timeouts based on operation type

**Guidance**:
- **Simple LLM calls** (gpt-4, claude-3): 30 seconds
- **Reasoning models** (o1, o3, claude with extended thinking): 300 seconds (5 minutes)
- **Web searches**: 300 seconds
- **Simple tool execution**: 30-60 seconds

**Example**:
```python
# Simple LLM call
await workflow.execute_activity(
    call_gpt4,
    prompt,
    start_to_close_timeout=timedelta(seconds=30),
)

# Reasoning model (o1, o3)
await workflow.execute_activity(
    call_reasoning_model,
    complex_prompt,
    start_to_close_timeout=timedelta(seconds=300),  # 5 minutes
)

# Web search
await workflow.execute_activity(
    web_search,
    query,
    start_to_close_timeout=timedelta(seconds=300),
)
```

**Why different timeouts?**:
- Reasoning models take longer to think through complex problems
- Web searches may need time for rate limiting and retries
- Fast timeouts catch stuck operations quickly
- Longer timeouts prevent premature failures for expensive operations

## Configuration and Setup

### Required Dependencies

```bash
# Core Temporal SDK
pip install temporalio

# For Pydantic data converter (recommended for all AI work)
pip install temporalio[pydantic]

# For OpenAI
pip install openai

# For multi-model support
pip install litellm

# For data validation
pip install pydantic
```

### Client Configuration with Pydantic Converter

```python
from temporalio.client import Client
from temporalio.converter import pydantic_data_converter

client = await Client.connect(
    "localhost:7233",
    namespace="default",
    data_converter=pydantic_data_converter(),
)
```

### OpenAI Client Configuration

```python
from openai import AsyncOpenAI

# Configure OpenAI client with retry disabled
openai_client = AsyncOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    max_retries=0,  # CRITICAL: Let Temporal handle retries
    timeout=30.0,   # Request timeout
)
```

### Worker Configuration

```python
from temporalio.worker import Worker

worker = Worker(
    client,
    task_queue="ai-task-queue",
    workflows=[AIWorkflow, AgentWorkflow],
    activities=[
        call_llm,
        execute_tool,
        synthesize_results,
    ],
    max_concurrent_activities=10,  # Adjust based on rate limits
)

await worker.run()
```

### Environment Variables

```bash
# .env file
OPENAI_API_KEY=sk-...
TEMPORAL_ADDRESS=localhost:7233
TEMPORAL_NAMESPACE=default
TASK_QUEUE=ai-task-queue
```

## Best Practices for AI Workflows

### Retry Management
- **Always disable retries** in external libraries (OpenAI, LiteLLM, etc.)
- Let Temporal manage all retry logic through activity retry policies
- Use exponential backoff for transient failures
- Set reasonable maximum attempts (3-5 for expensive LLM calls)

### Serialization
- **Use Pydantic data converter** for all AI workflows
- Properly handles OpenAI response objects and Pydantic models
- Enables type safety and validation
- Simplifies debugging with readable serialized data

### Activity Design
- **Keep LLM calls in separate, reusable activities**
- One activity per logical operation (LLM call, tool execution, etc.)
- Make activities generic and parameterized
- Avoid mixing concerns (LLM + business logic) in single activity

### Timeout Configuration
- **Set appropriate timeouts** based on operation type
- Simple LLM calls: 30 seconds
- Reasoning models: 300 seconds (5 minutes)
- Web searches: 300 seconds
- Monitor actual durations and adjust accordingly

### Error Handling
- Use **Temporal's retry policies** for transient failures (rate limits, network issues)
- Use **ApplicationError** for permanent failures (invalid input, business logic errors)
- Return exceptions=True in asyncio.gather() for resilient parallel execution
- Log errors with context for debugging

### Resilience
- Design workflows to **continue with partial results** when possible
- Use parallel execution with failure tolerance (Deep Research pattern)
- Implement circuit breakers for external APIs
- Set appropriate retry limits to avoid runaway costs

### Cost Optimization
- Cache LLM responses when appropriate (use workflow state)
- Use cheaper models for simple tasks (gpt-4o-mini vs gpt-4)
- Implement token counting and limits
- Monitor costs through Temporal metrics

### Testing
- Use **Temporal's testing framework** to test AI workflows
- Mock LLM activities for fast unit tests
- Use recorded responses for integration tests
- Test error scenarios (rate limits, timeouts, invalid responses)

**Example test**:
```python
import pytest
from temporalio.testing import WorkflowEnvironment

@pytest.mark.asyncio
async def test_ai_workflow():
    async with await WorkflowEnvironment.start_time_skipping() as env:
        # Mock LLM activity
        async def mock_call_llm(prompt: str) -> str:
            return "Mocked LLM response"

        worker = Worker(
            env.client,
            task_queue="test-queue",
            workflows=[AIWorkflow],
            activities=[mock_call_llm],
        )

        async with worker:
            result = await env.client.execute_workflow(
                AIWorkflow.run,
                "test query",
                id="test-workflow-id",
                task_queue="test-queue",
            )

            assert "Mocked LLM response" in result
```

### Production Deployment
- **Monitor LLM latency** and set up alerts for failures
- Configure appropriate worker pools (separate queues for different model types)
- Use Temporal Cloud for production deployments
- Implement proper API key rotation
- Set up cost alerts for LLM usage

### Versioning
- Use **workflow patching** for safe updates to AI logic
- Version your prompts and track changes
- Test new prompt versions before deploying
- Use workflow versioning for major changes

**Example workflow patching**:
```python
@workflow.defn
class AIWorkflow:
    @workflow.run
    async def run(self, query: str) -> str:
        if workflow.patched("use-new-prompt-v2"):
            # New version with improved prompt
            prompt = f"Enhanced: {query}"
        else:
            # Old version
            prompt = query

        return await workflow.execute_activity(...)
```

## Testing AI Workflows

### Using Temporal's Testing Framework

Temporal provides `WorkflowEnvironment` for testing workflows without hitting external APIs:

```python
import pytest
from temporalio.testing import WorkflowEnvironment
from temporalio.worker import Worker

@pytest.mark.asyncio
async def test_agent_workflow():
    async with await WorkflowEnvironment.start_time_skipping() as env:
        # Mock LLM activity
        async def mock_llm_activity(prompt: str) -> str:
            return "Mocked LLM response for testing"

        # Setup worker with mocked activities
        worker = Worker(
            env.client,
            task_queue="test-queue",
            workflows=[AgentWorkflow],
            activities=[mock_llm_activity],
        )

        async with worker:
            # Execute workflow
            result = await env.client.execute_workflow(
                AgentWorkflow.run,
                "test query",
                id="test-workflow-id",
                task_queue="test-queue",
            )

            # Assert expected behavior
            assert "Mocked LLM response" in result
```

### Testing with Recorded Responses

For integration tests, record real LLM responses and replay them:

```python
import json

# Record responses during development
recorded_responses = {
    "what is the weather": "The weather is sunny and 72°F",
    "summarize this": "This is a summary of the document"
}

@activity.defn
async def mock_llm_with_recordings(prompt: str) -> str:
    # Look up recorded response
    return recorded_responses.get(prompt, "Default response")
```

### Reference

See main Python SDK documentation for comprehensive testing guidance: https://docs.temporal.io/develop/python/testing

## Common Issues and Solutions

### Issue: Serialization errors with OpenAI response objects

**Error**: `TypeError: Object of type ... is not JSON serializable`

**Solution**: Use Pydantic data converter
```python
from temporalio.converter import pydantic_data_converter

client = await Client.connect(
    "localhost:7233",
    data_converter=pydantic_data_converter(),
)
```

---

### Issue: Duplicate retries from both Temporal and OpenAI client

**Symptom**: LLM called multiple times for same input, unexpected costs

**Solution**: Set `max_retries=0` in OpenAI client
```python
openai_client = AsyncOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    max_retries=0,  # Let Temporal handle retries
)
```

For LiteLLM:
```python
import litellm
litellm.num_retries = 0
```

---

### Issue: Workflow timeouts with reasoning models (o1, o3)

**Error**: `TimeoutError: Activity timed out`

**Solution**: Increase activity timeout to 300+ seconds
```python
await workflow.execute_activity(
    call_reasoning_model,
    complex_query,
    start_to_close_timeout=timedelta(seconds=300),  # 5 minutes
)
```

---

### Issue: Tool calling agent not invoking functions

**Symptom**: Agent doesn't call tools, or tool calls fail

**Solution**: Verify tool definitions use correct schema format
```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get weather for a location",  # Clear description
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name"
                    }
                },
                "required": ["location"]  # Specify required params
            }
        }
    }
]
```

---

### Issue: Rate limits from LLM provider

**Error**: `RateLimitError` from OpenAI/other provider

**Solution**: Configure appropriate retry policy
```python
from temporalio.common import RetryPolicy

await workflow.execute_activity(
    call_llm,
    prompt,
    retry_policy=RetryPolicy(
        initial_interval=timedelta(seconds=2),
        maximum_interval=timedelta(seconds=60),
        backoff_coefficient=2.0,
        maximum_attempts=5,
    ),
    start_to_close_timeout=timedelta(seconds=30),
)
```

---

### Getting Help

- **Community Forum**: https://community.temporal.io/
- **GitHub Issues**: https://github.com/temporalio/ai-cookbook/issues
- **Temporal Slack**: https://temporal.io/slack

## Additional Resources

### Official Documentation
- **AI Cookbook**: https://docs.temporal.io/ai-cookbook
- **AI Cookbook GitHub**: https://github.com/temporalio/ai-cookbook
- **Python SDK Documentation**: https://docs.temporal.io/develop/python
- **Python SDK API Reference**: https://python.temporal.io/
- **Temporal Cloud**: https://docs.temporal.io/cloud

### LLM Provider Documentation
- **OpenAI Python SDK**: https://github.com/openai/openai-python
- **OpenAI API Reference**: https://platform.openai.com/docs/api-reference
- **LiteLLM Documentation**: https://docs.litellm.ai/
- **Anthropic Python SDK**: https://github.com/anthropics/anthropic-sdk-python

### Community
- **Community Forum**: https://community.temporal.io/
- **Temporal Slack**: https://temporal.io/slack
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/temporal-workflow

### Learning Resources
- **Interactive Tutorials**: https://learn.temporal.io/
- **Python Samples**: https://github.com/temporalio/samples-python

---

**Note**: For general Python SDK guidance (workflows, activities, workers, testing), see the main `python.md` resource. This document focuses specifically on AI integration patterns from the Temporal AI Cookbook.
