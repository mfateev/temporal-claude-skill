# Feature: Python SDK Resource for Temporal Skill

## Feature Description
Add a comprehensive Python SDK resource to the Temporal skill package, mirroring the structure and depth of the existing Java SDK resource. This resource will provide Claude with detailed guidance on working with Temporal using the Python SDK, including dependency management, common frameworks (e.g., FastAPI, Django), testing patterns, and a curated samples catalog.

The Python SDK resource will enable Claude to:
- Generate Python-specific Temporal workflows and activities
- Provide accurate dependency information using Poetry, pip, or other Python package managers
- Guide framework integrations for popular Python frameworks
- Reference the official Python SDK samples repository
- Fetch the latest Python SDK version from PyPI
- Provide Python-specific testing patterns and best practices

## User Story
As a Python developer using Claude Code with the Temporal skill
I want Claude to provide Python-specific guidance and code examples
So that I can build reliable Temporal applications in Python with the same level of support available for Java developers

## Problem Statement
Currently, the Temporal skill only has a complete resource for Java SDK (✅ Complete). The Python SDK is marked as "🚧 Planned" in the main skill file. Python developers using Claude Code cannot get Python-specific:
- Code examples and patterns
- Dependency management guidance (Poetry, pip, requirements.txt)
- Framework integration patterns (FastAPI, Django, Flask)
- Samples catalog with categorized examples
- Testing strategies specific to Python's async patterns
- Latest version fetching from PyPI

This creates an inconsistent experience where Java developers have comprehensive support while Python developers only get generic Temporal concepts.

## Solution Statement
Create a complete Python SDK resource following the established pattern:

1. **Main Python SDK file** (`src/sdks/python/python.md`) - Similar to `java.md`, this will be the primary reference containing:
   - Official documentation links
   - PyPI package information and version fetching
   - Core concepts with Python-specific code patterns
   - Key API packages and classes
   - Configuration options
   - Advanced patterns (child workflows, saga, signals/queries, etc.)
   - Testing framework guidance
   - Best practices for Python development

2. **References subdirectory** (`src/sdks/python/references/`) - Following the Java pattern with:
   - **samples.md** - Comprehensive catalog of Python samples from official repository
   - **framework-integration.md** - Guidance for FastAPI, Django, Flask integrations
   - *(Optional)* **async-patterns.md** - Python-specific async/await patterns

3. **Integration test suite** (`test/python/skill-integration/`) - Automated tests to validate:
   - Skill generates working Python code
   - Generated code follows Python best practices
   - Dependencies are correctly specified
   - Code can be executed with Temporal server

4. **Update main skill** - Update `src/temporal.md` to mark Python SDK as complete and reference the new resource

## Relevant Files

### Existing Files (Templates/References)
- **src/temporal.md** (line 40-45) - Main skill file, currently marks Python as "🚧 Planned". Need to update to "✅ Complete" and ensure proper documentation.
  - References Python SDK location
  - Contains SDK selection guidance
  - Lists Python as best for "Data pipelines, ML workflows, async operations"

- **src/sdks/java/java.md** - Template for structure and content depth. This file provides:
  - Pattern for official documentation links
  - Maven Central coordinates pattern (adapt to PyPI)
  - Framework integration section (adapt for Python frameworks)
  - Core concepts section structure
  - API packages overview
  - Configuration options layout
  - Advanced patterns organization
  - Testing section structure
  - Best practices format
  - Project structure recommendations

- **src/sdks/java/references/spring-boot.md** - Template for framework integration reference. Shows:
  - When to use framework integration
  - Detailed setup instructions
  - Configuration patterns
  - Annotations/decorators patterns
  - Project structure
  - Testing with framework
  - Best practices and troubleshooting

- **src/sdks/java/references/samples.md** - Template for samples catalog. Demonstrates:
  - Categorization by use case
  - Quick links table format
  - Detailed sample descriptions with paths
  - "What it shows" and "Use when" patterns
  - Scenario-based samples organization
  - Advanced features catalog
  - Common patterns across samples

- **build-skill-package.sh** (line 100) - Build script metadata generation
  - Currently only lists Java in "sdks" array
  - Needs update to include "python" when Python SDK is added
  - Automatically discovers SDKs in src/sdks/ directory

- **README.md** (line 141-160) - Repository README
  - Lists SDK statuses (Python currently shows "🚧 Planned")
  - Needs update to show "✅ Complete" for Python
  - Update features list to include Python SDK

