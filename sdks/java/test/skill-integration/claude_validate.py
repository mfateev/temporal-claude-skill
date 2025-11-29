#!/usr/bin/env python3
"""
Claude-powered validation for generated Temporal applications.
Uses Claude AI to intelligently analyze project structure and code quality.
"""

import os
import sys
import json
from pathlib import Path
from typing import Dict, List, Optional

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

def collect_project_structure(workspace_dir: Path) -> Dict:
    """Collect project structure information"""
    print_step("Collecting project structure...")

    structure = {
        "files": [],
        "directories": [],
        "pom_xml": None,
        "java_files": {},
        "resources": []
    }

    # Collect all files and directories
    for root, dirs, files in os.walk(workspace_dir):
        rel_root = Path(root).relative_to(workspace_dir)

        for d in dirs:
            rel_path = str(rel_root / d)
            if not rel_path.startswith('.'):
                structure["directories"].append(rel_path)

        for f in files:
            rel_path = str(rel_root / f)
            if rel_path.startswith('.'):
                continue

            structure["files"].append(rel_path)

            # Collect Java files with content
            if f.endswith('.java'):
                file_path = Path(root) / f
                try:
                    with open(file_path, 'r') as java_file:
                        structure["java_files"][rel_path] = java_file.read()
                except Exception as e:
                    print(f"  Warning: Could not read {rel_path}: {e}")

            # Collect pom.xml
            elif f == 'pom.xml':
                file_path = Path(root) / f
                try:
                    with open(file_path, 'r') as pom_file:
                        structure["pom_xml"] = pom_file.read()
                except Exception as e:
                    print(f"  Warning: Could not read pom.xml: {e}")

            # Collect resources
            elif 'resources' in str(rel_root):
                structure["resources"].append(rel_path)

    print_success(f"Collected {len(structure['files'])} files, {len(structure['java_files'])} Java files")
    return structure

def invoke_claude_validation(structure: Dict, api_key: str) -> Dict:
    """Use Claude to validate the project structure"""
    print_step("Invoking Claude for intelligent validation...")

    client = anthropic.Anthropic(api_key=api_key)

    # Build a concise summary for Claude
    summary = f"""
# Project Structure Analysis Request

Please analyze this generated Temporal Java application and validate it.

## Files Present
{chr(10).join([f"- {f}" for f in sorted(structure['files'])])}

## Directories
{chr(10).join([f"- {d}" for d in sorted(structure['directories'])])}

## pom.xml Content
```xml
{structure['pom_xml'] if structure['pom_xml'] else 'NOT FOUND'}
```

## Java Files
"""

    # Add Java files (with truncation for very long files)
    for file_path, content in structure['java_files'].items():
        # Truncate very long files to save tokens
        if len(content) > 3000:
            content = content[:3000] + "\n... (truncated)"
        summary += f"\n### {file_path}\n```java\n{content}\n```\n"

    validation_prompt = summary + """

# Validation Requirements

Please validate this Temporal Java application and provide a structured response:

1. **Structure Validation**
   - Is there a valid pom.xml with Temporal SDK dependency?
   - Are workflow interface and implementation present?
   - Are activity interface and implementation present?
   - Is there a worker class to register workflows/activities?
   - Is there a client class to start workflows?
   - Is the package structure reasonable?

2. **Code Quality**
   - Do workflows follow Temporal patterns (@WorkflowInterface, @WorkflowMethod)?
   - Do activities follow Temporal patterns (@ActivityInterface, @ActivityMethod)?
   - Are there any obvious compilation errors?
   - Are imports reasonable?

3. **Advanced Features** (if present)
   - Signal methods (@SignalMethod)
   - Query methods (@QueryMethod)
   - Spring Boot integration
   - Testing classes

4. **Flexibility Notes**
   - Don't be rigid about directory names (workflow vs workflows is fine)
   - Don't be rigid about file names (HelloWorldWorkflow vs GreetingWorkflow is fine)
   - Focus on whether the Temporal patterns are correctly implemented
   - Accept both standard Java and Spring Boot approaches

Please provide your response in this JSON format:
```json
{
  "valid": true/false,
  "summary": "Brief overall assessment",
  "structure": {
    "pom_xml": {"present": true/false, "has_temporal_sdk": true/false, "notes": "..."},
    "workflows": {"present": true/false, "count": N, "notes": "..."},
    "activities": {"present": true/false, "count": N, "notes": "..."},
    "worker": {"present": true/false, "notes": "..."},
    "client": {"present": true/false, "notes": "..."}
  },
  "code_quality": {
    "follows_patterns": true/false,
    "notes": "..."
  },
  "advanced_features": {
    "signals": true/false,
    "queries": true/false,
    "spring_boot": true/false,
    "tests": true/false
  },
  "issues": ["list of issues if any"],
  "warnings": ["list of warnings if any"],
  "recommendations": ["list of recommendations if any"]
}
```
"""

    try:
        message = client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=4000,
            messages=[
                {
                    "role": "user",
                    "content": validation_prompt
                }
            ]
        )

        response_text = message.content[0].text
        print_success(f"Received validation response ({len(response_text)} chars)")

        # Extract JSON from response (may be wrapped in markdown)
        import re
        json_match = re.search(r'```json\s*(\{.*?\})\s*```', response_text, re.DOTALL)
        if json_match:
            json_text = json_match.group(1)
        else:
            # Try to find JSON without markdown wrapper
            json_match = re.search(r'\{.*"valid".*\}', response_text, re.DOTALL)
            if json_match:
                json_text = json_match.group(0)
            else:
                print_error("Could not extract JSON from response")
                print("Response:", response_text[:500])
                return {
                    "valid": False,
                    "summary": "Failed to parse validation response",
                    "raw_response": response_text
                }

        validation_result = json.loads(json_text)
        return validation_result

    except Exception as e:
        print_error(f"Validation failed: {e}")
        return {
            "valid": False,
            "summary": f"API call failed: {str(e)}",
            "error": str(e)
        }

