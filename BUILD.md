# Building Skill Packages

This directory contains a build system for packaging skills for Claude Cloud upload.

## Quick Start

```bash
# Build the skill package
./build-skill-package.sh

# Build without URL validation (faster)
./build-skill-package.sh --skip-url-check
```

## What Gets Created

The build process creates:

```
dist/
├── temporal-java-skill-YYYYMMDD_HHMMSS.zip  # Timestamped package
├── temporal-java-skill-latest.zip            # Symlink to latest
└── build-report.txt                          # Detailed build report
```

## Package Contents

Each skill package includes:

- **temporal-java.md** - The skill file
- **skill-metadata.json** - Metadata for Cloud skill management
- **README.md** - Installation and usage instructions

## Package Structure

```
temporal-java-skill/
├── temporal-java.md           # Main skill file
├── skill-metadata.json        # Metadata (auto-generated)
└── README.md                  # Package documentation
```

## Build Process

The build script performs these steps:

1. **Validation** - Checks skill file format and content
2. **Structure Creation** - Creates proper package directory layout
3. **Metadata Generation** - Extracts metadata from skill file
4. **URL Validation** - Verifies all links are accessible (optional)
5. **Packaging** - Creates timestamped zip file
6. **Report Generation** - Creates detailed build report

## Validation

### Skill File Validation
- File exists and is not empty
- Contains markdown headers
- Contains documentation URLs

### URL Validation
- Tests all URLs in the skill file
- Verifies HTTP status codes (200-399)
- Reports any broken links
- Can be skipped with `--skip-url-check`

## Usage

### For Claude Cloud

1. Build the package:
   ```bash
   ./build-skill-package.sh
   ```

2. Upload the generated zip file to Claude Cloud:
   ```
   dist/temporal-java-skill-latest.zip
   ```

3. Activate the skill in your Cloud project

### For Local Claude Code

Extract the skill file from the package:
```bash
unzip -j dist/temporal-java-skill-latest.zip "*/temporal-java.md" -d .claude/skills/
```

Or copy directly:
```bash
cp temporal-java.md .claude/skills/
```

## Command Line Options

```
./build-skill-package.sh [OPTIONS]

Options:
  --skip-url-check    Skip URL validation (faster builds)
  --help, -h          Show help message
```

## Build Artifacts

All build artifacts are ignored by git:
- `build/` - Temporary build directory
- `dist/` - Distribution packages
- `*.zip` - All zip files

See `.gitignore` for details.

## Troubleshooting

### "URL validation failed"
Some URLs may be temporarily unavailable. Options:
- Wait and retry
- Use `--skip-url-check` to skip validation
- Fix broken URLs in the skill file

### "Skill file not found"
Ensure you're running the script from the repository root where `temporal-java.md` exists.

### Permission denied
Make the script executable:
```bash
chmod +x build-skill-package.sh
```

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Build Skill Package

on:
  push:
    branches: [ main ]
    paths: [ 'temporal-java.md' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build skill package
        run: ./build-skill-package.sh

      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: skill-package
          path: dist/temporal-java-skill-*.zip

      - name: Upload to release
        if: startsWith(github.ref, 'refs/tags/')
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: dist/temporal-java-skill-latest.zip
          asset_name: temporal-java-skill.zip
          asset_content_type: application/zip
```

## Version Management

Package versions are tracked in `skill-metadata.json`:

```json
{
  "version": "1.0.0",
  "created": "2025-11-29T21:24:10Z"
}
```

Consider updating the version in the build script when making significant changes to the skill.

## Testing

After building, test the package:

1. **Structure Test** - Verify zip contents:
   ```bash
   unzip -l dist/temporal-java-skill-latest.zip
   ```

2. **Integration Test** - Use the automated test:
   ```bash
   cd test/skill-integration
   ./run-integration-test.sh
   ```

3. **Manual Test** - Extract and use locally:
   ```bash
   unzip -j dist/temporal-java-skill-latest.zip "*/temporal-java.md" -d test-dir/.claude/skills/
   ```

## Best Practices

1. **Always validate URLs** before uploading to Cloud
2. **Test the package** with the integration test suite
3. **Review the build report** for any warnings
4. **Version your releases** with git tags
5. **Keep metadata accurate** (update version, description)

## Support

For issues with:
- **Skill content**: Edit `temporal-java.md`
- **Build process**: Check `build-skill-package.sh`
- **Integration tests**: See `test/skill-integration/README.md`
- **Package format**: Review Cloud skill documentation
