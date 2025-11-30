# Temporal Python Framework Integration Reference

This reference provides detailed information about integrating Temporal with popular Python web frameworks.

## Overview

Temporal Python SDK can be integrated with web frameworks to build applications that combine HTTP APIs with durable workflow orchestration. This allows you to:
- Trigger workflows from web endpoints
- Query workflow status via APIs
- Build admin interfaces for workflow management
- Combine REST APIs with background workflow processing

## When to Use Framework Integration

### Use Framework Integration When:
- Building web applications that need durable workflows
- Creating REST APIs to manage workflows
- Need authentication/authorization for workflow access
- Want to leverage framework features (ORM, admin, middleware)
- Building microservices with HTTP interfaces

### Use Standard SDK When:
- Building standalone workflow applications
- Creating CLI tools or background services
- Don't need HTTP interfaces
- Want minimal dependencies

## FastAPI Integration

FastAPI is the most popular choice for async Python APIs and works naturally with Temporal's async SDK.

### When to Use FastAPI

**Use FastAPI if:**
- Building modern async REST APIs
- Want automatic OpenAPI documentation
- Need high performance async endpoints
- Prefer type-safe API development with Pydantic
- Building microservices or serverless functions

### Installation

```bash
pip install temporalio fastapi uvicorn
```

Or with Poetry:
```bash
poetry add temporalio fastapi uvicorn
```

### Basic Setup

**Project Structure:**
```
my-fastapi-temporal-app/
├── main.py              # FastAPI app with endpoints
├── workflows.py         # Workflow definitions
├── activities.py        # Activity definitions
├── worker.py            # Temporal worker
└── requirements.txt     # Dependencies
```

### Complete Example

**workflows.py:**
```python
from datetime import timedelta
from temporalio import workflow
from temporalio.common import RetryPolicy

@workflow.defn
class OrderWorkflow:
    @workflow.run
    async def run(self, order_id: str) -> str:
        # Execute activities
        result = await workflow.execute_activity(
            process_order,
            args=[order_id],
            start_to_close_timeout=timedelta(minutes=5),
            retry_policy=RetryPolicy(maximum_attempts=3),
        )
        return result
```

**activities.py:**
```python
from temporalio import activity
import httpx

@activity.defn
async def process_order(order_id: str) -> str:
    # Activity can make external API calls
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.example.com/orders/{order_id}")
        # Process order...
    return f"Processed order {order_id}"
```

**worker.py:**
```python
import asyncio
from temporalio.client import Client
from temporalio.worker import Worker
from workflows import OrderWorkflow
from activities import process_order

async def main():
    # Connect to Temporal
    client = await Client.connect("localhost:7233")

    # Create worker
    worker = Worker(
        client,
        task_queue="order-queue",
        workflows=[OrderWorkflow],
        activities=[process_order],
    )

    # Run worker
    await worker.run()

if __name__ == "__main__":
    asyncio.run(main())
```

