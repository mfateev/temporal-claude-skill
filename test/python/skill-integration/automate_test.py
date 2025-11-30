#!/usr/bin/env python3
"""
Automated skill integration test that uses the Anthropic API
to invoke Claude with the temporal-python skill and generate code.
"""

import os
import sys
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

try:
    import anthropic
except ImportError:
    print("ERROR: anthropic package not found")
    print("Install it with: pip install anthropic")
    sys.exit(1)

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

def read_skill_files(workspace_dir: Path) -> Dict[str, str]:
    """Read the temporal skill files"""
    print_step("Reading skill files...")

    skills_dir = workspace_dir / ".claude" / "skills"

    # Read main temporal skill
    temporal_skill = skills_dir / "temporal.md"
    if not temporal_skill.exists():
        print_error(f"Temporal skill not found: {temporal_skill}")
        sys.exit(1)

    # Read Python SDK resource
    python_sdk = skills_dir / "sdks" / "python" / "python.md"
    if not python_sdk.exists():
        print_error(f"Python SDK resource not found: {python_sdk}")
        sys.exit(1)

    skills = {}

    with open(temporal_skill, 'r') as f:
        skills['temporal'] = f.read()
        print_success(f"Loaded temporal.md ({len(skills['temporal'])} chars)")

    with open(python_sdk, 'r') as f:
        skills['python_sdk'] = f.read()
        print_success(f"Loaded python.md ({len(skills['python_sdk'])} chars)")

    # Read framework integration reference if exists
    framework_ref = skills_dir / "sdks" / "python" / "references" / "framework-integration.md"
    if framework_ref.exists():
        with open(framework_ref, 'r') as f:
            skills['framework'] = f.read()
            print_success(f"Loaded framework-integration.md ({len(skills['framework'])} chars)")

    # Read samples reference if exists
    samples_ref = skills_dir / "sdks" / "python" / "references" / "samples.md"
    if samples_ref.exists():
        with open(samples_ref, 'r') as f:
            skills['samples'] = f.read()
            print_success(f"Loaded samples.md ({len(skills['samples'])} chars)")

    return skills

def read_prompt_file(prompt_path: Path) -> str:
    """Read the test prompt"""
    print_step(f"Reading prompt file: {prompt_path}")

    with open(prompt_path, 'r') as f:
        content = f.read()

    print_success("Loaded test prompt")
    return content

def invoke_claude(skills: Dict[str, str], prompt: str, api_key: str) -> str:
    """Invoke Claude API with the skills and prompt"""
    print_step("Invoking Claude API...")

    client = anthropic.Anthropic(api_key=api_key)

    # Construct skill context
    skill_context = f"""<skill name="temporal">
{skills['temporal']}
</skill>

<resource name="python-sdk" type="sdk">
{skills['python_sdk']}
</resource>
"""

    if 'framework' in skills:
        skill_context += f"""
<resource name="framework-integration" type="reference">
{skills['framework']}
</resource>
"""

    if 'samples' in skills:
        skill_context += f"""
<resource name="samples" type="reference">
{skills['samples']}
</resource>
"""

    # Construct the system prompt
    system_prompt = f"""You are an expert Python developer using the Temporal.io framework.

You have access to a comprehensive Temporal skill with Python SDK resources.

Here are the skill resources:

{skill_context}

When generating code:
1. Follow the patterns from the Python SDK resource
2. Use the latest temporalio package from PyPI
3. Generate complete, working Python code
4. Include all necessary files (workflows.py, activities.py, worker.py, client.py, requirements.txt)
5. Use proper async/await patterns
6. Include type hints on all functions
7. Use @workflow.defn, @activity.defn, and @workflow.run decorators
8. Follow Python best practices
"""

    print(f"  Model: claude-sonnet-4-5-20250929")
    print(f"  Prompt length: {len(prompt)} chars")
    print(f"  Total skill content: {sum(len(s) for s in skills.values())} chars")

    try:
        message = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=8000,
            system=system_prompt,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )

        response_text = message.content[0].text
        print_success(f"Received response ({len(response_text)} chars)")
        print(f"  Usage: {message.usage.input_tokens} input, {message.usage.output_tokens} output tokens")

        return response_text

    except anthropic.APIError as e:
        print_error(f"API Error: {e}")
        sys.exit(1)

