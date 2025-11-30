# Chore: Refactor run-skill-test to test-skill that tests all SDKs

## Chore Description

Refactor the existing `/run-skill-test` slash command to create a new unified `test-skill` script that can test all SDK integrations (Java, Python, and future SDKs). The new script should:

1. Accept a single SDK name as an argument (e.g., "Java", "Python", "TypeScript")
2. Execute the appropriate SDK-specific integration test
3. Support all existing test capabilities (validation, execution, Spring Boot variant for Java)
4. Provide a consistent interface across all SDK tests
5. Be easily extensible for new SDKs (TypeScript, Go, .NET, PHP)

This refactoring consolidates the testing workflow into a single entry point while maintaining all SDK-specific test logic in their respective directories.

## Relevant Files

Use these files to resolve the chore:

**Existing Files:**

- `.claude/commands/run-skill-test.md` (lines 1-29) - Current slash command that only tests Java SDK. This will be replaced with the new unified command.

- `test/java/skill-integration/run-integration-test.sh` (lines 1-150) - Java SDK standard integration test script. Contains setup, validation, and execution logic for testing Java SDK skill.

- `test/java/skill-integration/run-spring-boot-test.sh` (lines 1-150) - Java SDK Spring Boot variant test. Tests Spring Boot-specific patterns and autoconfiguration.

- `test/python/skill-integration/run-integration-test.sh` (lines 1-150) - Python SDK integration test script. Contains setup, validation, and execution logic for testing Python SDK skill.

- `README.md` (lines 199-246) - Main repository README documenting the testing structure. Will need updates to reflect the new unified test command.

### New Files

- `test-skill.sh` - New unified test runner script at repository root that accepts SDK name as argument and delegates to SDK-specific test scripts.

- `.claude/commands/test-skill.md` - New slash command definition that replaces `run-skill-test.md`.

## Step by Step Tasks

### Step 1: Create the unified test-skill.sh script

- Create `test-skill.sh` at repository root
- Accept SDK name as first argument (case-insensitive)
- Validate SDK name against supported SDKs (Java, Python)
- Map SDK names to test script paths:
  - "Java" → `test/java/skill-integration/run-integration-test.sh`
  - "Java-SpringBoot" → `test/java/skill-integration/run-spring-boot-test.sh`
  - "Python" → `test/python/skill-integration/run-integration-test.sh`
- Support additional flags/options:
  - `--skip-execution` - Pass through to SDK test scripts for validation-only testing
  - `--variant <name>` - For Java, specify "standard" or "spring-boot" (default: standard)
- Provide helpful usage message with list of supported SDKs
- Set appropriate error codes for different failure scenarios
- Forward environment variables (ANTHROPIC_API_KEY, SKIP_EXECUTION) to SDK test scripts
- Include colored output for better UX (same style as existing scripts)
- Print test summary showing which SDK and variant was tested

### Step 2: Update the slash command

- Delete `.claude/commands/run-skill-test.md`
- Create `.claude/commands/test-skill.md` with new command syntax
- Document the SDK argument requirement
- Provide examples for testing different SDKs:
  - Standard Java: `test-skill Java`
  - Spring Boot: `test-skill Java --variant spring-boot`
  - Python: `test-skill Python`
- Include prerequisites check (ANTHROPIC_API_KEY)
- Explain output and what each test phase validates
- Add troubleshooting notes for common issues

### Step 3: Update README.md documentation

- Update the "Testing" section (lines 199-246) to reference the new `test-skill.sh` script
- Replace individual SDK test commands with unified command examples:
  - Before: `cd test/java/skill-integration && ./run-integration-test.sh`
  - After: `./test-skill.sh Java`
- Document the `--variant` flag for Java Spring Boot tests
- Document the `--skip-execution` flag for validation-only testing
- Add examples showing how to test all SDKs sequentially
- Keep links to individual SDK test READMEs for detailed documentation
- Add note that SDK-specific scripts can still be run directly if needed

### Step 4: Ensure backward compatibility

- Verify existing SDK test scripts (`run-integration-test.sh`, `run-spring-boot-test.sh`) still work standalone
- Ensure environment variable passing works correctly (ANTHROPIC_API_KEY, SKIP_EXECUTION)
- Test that both direct invocation and test-skill.sh invocation produce same results
- Verify all test output, error messages, and exit codes remain consistent

### Step 5: Add extensibility for future SDKs

- Document in test-skill.sh how to add new SDKs (inline comments)
- Create a clear pattern for SDK test script paths: `test/<sdk-lowercase>/skill-integration/run-integration-test.sh`
- Add validation that checks for test script existence before execution
- Provide helpful error message if SDK is recognized but test script doesn't exist
- Add comments showing where to add TypeScript, Go, .NET, PHP when ready

### Step 6: Run validation commands

- Test the new test-skill.sh script with all supported SDKs and variants
- Verify slash command loads correctly in Claude Code
- Ensure all documentation is accurate and examples work
- Confirm no regressions in existing test functionality

## Validation Commands

Execute every command to validate the chore is complete with zero regressions.

- `./test-skill.sh --help` - Display help message showing usage and supported SDKs
- `./test-skill.sh` - Show error message about missing SDK argument
- `./test-skill.sh InvalidSDK` - Show error message about unsupported SDK
- `SKIP_EXECUTION=true ./test-skill.sh Java` - Run Java integration test (validation only)
- `SKIP_EXECUTION=true ./test-skill.sh Java --variant spring-boot` - Run Java Spring Boot test (validation only)
- `SKIP_EXECUTION=true ./test-skill.sh Python` - Run Python integration test (validation only)
- `cd test/java/skill-integration && SKIP_EXECUTION=true ./run-integration-test.sh` - Verify standalone Java test still works
- `cd test/python/skill-integration && SKIP_EXECUTION=true ./run-integration-test.sh` - Verify standalone Python test still works
- `grep -r "run-skill-test" .claude/ README.md` - Verify all references to old command are removed

## Notes

- The new `test-skill.sh` script should be placed at the repository root for easy access
- All SDK-specific test logic remains in `test/<sdk>/skill-integration/` directories
- The script should be executable: `chmod +x test-skill.sh`
- Consider adding bash completion for SDK names in future enhancement
- The script should detect if it's being run from the wrong directory and provide guidance
- Keep error messages consistent with the style used in existing test scripts
- Ensure the script works on both macOS and Linux (avoid platform-specific commands)
- The `--variant` flag is Java-specific but the architecture should allow other SDKs to add variants in the future
- Environment variable SKIP_EXECUTION should be respected by all SDK test scripts
- The slash command should check for ANTHROPIC_API_KEY before invoking the test script
