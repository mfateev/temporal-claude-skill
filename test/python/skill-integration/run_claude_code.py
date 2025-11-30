#!/usr/bin/env python3
"""
Invokes claude-code CLI non-interactively with a prompt from the workspace.
This replaces the old automate_test.py that used the Anthropic API directly.
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

# Colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'

def print_step(message):
    print(f"{YELLOW}==> {message}{NC}")

def print_success(message):
    print(f"{GREEN}✓ {message}{NC}")

def print_error(message):
    print(f"{RED}✗ {message}{NC}")

def check_claude_code_installed():
    """Check if Claude CLI is available"""
    print_step("Checking for Claude CLI...")

    if shutil.which('claude'):
        print_success("Claude CLI found")
        return True
    else:
        print_error("Claude CLI not found")
        print("\nTo install Claude:")
        print("  npm install -g @anthropic-ai/claude-code")
        print("\nOr use npx (no installation needed):")
        print("  npx @anthropic-ai/claude-code")
        return False

def check_api_key():
    """Check if ANTHROPIC_API_KEY is set"""
    print_step("Checking for ANTHROPIC_API_KEY...")

    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if api_key:
        print_success("ANTHROPIC_API_KEY found")
        return True
    else:
        print_error("ANTHROPIC_API_KEY not set")
        print("\nSet your API key:")
        print("  export ANTHROPIC_API_KEY='your-key-here'")
        return False

def read_prompt_file(workspace_dir: Path) -> str:
    """Read the test prompt from the workspace"""
    prompt_path = workspace_dir / "test-prompt.txt"

    print_step(f"Reading prompt from: {prompt_path}")

    if not prompt_path.exists():
        print_error(f"Prompt file not found: {prompt_path}")
        sys.exit(1)

    with open(prompt_path, 'r') as f:
        prompt = f.read()

    print_success(f"Loaded prompt ({len(prompt)} chars)")
    return prompt

def invoke_claude_code(workspace_dir: Path, prompt: str) -> bool:
    """
    Invoke Claude CLI with the prompt in the workspace directory.
    Returns True if successful, False otherwise.
    """
    print_step("Invoking Claude CLI...")
    print(f"  Working directory: {workspace_dir}")
    print(f"  Prompt length: {len(prompt)} chars")
    print()

    try:
        # Invoke claude with prompt piped to stdin
        # Use cwd parameter to set working directory so skills are auto-loaded from .claude/skills/
        process = subprocess.Popen(
            ['claude', '--print'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            cwd=str(workspace_dir),
            bufsize=1  # Line buffered
        )

        # Send the prompt and close stdin
        stdout, _ = process.communicate(input=prompt)

        # Stream output to console
        print(stdout)

        # Check exit code
        if process.returncode == 0:
            print_success("Claude completed successfully")
            return True
        else:
            print_error(f"Claude failed with exit code {process.returncode}")
            return False

    except FileNotFoundError:
        print_error("claude command not found")
        print("\nMake sure Claude is installed:")
        print("  npm install -g @anthropic-ai/claude-code")
        return False
    except Exception as e:
        print_error(f"Failed to invoke Claude: {e}")
        return False

def main():
    print(f"{YELLOW}{'='*60}{NC}")
    print(f"{YELLOW}Claude Code Integration Test Runner{NC}")
    print(f"{YELLOW}{'='*60}{NC}\n")

    # Get workspace directory from command line
    if len(sys.argv) < 2:
        print_error("Usage: python3 run_claude_code.py <workspace_dir>")
        print("\nExample:")
        print("  python3 run_claude_code.py test-workspace")
        sys.exit(1)

    workspace_dir = Path(sys.argv[1])

    # Make path absolute if relative
    if not workspace_dir.is_absolute():
        workspace_dir = Path.cwd() / workspace_dir

    if not workspace_dir.exists():
        print_error(f"Workspace directory not found: {workspace_dir}")
        sys.exit(1)

    print_success(f"Workspace found: {workspace_dir}")

    # Check prerequisites
    if not check_claude_code_installed():
        sys.exit(1)

    if not check_api_key():
        sys.exit(1)

    # Read prompt
    prompt = read_prompt_file(workspace_dir)

    # Invoke claude-code
    success = invoke_claude_code(workspace_dir, prompt)

    if success:
        print(f"\n{GREEN}{'='*60}{NC}")
        print(f"{GREEN}✓ Code Generation Complete{NC}")
        print(f"{GREEN}{'='*60}{NC}\n")
        print("Next steps:")
        print(f"  1. Review generated code in: {workspace_dir}")
        print(f"  2. Validation will run automatically")
        print()
        sys.exit(0)
    else:
        print(f"\n{RED}{'='*60}{NC}")
        print(f"{RED}✗ Code Generation Failed{NC}")
        print(f"{RED}{'='*60}{NC}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
