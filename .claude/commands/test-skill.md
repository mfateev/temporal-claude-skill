Run the unified skill integration test that supports all SDK implementations (Java, Python, and future SDKs).

Before running, verify prerequisites:
1. ANTHROPIC_API_KEY environment variable is set (check with `echo $ANTHROPIC_API_KEY`)
2. If not set, inform the user they need to set it: `export ANTHROPIC_API_KEY='your-key'`

Then run the appropriate test:

**Standard Java SDK:**
```bash
./test-skill.sh Java
```

**Java Spring Boot variant:**
```bash
./test-skill.sh Java --variant spring-boot
```

**Python SDK:**
```bash
./test-skill.sh Python
```

**Validation only (skip execution tests):**
```bash
./test-skill.sh Java --skip-execution
./test-skill.sh Python --skip-execution
```

The test will:
- Set up test workspace with skill
- Use Anthropic API to generate Temporal application code
- Use Claude AI to intelligently validate the generated code structure
- Test compilation with SDK-specific build tools (Maven for Java, pytest for Python)
- Run execution tests with Temporal server (optional, can be skipped with --skip-execution)
- Report pass/fail results

Monitor the output and report:
- Which SDK and variant is being tested
- Whether code generation succeeded
- Claude's validation assessment (structure, patterns, quality)
- Whether compilation/build succeeded
- Whether execution tests passed (if run)
- Any errors or warnings encountered

**Available Options:**
- `--variant <name>` - Specify SDK variant (Java only: 'standard' or 'spring-boot')
- `--skip-execution` - Run validation only, skip execution tests
- `--help` - Display help message with all options

**Troubleshooting:**

*API Key Issues:*
- Error: "ANTHROPIC_API_KEY not set"
- Solution: Export your API key: `export ANTHROPIC_API_KEY='your-key'`

*Claude CLI Not Found:*
- Error: "Claude CLI not found"
- Solution: Install globally: `npm install -g @anthropic-ai/claude-code`
- Or use npx: `npx @anthropic-ai/claude-code`

*Test Script Not Found:*
- Error: "Test script not found"
- Solution: Ensure you're running from repository root and SDK test directory exists

*Permission Denied:*
- Error: "Permission denied"
- Solution: Make script executable: `chmod +x test-skill.sh`

**Direct SDK Test Scripts:**
You can still run SDK-specific test scripts directly if needed:
- `cd test/java/skill-integration && ./run-integration-test.sh`
- `cd test/java/skill-integration && ./run-spring-boot-test.sh`
- `cd test/python/skill-integration && ./run-integration-test.sh`

**Note:** Validation is performed by Claude AI, which provides intelligent analysis of the generated code structure, Temporal patterns, and code quality. This ensures generated code follows best practices for each SDK.