**main.py (FastAPI Application):**
```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from temporalio.client import Client
from workflows import OrderWorkflow
import asyncio

app = FastAPI()

# Global client (initialized on startup)
temporal_client = None

@app.on_event("startup")
async def startup_event():
    global temporal_client
    temporal_client = await Client.connect("localhost:7233")

@app.on_event("shutdown")
async def shutdown_event():
    if temporal_client:
        await temporal_client.close()

class OrderRequest(BaseModel):
    order_id: str

class OrderResponse(BaseModel):
    workflow_id: str
    run_id: str
    status: str

@app.post("/orders", response_model=OrderResponse)
async def create_order(request: OrderRequest):
    """Start a new order workflow"""
    try:
        handle = await temporal_client.start_workflow(
            OrderWorkflow.run,
            request.order_id,
            id=f"order-{request.order_id}",
            task_queue="order-queue",
        )

        return OrderResponse(
            workflow_id=handle.id,
            run_id=handle.result_run_id,
            status="started"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/orders/{workflow_id}")
async def get_order_status(workflow_id: str):
    """Query order workflow status"""
    try:
        handle = temporal_client.get_workflow_handle(workflow_id)

        # Check if workflow is running
        description = await handle.describe()

        return {
            "workflow_id": workflow_id,
            "status": str(description.status),
            "run_id": description.run_id,
        }
    except Exception as e:
        raise HTTPException(status_code=404, detail="Workflow not found")

@app.post("/orders/{workflow_id}/cancel")
async def cancel_order(workflow_id: str):
    """Cancel an order workflow"""
    try:
        handle = temporal_client.get_workflow_handle(workflow_id)
        await handle.cancel()
        return {"status": "cancelled"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### Running FastAPI + Temporal

**Start Temporal server:**
```bash
temporal server start-dev
```

**Run the worker (in one terminal):**
```bash
python worker.py
```

**Run the FastAPI app (in another terminal):**
```bash
uvicorn main:app --reload
```

**Access the API:**
- Swagger UI: http://localhost:8000/docs
- Create order: `POST http://localhost:8000/orders`
- Check status: `GET http://localhost:8000/orders/{workflow_id}`

### Dependency Injection in FastAPI

FastAPI's dependency injection can be used to share the Temporal client:

```python
from fastapi import FastAPI, Depends
from temporalio.client import Client

async def get_temporal_client() -> Client:
    """Dependency that provides Temporal client"""
    # In production, use a singleton or connection pool
    client = await Client.connect("localhost:7233")
    try:
        yield client
    finally:
        await client.close()

@app.post("/orders")
async def create_order(
    request: OrderRequest,
    client: Client = Depends(get_temporal_client)
):
    handle = await client.start_workflow(...)
    return {"workflow_id": handle.id}
```

### Best Practices for FastAPI

1. **Connection Management**: Create client on startup, reuse across requests
2. **Error Handling**: Use FastAPI exception handlers for Temporal errors
3. **Async All The Way**: Use async/await for all Temporal operations
4. **Pydantic Models**: Use for request/response validation
5. **API Documentation**: FastAPI auto-generates OpenAPI docs
6. **Middleware**: Add logging, tracing, authentication middleware
7. **Background Tasks**: Don't wait for workflow completion in endpoints (use async start)

### Testing FastAPI + Temporal

```python
import pytest
from fastapi.testclient import TestClient
from temporalio.testing import WorkflowEnvironment
from temporalio.worker import Worker
from main import app, temporal_client
from workflows import OrderWorkflow
from activities import process_order

@pytest.mark.asyncio
async def test_create_order():
    async with await WorkflowEnvironment.start_time_skipping() as env:
        # Setup worker
        worker = Worker(
            env.client,
            task_queue="order-queue",
            workflows=[OrderWorkflow],
            activities=[process_order],
        )

        async with worker:
            # Override temporal_client in FastAPI app
            app.dependency_overrides[get_temporal_client] = lambda: env.client

            # Test the endpoint
            client = TestClient(app)
            response = client.post("/orders", json={"order_id": "123"})

            assert response.status_code == 200
            assert "workflow_id" in response.json()
```

## Django Integration

Django is a full-featured web framework with ORM, admin interface, and comprehensive ecosystem.

### When to Use Django

**Use Django if:**
- Building full-featured web applications
- Need ORM for database management
- Want Django's admin interface
- Have existing Django infrastructure
- Need traditional request/response patterns

### Installation

```bash
pip install temporalio django
```

### Basic Setup

**Project Structure:**
```
myproject/
├── manage.py
├── myproject/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
└── temporal_app/
    ├── __init__.py
    ├── apps.py
    ├── views.py
    ├── workflows.py
    ├── activities.py
    ├── worker.py
    └── management/
        └── commands/
            └── run_temporal_worker.py
```

### Configuration (settings.py)

```python
# settings.py
TEMPORAL_SERVER = "localhost:7233"
TEMPORAL_NAMESPACE = "default"
TEMPORAL_TASK_QUEUE = "django-queue"

INSTALLED_APPS = [
    # ... other apps
    'temporal_app',
]
```

