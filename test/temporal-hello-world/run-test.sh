#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Temporal Hello World Test ===${NC}\n"

# Check if Temporal server is running
echo -e "${YELLOW}Checking if Temporal server is running...${NC}"
if ! curl -s http://localhost:7233 > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Temporal server is not running!${NC}"
    echo -e "Please start Temporal server first:"
    echo -e "  Using Docker: ${YELLOW}docker run -p 7233:7233 -p 8233:8233 temporalio/auto-setup:latest${NC}"
    echo -e "  Or using Temporal CLI: ${YELLOW}temporal server start-dev${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Temporal server is running${NC}\n"

# Build the project
echo -e "${YELLOW}Building the project...${NC}"
mvn clean compile
echo -e "${GREEN}✓ Build successful${NC}\n"

# Start the worker in the background
echo -e "${YELLOW}Starting worker...${NC}"
mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldWorker" > worker.log 2>&1 &
WORKER_PID=$!
echo -e "${GREEN}✓ Worker started (PID: $WORKER_PID)${NC}\n"

# Wait a bit for worker to initialize
echo -e "${YELLOW}Waiting for worker to initialize...${NC}"
sleep 3
echo -e "${GREEN}✓ Worker ready${NC}\n"

# Run the client
echo -e "${YELLOW}Executing workflow...${NC}"
if mvn exec:java -Dexec.mainClass="io.temporal.hello.HelloWorldClient" -Dexec.args="World"; then
    echo -e "\n${GREEN}✓ Workflow executed successfully!${NC}\n"
    TEST_RESULT=0
else
    echo -e "\n${RED}✗ Workflow execution failed!${NC}\n"
    TEST_RESULT=1
fi

# Clean up: kill the worker
echo -e "${YELLOW}Cleaning up...${NC}"
kill $WORKER_PID 2>/dev/null || true
echo -e "${GREEN}✓ Worker stopped${NC}\n"

# Show worker logs
if [ $TEST_RESULT -ne 0 ]; then
    echo -e "${YELLOW}Worker logs:${NC}"
    cat worker.log
fi

# Clean up log file
rm -f worker.log

if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}=== Test PASSED ===${NC}"
else
    echo -e "${RED}=== Test FAILED ===${NC}"
fi

exit $TEST_RESULT