def print_validation_results(result: Dict):
    """Print validation results in a readable format"""
    print("\n" + "="*60)
    print(f"{YELLOW}VALIDATION RESULTS{NC}")
    print("="*60 + "\n")

    # Overall status
    if result.get("valid"):
        print_success(f"PASSED: {result.get('summary', 'Application is valid')}")
    else:
        print_error(f"FAILED: {result.get('summary', 'Application has issues')}")

    print()

    # Structure details
    if "structure" in result:
        print(f"{YELLOW}Structure:{NC}")
        struct = result["structure"]

        if "pom_xml" in struct:
            pom = struct["pom_xml"]
            status = "✓" if pom.get("present") and pom.get("has_temporal_sdk") else "✗"
            print(f"  {status} pom.xml: {pom.get('notes', '')}")

        if "workflows" in struct:
            wf = struct["workflows"]
            status = "✓" if wf.get("present") else "✗"
            count = wf.get("count", 0)
            print(f"  {status} Workflows: {count} files - {wf.get('notes', '')}")

        if "activities" in struct:
            act = struct["activities"]
            status = "✓" if act.get("present") else "✗"
            count = act.get("count", 0)
            print(f"  {status} Activities: {count} files - {act.get('notes', '')}")

        if "worker" in struct:
            worker = struct["worker"]
            status = "✓" if worker.get("present") else "✗"
            print(f"  {status} Worker: {worker.get('notes', '')}")

        if "client" in struct:
            client = struct["client"]
            status = "✓" if client.get("present") else "✗"
            print(f"  {status} Client: {client.get('notes', '')}")

        print()

    # Code quality
    if "code_quality" in result:
        cq = result["code_quality"]
        status = "✓" if cq.get("follows_patterns") else "✗"
        print(f"{YELLOW}Code Quality:{NC}")
        print(f"  {status} {cq.get('notes', 'No notes')}")
        print()

    # Advanced features
    if "advanced_features" in result:
        af = result["advanced_features"]
        print(f"{YELLOW}Advanced Features:{NC}")
        if af.get("signals"):
            print(f"  ✓ Signal methods implemented")
        if af.get("queries"):
            print(f"  ✓ Query methods implemented")
        if af.get("spring_boot"):
            print(f"  ✓ Spring Boot integration detected")
        if af.get("tests"):
            print(f"  ✓ Test classes present")
        if not any([af.get("signals"), af.get("queries"), af.get("spring_boot"), af.get("tests")]):
            print(f"  (none detected)")
        print()

    # Issues
    if result.get("issues"):
        print(f"{RED}Issues:{NC}")
        for issue in result["issues"]:
            print(f"  ✗ {issue}")
        print()

    # Warnings
    if result.get("warnings"):
        print(f"{YELLOW}Warnings:{NC}")
        for warning in result["warnings"]:
            print(f"  ! {warning}")
        print()

    # Recommendations
    if result.get("recommendations"):
        print(f"{YELLOW}Recommendations:{NC}")
        for rec in result["recommendations"]:
            print(f"  → {rec}")
        print()

    print("="*60)

