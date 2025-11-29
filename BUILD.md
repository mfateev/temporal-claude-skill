# Building Skill Packages

This repository contains a build system for packaging Temporal skills across multiple SDKs for Claude Cloud upload.

## Quick Start

```bash
# List available SDKs
./build-skill-package.sh --list

# Build a specific SDK (default: java)
./build-skill-package.sh --sdk java

# Build all SDKs
./build-skill-package.sh --all

# Build without URL validation (faster)
./build-skill-package.sh --sdk java --skip-url-check
```

## Available Commands

```bash
./build-skill-package.sh [OPTIONS]

Options:
  --sdk <name>        Build specific SDK (e.g., --sdk java)
  --all               Build all available SDKs
  --list              List available SDKs
  --skip-url-check    Skip URL validation (faster builds)
  --help, -h          Show help message
```

## What Gets Created

The build process creates SDK-specific packages:

```
dist/
├── temporal-java-skill-YYYYMMDD_HHMMSS.zip   # Timestamped Java package
├── temporal-java-skill-latest.zip             # Symlink to latest Java
├── build-report-java.txt                      # Java build report
├── temporal-python-skill-YYYYMMDD_HHMMSS.zip # (future SDK packages)
└── ...
```

## Package Contents

Each skill package includes:

- **temporal-<sdk>.md** - The main skill file
- **references/** - Additional reference documentation (if available)
- **skill-metadata.json** - Metadata for Cloud skill management
- **README.md** - Installation and usage instructions

## Package Structure

Example for Java SDK:

```
temporal-java-skill/
├── temporal-java.md           # Main skill file
├── references/
│   ├── samples.md             # Samples reference
│   └── spring-boot.md         # Spring Boot guide
├── skill-metadata.json        # Metadata (auto-generated)
└── README.md                  # Package documentation
```

## Build Process

The build script performs these steps for each SDK:

1. **SDK Discovery** - Finds available SDKs in `sdks/` directory
2. **Validation** - Checks skill file format and content
3. **Structure Creation** - Creates proper package directory layout
4. **Metadata Generation** - Extracts metadata from skill file
5. **URL Validation** - Verifies all links are accessible (optional)
6. **Packaging** - Creates timestamped zip file with symlink to latest
7. **Report Generation** - Creates detailed build report per SDK

## Validation

### Skill File Validation
- File exists and is not empty
- Contains markdown headers
- Contains documentation URLs
- Named correctly (`temporal-<sdk>.md`)

### URL Validation
- Tests all URLs in all markdown files
- Verifies HTTP status codes (200-399)
- Reports any broken links
- Can be skipped with `--skip-url-check`

## SDK Organization

SDKs are organized under the `sdks/` directory:

```
sdks/
├── java/
│   ├── temporal-java.md       # Main skill file (required)
│   ├── references/            # Additional docs (optional)
│   └── test/                  # Integration tests (optional)
├── python/                    # (future SDK)
├── typescript/                # (future SDK)
└── go/                        # (future SDK)
```

### Adding a New SDK

1. Create SDK directory:
   ```bash
   mkdir -p sdks/newsdk
   ```

2. Create the skill file:
   ```bash
   # File must be named temporal-<sdk>.md
   touch sdks/newsdk/temporal-newsdk.md
   ```

3. (Optional) Add references:
   ```bash
   mkdir -p sdks/newsdk/references
   ```

4. Build it:
   ```bash
   ./build-skill-package.sh --sdk newsdk
   ```

## Usage Examples

### Build Java SDK Only

```bash
./build-skill-package.sh --sdk java
```

Output:
```
╔════════════════════════════════════════════════╗
║  Building: temporal-java-skill                 ║
╚════════════════════════════════════════════════╝

[14:30:45] Cleaning build directories...
✓ Build directories cleaned
[14:30:45] Validating skill file: temporal-java.md
✓ Skill file validated (15234 bytes)
[14:30:45] Creating package structure for java...
✓ Copied skill file: temporal-java.md
✓ Copied references directory
✓ Generated metadata file
✓ Created package README
✓ Package structure created for java
[14:30:45] Validating URLs in skill package...
  ✓ [200] https://docs.temporal.io/
  ✓ [200] https://docs.temporal.io/dev-guide/java
  ...
✓ All 25 URLs validated successfully
[14:30:52] Creating zip package...
✓ Created zip package: temporal-java-skill-20251129_143052.zip (45K)

╔════════════════════════════════════════════════╗
║       BUILD COMPLETED SUCCESSFULLY!            ║
╚════════════════════════════════════════════════╝

Next steps:
  • Upload to Cloud: dist/temporal-java-skill-latest.zip
  • View report: dist/build-report-java.txt
  • Test locally: Copy temporal-java.md to .claude/skills/
```

### Build All SDKs

```bash
./build-skill-package.sh --all
```

This will:
1. Discover all SDKs in `sdks/` directory
2. Build each SDK sequentially
3. Create separate packages and reports for each
4. Continue even if one SDK fails

### Fast Build for Development

```bash
./build-skill-package.sh --sdk java --skip-url-check
```

Skips URL validation for faster iteration during development.

## Usage for Different Platforms

### For Claude Cloud

1. Build the package:
   ```bash
   ./build-skill-package.sh --sdk java
   ```

2. Upload the generated zip file to Claude Cloud:
   ```
   dist/temporal-java-skill-latest.zip
   ```

3. Activate the skill in your Cloud project

### For Local Claude Code

Extract the skill file from the package:
```bash
# Extract just the skill file
unzip -j dist/temporal-java-skill-latest.zip "*/temporal-java.md" -d ~/.claude/skills/

