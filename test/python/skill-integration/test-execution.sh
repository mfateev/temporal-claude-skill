#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Testing Application Execution ===${NC}\n"

# Check if we're in the workspace directory with Python files
if [ ! -f "requirements.txt" ] && [ -z "$(find . -name "*worker.py" 2>/dev/null)" ]; then
    echo -e "${RED}✗ Must be run from workspace directory with Python files${NC}"
    exit 1
fi

# Function to check if Temporal server is running
check_temporal() {
    OUTPUT=$(temporal operator cluster health --tls=false 2>/dev/null)
    echo "$OUTPUT" | grep -q "SERVING"
    return $?
}

# Function to start Temporal server
start_temporal() {
    echo -e "${YELLOW}Starting Temporal development server...${NC}"

    if ! command -v temporal &> /dev/null; then
        echo -e "${RED}✗ Temporal CLI not found${NC}"
        echo -e "Install it with:"
        echo -e "  ${YELLOW}brew install temporal${NC}  (macOS)"
        echo -e "  Or follow: https://docs.temporal.io/cli"
        return 1
    fi

    echo -e "${GREEN}✓ Temporal CLI found${NC}"

    # Start Temporal server in background
    temporal server start-dev > temporal-server.log 2>&1 &
    TEMPORAL_PID=$!
    echo $TEMPORAL_PID > .temporal-server.pid

    echo -e "  Started Temporal server (PID: $TEMPORAL_PID)"
    echo -e "  Waiting for server to be ready..."

    # Wait for Temporal to be ready (max 30 seconds)
    for i in {1..30}; do
        if check_temporal; then
            echo -e "${GREEN}✓ Temporal server is ready${NC}"
            return 0
        fi

        # Check if we got "address already in use" error
        if grep -q "address already in use" temporal-server.log 2>/dev/null; then
            echo -e "\n${YELLOW}! Port already in use - Temporal is already running${NC}"
            # Clean up our failed start attempt
            kill $TEMPORAL_PID 2>/dev/null || true
            rm -f .temporal-server.pid

            # Verify Temporal is actually accessible
            if check_temporal; then
                echo -e "${GREEN}✓ Confirmed Temporal server is accessible${NC}"
                return 0
            else
                echo -e "${RED}✗ Port is in use but Temporal is not responding${NC}"
                return 1
            fi
        fi

        sleep 1
        echo -n "."
    done

    echo -e "\n${RED}✗ Temporal server failed to start within 30 seconds${NC}"
    echo -e "Check temporal-server.log for details"
    return 1
}

# Function to stop Temporal server
stop_temporal() {
    # Only stop if we started it
    if [ "${TEMPORAL_STARTED_BY_US:-false}" = "true" ] && [ -f ".temporal-server.pid" ]; then
        TEMPORAL_PID=$(cat .temporal-server.pid)
        echo -e "${YELLOW}Stopping Temporal server (PID: $TEMPORAL_PID)...${NC}"
        kill $TEMPORAL_PID 2>/dev/null || true
        rm -f .temporal-server.pid
        echo -e "${GREEN}✓ Temporal server stopped${NC}"
    fi
}

# Trap to ensure cleanup on exit
trap stop_temporal EXIT

# Check if Temporal is already running
echo -e "${YELLOW}Checking for Temporal server...${NC}"
if check_temporal; then
    echo -e "${GREEN}✓ Temporal server is already running${NC}"
    TEMPORAL_STARTED_BY_US=false
else
    echo -e "${YELLOW}! Temporal server not running${NC}"
    if ! start_temporal; then
        exit 1
    fi
    # Check if start_temporal detected it was already running
    if [ -f ".temporal-server.pid" ]; then
        TEMPORAL_STARTED_BY_US=true
    else
        # start_temporal detected "address already in use" and didn't create pid file
        TEMPORAL_STARTED_BY_US=false
    fi
fi

echo ""

# Check if temporalio is installed
echo -e "${YELLOW}Checking Python dependencies...${NC}"
if ! python3 -c "import temporalio" 2>/dev/null; then
    echo -e "${YELLOW}! temporalio package not found${NC}"
    if [ -f "requirements.txt" ]; then
        echo -e "${YELLOW}Installing dependencies from requirements.txt...${NC}"
        pip install -r requirements.txt > /dev/null 2>&1 || {
            echo -e "${RED}✗ Failed to install dependencies${NC}"
            echo -e "Try running: pip install -r requirements.txt"
            exit 1
        }
        echo -e "${GREEN}✓ Dependencies installed${NC}"
    else
        echo -e "${RED}✗ temporalio package is required${NC}"
        echo -e "Install it with: pip install temporalio"
        exit 1
    fi