- **test/java/skill-integration/** - Testing pattern reference
  - Structure for integration tests
  - Python tests should follow similar pattern
  - Validation scripts, automation scripts

### New Files

#### Core Python SDK Files
- **src/sdks/python/python.md** - Main Python SDK resource (to be created)
  - Primary reference file Claude will use for Python development
  - ~250-300 lines similar to java.md length
  - Must include PyPI links, async patterns, Python-specific APIs

#### Python References
- **src/sdks/python/references/samples.md** - Python samples catalog (to be created)
  - Comprehensive mapping of official Python samples
  - Repository: https://github.com/temporalio/samples-python
  - Categorize samples by: hello samples, scenario samples, advanced features
  - Include async/await examples

- **src/sdks/python/references/framework-integration.md** - Framework integration guide (to be created)
  - FastAPI integration (most common for async Python)
  - Django integration patterns
  - Flask integration patterns
  - Dependency injection patterns in Python
  - Framework-specific configuration

#### Testing Infrastructure
- **test/python/skill-integration/README.md** - Test documentation (to be created)
  - Similar to Java test README
  - Python-specific setup instructions
  - How to run tests with pytest

- **test/python/skill-integration/run-integration-test.sh** - Main test runner (to be created)
  - Bash script to run full integration test
  - Sets up test environment
  - Calls Claude API to generate Python code
  - Validates generated code
  - Runs the application

- **test/python/skill-integration/automate_test.py** - Test automation script (to be created)
  - Python script using anthropic SDK
  - Generates Temporal application using skill
  - Validates code structure and dependencies

- **test/python/skill-integration/setup-test-workspace.sh** - Workspace setup (to be created)
  - Creates test environment
  - Installs skill files
  - Prepares for code generation

- **test/python/skill-integration/test-prompt.txt** - Test prompt template (to be created)
  - Prompt used to test skill
  - Should generate complete Temporal application

## Implementation Plan

### Phase 1: Foundation
Research and document Python SDK specifics to ensure accuracy:

1. **Research Python SDK documentation** - Review official Temporal Python SDK docs
   - Understand Python-specific patterns (async/await, decorators)
   - Document key differences from Java SDK
   - Identify Python-specific best practices

2. **Analyze Python samples repository** - Study https://github.com/temporalio/samples-python
   - Catalog all samples with descriptions
   - Identify common patterns
   - Note Python-specific examples (async, type hints)
   - Document framework integration examples

3. **Research PyPI package structure** - Understand Python dependency management
   - PyPI package location and naming
   - Version fetching mechanisms
   - Poetry vs pip vs requirements.txt patterns
   - Optional dependencies for frameworks

4. **Research framework integrations** - Investigate popular Python frameworks with Temporal
   - FastAPI integration patterns (most common)
   - Django integration approaches
   - Flask usage patterns
   - Dependency injection in Python context

### Phase 2: Core Implementation
Create the Python SDK resource files following the established pattern:

1. **Create main Python SDK resource** (`src/sdks/python/python.md`)
   - Follow java.md structure closely
   - Include official documentation links
   - Document PyPI package information
   - Provide async/await code examples
   - Cover decorators (@workflow.defn, @activity.defn)
   - Include type hints examples
   - Document testing with pytest
   - Add Python-specific best practices

2. **Create samples catalog** (`src/sdks/python/references/samples.md`)
   - Follow java/references/samples.md structure
   - Catalog all Python samples from official repo
   - Organize by: hello samples, scenario samples, advanced features
   - Include quick links table
   - Add "What it shows" and "Use when" for each sample
   - Document async patterns in samples

3. **Create framework integration guide** (`src/sdks/python/references/framework-integration.md`)
   - Follow spring-boot.md structure
   - Cover FastAPI integration (most important)
   - Include Django patterns
   - Add Flask examples
   - Document dependency injection approaches
   - Include configuration examples for each framework

### Phase 3: Integration
Integrate Python SDK with existing skill infrastructure:

1. **Update main skill file** (`src/temporal.md`)
   - Change Python status from "🚧 Planned" to "✅ Complete"
   - Update description with included features
   - Ensure SDK selection logic includes Python
   - Add usage examples for Python

2. **Update build script** (`build-skill-package.sh`)
   - Add "python" to SDK list in metadata (line 100)
   - Verify Python SDK is included in package
   - Test build process includes all Python files

3. **Update repository README** (`README.md`)
   - Mark Python SDK as "✅ Complete"
   - Update features list
   - Add Python to "What's Included" section
   - Update SDK Resources section with Python details

4. **Create integration test suite** (`test/python/skill-integration/`)
   - Create test structure similar to Java
   - Implement automated test scripts
   - Add validation for generated code
   - Include README with test instructions

## Step by Step Tasks

### Step 1: Research and Preparation
- Read official Temporal Python SDK documentation at https://docs.temporal.io/develop/python
- Browse Python SDK API reference to understand key classes and decorators
- Study Python samples repository structure at https://github.com/temporalio/samples-python
- Document Python-specific patterns (async/await, type hints, decorators)
- Research PyPI package: https://pypi.org/project/temporalio/
- Identify latest version fetching mechanism for Python
- Review framework integration patterns (FastAPI, Django, Flask)

### Step 2: Create Python SDK Directory Structure
- Create directory: `mkdir -p src/sdks/python/references`
- Verify directory structure matches Java SDK pattern
- Create placeholder files to establish structure

### Step 3: Write Main Python SDK Resource
- Create `src/sdks/python/python.md`
- Follow `src/sdks/java/java.md` as structural template
- Include sections:
  - Official Documentation links
  - PyPI package information and version fetching
  - Core Concepts (workflows, activities, workers, clients) with Python examples
  - Key API packages (temporalio.workflow, temporalio.activity, etc.)
  - Configuration options (WorkflowOptions, ActivityOptions, etc.)
  - Advanced patterns (child workflows, saga, signals/queries, async completion)
  - Testing with pytest
  - Project structure recommendations
  - Best practices for Python/async
- Use Python code examples with async/await, type hints, decorators
- Link to official docs for detailed information (don't duplicate)
- Reference framework integration guide and samples catalog

### Step 4: Create Python Samples Catalog
- Create `src/sdks/python/references/samples.md`
- Follow `src/sdks/java/references/samples.md` structure
- Clone or browse https://github.com/temporalio/samples-python to analyze samples
- Create quick links table mapping use cases to samples
- Categorize samples:
  - Hello samples (getting started)
  - Scenario-based samples (real-world patterns)
  - Advanced features (interceptors, encryption, etc.)
  - Framework integration samples
- For each sample provide:
  - Path in repository
  - "What it shows" description
  - "Use when" guidance
  - Key concepts demonstrated
- Include common patterns section with Python code examples
- Add links to official repository and documentation

### Step 5: Create Framework Integration Guide
- Create `src/sdks/python/references/framework-integration.md`
- Follow `src/sdks/java/references/spring-boot.md` structure
- Include sections for:
  - FastAPI integration (most common for async Python)
    - When to use
    - Dependencies and setup
    - Code examples with FastAPI decorators
    - Project structure
    - Testing with FastAPI
  - Django integration
    - When to use
    - Setup instructions
    - Integration patterns
    - Configuration
  - Flask integration (brief)
    - When to use
    - Basic patterns
- Include dependency injection patterns in Python
- Add configuration examples for each framework
- Provide troubleshooting guidance

### Step 6: Update Main Skill File
- Edit `src/temporal.md`
- Locate Python SDK section (around line 40-45)
- Change status from "🚧 Planned" to "✅ Complete"
- Update description to list included features:
  - Complete SDK reference guide
  - Poetry/pip dependency management
  - FastAPI/Django/Flask integration patterns
  - Comprehensive samples catalog
  - Testing strategies with pytest
- Update any SDK selection guidance to properly include Python

### Step 7: Update Build Script Metadata
- Edit `build-skill-package.sh`
- Find `extract_metadata()` function around line 100
- Update `"sdks": ["java"]` to `"sdks": ["java", "python"]`
- This ensures metadata correctly reflects both SDKs

### Step 8: Update Repository README
- Edit `README.md`
- Update Python SDK status section (around line 141-144):
  - Change Status from "🚧 Planned" to "✅ Complete"
  - Update Location to show actual file path
  - List Features (similar to Java section)
- Update "What the Skill Provides" section if needed
- Ensure examples mention Python

### Step 9: Create Python Test Infrastructure
- Create directory: `mkdir -p test/python/skill-integration`
- Create `test/python/skill-integration/README.md`
  - Document test purpose and setup
  - Include prerequisites (Python, Anthropic API key, Temporal CLI)
  - Explain how to run tests
  - Follow pattern from `test/java/skill-integration/README.md`
- Create `test/python/skill-integration/.gitignore`
  - Ignore test workspaces
  - Ignore generated code
  - Ignore Python cache files (__pycache__, *.pyc)
- Create `test/python/skill-integration/setup-test-workspace.sh`
  - Sets up test environment
  - Copies skill files to test workspace
  - Prepares for code generation
- Create `test/python/skill-integration/test-prompt.txt`
  - Define prompt for generating test application
  - Should ask for complete Temporal app with workflow, activity, worker, client
- Create `test/python/skill-integration/automate_test.py`
  - Python script using anthropic package
  - Calls Claude API with skill and prompt
  - Generates Temporal application code
  - Validates code structure
  - Validates dependencies (pyproject.toml or requirements.txt)
- Create `test/python/skill-integration/run-integration-test.sh`
  - Main test runner bash script
  - Runs setup script
  - Runs automate_test.py
  - Validates generated code compiles/runs
  - Reports success/failure

### Step 10: Build and Validate Package
- Run build script: `./build-skill-package.sh`
- Verify Python SDK files are included in package
- Check build-report.txt shows Python in SDK resources
- Verify package structure includes:
  - temporal.md
  - sdks/python/python.md
  - sdks/python/references/samples.md
  - sdks/python/references/framework-integration.md
- Ensure no build errors

### Step 11: Test the Python SDK Integration
- Run integration test: `cd test/python/skill-integration && ./run-integration-test.sh`
- Verify test generates working Python code
- Check generated code follows Python best practices
- Validate dependencies are correct
- Confirm code structure matches expectations
- Test with Temporal server if available

### Step 12: Manual Testing and Validation
- Extract built package: `unzip dist/temporal-skill-latest.zip`
- Copy to test Claude Code installation
- Ask Claude to create a Python Temporal workflow
- Verify Claude references the Python SDK resource
- Check generated code quality and accuracy
- Test with various prompts (FastAPI integration, signals, testing, etc.)
- Validate framework integration guidance works

### Step 13: Run Final Validation Commands
- Execute all validation commands listed below
- Fix any issues discovered
- Re-run validation until all pass

## Testing Strategy

### Unit Tests
Since this is a documentation/skill resource, traditional unit tests don't apply. Instead:
- **Content validation**: Verify all markdown files are well-formed
- **Link validation**: Ensure all URLs are accessible (build script does this)
- **Structure validation**: Confirm directory structure matches pattern
- **Metadata validation**: Check skill-metadata.json is correct

### Integration Tests
Critical for validating the skill actually works:
- **Code generation test**: Claude generates working Python Temporal application
- **Dependency test**: Generated code has correct dependencies (PyPI packages)
- **Compilation test**: Generated Python code has no syntax errors
- **Execution test**: Generated application runs with Temporal server
- **Framework test**: Can generate FastAPI/Django integration code
- **Testing patterns test**: Generated code includes proper pytest tests

### Edge Cases
- **Version fetching**: Verify skill can fetch latest Python SDK version from PyPI
- **Multiple frameworks**: Test both FastAPI and Django integration paths
- **Async patterns**: Ensure async/await code is generated correctly
- **Type hints**: Verify type hints are included appropriately
- **Error handling**: Test that retry policies and error handling are Python-idiomatic
- **Virtual environments**: Test that Poetry/pip/venv patterns are recommended

## Acceptance Criteria
1. ✅ **Python SDK resource file created** - `src/sdks/python/python.md` exists with comprehensive content
2. ✅ **Samples catalog created** - `src/sdks/python/references/samples.md` catalogs all official Python samples
3. ✅ **Framework guide created** - `src/sdks/python/references/framework-integration.md` covers FastAPI, Django, Flask
4. ✅ **Main skill updated** - `src/temporal.md` marks Python as "✅ Complete"
5. ✅ **Build script updated** - Python included in SDK metadata
6. ✅ **README updated** - Python SDK marked as complete with features listed
7. ✅ **Integration tests created** - Test suite in `test/python/skill-integration/` validates skill
8. ✅ **Build succeeds** - `./build-skill-package.sh` completes without errors
9. ✅ **Package includes Python** - Zip contains all Python SDK files
10. ✅ **Integration test passes** - Generated Python code compiles and executes
11. ✅ **Manual testing successful** - Claude generates correct Python code when asked
12. ✅ **All URLs valid** - All links in Python SDK files are accessible
13. ✅ **Follows patterns** - Structure and content depth match Java SDK resource
14. ✅ **Python-specific** - Examples use async/await, type hints, decorators appropriately
15. ✅ **Framework coverage** - FastAPI integration well-documented with examples

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

```bash
# Verify directory structure created
ls -R src/sdks/python
# Expected: python.md and references/ directory with samples.md and framework-integration.md

# Verify files are not empty
wc -l src/sdks/python/python.md src/sdks/python/references/*.md
# Expected: All files have substantial content (python.md ~250-300 lines, references ~200+ lines each)

# Verify main skill updated
grep -A 5 "### Python SDK" src/temporal.md
# Expected: Shows "✅ Complete" status with features listed

# Build the package
./build-skill-package.sh
# Expected: Build completes successfully with no errors

# Verify package includes Python SDK
unzip -l dist/temporal-skill-latest.zip | grep python
# Expected: Lists sdks/python/python.md and reference files

# Check build report shows Python
cat dist/build-report.txt | grep -A 10 "SDK Resources"
# Expected: Lists both java and python as SDK resources

# Verify metadata includes Python
cat build/temporal-skill/skill-metadata.json | grep -A 2 '"sdks"'
# Expected: Shows ["java", "python"]

# Run Python integration test
cd test/python/skill-integration
./run-integration-test.sh
# Expected: Test passes, generates working Python code

# Validate generated Python code has correct structure
ls test/python/skill-integration/test-workspace/
# Expected: Shows Python project with workflows/, activities/, worker, client files

# Check generated dependencies
cat test/python/skill-integration/test-workspace/pyproject.toml || cat test/python/skill-integration/test-workspace/requirements.txt
# Expected: Shows temporalio package with appropriate version

# Validate Python code syntax
python3 -m py_compile test/python/skill-integration/test-workspace/**/*.py
# Expected: No syntax errors

