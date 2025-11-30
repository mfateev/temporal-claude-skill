# Chore: Move skill files into src directory and test files into test directory

## Chore Description
Reorganize the repository to separate skill content from test infrastructure by:
1. Moving all skill files (temporal.md and sdks/) into a new `src/` directory
2. Moving all test files from `sdks/java/test/` into a top-level `test/` directory
3. Updating all references and paths in build scripts and test scripts
4. Updating documentation to reflect the new structure

This improves repository organization by clearly separating source skill content from test infrastructure, making the codebase more maintainable and easier to understand.

## Relevant Files
Use these files to resolve the chore:

### Existing Files to Move

**Skill Files (move to src/):**
- `temporal.md` - Main skill file with core Temporal concepts
  - Moving to: `src/temporal.md`
- `sdks/java/java.md` - Java SDK resource file
  - Moving to: `src/sdks/java/java.md`
- `sdks/java/references/samples.md` - Java samples catalog
  - Moving to: `src/sdks/java/references/samples.md`
- `sdks/java/references/spring-boot.md` - Spring Boot integration guide
  - Moving to: `src/sdks/java/references/spring-boot.md`

**Test Files (move to test/):**
- `sdks/java/test/skill-integration/.gitignore` - Test workspace gitignore
  - Moving to: `test/java/skill-integration/.gitignore`
- `sdks/java/test/skill-integration/README.md` - Test documentation
  - Moving to: `test/java/skill-integration/README.md`
- `sdks/java/test/skill-integration/VALIDATION.md` - Validation documentation
  - Moving to: `test/java/skill-integration/VALIDATION.md`
- `sdks/java/test/skill-integration/automate_test.py` - Automated test with Claude API
  - Moving to: `test/java/skill-integration/automate_test.py`
- `sdks/java/test/skill-integration/claude_validate.py` - Claude-powered validation script
  - Moving to: `test/java/skill-integration/claude_validate.py`
- `sdks/java/test/skill-integration/run-integration-test.sh` - Main test runner
  - Moving to: `test/java/skill-integration/run-integration-test.sh`
- `sdks/java/test/skill-integration/run-spring-boot-test.sh` - Spring Boot test runner
  - Moving to: `test/java/skill-integration/run-spring-boot-test.sh`
- `sdks/java/test/skill-integration/setup-test-workspace.sh` - Test workspace setup
  - Moving to: `test/java/skill-integration/setup-test-workspace.sh`
- `sdks/java/test/skill-integration/test-execution.sh` - Execution test script
  - Moving to: `test/java/skill-integration/test-execution.sh`
- `sdks/java/test/skill-integration/test-spring-boot-prompt.txt` - Spring Boot test prompt
  - Moving to: `test/java/skill-integration/test-spring-boot-prompt.txt`

**Scripts to Update:**
- `build-skill-package.sh` - Build script that references skill files
  - Update to read from `src/temporal.md` and `src/sdks/`
- `test/java/skill-integration/setup-test-workspace.sh` - After move, update paths to skill files
  - Update to reference `../../../../src/temporal.md` and `../../../../src/sdks`

**Documentation to Update:**
- `README.md` - Main documentation with structure examples and usage instructions
  - Update all structure diagrams and paths
- `BUILD.md` - Build documentation with package structure examples
  - Update structure examples and paths

### New Files
No new files need to be created. This is purely a reorganization chore.

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

### Step 1: Create new directory structure
- Create `src/` directory in repository root
- Create `test/` directory in repository root
- Verify directories were created successfully

### Step 2: Move skill files to src/
- Move `temporal.md` to `src/temporal.md`
- Move `sdks/` directory to `src/sdks/` (but exclude test subdirectories)
  - Specifically: Move `sdks/java/java.md` and `sdks/java/references/` to `src/sdks/java/`
- Verify skill files are in correct location

### Step 3: Move test files to test/
- Move `sdks/java/test/skill-integration/` to `test/java/skill-integration/`
- Remove empty `sdks/` directory tree after moves complete
- Verify test files are in correct location

### Step 4: Update build-skill-package.sh
- Update line 115: Change `"${SCRIPT_DIR}/temporal.md"` to `"${SCRIPT_DIR}/src/temporal.md"`
- Update line 119: Change `cp "${SCRIPT_DIR}/temporal.md"` to `cp "${SCRIPT_DIR}/src/temporal.md"`
- Update line 123: Change `if [ -d "${SCRIPT_DIR}/sdks" ]` to `if [ -d "${SCRIPT_DIR}/src/sdks" ]`
- Update line 124: Change `cp -r "${SCRIPT_DIR}/sdks"` to `cp -r "${SCRIPT_DIR}/src/sdks" "${pkg_dir}/sdks"`
- Update line 133: Change `extract_metadata "${SCRIPT_DIR}/temporal.md"` to `extract_metadata "${SCRIPT_DIR}/src/temporal.md"`
- Update line 350: Change `validate_skill "${SCRIPT_DIR}/temporal.md"` to `validate_skill "${SCRIPT_DIR}/src/temporal.md"`

### Step 5: Update test/java/skill-integration/setup-test-workspace.sh
- Update line 14: Change `SKILL_FILE="$SCRIPT_DIR/../../../../temporal.md"` to `SKILL_FILE="$SCRIPT_DIR/../../../../src/temporal.md"`
- Update line 15: Change `SDK_DIR="$SCRIPT_DIR/../../../../sdks"` to `SDK_DIR="$SCRIPT_DIR/../../../../src/sdks"`