else
    echo -e "${GREEN}✓ temporalio package is installed${NC}"
fi

echo ""

# Find the worker script
WORKER_FILE=$(find . -name "*worker.py" | head -1)
if [ -z "$WORKER_FILE" ]; then
    echo -e "${RED}✗ Could not find worker.py file${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found worker script: $WORKER_FILE${NC}"

# Find the client script
CLIENT_FILE=$(find . -name "*client.py" | head -1)
if [ -z "$CLIENT_FILE" ]; then
    echo -e "${RED}✗ Could not find client.py file${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found client script: $CLIENT_FILE${NC}"

echo ""

# Start the worker in background
echo -e "${YELLOW}Starting worker...${NC}"
python3 "$WORKER_FILE" > worker.log 2>&1 &
WORKER_PID=$!
echo -e "  Worker started (PID: $WORKER_PID)"

# Wait for worker to initialize
echo -e "  Waiting for worker to initialize..."
sleep 5

# Check if worker is still running
if ! kill -0 $WORKER_PID 2>/dev/null; then
    echo -e "${RED}✗ Worker failed to start${NC}"
    echo -e "Last 20 lines of worker.log:"
    tail -20 worker.log
    exit 1
fi

echo -e "${GREEN}✓ Worker is running${NC}"
echo ""

# Execute the workflow via client
echo -e "${YELLOW}Executing workflow via client...${NC}"
WORKFLOW_OUTPUT=$(mktemp)

# Try to detect if client uses --name flag or positional argument
# First try with --name flag, if it fails try positional argument
if python3 "$CLIENT_FILE" --name TestUser > "$WORKFLOW_OUTPUT" 2>&1; then
    echo -e "${GREEN}✓ Workflow execution started${NC}"
elif python3 "$CLIENT_FILE" TestUser > "$WORKFLOW_OUTPUT" 2>&1; then
    echo -e "${GREEN}✓ Workflow execution started${NC}"
else
    # If both fail, show the error
    echo -e "${RED}✗ Client execution failed${NC}"
    echo -e "Last 20 lines of output:"
    tail -20 "$WORKFLOW_OUTPUT"
    cat "$WORKFLOW_OUTPUT" > workflow-output.log

    # Cleanup worker
    echo -e "\n${YELLOW}Stopping worker...${NC}"
    kill $WORKER_PID 2>/dev/null || true
    echo -e "${GREEN}✓ Worker stopped${NC}"

    # Cleanup Temporal if we started it
    if [ "$TEMPORAL_STARTED_BY_US" = true ]; then
        echo ""
        stop_temporal
    fi

    # Clean up log files
    echo -e "\n${YELLOW}Cleaning up log files...${NC}"
    rm -f worker.log temporal-server.log
    echo -e "${GREEN}✓ Cleanup complete${NC}"

    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║       EXECUTION TEST FAILED                    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
    echo -e "\nCheck workflow-output.log for details"
    exit 1
fi

# Give it time to complete
echo -e "  Waiting for workflow to complete..."
sleep 5

# Check for success indicators in output
if grep -q -i "completed\|success\|hello\|result" "$WORKFLOW_OUTPUT"; then
    echo -e "${GREEN}✓ Workflow completed successfully${NC}"

    # Show relevant output
    echo -e "\n${YELLOW}Workflow output:${NC}"
    grep -i "hello\|completed\|result" "$WORKFLOW_OUTPUT" || cat "$WORKFLOW_OUTPUT"

    EXECUTION_SUCCESS=true
else
    echo -e "${YELLOW}! Workflow may not have completed as expected${NC}"
    echo -e "Check full output in workflow-output.log"
    cat "$WORKFLOW_OUTPUT" > workflow-output.log
    EXECUTION_SUCCESS=false
fi

rm -f "$WORKFLOW_OUTPUT"

# Cleanup worker
echo -e "\n${YELLOW}Stopping worker...${NC}"
kill $WORKER_PID 2>/dev/null || true
echo -e "${GREEN}✓ Worker stopped${NC}"

# Cleanup Temporal if we started it
if [ "$TEMPORAL_STARTED_BY_US" = true ]; then
    echo ""
    stop_temporal
fi

# Clean up log files
echo -e "\n${YELLOW}Cleaning up log files...${NC}"
rm -f worker.log temporal-server.log
echo -e "${GREEN}✓ Cleanup complete${NC}"

echo ""
if [ "$EXECUTION_SUCCESS" = true ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       EXECUTION TEST PASSED!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║       EXECUTION TEST FAILED                    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
    echo -e "\nCheck workflow-output.log for details"
    exit 1
fi