# Validate all URLs in Python SDK files
grep -oE 'https?://[^)[:space:]]+' src/sdks/python/*.md src/sdks/python/references/*.md | sort -u | while read url; do curl -I -L -s -o /dev/null -w "%{http_code} $url\n" "$url"; done
# Expected: All URLs return 200-399 status codes

# Test package extraction and structure
cd /tmp && unzip -q ~/ai/skills/dist/temporal-skill-latest.zip && cd temporal-skill && ls -R
# Expected: Shows proper structure with temporal.md, sdks/java/, sdks/python/

# Return to project directory
cd ~/ai/skills
```

## Notes

### Key Success Factors
1. **Follow Java pattern closely** - The Java SDK resource is proven to work well. Mirror its structure, depth, and organization for consistency.
2. **Python-specific examples** - All code examples must use Python idioms: async/await, type hints, decorators (@workflow.defn, @activity.defn), proper imports.
3. **Link to official docs** - Don't duplicate documentation. Point to official Temporal docs and provide context on how to use them.
4. **Framework integration** - FastAPI is the most important for Python/Temporal integration. Ensure comprehensive coverage.
5. **Testing patterns** - Python testing with pytest has different patterns than Java JUnit. Document clearly.
6. **Package management** - Cover Poetry (modern), pip (traditional), and requirements.txt patterns. Show how to fetch latest version from PyPI.

### Future Considerations
- **Advanced async patterns** - Consider adding a dedicated reference for complex async/await scenarios
- **Type checking** - Document mypy usage for type checking Temporal workflows
- **Data science integration** - Python is popular for ML/data pipelines. Consider adding examples for pandas, numpy integration
- **Deployment patterns** - Docker, Kubernetes deployment for Python Temporal workers
- **.NET SDK** - After Python, follow the same pattern for .NET, TypeScript, Go, PHP SDKs

### Technical Considerations
- Python samples repository structure may differ from Java - adapt catalog accordingly
- Python uses decorators instead of annotations - adjust terminology
- Async/await is fundamental to Python SDK - emphasize throughout
- Virtual environments are Python-specific - document in setup sections
- Poetry vs pip vs conda - support multiple package managers

### Dependencies to Research
- **temporalio** - Main PyPI package
- **temporalio[opentelemetry]** - Optional for tracing
- **pytest-asyncio** - For testing async workflows
- Framework-specific packages (fastapi, django, flask)

### Related Documentation
- Official Python SDK: https://docs.temporal.io/develop/python
- Python SDK API: https://python.temporal.io/
- Python samples: https://github.com/temporalio/samples-python
- PyPI package: https://pypi.org/project/temporalio/
