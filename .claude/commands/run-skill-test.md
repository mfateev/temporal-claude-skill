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
- Use Claude AI to intelligently validate the generated code structure
- Test compilation with Maven
- Run execution tests with Temporal server (optional)
- Report pass/fail results

Monitor the output and report:
- Whether code generation succeeded
- Claude's validation assessment (structure, patterns, quality)
- Whether compilation succeeded
- Whether execution tests passed (if run)
- Any errors or warnings encountered

Note: Validation is now performed by Claude AI, which provides intelligent
analysis of the generated code structure, Temporal patterns, and code quality.
