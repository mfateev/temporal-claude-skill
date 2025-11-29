#!/usr/bin/env python3
"""
Automated skill integration test that uses the Anthropic API
to invoke Claude with the temporal-java skill and generate code.
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

def read_skill_file(skill_path: Path) -> str:
    """Read the temporal-java skill file"""
    print_step(f"Reading skill file: {skill_path}")

    if not skill_path.exists():
        print_error(f"Skill file not found: {skill_path}")
        sys.exit(1)

    with open(skill_path, 'r') as f:
        content = f.read()

    print_success(f"Loaded skill file ({len(content)} chars)")
    return content

def read_prompt_file(prompt_path: Path) -> str:
    """Read the test prompt"""
    print_step(f"Reading prompt file: {prompt_path}")

    with open(prompt_path, 'r') as f:
        content = f.read()

    print_success("Loaded test prompt")
    return content

def invoke_claude(skill_content: str, prompt: str, api_key: str) -> str:
    """Invoke Claude API with the skill and prompt"""
    print_step("Invoking Claude API...")

    client = anthropic.Anthropic(api_key=api_key)

    # Construct the message with skill as context
    system_prompt = f"""You are an expert Java developer using the Temporal.io framework.

You have access to a skill called 'temporal-java' that provides patterns and examples for creating Temporal applications.

Here is the skill content:

<skill name="temporal-java">
{skill_content}
</skill>

When generating code:
1. Follow the patterns from the skill
2. Fetch the latest Temporal SDK version from Maven Central
3. Generate complete, working code
4. Include all necessary files (pom.xml, workflow, activities, worker, client)
5. Use proper package structure
"""

    print(f"  Model: claude-sonnet-4-5-20250929")
    print(f"  Prompt length: {len(prompt)} chars")
    print(f"  Skill length: {len(skill_content)} chars")

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
        return response_text

    except Exception as e:
        print_error(f"API call failed: {e}")
        sys.exit(1)

def extract_code_blocks(response: str) -> Dict[str, str]:
    """Extract code blocks from Claude's response"""
    print_step("Extracting code blocks from response...")

    files = {}

    # Pattern to match code blocks with file paths
    # Looks for patterns like:
    # ```java
    # // path/to/File.java
    # or
    # ```xml
    # <!-- pom.xml -->

    # First, try to find explicit file paths in comments
    code_block_pattern = r'```(?:java|xml|properties)\n(.*?)```'
    blocks = re.findall(code_block_pattern, response, re.DOTALL)

    for block in blocks:
        # Try to extract file path from comments
        file_path = None

        # Java file comment: // path/to/File.java
        java_match = re.match(r'^//\s*(.+\.java)', block.strip())
        if java_match:
            file_path = java_match.group(1)

        # XML comment: <!-- pom.xml -->
        xml_match = re.match(r'^<!--\s*(.+)\s*-->', block.strip())
        if xml_match:
            file_path = xml_match.group(1)

        # Try to infer from package and class name
        if not file_path and 'package ' in block:
            package_match = re.search(r'package\s+([\w.]+);', block)
            class_match = re.search(r'(?:public\s+)?(?:class|interface)\s+(\w+)', block)

            if package_match and class_match:
                package = package_match.group(1).replace('.', '/')
                classname = class_match.group(1)
                file_path = f"src/main/java/{package}/{classname}.java"

        # Check for pom.xml
        if '<project' in block and '<groupId>' in block:
            file_path = 'pom.xml'

        # Check for logback.xml
        if '<configuration>' in block and '<appender' in block:
            file_path = 'src/main/resources/logback.xml'

        if file_path:
            # Clean up the block (remove file path comment)
            clean_block = re.sub(r'^//\s*.+\.java\n', '', block)
            clean_block = re.sub(r'^<!--\s*.+\s*-->\n', '', clean_block)
            files[file_path] = clean_block.strip()

    print_success(f"Extracted {len(files)} code files")
    for file_path in files.keys():
        print(f"  - {file_path}")

    return files

def write_generated_files(workspace_dir: Path, files: Dict[str, str]) -> None:
    """Write generated code files to workspace"""
    print_step("Writing generated files...")

    for file_path, content in files.items():
        full_path = workspace_dir / file_path
        full_path.parent.mkdir(parents=True, exist_ok=True)

        with open(full_path, 'w') as f:
            f.write(content)

        print(f"  Wrote: {file_path}")

    print_success(f"Wrote {len(files)} files")

