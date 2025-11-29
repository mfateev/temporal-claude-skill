# Run Skill Integration Test

Run the automated integration test for the temporal-java.md skill.

This test will:
1. Set up a test workspace with the skill installed
2. Use the Anthropic API to generate a Temporal application
3. Validate the generated code structure and compilation
4. Run execution tests with Temporal server
5. Report results

## Requirements

- ANTHROPIC_API_KEY environment variable must be set
- Python 3 with anthropic package
- Java 11+ and Maven
- Temporal CLI (for execution testing)

## Instructions

Execute the integration test script:

```bash
cd test/skill-integration && ./run-integration-test.sh
```

Check the test output for:
- Code generation from Claude API
- Structure validation
- Build success
- Execution test results
