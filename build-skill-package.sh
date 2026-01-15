#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
DIST_DIR="${SCRIPT_DIR}/dist"
PACKAGE_NAME="temporal-skill"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Print header
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Temporal Skill Package Builder               ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print step
print_step() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)] $1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Clean build directories
clean_build() {
    print_step "Cleaning build directories..."
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${DIST_DIR}"
    print_success "Build directories cleaned"
}

# Validate skill file
validate_skill() {
    local skill_file="$1"
    print_step "Validating skill file: $(basename "$skill_file")"

    if [ ! -f "$skill_file" ]; then
        print_error "Skill file not found: $skill_file"
        return 1
    fi

    # Check file size
    local size=$(wc -c < "$skill_file")
    if [ "$size" -eq 0 ]; then
        print_error "Skill file is empty"
        return 1
    fi

    # Check for markdown headers
    if ! grep -q "^#" "$skill_file"; then
        print_error "No markdown headers found in skill file"
        return 1
    fi

    # Check for URLs (skills should reference documentation)
    if ! grep -qE 'https?://' "$skill_file"; then
        print_error "Warning: No URLs found in skill file"
    fi

    print_success "Skill file validated ($(printf "%8d" $size) bytes)"
}

# Extract metadata from skill file
extract_metadata() {
    local skill_file="$1"
    local title=$(head -1 "$skill_file" | sed 's/^#\+[[:space:]]*//')
    local description="Comprehensive Temporal.io skill with support for multiple SDKs"

    # Get list of all markdown files in the package
    local pkg_dir="${BUILD_DIR}/${PACKAGE_NAME}"
    local files_json=$(cd "$pkg_dir" && find . -type f -name "*.md" | sed 's|^\./||' | sort | awk '{printf "    \"%s\",\n", $0}' | sed '$ s/,$//')

    echo "{
  \"name\": \"temporal\",
  \"title\": \"${title}\",
  \"description\": \"${description}\",
  \"version\": \"1.0.0\",
  \"author\": \"Temporal Technologies\",
  \"created\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"format\": \"cloud-skill-v1\",
  \"sdks\": [\"java\", \"python\"],
  \"files\": [
${files_json}
  ]
}"
}