def fallback_extraction(response: str, workspace_dir: Path) -> bool:
    """
    Fallback: Try to extract code even without explicit file markers
    by inferring structure from content
    """
    print_step("Attempting fallback code extraction...")

    # Extract all code blocks
    code_blocks = re.findall(r'```(?:java|xml|properties)\n(.*?)```', response, re.DOTALL)

    if not code_blocks:
        print_error("No code blocks found in response")
        return False

    print(f"  Found {len(code_blocks)} code blocks")

    files_created = 0

    for i, block in enumerate(code_blocks):
        file_path = None

        # Detect pom.xml
        if '<project' in block and '<artifactId>' in block:
            file_path = 'pom.xml'

        # Detect logback.xml
        elif '<configuration>' in block and '<appender' in block:
            file_path = 'src/main/resources/logback.xml'

        # Detect Java files
        elif 'package ' in block:
            package_match = re.search(r'package\s+([\w.]+);', block)

            # Look for class/interface name
            class_match = re.search(r'(?:public\s+)?(?:class|interface)\s+(\w+)', block)

            if package_match and class_match:
                package = package_match.group(1).replace('.', '/')
                classname = class_match.group(1)
                file_path = f"src/main/java/{package}/{classname}.java"

        if file_path:
            full_path = workspace_dir / file_path
            full_path.parent.mkdir(parents=True, exist_ok=True)

            with open(full_path, 'w') as f:
                f.write(block.strip() + '\n')

            print(f"  Created: {file_path}")
            files_created += 1
        else:
            print(f"  Skipped block {i+1} (couldn't determine file path)")

    if files_created > 0:
        print_success(f"Created {files_created} files via fallback")
        return True
    else:
        print_error("Fallback extraction failed")
        return False

def main():
    print(f"{YELLOW}{'='*60}{NC}")
    print(f"{YELLOW}Automated Temporal Java Skill Integration Test{NC}")
    print(f"{YELLOW}{'='*60}{NC}\n")

    # Get API key from environment
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        print_error("ANTHROPIC_API_KEY environment variable not set")
        print("\nTo run this test, set your API key:")
        print("  export ANTHROPIC_API_KEY='your-key-here'")
        print("\nOr run the manual test instead:")
        print("  ./run-integration-test.sh")
        sys.exit(1)

    print_success("Found ANTHROPIC_API_KEY")

    # Paths
    script_dir = Path(__file__).parent
    skill_path = script_dir.parent.parent / "temporal-java.md"

    # Allow workspace directory to be overridden via command line or environment
    if len(sys.argv) > 1:
        workspace_dir = Path(sys.argv[1])
    elif 'TEST_WORKSPACE' in os.environ:
        workspace_dir = Path(os.environ['TEST_WORKSPACE'])
    else:
        workspace_dir = script_dir / "test-workspace"

    prompt_path = workspace_dir / "test-prompt.txt"

    # Read skill and prompt
    skill_content = read_skill_file(skill_path)
    prompt = read_prompt_file(prompt_path)

    # Invoke Claude
    response = invoke_claude(skill_content, prompt, api_key)

    # Save raw response for debugging
    response_file = workspace_dir / "claude-response.txt"
    with open(response_file, 'w') as f:
        f.write(response)
    print(f"  Saved response to: {response_file}")

    # Extract and write code
    files = extract_code_blocks(response)

    if not files:
        print_error("No files extracted with primary method")
        print("  Trying fallback extraction...")
        if not fallback_extraction(response, workspace_dir):
            print_error("Code extraction failed")
            print(f"\nCheck the response in: {response_file}")
            sys.exit(1)
    else:
        write_generated_files(workspace_dir, files)

    print(f"\n{GREEN}{'='*60}{NC}")
    print(f"{GREEN}✓ Code Generation Complete{NC}")
    print(f"{GREEN}{'='*60}{NC}\n")

    print("Next steps:")
    print(f"  1. Review generated code in: {workspace_dir}")
    print(f"  2. Run validation: cd {workspace_dir} && ./validate.sh")
    print()

if __name__ == "__main__":
    main()
