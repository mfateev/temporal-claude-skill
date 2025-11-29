#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Testing Application Execution ===${NC}\n"

# Check if we're in the workspace directory
if [ ! -f "pom.xml" ]; then
    echo -e "${RED}✗ Must be run from workspace directory with pom.xml${NC}"
    exit 1
fi

# Function to check if Temporal server is running
check_temporal() {
    curl -s http://localhost:7233 > /dev/null 2>&1
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
        sleep 1
        echo -n "."
    done

    echo -e "\n${RED}✗ Temporal server failed to start within 30 seconds${NC}"
    echo -e "Check temporal-server.log for details"
    return 1
}

# Function to stop Temporal server
stop_temporal() {
    if [ -f ".temporal-server.pid" ]; then
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
    TEMPORAL_STARTED_BY_US=true
fi

echo ""

# Find the Worker class
WORKER_CLASS=$(find src/main/java -name "*Worker.java" | head -1 | sed 's|src/main/java/||' | sed 's|/|.|g' | sed 's|.java||')
if [ -z "$WORKER_CLASS" ]; then
    echo -e "${RED}✗ Could not find Worker class${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found worker class: $WORKER_CLASS${NC}"

# Find the Client class
CLIENT_CLASS=$(find src/main/java -name "*Client.java" | head -1 | sed 's|src/main/java/||' | sed 's|/|.|g' | sed 's|.java||')
if [ -z "$CLIENT_CLASS" ]; then
    echo -e "${RED}✗ Could not find Client class${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found client class: $CLIENT_CLASS${NC}"

echo ""

# Start the worker in background
echo -e "${YELLOW}Starting worker...${NC}"
mvn exec:java -Dexec.mainClass="$WORKER_CLASS" > worker.log 2>&1 &
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

# Run client and capture output
if mvn exec:java -Dexec.mainClass="$CLIENT_CLASS" -Dexec.args="TestUser" > "$WORKFLOW_OUTPUT" 2>&1; then
    echo -e "${GREEN}✓ Workflow execution started${NC}"

    # Give it time to complete
    echo -e "  Waiting for workflow to complete..."
    sleep 5

    # Check for success indicators in output
    if grep -q -i "completed\|success\|hello" "$WORKFLOW_OUTPUT"; then
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
else
    echo -e "${RED}✗ Client execution failed${NC}"
    echo -e "Last 20 lines of output:"
    tail -20 "$WORKFLOW_OUTPUT"
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