# Or copy directly from source (for development)
cp sdks/java/temporal-java.md ~/.claude/skills/
```

## Build Artifacts

All build artifacts are gitignored:
- `build/` - Temporary build directory (cleaned each run)
- `dist/` - Distribution packages (preserved across builds)
- `*.zip` - All zip files

See `.gitignore` for details.

## Troubleshooting

### "URL validation failed"
Some URLs may be temporarily unavailable. Options:
- Wait and retry
- Use `--skip-url-check` to skip validation
- Fix broken URLs in the skill file

### "No skill file found in sdks/xxx"
Ensure the skill file follows naming convention:
- Must be named `temporal-<sdk>.md`
- Must be in the root of the SDK directory
- Example: `sdks/java/temporal-java.md`

### "SDK not found"
Check that:
- SDK directory exists under `sdks/`
- Directory name matches `--sdk` parameter
- Use `--list` to see available SDKs

### Permission denied
Make the script executable:
```bash
chmod +x build-skill-package.sh
```

## CI/CD Integration

Example GitHub Actions workflow for building all SDKs:

```yaml
name: Build Skill Packages

on:
  push:
    branches: [ main ]
    paths: [ 'sdks/**/*.md' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build all skill packages
        run: ./build-skill-package.sh --all

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: skill-packages
          path: dist/*.zip

      - name: Upload to release
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*-latest.zip
```

Example for building specific SDK on changes:

```yaml
name: Build Java Skill

on:
  push:
    paths: [ 'sdks/java/**' ]

jobs:
  build-java:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Java skill package
        run: ./build-skill-package.sh --sdk java

      - name: Run integration tests
        run: |
          cd sdks/java/test/skill-integration
          ./run-integration-test.sh
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Version Management

Package versions are tracked in `skill-metadata.json`:

```json
{
  "name": "temporal-java",
  "version": "1.0.0",
  "created": "2025-11-29T21:24:10Z"
}
```

To update versions:
1. Edit the version in `build-skill-package.sh` (search for `"version":`)
2. Rebuild the packages
3. Tag the release: `git tag -a v1.1.0 -m "Release 1.1.0"`

## Testing Built Packages

After building, validate the packages:

### 1. Structure Test

Verify zip contents:
```bash
unzip -l dist/temporal-java-skill-latest.zip
```

Expected output:
```
Archive:  dist/temporal-java-skill-latest.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
    15234  2025-11-29 14:30   temporal-java-skill/temporal-java.md
     8432  2025-11-29 14:30   temporal-java-skill/references/samples.md
     5672  2025-11-29 14:30   temporal-java-skill/references/spring-boot.md
      543  2025-11-29 14:30   temporal-java-skill/skill-metadata.json
     1234  2025-11-29 14:30   temporal-java-skill/README.md
---------                     -------
    31115                     5 files
```

### 2. Integration Test

Use the automated test suite:
```bash
cd sdks/java/test/skill-integration
./run-integration-test.sh
```

### 3. Manual Test

Extract and use locally:
```bash
# Extract to test location
unzip -j dist/temporal-java-skill-latest.zip "*/temporal-java.md" -d test-dir/.claude/skills/

# Test with Claude Code
cd test-dir
# Ask Claude to create a Temporal application
```

## Best Practices

1. **Always validate URLs** before uploading to Cloud (skip only for dev)
2. **Test the package** with integration test suite after building
3. **Review the build report** for any warnings or issues
4. **Version your releases** with git tags for traceability
5. **Keep metadata accurate** (update version numbers appropriately)
6. **Build all SDKs** before major releases to ensure consistency
7. **Use --list** to verify SDK discovery before building

## Build Report

Each build generates a detailed report in `dist/build-report-<sdk>.txt` containing:

- Build timestamp and package details
- List of all files included in package
- Package size and location
- Skill metadata (parsed from JSON)
- Installation instructions for Cloud and local use

Review this report to ensure:
- All expected files are included
- URLs were validated (if not skipped)
- Metadata is correct
- Package size is reasonable

## Support

For issues with:
- **Skill content**: Edit `sdks/<sdk>/temporal-<sdk>.md`
- **Build process**: Check this BUILD.md or the build script
- **Package format**: Review Cloud skill documentation
- **Integration tests**: See `sdks/<sdk>/test/skill-integration/README.md`
