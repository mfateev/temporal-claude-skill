# Temporal Skill for Claude Code

A comprehensive Claude Code skill for working with [Temporal.io](https://temporal.io) across multiple SDK languages. This skill helps Claude assist developers in building reliable, distributed applications with Temporal.

## What is this?

This repository contains a **single Temporal skill** for Claude Code with SDK-specific resources for each programming language. The skill provides:

- Unified Temporal concepts and best practices
- SDK-specific guidance as resources (Java, Python, TypeScript, Go, .NET, PHP)
- Curated links to official Temporal documentation
- Framework integration guidance (e.g., Spring Boot for Java)
- Sample code references and patterns

## Architecture

**Single Skill with SDK Resources:**
- `src/temporal.md` - Main skill file with core Temporal concepts
- `src/sdks/java/` - Java SDK resource with Spring Boot integration
- `src/sdks/python/` - Python SDK resource with FastAPI/Django integration
- `src/sdks/typescript/` - *(Coming soon)* TypeScript SDK resource
- ...and more

When you use the skill, Claude references the appropriate SDK resource based on your language.

## Quick Start

### For Claude Code Users

**Option 1: Use the pre-built package**

1. Download the latest skill package from the releases
2. Extract the contents:
   ```bash
   unzip temporal-skill-latest.zip
   cd temporal-skill
   ```
3. Copy to your Claude skills directory:
   ```bash
   cp temporal.md ~/.claude/skills/
   cp -r sdks ~/.claude/skills/
   ```
4. Start using Claude Code - reference the skill in your prompts

**Option 2: Copy directly (for development)**

```bash
# Copy the skill and SDK resources
cp src/temporal.md ~/.claude/skills/
cp -r src/sdks ~/.claude/skills/

# Or if Claude Code is configured differently:
cp src/temporal.md .claude/skills/
cp -r src/sdks .claude/skills/
```

### For Claude Cloud Users

1. Build the skill package:
   ```bash
   ./build-skill-package.sh
   ```

2. Upload the generated package to Claude Cloud:
   ```
   dist/temporal-skill-latest.zip
   ```

3. Activate the skill in your Cloud project

## Usage Examples

```
You: "Create a Temporal workflow in Java that processes orders with retry logic"

Claude: [Uses the temporal skill to understand the request, references the Java SDK
         resource, fetches latest SDK version, generates proper workflow/activity
         interfaces, implements retry policies, creates worker and client code]
```

```
You: "How do I implement signals in Temporal?"

Claude: [References temporal.md for signal concepts, then provides language-specific
         examples from your SDK resource]
```

```
You: "Set up a new Temporal project with Spring Boot"

Claude: [References Java SDK resource's Spring Boot integration guide, provides
         dependencies, configuration, and project structure]
```

## What the Skill Provides

When you ask Claude about Temporal with this skill installed, Claude can help you with:

- **SDK Selection**: Help you choose the right SDK for your project
- **Getting Started**: Set up new Temporal projects with proper dependency configuration
- **Core Concepts**: Understand workflows, activities, workers, and clients
- **Framework Integration**: Implement framework-specific patterns (Spring Boot, etc.)
- **Advanced Patterns**: Implement signals, queries, sagas, child workflows, and more
- **Testing**: Write unit and integration tests for your workflows
- **Best Practices**: Follow Temporal's recommended patterns and avoid common pitfalls
- **Sample Discovery**: Find relevant examples from official samples repositories
- **Latest Versions**: Automatically fetch and use the newest SDK versions

## Repository Structure

```
.
├── src/
│   ├── temporal.md              # Main skill file
│   └── sdks/
│       ├── java/                # Java SDK resource
│       │   ├── java.md          # Java SDK guide
│       │   └── references/      # Additional references
│       │       ├── samples.md   # Samples catalog
│       │       └── spring-boot.md # Spring Boot guide
│       └── python/              # Python SDK resource
│           ├── python.md        # Python SDK guide
│           └── references/      # Additional references
│               ├── samples.md   # Samples catalog
│               └── framework-integration.md # FastAPI/Django/Flask
├── test/
│   ├── java/
│   │   └── skill-integration/   # Java integration tests
│   └── python/
│       └── skill-integration/   # Python integration tests
├── build-skill-package.sh       # Build script
├── BUILD.md                     # Build documentation
└── README.md                    # This file
```

## Current SDK Resources

### Java SDK
**Status**: ✅ Complete
**Location**: `src/sdks/java/java.md`
**Features**:
- Complete Java SDK reference guide
- Maven/Gradle dependency management
- Spring Boot integration patterns
- Comprehensive samples catalog
- Testing strategies

### Python SDK
**Status**: ✅ Complete
**Location**: `src/sdks/python/python.md`
**Features**:
- Complete Python SDK reference guide
- Poetry/pip dependency management
- FastAPI/Django/Flask integration patterns
- Comprehensive samples catalog (42+ samples)
- Testing strategies with pytest
- Async/await patterns and best practices

### TypeScript SDK
**Status**: 🚧 Planned
**Location**: `src/sdks/typescript/typescript.md` *(Coming soon)*

### Go SDK
**Status**: 🚧 Planned
**Location**: `src/sdks/go/go.md` *(Coming soon)*

### .NET SDK
**Status**: 🚧 Planned
**Location**: `src/sdks/dotnet/dotnet.md` *(Coming soon)*

### PHP SDK
**Status**: 🚧 Planned
**Location**: `src/sdks/php/php.md` *(Coming soon)*

## Building the Skill Package

The build system creates a single production-ready package:

```bash
# Build the skill package
./build-skill-package.sh

# Build without URL validation (faster)
./build-skill-package.sh --skip-url-check
```

**Output:**
```
dist/
├── temporal-skill-YYYYMMDD_HHMMSS.zip  # Timestamped package
├── temporal-skill-latest.zip            # Symlink to latest
└── build-report.txt                     # Build validation report
```

See [BUILD.md](BUILD.md) for detailed build documentation.

## Testing

Integration tests validate the skills work end-to-end in the actual Claude Code workflow.

### Prerequisites

- **claude-code CLI**: `npm install -g @anthropic-ai/claude-code`
- **Anthropic API Key**: Set as `ANTHROPIC_API_KEY` environment variable

### Unified Test Runner

The repository provides a unified test runner at the root that supports all SDK implementations:

```bash
# Set your Anthropic API key
export ANTHROPIC_API_KEY='your-api-key-here'

# Test Java SDK (standard)
./test-skill.sh Java

# Test Java SDK (Spring Boot variant)
./test-skill.sh Java --variant spring-boot

# Test Python SDK
./test-skill.sh Python

# Validation only (skip execution tests)
./test-skill.sh Java --skip-execution
./test-skill.sh Python --skip-execution
```

Run `./test-skill.sh --help` for all available options and supported SDKs.

### Testing All SDKs

To test all SDKs sequentially:

```bash
export ANTHROPIC_API_KEY='your-api-key-here'

# Run all tests
./test-skill.sh Java
./test-skill.sh Java --variant spring-boot
./test-skill.sh Python
```

### Direct SDK Test Scripts

SDK-specific test scripts can still be run directly if needed:

```bash
# Java standard
cd test/java/skill-integration && ./run-integration-test.sh

# Java Spring Boot
cd test/java/skill-integration && ./run-spring-boot-test.sh

# Python
cd test/python/skill-integration && ./run-integration-test.sh
```

### What the Tests Do

The integration tests:
1. Install the skill (temporal.md + sdks/) in a test workspace
2. Invoke claude-code CLI with a test prompt that triggers the skill
3. claude-code auto-loads the skill and generates a complete application
4. Validate the generated code structure and compilation
5. Optionally run the application with Temporal server

This proves the skill works correctly in the actual Claude Code user workflow and generates production-ready code.

See test READMEs for detailed documentation:
- [test/java/skill-integration/README.md](test/java/skill-integration/README.md)
- [test/python/skill-integration/README.md](test/python/skill-integration/README.md)

## How It Works

### Skill Architecture

The skill uses a **unified architecture with SDK resources**:

1. **Main Skill**: `src/temporal.md` provides core Temporal concepts and SDK selection
2. **SDK Resources**: Language-specific guides in `src/sdks/<language>/<language>.md`
3. **Documentation-First**: Points to official Temporal docs rather than duplicating content
4. **Latest Versions**: Fetches current SDK versions from package repositories
5. **Sample Mapping**: Maps use cases to relevant examples in official samples repositories
6. **Pattern Library**: Provides common patterns and best practices

### Framework Intelligence

SDK resources include smart framework detection and guidance. For example, the Java SDK resource:

- Asks if you want Spring Boot integration before proceeding
- Uses appropriate dependencies and annotations for the chosen framework
- Generates framework-specific configuration files
- Leverages framework features like dependency injection

## Development

### Adding a New SDK Resource

To add support for a new Temporal SDK:

1. Create SDK directory:
   ```bash
   mkdir -p src/sdks/newsdk
   ```

2. Create the SDK resource file:
   ```bash
   # File should be named <sdk>.md
   touch src/sdks/newsdk/newsdk.md
   ```

3. (Optional) Add SDK-specific references:
   ```bash
   mkdir -p src/sdks/newsdk/references
   ```

4. Update `src/temporal.md` to mention the new SDK

5. Build and test:
   ```bash
   ./build-skill-package.sh
   ```

### Modifying the Skill

1. Edit `src/temporal.md` for core Temporal concepts
2. Edit SDK resources in `src/sdks/<language>/` for language-specific content
3. Run tests to validate (for Java SDK):
   ```bash
   cd test/java/skill-integration
   ./run-integration-test.sh
   ```
4. Build the package:
   ```bash
   ./build-skill-package.sh
   ```

### Best Practices

- **Keep URLs Current**: Validate all documentation links regularly
- **Test SDK Variations**: Run integration tests for SDK-specific features
- **Version Awareness**: Ensure package repository links work correctly
- **Sample Updates**: Keep sample references in sync with official repositories
- **Cross-SDK Consistency**: Maintain similar structure across SDK resources

## Requirements

### For Using the Skill
- Claude Code installed and configured
- Basic understanding of Temporal concepts

### For Building
- Bash shell
- `curl` or `wget` for URL validation

### For Testing (Java SDK)
- Anthropic API key (for automated tests)
- Python 3 with `anthropic` package
- Java 11+ and Maven
- Temporal CLI (optional, for execution tests)

## Contributing

Contributions are welcome! Areas for improvement:

- **New SDK Resources**: Add resources for Python, TypeScript, Go, .NET, PHP
- **Additional Patterns**: Add more advanced Temporal patterns to SDK resources
- **Sample Mapping**: Improve use-case to sample mapping
- **Framework Examples**: Expand framework integration guidance
- **Test Coverage**: Add more test scenarios for existing SDKs
- **Documentation**: Keep references current with Temporal updates

### Contribution Workflow

1. Fork the repository
2. Create a new branch for your changes
3. Add/modify skill content or SDK resources
4. Run the integration tests (if applicable)
5. Build and validate the package
6. Submit a pull request

## Support

### For Skill Content
- Main skill: Edit `src/temporal.md`
- SDK-specific: Edit `src/sdks/<sdk>/<sdk>.md`
- Check official Temporal docs: https://docs.temporal.io/

### For Build Issues
- See [BUILD.md](BUILD.md)
- Check `dist/build-report.txt` for details

### For Test Issues
- See SDK-specific test documentation
- Review test workspace files for debugging

### For Temporal Questions
- Community forum: https://community.temporal.io/
- GitHub: https://github.com/temporalio/
- Slack: https://temporal.io/slack

## Resources

- **Temporal Documentation**: https://docs.temporal.io/
- **SDK Guides**: https://docs.temporal.io/develop/
- **Samples Repositories**: https://github.com/temporalio/samples-java (and others)
- **Community**: https://community.temporal.io/
- **Temporal Learn**: https://learn.temporal.io/

## License

This skill package references official Temporal documentation and samples. Please refer to Temporal's licensing for their content.

## Version

Current version: 1.0.0

Check `dist/build-report.txt` after building for package details.