### Workflows and Activities

**temporal_app/workflows.py:**
```python
from temporalio import workflow
from datetime import timedelta

@workflow.defn
class UserSignupWorkflow:
    @workflow.run
    async def run(self, user_id: int) -> str:
        result = await workflow.execute_activity(
            send_welcome_email,
            args=[user_id],
            start_to_close_timeout=timedelta(minutes=5),
        )
        return result
```

**temporal_app/activities.py:**
```python
from temporalio import activity
from django.core.mail import send_mail
from django.contrib.auth.models import User

@activity.defn
def send_welcome_email(user_id: int) -> str:
    # Access Django ORM from activity
    user = User.objects.get(id=user_id)

    send_mail(
        'Welcome!',
        f'Hello {user.username}',
        'from@example.com',
        [user.email],
    )

    return f"Email sent to {user.email}"
```

### Django Management Command for Worker

**temporal_app/management/commands/run_temporal_worker.py:**
```python
from django.core.management.base import BaseCommand
from django.conf import settings
import asyncio
from temporalio.client import Client
from temporalio.worker import Worker
from temporal_app.workflows import UserSignupWorkflow
from temporal_app.activities import send_welcome_email

class Command(BaseCommand):
    help = 'Run Temporal worker'

    def handle(self, *args, **options):
        asyncio.run(self.run_worker())

    async def run_worker(self):
        client = await Client.connect(settings.TEMPORAL_SERVER)

        worker = Worker(
            client,
            task_queue=settings.TEMPORAL_TASK_QUEUE,
            workflows=[UserSignupWorkflow],
            activities=[send_welcome_email],
        )

        self.stdout.write(self.style.SUCCESS('Starting Temporal worker...'))
        await worker.run()
```

**Run the worker:**
```bash
python manage.py run_temporal_worker
```

### Django Views

**temporal_app/views.py:**
```python
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from temporalio.client import Client
from django.conf import settings
import asyncio
import json
from .workflows import UserSignupWorkflow

# Create client (in production, use singleton)
async def get_temporal_client():
    return await Client.connect(settings.TEMPORAL_SERVER)

@csrf_exempt
def start_signup_workflow(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('user_id')

        # Run async code in Django sync view
        async def start_workflow():
            client = await get_temporal_client()
            handle = await client.start_workflow(
                UserSignupWorkflow.run,
                user_id,
                id=f"signup-{user_id}",
                task_queue=settings.TEMPORAL_TASK_QUEUE,
            )
            return handle.id

        workflow_id = asyncio.run(start_workflow())

        return JsonResponse({
            'status': 'started',
            'workflow_id': workflow_id
        })

    return JsonResponse({'error': 'Method not allowed'}, status=405)
```

### URLs Configuration

**temporal_app/urls.py:**
```python
from django.urls import path
from . import views

urlpatterns = [
    path('signup/', views.start_signup_workflow, name='start_signup'),
]
```

### Best Practices for Django

1. **Use Management Commands**: Create commands for running workers
2. **ORM Access**: Access Django models from activities (not workflows)
3. **Sync vs Async**: Django views are sync by default, use `asyncio.run()` for Temporal calls
4. **Settings**: Store Temporal config in Django settings
5. **Admin Integration**: Create admin views for workflow monitoring
6. **Celery Alternative**: Use Temporal instead of Celery for task orchestration
7. **Database Transactions**: Be careful with transactions in activities

### Django + Django Async Views (Django 4.1+)

```python
from django.http import JsonResponse
from temporalio.client import Client
from asgiref.sync import async_to_sync

async def start_signup_workflow_async(request):
    """Async Django view (requires ASGI server)"""
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('user_id')

        client = await Client.connect(settings.TEMPORAL_SERVER)
        handle = await client.start_workflow(
            UserSignupWorkflow.run,
            user_id,
            id=f"signup-{user_id}",
            task_queue=settings.TEMPORAL_TASK_QUEUE,
        )

        return JsonResponse({'workflow_id': handle.id})
```

