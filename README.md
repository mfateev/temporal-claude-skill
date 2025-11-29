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
- `temporal.md` - Main skill file with core Temporal concepts
- `sdks/java/` - Java SDK resource with Spring Boot integration
- `sdks/python/` - *(Coming soon)* Python SDK resource
- `sdks/typescript/` - *(Coming soon)* TypeScript SDK resource
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
cp temporal.md ~/.claude/skills/
cp -r sdks ~/.claude/skills/

# Or if Claude Code is configured differently:
cp temporal.md .claude/skills/
cp -r sdks .claude/skills/
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
├── temporal.md                     # Main skill file
├── sdks/
│   └── java/                       # Java SDK resource
│       ├── java.md                 # Java SDK guide
│       ├── references/             # Additional references
│       │   ├── samples.md          # Samples catalog
│       │   └── spring-boot.md      # Spring Boot guide
│       └── test/                   # Integration tests
│           └── skill-integration/
├── build-skill-package.sh          # Build script
├── BUILD.md                        # Build documentation
└── README.md                       # This file
```

## Current SDK Resources

### Java SDK
**Status**: ✅ Complete
**Location**: `sdks/java/java.md`
**Features**:
- Complete Java SDK reference guide
- Maven/Gradle dependency management
- Spring Boot integration patterns
- Comprehensive samples catalog
- Testing strategies

### Python SDK
**Status**: 🚧 Planned
**Location**: `sdks/python/python.md` *(Coming soon)*

### TypeScript SDK
**Status**: 🚧 Planned
**Location**: `sdks/typescript/typescript.md` *(Coming soon)*

### Go SDK
**Status**: 🚧 Planned
**Location**: `sdks/go/go.md` *(Coming soon)*

### .NET SDK
**Status**: 🚧 Planned
**Location**: `sdks/dotnet/dotnet.md` *(Coming soon)*

### PHP SDK
**Status**: 🚧 Planned
**Location**: `sdks/php/php.md` *(Coming soon)*

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

The Java SDK includes a comprehensive integration test suite that validates the skill works end-to-end.

### Java SDK Integration Tests

Tests both standard SDK and Spring Boot integration paths:

```bash
# Set your Anthropic API key
export ANTHROPIC_API_KEY='your-api-key-here'

# Test standard Java SDK
cd sdks/java/test/skill-integration
./run-integration-test.sh

# Test Spring Boot integration
./run-spring-boot-test.sh
```

### What the Tests Do

The integration tests:
1. Install the skill (temporal.md + sdks/) in a test workspace
2. Use the Claude API to generate a complete Temporal application
3. Validate the generated code structure
4. Compile the project with Maven
5. Optionally run the application with Temporal server

This proves the skill works correctly and generates production-ready code.

See [sdks/java/test/skill-integration/README.md](sdks/java/test/skill-integration/README.md) for detailed test documentation.

## How It Works

### Skill Architecture

The skill uses a **unified architecture with SDK resources**:

1. **Main Skill**: `temporal.md` provides core Temporal concepts and SDK selection
2. **SDK Resources**: Language-specific guides in `sdks/<language>/<language>.md`
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
   mkdir -p sdks/newsdk
   ```

2. Create the SDK resource file:
   ```bash
   # File should be named <sdk>.md
   touch sdks/newsdk/newsdk.md
   ```

3. (Optional) Add SDK-specific references:
   ```bash
   mkdir -p sdks/newsdk/references
   ```

4. Update `temporal.md` to mention the new SDK

5. Build and test:
   ```bash
   ./build-skill-package.sh
   ```

### Modifying the Skill

1. Edit `temporal.md` for core Temporal concepts
2. Edit SDK resources in `sdks/<language>/` for language-specific content
3. Run tests to validate (for Java SDK):
   ```bash
   cd sdks/java/test/skill-integration
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
- Main skill: Edit `temporal.md`
- SDK-specific: Edit `sdks/<sdk>/<sdk>.md`
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
