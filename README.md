# Temporal Skills for Claude Code

A collection of Claude Code skills that provide expert guidance on working with [Temporal.io](https://temporal.io) across multiple SDK languages. These skills help Claude assist developers in building reliable, distributed applications with Temporal.

## What is this?

This repository contains **skill packages** for Claude Code - structured knowledge resources that teach Claude how to help developers work with Temporal. Instead of embedding code directly, the skills provide:

- Curated links to official Temporal documentation
- Language-specific SDK guidance and best practices
- Core concepts and API package information
- Framework integration guidance (e.g., Spring Boot for Java)
- Sample code references and patterns

## Available SDKs

### Java SDK
**Status**: ✅ Available
**Location**: `sdks/java/`
**Features**:
- Complete Java SDK reference guide
- Spring Boot integration guidance
- Comprehensive samples catalog
- Automated integration tests

## Quick Start

### For Claude Code Users

**Option 1: Use the pre-built package**

1. Download the latest skill package for your SDK from the releases
2. Extract the skill file:
   ```bash
   # For Java SDK
   unzip -j temporal-java-skill-latest.zip "*/temporal-java.md" -d ~/.claude/skills/
   ```
3. Start using Claude Code - it will automatically use the skill when you ask about Temporal

**Option 2: Copy directly (for development)**

```bash
# For Java SDK
cp sdks/java/temporal-java.md ~/.claude/skills/

# Or if Claude Code is configured differently:
cp sdks/java/temporal-java.md .claude/skills/
```

### For Claude Cloud Users

1. Build the skill package for your SDK:
   ```bash
   # Build Java SDK
   ./build-skill-package.sh --sdk java

   # Or build all SDKs
   ./build-skill-package.sh --all
   ```

2. Upload the generated package to Claude Cloud:
   ```
   dist/temporal-java-skill-latest.zip
   ```

3. Activate the skill in your Cloud project

## What the Skills Provide

When you ask Claude Code about Temporal with these skills installed, Claude can help you with:

- **Getting Started**: Set up new Temporal projects with proper dependency configuration
- **Core Concepts**: Understand workflows, activities, workers, and clients
- **Framework Integration**: Choose and implement framework-specific patterns (e.g., Spring Boot)
- **Advanced Patterns**: Implement signals, queries, sagas, child workflows, and more
- **Testing**: Write unit and integration tests for your workflows
- **Best Practices**: Follow Temporal's recommended patterns and avoid common pitfalls
- **Sample Discovery**: Find relevant examples from official samples repositories
- **Latest Versions**: Automatically fetch and use the newest SDK versions

## Example Usage

```
You: "Create a Temporal workflow that processes orders with retry logic"

Claude: [Uses the skill to fetch latest SDK version, generates proper workflow/activity
         interfaces, implements retry policies, creates worker and client code]
```

```
You: "I need to add a signal to pause my workflow"

Claude: [References the skill's signal documentation and relevant samples,
         generates proper signal method implementation with handling]
```

## Repository Structure

```
.
├── sdks/
│   └── java/                       # Java SDK skill
│       ├── temporal-java.md        # Main skill file
│       ├── references/             # Additional references
│       │   ├── samples.md          # Samples guide
│       │   └── spring-boot.md      # Spring Boot guide
│       └── test/                   # Integration tests
│           └── skill-integration/
├── build-skill-package.sh          # Build script for all SDKs
├── BUILD.md                        # Build system documentation
└── README.md                       # This file
```

## Building Skill Packages

The build system creates production-ready packages for Claude Cloud:

```bash
# List available SDKs
./build-skill-package.sh --list

# Build a specific SDK
./build-skill-package.sh --sdk java

# Build all SDKs
./build-skill-package.sh --all

# Fast build without URL validation
./build-skill-package.sh --sdk java --skip-url-check
```

**Output:**
```
dist/
├── temporal-java-skill-YYYYMMDD_HHMMSS.zip   # Timestamped package
├── temporal-java-skill-latest.zip             # Symlink to latest
└── build-report-java.txt                      # Build validation report
```

See [BUILD.md](BUILD.md) for detailed build documentation.

## Testing

Each SDK includes a comprehensive integration test suite that validates the skill works end-to-end.

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
1. Install the skill in a test workspace
2. Use the Claude API to generate a complete Temporal application
3. Validate the generated code structure
4. Compile the project with language-specific build tools
5. Optionally run the application with Temporal server

This proves the skill works correctly and generates production-ready code.

See SDK-specific test documentation for details:
- Java: [sdks/java/test/skill-integration/README.md](sdks/java/test/skill-integration/README.md)

## How It Works

### Skill Architecture

The skills use a **documentation-first approach**:

1. **Curated References**: Points to official Temporal docs rather than duplicating content
2. **Latest Versions**: Fetches current SDK versions from package repositories
3. **Sample Mapping**: Maps use cases to relevant examples in official samples repositories
4. **Decision Guidance**: Helps choose between different SDK approaches and frameworks
5. **Pattern Library**: Provides common patterns and best practices

### Framework Intelligence

Skills include smart framework detection and guidance. For example, the Java skill:

- Asks if you want Spring Boot integration before proceeding
- Uses appropriate dependencies and annotations for the chosen framework
- Generates framework-specific configuration files
- Leverages framework features like dependency injection

## Development

### Adding a New SDK

To add support for a new Temporal SDK:

1. Create a new directory under `sdks/`:
   ```bash
   mkdir -p sdks/python
   ```

2. Create the skill file following naming convention:
   ```bash
   touch sdks/python/temporal-python.md
   ```

3. Add references directory if needed:
   ```bash
   mkdir -p sdks/python/references
   ```

4. Create integration tests:
   ```bash
   mkdir -p sdks/python/test/skill-integration
   ```

5. Build and test:
   ```bash
   ./build-skill-package.sh --sdk python
   ```

### Modifying an Existing Skill

1. Edit the skill file (e.g., `sdks/java/temporal-java.md`)
2. Update references if needed
3. Run tests to validate:
   ```bash
   cd sdks/java/test/skill-integration
   ./run-integration-test.sh
   ```
4. Build the package:
   ```bash
   ./build-skill-package.sh --sdk java
   ```

### Best Practices

- **Keep URLs Current**: Validate all documentation links regularly
- **Test All Variations**: Run integration tests for all SDK variants
- **Version Awareness**: Ensure package repository links work correctly
- **Sample Updates**: Keep sample references in sync with official repositories
- **Cross-SDK Consistency**: Maintain similar structure across SDK skills

## Requirements

### For Using the Skills
- Claude Code installed and configured
- Basic understanding of Temporal concepts

### For Building
- Bash shell
- `curl` or `wget` for URL validation

### For Testing
- Anthropic API key (for automated tests)
- Python 3 with `anthropic` package
- SDK-specific requirements (e.g., Java 11+ and Maven for Java SDK)
- Temporal CLI (optional, for execution tests)

## Contributing

Contributions are welcome! Areas for improvement:

- **New SDKs**: Add skills for TypeScript, Python, Go, .NET, PHP
- **Additional Patterns**: Add more advanced Temporal patterns
- **Sample Mapping**: Improve use-case to sample mapping
- **Framework Examples**: Expand framework integration guidance
- **Test Coverage**: Add more test scenarios
- **Documentation**: Keep references current with Temporal updates

### Contribution Workflow

1. Fork the repository
2. Create a new branch for your changes
3. Make your changes to SDK skill files or add new SDKs
4. Run the integration tests
5. Build and validate the packages
6. Submit a pull request

## Support

### For Skill Content
- Edit SDK-specific files in `sdks/<sdk-name>/`
- Check official Temporal docs: https://docs.temporal.io/

### For Build Issues
- See [BUILD.md](BUILD.md)
- Check `dist/build-report-<sdk>.txt` for details

### For Test Issues
- See SDK-specific test documentation
- Review test workspace files for debugging

### For Temporal Questions
- Community forum: https://community.temporal.io/
- GitHub: https://github.com/temporalio/

## Resources

- **Temporal Documentation**: https://docs.temporal.io/
- **SDK Guides**: https://docs.temporal.io/develop/
- **Samples Repositories**: https://github.com/temporalio/samples-java (and others)
- **Community**: https://community.temporal.io/

## License

This skill package references official Temporal documentation and samples. Please refer to Temporal's licensing for their content.

## Version

Current version: 1.0.0

Check SDK-specific build reports after building for package details.