## Flask Integration

Flask is a lightweight micro-framework for simpler web applications.

### When to Use Flask

**Use Flask if:**
- Building smaller web applications
- Want minimal framework overhead
- Prefer simplicity over features
- Need quick prototypes

### Installation

```bash
pip install temporalio flask
```

### Basic Example

**app.py:**
```python
from flask import Flask, request, jsonify
from temporalio.client import Client
import asyncio
from workflows import OrderWorkflow

app = Flask(__name__)

# Global client
temporal_client = None

def get_client():
    """Get or create Temporal client"""
    global temporal_client
    if temporal_client is None:
        temporal_client = asyncio.run(Client.connect("localhost:7233"))
    return temporal_client

@app.route('/orders', methods=['POST'])
def create_order():
    """Start order workflow"""
    data = request.json
    order_id = data.get('order_id')

    async def start_workflow():
        client = await Client.connect("localhost:7233")
        handle = await client.start_workflow(
            OrderWorkflow.run,
            order_id,
            id=f"order-{order_id}",
            task_queue="order-queue",
        )
        return handle.id

    workflow_id = asyncio.run(start_workflow())

    return jsonify({
        'workflow_id': workflow_id,
        'status': 'started'
    })

@app.route('/orders/<workflow_id>', methods=['GET'])
def get_order(workflow_id):
    """Get workflow status"""
    async def get_status():
        client = await Client.connect("localhost:7233")
        handle = client.get_workflow_handle(workflow_id)
        description = await handle.describe()
        return {
            'workflow_id': workflow_id,
            'status': str(description.status)
        }

    result = asyncio.run(get_status())
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True)
```

### Best Practices for Flask

1. **Connection Pooling**: Reuse Temporal client across requests
2. **Error Handling**: Use Flask error handlers
3. **Blueprints**: Organize Temporal routes in Flask blueprints
4. **Configuration**: Use Flask config for Temporal settings
5. **Keep It Simple**: Flask is best for simpler integrations

## General Best Practices

### Connection Management
- Create Temporal client once, reuse across requests
- Close client on application shutdown
- Use connection pooling for high-traffic applications

### Error Handling
- Catch Temporal exceptions and convert to HTTP errors
- Return appropriate status codes (404, 500, etc.)
- Log errors for debugging

### Async/Await
- Use async endpoints when possible (FastAPI, async Django)
- Don't block the event loop with sync operations
- Use proper async context managers

### Security
- Authenticate API endpoints that start workflows
- Validate input data before starting workflows
- Use RBAC for workflow access control
- Secure Temporal connection with mTLS for production

### Monitoring
- Add logging for workflow starts/completions
- Integrate with OpenTelemetry for tracing
- Monitor workflow execution metrics
- Use framework middleware for request logging

### Testing
- Use WorkflowEnvironment for integration tests
- Mock activities for faster tests
- Test both web endpoints and workflows
- Use framework testing utilities (TestClient, Django test client)

## Troubleshooting

### Common Issues

**Issue: "Event loop is closed" error in Django**
- Solution: Use `asyncio.run()` for each async operation in sync views

**Issue: Slow API responses**
- Solution: Use `start_workflow()` not `execute_workflow()` - don't wait for completion

**Issue: Worker not processing workflows**
- Solution: Ensure worker is running and task queue names match

**Issue: Import errors with Django ORM in activities**
- Solution: Activities can import Django models, workflows cannot

**Issue: FastAPI startup event not working**
- Solution: Use lifespan context manager (FastAPI 0.93+)

## Additional Resources

- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **Django Documentation**: https://docs.djangoproject.com/
- **Flask Documentation**: https://flask.palletsprojects.com/
- **Temporal Python SDK**: https://docs.temporal.io/develop/python
- **Python Samples**: https://github.com/temporalio/samples-python
- **Community Forum**: https://community.temporal.io/
