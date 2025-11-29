Run the automated integration test for the temporal-java.md skill by executing the test script located at test/skill-integration/run-integration-test.sh

Before running, verify:
1. ANTHROPIC_API_KEY environment variable is set (check with `echo $ANTHROPIC_API_KEY`)
2. If not set, inform the user they need to set it: `export ANTHROPIC_API_KEY='your-key'`

Then run the test:
```bash
cd test/skill-integration && ./run-integration-test.sh
```

The test will:
- Set up test workspace with skill
- Use Anthropic API to generate Temporal application
- Validate generated code structure and compilation
- Run execution tests with Temporal server
- Report pass/fail results

Monitor the output and report:
- Whether code generation succeeded
- Whether validation passed (structure + build)
- Whether execution tests passed
- Any errors encountered