### Step 6: Update README.md
- Update "Repository Structure" section (lines 110-125) to show new structure:
  ```
  .
  ├── src/
  │   ├── temporal.md              # Main skill file
  │   └── sdks/
  │       └── java/                # Java SDK resource
  │           ├── java.md          # Java SDK guide
  │           └── references/      # Additional references
  │               ├── samples.md   # Samples catalog
  │               └── spring-boot.md # Spring Boot guide
  ├── test/
  │   └── java/
  │       └── skill-integration/   # Integration tests
  ├── build-skill-package.sh       # Build script
  ├── BUILD.md                     # Build documentation
  └── README.md                    # This file
  ```
- Update "Quick Start" section (lines 40, 49, 50) to reference `src/` directory:
  - Line 40: Change `cp temporal.md` to `cp src/temporal.md`
  - Line 49: Change `cp temporal.md` to `cp src/temporal.md`
  - Line 50: Change `cp -r sdks` to `cp -r src/sdks`
- Update "Architecture" section (lines 17-19) paths:
  - Line 18: Change `temporal.md` to `src/temporal.md`
  - Line 19: Change `sdks/java/` to `src/sdks/java/`
- Update "Current SDK Resources" section (line 131) path:
  - Line 131: Change `**Location**: sdks/java/java.md` to `**Location**: src/sdks/java/java.md`
- Update "Testing" section (lines 194, 212) to reference new test path:
  - Line 194: Change `cd sdks/java/test/skill-integration` to `cd test/java/skill-integration`
  - Line 212: Change path in See link to `test/java/skill-integration/README.md`
- Update "Adding a New SDK Resource" section (lines 243, 248) paths:
  - Line 243: Change `mkdir -p sdks/newsdk` to `mkdir -p src/sdks/newsdk`
  - Line 248: Change `touch sdks/newsdk/newsdk.md` to `touch src/sdks/newsdk/newsdk.md`
  - Line 253: Change `mkdir -p sdks/newsdk/references` to `mkdir -p src/sdks/newsdk/references`
  - Line 254: Change `temporal.md` to `src/temporal.md`
- Update "Modifying the Skill" section (lines 267, 268, 270) paths:
  - Line 267: Change `Edit temporal.md` to `Edit src/temporal.md`
  - Line 268: Change `Edit SDK resources in sdks/<language>/` to `Edit SDK resources in src/sdks/<language>/`
  - Line 270: Change `cd sdks/java/test/skill-integration` to `cd test/java/skill-integration`
- Update last instruction section (line 373) path:
  - Line 373: Change `Copy temporal.md and sdks/` to `Copy src/temporal.md and src/sdks/`

### Step 7: Update BUILD.md
- Update "Package Structure" section (lines 40-51) to reflect source comes from src/:
  - Add comment that source files are in src/ but packaged without src/ prefix
- Update "Adding New SDK Resources" section (lines 163-185) paths:
  - Line 165: Change `mkdir -p sdks/newsdk` to `mkdir -p src/sdks/newsdk`
  - Line 170: Change `touch sdks/newsdk/newsdk.md` to `touch src/sdks/newsdk/newsdk.md`
  - Line 175: Change `mkdir -p sdks/newsdk/references` to `mkdir -p src/sdks/newsdk/references`
  - Line 178: Change `temporal.md` to `src/temporal.md`
  - Line 187: Add note that build system automatically includes all SDKs in `src/sdks/`
- Update "Testing Built Packages" section (lines 227, 270) test path:
  - Line 227: Change `cd sdks/java/test/skill-integration` to `cd test/java/skill-integration`
  - Line 274: Change path reference to `test/<sdk>/skill-integration/README.md`

### Step 8: Update .gitignore if needed
- Verify that build/, dist/, and test workspace patterns still correctly ignore generated files
- No changes should be needed since paths are relative to test directories

### Step 9: Clean up empty directories
- Remove `sdks/` directory if it still exists and is empty after moves
- Verify repository structure matches target structure

### Step 10: Run validation commands
- Execute all validation commands to ensure zero regressions

## Validation Commands
Execute every command to validate the chore is complete with zero regressions.

- `ls -la src/` - Verify src directory exists with temporal.md and sdks/
- `ls -la src/sdks/java/` - Verify Java SDK files are in correct location
- `ls -la test/java/skill-integration/` - Verify test files moved correctly
- `./build-skill-package.sh --skip-url-check` - Verify build script works with new paths
- `unzip -l dist/temporal-skill-latest.zip` - Verify package structure is correct (should NOT contain src/ prefix in package)
- `cd test/java/skill-integration && ./run-integration-test.sh` - Run full integration test (requires ANTHROPIC_API_KEY or will prompt for manual testing)
- `git status` - Review all changes are as expected

## Notes

### Important Path Considerations
1. The `src/` directory is for **source organization only** - the build script should copy files from `src/` but create a package **without** the `src/` prefix (i.e., package should contain `temporal.md` and `sdks/`, not `src/temporal.md`)
2. Test scripts need to traverse up 4 levels (`../../../../`) from their new location to reach repository root, then down into `src/`
3. The `.gitignore` should continue to ignore test workspace directories which are created inside the test/ directory

### Build Package Structure Unchanged
The **packaged skill** structure remains the same for end users:
```
temporal-skill/
├── temporal.md
├── sdks/
│   └── java/
│       ├── java.md
│       └── references/
└── ...
```

Only the **repository** structure changes to use `src/` for source organization.

### Test Location Benefits
Moving tests to `test/` at root level:
- Clearly separates test infrastructure from skill content
- Makes it obvious that tests are not part of the skill package
- Follows common repository organization patterns
- Easier to exclude from packaging (already done, just cleaner)

### Source Location Benefits
Moving skill files to `src/`:
- Makes it immediately clear what files are the "source" skill content
- Separates source from build artifacts, docs, and test infrastructure
- Common pattern in many projects
- Future-proofs for additional tooling that expects sources in src/