# Create package structure
create_package_structure() {
    print_step "Creating package structure..."

    local pkg_dir="${BUILD_DIR}/${PACKAGE_NAME}"
    mkdir -p "${pkg_dir}"

    # Copy main skill file
    if [ ! -f "${SCRIPT_DIR}/src/temporal.md" ]; then
        print_error "Main skill file not found: src/temporal.md"
        return 1
    fi
    cp "${SCRIPT_DIR}/src/temporal.md" "${pkg_dir}/"
    print_success "Copied main skill file"

    # Copy all SDK resources
    if [ -d "${SCRIPT_DIR}/src/sdks" ]; then
        cp -r "${SCRIPT_DIR}/src/sdks" "${pkg_dir}/sdks"
        print_success "Copied SDK resources"

        # Count SDKs
        local sdk_count=$(find "${pkg_dir}/sdks" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
        print_success "Included ${sdk_count} SDK resource(s)"
    fi

    # Generate metadata
    extract_metadata "${SCRIPT_DIR}/src/temporal.md" > "${pkg_dir}/skill-metadata.json"
    print_success "Generated metadata file"

    # Create README for the package
    cat > "${pkg_dir}/README.md" <<'EOF'
# Temporal Skill

This skill provides comprehensive guidance for working with Temporal.io across multiple SDKs.

## What's Included

- **temporal.md**: Main skill file with Temporal concepts and SDK selection guidance
- **sdks/**: SDK-specific resources for each supported language
  - **java/**: Complete Java SDK reference with Spring Boot integration
  - *(More SDKs coming soon: Python, TypeScript, Go, .NET, PHP)*

## Installation

### For Claude Code (Local)
1. Copy `temporal.md` to your project's `.claude/skills/` directory
2. Copy the entire `sdks/` directory alongside it
3. Reference the skill in your prompts: "Use the temporal skill"

### For Claude Cloud
Upload this entire skill package through the Claude Cloud interface.

## Usage

When working on Temporal applications, mention this skill in your prompts:

```
Create a Temporal workflow in Java that processes orders
Help me implement a Python Temporal workflow with signals
```

The skill will:
- Help you choose the right SDK for your project
- Reference SDK-specific documentation and examples
- Provide language-specific code patterns
- Guide you through framework integrations
- Fetch latest SDK versions

## Skill Contents

- **temporal.md**: Main skill file
- **sdks/java/java.md**: Java SDK resource
- **sdks/java/references/**: Java-specific guides
  - spring-boot.md: Spring Boot integration
  - samples.md: Samples catalog
- **skill-metadata.json**: Metadata for Cloud skill management
- **README.md**: This file

## Supported SDKs

✅ **Java**: Complete reference with Spring Boot integration
✅ **Python**: Complete reference with FastAPI/Django/Flask integration
✅ **Go**: Complete reference with determinism rules and best practices
🚧 **TypeScript**: Coming soon
🚧 **.NET**: Coming soon
🚧 **PHP**: Coming soon

## Links

- Official Temporal Documentation: https://docs.temporal.io/
- Community: https://community.temporal.io/
- GitHub: https://github.com/temporalio/

## Testing

This skill has been validated with automated integration tests that verify:
- Claude can generate working Temporal applications
- Generated code compiles successfully
- Applications execute correctly with Temporal server
EOF
    print_success "Created package README"

    # Copy license if exists
    if [ -f "${SCRIPT_DIR}/LICENSE" ]; then
        cp "${SCRIPT_DIR}/LICENSE" "${pkg_dir}/"
        print_success "Copied LICENSE"
    fi

    print_success "Package structure created"
}

# Validate all URLs in skill
validate_urls() {
    print_step "Validating URLs in skill package..."

    local pkg_dir="${BUILD_DIR}/${PACKAGE_NAME}"
    local failed=0
    local total=0

    # Find all markdown files and extract URLs
    while IFS= read -r url; do
        ((total++))
        status=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)
        if [[ $status -ge 200 && $status -lt 400 ]]; then
            echo "  ✓ [$status] $url"
        else
            echo "  ✗ [$status] $url"
            ((failed++))
        fi
    done < <(find "$pkg_dir" -name "*.md" -exec grep -oE 'https?://[^)[:space:]]+' {} \; | sort -u)

    if [ $failed -eq 0 ]; then
        print_success "All $total URLs validated successfully"
    else
        print_error "$failed of $total URLs failed validation"
        return 1
    fi
}

# Create zip package
create_zip() {
    print_step "Creating zip package..."

    local pkg_dir="${BUILD_DIR}/${PACKAGE_NAME}"
    local zip_name="${PACKAGE_NAME}-${TIMESTAMP}.zip"
    local zip_path="${DIST_DIR}/${zip_name}"

    # Create zip from within the build directory
    (cd "${BUILD_DIR}" && zip -r -q "${zip_path}" "${PACKAGE_NAME}")

    # Create a latest symlink
    ln -sf "${zip_name}" "${DIST_DIR}/${PACKAGE_NAME}-latest.zip"

    local size=$(du -h "${zip_path}" | cut -f1)
    print_success "Created zip package: ${zip_name} (${size})"

    echo ""
    echo -e "${GREEN}Package created successfully!${NC}"
    echo -e "  Location: ${zip_path}"
    echo -e "  Size: ${size}"
    echo -e "  Latest link: ${DIST_DIR}/${PACKAGE_NAME}-latest.zip"
}

# Generate build report
generate_report() {
    print_step "Generating build report..."

    local report="${DIST_DIR}/build-report.txt"
    local zip_latest="${DIST_DIR}/${PACKAGE_NAME}-latest.zip"

    cat > "${report}" <<EOF
Temporal Skill Package Build Report
====================================

Build Time: $(date)
Package Name: ${PACKAGE_NAME}
Build Directory: ${BUILD_DIR}
Distribution Directory: ${DIST_DIR}

Files Included:
$(cd "${BUILD_DIR}/${PACKAGE_NAME}" && find . -type f | sort | sed 's|^\./|  - |')

Package Size: $(du -h "${zip_latest}" | cut -f1)
Package Location: ${zip_latest}

Skill Metadata:
$(cat "${BUILD_DIR}/${PACKAGE_NAME}/skill-metadata.json" | sed 's/^/  /')

SDK Resources:
$(find "${BUILD_DIR}/${PACKAGE_NAME}/sdks" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's|.*/|  - |' || echo "  (none)")

Installation Instructions:
--------------------------
For Claude Cloud:
  1. Navigate to Claude Cloud skill management
  2. Upload: ${zip_latest}
  3. Activate the skill for your projects

For Claude Code (Local):
  1. Extract temporal.md from the zip
  2. Extract the sdks/ directory
  3. Copy both to your project: .claude/skills/
  4. Reference in prompts: "Use the temporal skill"

Build completed successfully!
EOF

    print_success "Build report created: ${report}"
}

# Main build process
main() {
    print_header

    # Parse arguments
    SKIP_URL_CHECK=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-url-check)
                SKIP_URL_CHECK=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Builds a single Temporal skill package with all SDK resources."
                echo ""
                echo "Options:"
                echo "  --skip-url-check    Skip URL validation (faster builds)"
                echo "  --help, -h          Show this help message"
                echo ""
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Execute build steps
    clean_build
    validate_skill "${SCRIPT_DIR}/src/temporal.md" || exit 1
    create_package_structure || exit 1

    if [ "$SKIP_URL_CHECK" = false ]; then
        validate_urls || {
            print_error "URL validation failed. Use --skip-url-check to skip this check."
            exit 1
        }
    else
        print_step "Skipping URL validation (--skip-url-check)"
    fi

    create_zip
    generate_report

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       BUILD COMPLETED SUCCESSFULLY!            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  • Upload to Cloud: ${DIST_DIR}/${PACKAGE_NAME}-latest.zip"
    echo "  • View report: ${DIST_DIR}/build-report.txt"
    echo "  • Test locally: Copy temporal.md and sdks/ to .claude/skills/"
    echo ""
}

# Run main
main "$@"
