#!/bin/bash

set -e

echo "=================================================="
echo "  Temporal Java SDK Skill Validation Test"
echo "=================================================="
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is required but not installed"
    exit 1
fi

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    echo "ERROR: pip3 is required but not installed"
    exit 1
fi

# Install required Python packages
echo "Installing required Python packages..."
pip3 install -q requests 2>/dev/null || pip3 install --user requests

# Run the validation script
python3 validate_skill.py

# Capture exit code
exit $?