def test_compilation(workspace_dir: Path) -> bool:
    """Test if the project compiles with Maven"""
    print_step("Testing compilation with Maven...")

    import subprocess

    try:
        # Check if mvn is available
        result = subprocess.run(
            ["mvn", "--version"],
            cwd=workspace_dir,
            capture_output=True,
            timeout=10
        )

        if result.returncode != 0:
            print(f"  {YELLOW}Maven not available, skipping compilation test{NC}")
            return True  # Don't fail if Maven isn't available

    except (subprocess.TimeoutExpired, FileNotFoundError):
        print(f"  {YELLOW}Maven not available, skipping compilation test{NC}")
        return True

    # Try to compile
    try:
        print("  Running: mvn clean compile")
        result = subprocess.run(
            ["mvn", "clean", "compile", "-q"],
            cwd=workspace_dir,
            capture_output=True,
            timeout=180  # 3 minutes
        )

        if result.returncode == 0:
            print_success("Compilation successful")
            return True
        else:
            print_error("Compilation failed")
            print("\nBuild output:")
            print(result.stdout.decode())
            print(result.stderr.decode())
            return False

    except subprocess.TimeoutExpired:
        print_error("Compilation timed out after 3 minutes")
        return False
    except Exception as e:
        print_error(f"Compilation test failed: {e}")
        return False

def main():
    print(f"{YELLOW}{'='*60}{NC}")
    print(f"{YELLOW}Claude-Powered Temporal Application Validation{NC}")
    print(f"{YELLOW}{'='*60}{NC}\n")

    # Get API key
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        print_error("ANTHROPIC_API_KEY environment variable not set")
        print("\nTo run this validation, set your API key:")
        print("  export ANTHROPIC_API_KEY='your-key-here'")
        sys.exit(1)

    print_success("Found ANTHROPIC_API_KEY")

    # Get workspace directory
    if len(sys.argv) > 1:
        workspace_dir = Path(sys.argv[1])
    elif 'TEST_WORKSPACE' in os.environ:
        workspace_dir = Path(os.environ['TEST_WORKSPACE'])
    else:
        workspace_dir = Path.cwd()

    if not workspace_dir.exists():
        print_error(f"Workspace directory does not exist: {workspace_dir}")
        sys.exit(1)

    print(f"Workspace: {workspace_dir}\n")

    # Collect project structure
    structure = collect_project_structure(workspace_dir)

    if not structure["java_files"]:
        print_error("No Java files found in workspace")
        sys.exit(1)

    if not structure["pom_xml"]:
        print_error("No pom.xml found in workspace")
        sys.exit(1)

    # Run Claude validation
    result = invoke_claude_validation(structure, api_key)

    # Save result for debugging
    result_file = workspace_dir / "validation-result.json"
    with open(result_file, 'w') as f:
        json.dump(result, f, indent=2)
    print(f"\n  Saved validation result to: {result_file}")

    # Print results
    print_validation_results(result)

    # Test compilation
    compilation_ok = test_compilation(workspace_dir)

    # Final verdict
    print(f"\n{YELLOW}{'='*60}{NC}")
    if result.get("valid") and compilation_ok:
        print(f"{GREEN}✓ VALIDATION PASSED{NC}")
        print(f"{GREEN}  Application structure is valid and compiles successfully{NC}")
        print(f"{YELLOW}{'='*60}{NC}\n")
        sys.exit(0)
    elif result.get("valid"):
        print(f"{YELLOW}⚠ PARTIAL PASS{NC}")
        print(f"{YELLOW}  Structure is valid but compilation failed{NC}")
        print(f"{YELLOW}{'='*60}{NC}\n")
        sys.exit(1)
    else:
        print(f"{RED}✗ VALIDATION FAILED{NC}")
        print(f"{RED}  Application structure has issues{NC}")
        print(f"{YELLOW}{'='*60}{NC}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
