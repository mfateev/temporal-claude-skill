# Temporal Java SDK Skill for Claude Code

A Claude Code skill that provides expert guidance on working with [Temporal.io](https://temporal.io) using the Java SDK. This skill helps Claude assist developers in building reliable, distributed applications with Temporal.

## What is this?

This repository contains a **skill package** for Claude Code - a structured knowledge resource that teaches Claude how to help developers work with the Temporal Java SDK. Instead of embedding code directly, the skill provides:

- Curated links to official Temporal documentation
- Maven Central coordinates for dependencies
- Core concepts and API package information
- Spring Boot integration guidance
- Best practices and common patterns
- Sample code references

## Quick Start

### For Claude Code Users

**Option 1: Use the pre-built package**

1. Download the latest skill package from the releases
2. Extract the skill file:
   ```bash
   unzip -j temporal-java-skill-latest.zip "*/temporal-java.md" -d ~/.claude/skills/
   ```
3. Start using Claude Code - it will automatically use the skill when you ask about Temporal

**Option 2: Copy directly (for development)**

```bash
# Copy the skill file to your Claude Code skills directory
cp src/temporal-java.md ~/.claude/skills/

# Or if Claude Code is configured differently:
cp src/temporal-java.md .claude/skills/
```

### For Claude Cloud Users

1. Build the skill package:
   ```bash
   ./build-skill-package.sh
   ```

2. Upload the generated package to Claude Cloud:
   ```
   dist/temporal-java-skill-latest.zip
   ```

3. Activate the skill in your Cloud project

## What the Skill Provides

When you ask Claude Code about Temporal with this skill installed, Claude can help you with:

- **Getting Started**: Set up new Temporal projects with proper Maven/Gradle configuration
- **Core Concepts**: Understand workflows, activities, workers, and clients
- **Spring Boot Integration**: Choose between standard SDK or Spring Boot starter based on your needs
- **Advanced Patterns**: Implement signals, queries, sagas, child workflows, and more
- **Testing**: Write unit and integration tests for your workflows
- **Best Practices**: Follow Temporal's recommended patterns and avoid common pitfalls
- **Sample Discovery**: Find relevant examples from the official samples repository
- **Latest Versions**: Automatically fetch and use the newest SDK versions

## Example Usage

```
You: "Create a Temporal workflow that processes orders with retry logic"

Claude: [Uses the skill to fetch latest SDK version, generates proper workflow/activity
         interfaces, implements retry policies, creates worker and client code]
```

```
You: "I need to add a signal to pause my workflow"

Claude: [References the skill's signal documentation and HelloSignal.java sample,
         generates @SignalMethod implementation with proper signal handling]
```

## Project Structure

```
.
├── src/
│   ├── temporal-java.md           # Main skill file
│   └── references/
│       ├── samples.md              # Categorized sample guide
│       └── spring-boot.md          # Spring Boot integration details
├── test/
│   └── skill-integration/          # Integration test suite
│       ├── run-integration-test.sh # Run standard SDK test
│       ├── run-spring-boot-test.sh # Run Spring Boot test
│       └── README.md               # Test documentation
├── build-skill-package.sh          # Build distributable package
├── BUILD.md                        # Build system documentation
└── README.md                       # This file
```

## Building the Skill Package

The build system creates production-ready packages for Claude Cloud:

```bash
# Full build with URL validation
./build-skill-package.sh

# Fast build without URL checks
./build-skill-package.sh --skip-url-check
```

**Output:**
```
dist/
├── temporal-java-skill-YYYYMMDD_HHMMSS.zip  # Timestamped package
├── temporal-java-skill-latest.zip            # Symlink to latest
└── build-report.txt                          # Build validation report
```

See [BUILD.md](BUILD.md) for detailed build documentation.

## Testing

This project includes a comprehensive integration test suite that validates the skill works end-to-end.

### Automated Integration Test

Tests the standard Temporal Java SDK path:

```bash
# Set your Anthropic API key
export ANTHROPIC_API_KEY='your-api-key-here'

# Run the test
cd test/skill-integration
./run-integration-test.sh
```

### Spring Boot Integration Test

Tests the Spring Boot integration path:

```bash
export ANTHROPIC_API_KEY='your-api-key-here'
cd test/skill-integration
./run-spring-boot-test.sh
```

### What the Tests Do

The integration tests:
1. Install the skill in a test workspace
2. Use the Claude API to generate a complete Temporal application
3. Validate the generated code structure
4. Compile the project with Maven
5. Optionally run the application with Temporal server

This proves the skill works correctly and generates production-ready code.

See [test/skill-integration/README.md](test/skill-integration/README.md) for detailed test documentation.

## How It Works

### Skill Architecture

The skill uses a **documentation-first approach**:

1. **Curated References**: Points to official Temporal docs rather than duplicating content
2. **Latest Versions**: Fetches current SDK versions from Maven Central
3. **Sample Mapping**: Maps use cases to relevant examples in the samples repository
4. **Decision Guidance**: Helps choose between standard SDK and Spring Boot integration
5. **Pattern Library**: Provides common patterns and best practices

### Spring Boot Intelligence

The skill includes smart Spring Boot detection:

```markdown
**IMPORTANT: Ask the developer if they want to use Spring Boot integration before proceeding.**
```

When appropriate, Claude will:
- Ask if you want Spring Boot integration
- Use `temporal-spring-boot-starter` dependency
- Generate Spring Boot annotations (`@WorkflowImpl`, `@ActivityImpl`)
- Configure via `application.yml`
- Leverage Spring dependency injection

## Development

### Modifying the Skill

1. Edit `src/temporal-java.md` with your changes
2. Update references in `src/references/` if needed
3. Run tests to validate:
   ```bash
   cd test/skill-integration
   ./run-integration-test.sh
   ```
4. Build the package:
   ```bash
   ./build-skill-package.sh
   ```

### Testing Changes

Always test skill modifications:

```bash
# Quick validation (no execution test)
export SKIP_EXECUTION=true
cd test/skill-integration
./run-integration-test.sh

# Full validation (with Temporal server)
./run-integration-test.sh
```

### Best Practices

- **Keep URLs Current**: Validate all documentation links regularly
- **Test Both Paths**: Run both standard SDK and Spring Boot tests
- **Version Awareness**: Ensure Maven Central links work correctly
- **Sample Updates**: Keep sample references in sync with the official repository

## Requirements

### For Using the Skill
- Claude Code installed and configured
- Basic understanding of Temporal concepts

### For Building
- Bash shell
- `curl` or `wget` for URL validation

### For Testing
- Anthropic API key (for automated tests)
- Python 3 with `anthropic` package
- Java 11+ and Maven (for validation)
- Temporal CLI (optional, for execution tests)

## Contributing

Contributions are welcome! Areas for improvement:

- **Additional Patterns**: Add more advanced Temporal patterns
- **Sample Mapping**: Improve use-case to sample mapping
- **Spring Boot Examples**: Expand Spring Boot guidance
- **Test Coverage**: Add more test scenarios
- **Documentation**: Keep references current with Temporal updates

### Contribution Workflow

1. Fork the repository
2. Make your changes to `src/temporal-java.md` or references
3. Run the integration tests
4. Build and validate the package
5. Submit a pull request

## Support

### For Skill Content
- Edit `src/temporal-java.md` or `src/references/`
- Check official Temporal docs: https://docs.temporal.io/dev-guide/java

### For Build Issues
- See [BUILD.md](BUILD.md)
- Check `dist/build-report.txt` for details

### For Test Issues
- See [test/skill-integration/README.md](test/skill-integration/README.md)
- Review `test-workspace/claude-response.txt` for debugging

### For Temporal Questions
- Community forum: https://community.temporal.io/
- GitHub issues: https://github.com/temporalio/sdk-java/issues

## Resources

- **Temporal Documentation**: https://docs.temporal.io/
- **Java SDK Guide**: https://docs.temporal.io/dev-guide/java
- **Java SDK API Reference**: https://www.javadoc.io/doc/io.temporal/temporal-sdk/latest/
- **Samples Repository**: https://github.com/temporalio/samples-java
- **Maven Central**: https://central.sonatype.com/artifact/io.temporal/temporal-sdk

## License

This skill package references official Temporal documentation and samples. Please refer to Temporal's licensing for their content.

## Version

Current version: 1.0.0

Check `dist/build-report.txt` after building for package details.
