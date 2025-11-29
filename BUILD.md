# Building the Temporal Skill Package

This repository contains a build system for packaging a single Temporal skill with multiple SDK resources for Claude Cloud upload.

## Quick Start

```bash
# Build the skill package
./build-skill-package.sh

# Build without URL validation (faster)
./build-skill-package.sh --skip-url-check
```

## What Gets Created

The build process creates a single skill package with all SDK resources:

```
dist/
├── temporal-skill-YYYYMMDD_HHMMSS.zip   # Timestamped package
├── temporal-skill-latest.zip             # Symlink to latest
└── build-report.txt                      # Build validation report
```

## Package Contents

The skill package includes:

- **temporal.md** - Main skill file with core Temporal concepts
- **sdks/** - SDK-specific resources
  - **java/java.md** - Java SDK resource
  - **java/references/** - Java-specific guides
  - *(Future SDKs will be added here)*
- **skill-metadata.json** - Metadata for Cloud skill management
- **README.md** - Installation and usage instructions

## Package Structure

```
temporal-skill/
├── temporal.md           # Main skill file
├── sdks/
│   └── java/
│       ├── java.md       # Java SDK resource
│       └── references/
│           ├── samples.md
│           └── spring-boot.md
├── skill-metadata.json   # Metadata (auto-generated)
└── README.md             # Package documentation
```

## Build Process

The build script performs these steps:

1. **Validation** - Checks skill file format and content
2. **Structure Creation** - Creates proper package directory layout
3. **SDK Resources Copy** - Includes all SDK resources from `sdks/`
4. **Metadata Generation** - Extracts metadata from skill file
5. **URL Validation** - Verifies all links are accessible (optional)
6. **Packaging** - Creates timestamped zip file
7. **Report Generation** - Creates detailed build report

## Validation

### Skill File Validation
- File exists and is not empty
- Contains markdown headers
- Contains documentation URLs

### URL Validation
- Tests all URLs in all markdown files
- Verifies HTTP status codes (200-399)
- Reports any broken links
- Can be skipped with `--skip-url-check`

## Usage

### Build the Package

```bash
./build-skill-package.sh
```

Output:
```
╔════════════════════════════════════════════════╗
║  Temporal Skill Package Builder               ║
╚════════════════════════════════════════════════╝

[15:07:11] Cleaning build directories...
✓ Build directories cleaned
[15:07:11] Validating skill file: temporal.md
✓ Skill file validated (8218 bytes)
[15:07:11] Creating package structure...
✓ Copied main skill file
✓ Copied SDK resources
✓ Included 1 SDK resource(s)
✓ Generated metadata file
✓ Created package README
✓ Package structure created
[15:07:11] Validating URLs in skill package...
  ✓ [200] https://docs.temporal.io/
  ...
✓ All 45 URLs validated successfully
[15:07:15] Creating zip package...
✓ Created zip package: temporal-skill-20251129_150711.zip (120K)

╔════════════════════════════════════════════════╗
║       BUILD COMPLETED SUCCESSFULLY!            ║
╚════════════════════════════════════════════════╝

Next steps:
  • Upload to Cloud: dist/temporal-skill-latest.zip
  • View report: dist/build-report.txt
  • Test locally: Copy temporal.md and sdks/ to .claude/skills/
```

### Fast Build for Development

```bash
./build-skill-package.sh --skip-url-check
```

Skips URL validation for faster iteration during development.

## For Claude Cloud

1. Build the package:
   ```bash
   ./build-skill-package.sh
   ```

2. Upload to Claude Cloud:
   ```
   dist/temporal-skill-latest.zip
   ```

3. Activate in your Cloud project

## For Local Claude Code

Extract and copy to your skills directory:

```bash
# Extract the package
unzip dist/temporal-skill-latest.zip
cd temporal-skill

# Copy to Claude Code skills directory
cp temporal.md ~/.claude/skills/
cp -r sdks ~/.claude/skills/

# Or copy directly from source (for development)
cp temporal.md ~/.claude/skills/
cp -r sdks ~/.claude/skills/
```

## Adding New SDK Resources

To add a new SDK resource:

1. Create SDK directory:
   ```bash
   mkdir -p sdks/newsdk
   ```

2. Create the resource file:
   ```bash
   # Must be named <sdk>.md
   touch sdks/newsdk/newsdk.md
   ```

3. (Optional) Add references:
   ```bash
   mkdir -p sdks/newsdk/references
   ```

4. Update `temporal.md` to mention the new SDK

5. Build:
   ```bash
   ./build-skill-package.sh
   ```

The build system automatically includes all SDKs in the `sdks/` directory.

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
- Fix broken URLs in the skill or SDK resource files

### "Skill file not found"
Ensure `temporal.md` exists in the repository root.

### Permission denied
Make the script executable:
```bash
chmod +x build-skill-package.sh
```

## Testing Built Packages

### 1. Structure Test

Verify zip contents:
```bash
unzip -l dist/temporal-skill-latest.zip
```

### 2. Integration Test

Use the automated test suite (Java SDK):
```bash
cd sdks/java/test/skill-integration
./run-integration-test.sh
```

### 3. Manual Test

```bash
# Extract to test location
unzip dist/temporal-skill-latest.zip
cd temporal-skill

# Copy to test Claude Code installation
cp temporal.md test-dir/.claude/skills/
cp -r sdks test-dir/.claude/skills/

# Test with Claude Code
cd test-dir
# Ask Claude to create a Temporal application
```

## Build Report

Each build generates a detailed report in `dist/build-report.txt` containing:

- Build timestamp and package details
- List of all files included
- Package size and location
- Skill metadata
- SDK resources included
- Installation instructions

## Best Practices

1. **Always validate URLs** before uploading to Cloud
2. **Test the package** with integration test suite
3. **Review the build report** for any warnings
4. **Version your releases** with git tags
5. **Keep metadata accurate** in skill files
6. **Test SDK resources** individually

## Support

For issues with:
- **Skill content**: Edit `temporal.md` or `sdks/<sdk>/<sdk>.md`
- **Build process**: Check this BUILD.md or the build script
- **Package format**: Review Cloud skill documentation
- **Integration tests**: See `sdks/<sdk>/test/skill-integration/README.md`