def extract_code_blocks(response: str) -> Dict[str, str]:
    """Extract code blocks from Claude's response"""
    print_step("Extracting code blocks from response...")

    # Pattern to match code blocks with optional file names
    pattern = r'```(?:python|toml|txt)?\s*(?:# )?([^\n]*)\n(.*?)```'
    matches = re.findall(pattern, response, re.DOTALL)

    files = {}

    for filename_line, code in matches:
        # Try to extract filename from various patterns
        filename = None

        # Pattern 1: "# filename.py" or "filename.py"
        if filename_line.strip():
            filename = filename_line.strip().lstrip('#').strip()
            # Remove any leading path indicators
            filename = filename.split('/')[-1]

        # If we have a filename, save it
        if filename and filename not in ['python', 'bash', 'sh']:
            files[filename] = code.strip()
            print_success(f"Extracted: {filename} ({len(code)} chars)")

    # If no filenames found, try to infer from content
    if not files:
        print_step("No explicit filenames found, analyzing content...")

        # Look for all code blocks
        code_pattern = r'```(?:python)?\n(.*?)```'
        code_blocks = re.findall(code_pattern, response, re.DOTALL)

        for i, code in enumerate(code_blocks):
            # Try to infer filename from imports or decorators
            if '@workflow.defn' in code or 'class.*Workflow' in code:
                filename = 'workflows.py'
            elif '@activity.defn' in code:
                filename = 'activities.py'
            elif 'Worker(' in code and 'worker.run()' in code:
                filename = 'worker.py'
            elif 'start_workflow' in code or 'execute_workflow' in code:
                filename = 'client.py'
            elif 'temporalio' in code and '[' not in code:  # requirements.txt
                filename = 'requirements.txt'
            elif '[project]' in code or '[tool.poetry]' in code:
                filename = 'pyproject.toml'
            else:
                filename = f'code_{i}.py'

            if filename not in files:
                files[filename] = code.strip()
                print_success(f"Inferred: {filename} ({len(code)} chars)")

    if not files:
        print_error("No code blocks found in response")
        sys.exit(1)

    return files

def write_files(files: Dict[str, str], workspace_dir: Path):
    """Write extracted files to workspace"""
    print_step(f"Writing {len(files)} files to workspace...")

    for filename, content in files.items():
        filepath = workspace_dir / filename

        # Create parent directory if needed
        filepath.parent.mkdir(parents=True, exist_ok=True)

        with open(filepath, 'w') as f:
            f.write(content)

        print_success(f"Wrote: {filename}")

def main():
    script_dir = Path(__file__).parent
    workspace_dir = script_dir / "test-workspace"

    print("\n" + "="*50)
    print("Temporal Python Skill Integration Test (Automated)")
    print("="*50 + "\n")

    # Check API key
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        print_error("ANTHROPIC_API_KEY environment variable not set")
        print("Set it with: export ANTHROPIC_API_KEY='your-key-here'")
        sys.exit(1)

    print_success("API key found")

    # Check workspace exists
    if not workspace_dir.exists():
        print_error(f"Workspace not found: {workspace_dir}")
        print("Run setup-test-workspace.sh first")
        sys.exit(1)

    print_success(f"Workspace found: {workspace_dir}")

    # Read skill files
    skills = read_skill_files(workspace_dir)

    # Read prompt
    prompt_file = workspace_dir / "test-prompt.txt"
    prompt = read_prompt_file(prompt_file)

    # Invoke Claude
    response = invoke_claude(skills, prompt, api_key)

    # Extract code blocks
    files = extract_code_blocks(response)

    # Write files
    write_files(files, workspace_dir)

    print("\n" + "="*50)
    print_success("Code generation complete!")
    print("="*50)
    print(f"\nGenerated {len(files)} files in: {workspace_dir}")
    print("\nNext step: Run validation")
    print(f"  cd {workspace_dir}")
    print("  ./validate.sh")

if __name__ == "__main__":
    main()
