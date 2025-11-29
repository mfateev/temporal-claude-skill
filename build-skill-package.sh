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
SDKS_DIR="${SCRIPT_DIR}/sdks"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Print header
print_header() {
    local sdk_name="$1"
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    if [ -z "$sdk_name" ]; then
        echo -e "${BLUE}║  Temporal Skills Package Builder              ║${NC}"
    else
        echo -e "${BLUE}║  Building: temporal-${sdk_name}-skill         ║${NC}"
    fi
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

# List available SDKs
list_sdks() {
    echo -e "${YELLOW}Available SDKs:${NC}"
    for sdk_dir in "${SDKS_DIR}"/*; do
        if [ -d "$sdk_dir" ]; then
            local sdk_name=$(basename "$sdk_dir")
            local skill_file=$(find "$sdk_dir" -maxdepth 1 -name "temporal-*.md" | head -1)
            if [ -n "$skill_file" ]; then
                echo "  • $sdk_name"
            fi
        fi
    done
    echo ""
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

    print_success "Skill file validated (${size} bytes)"
}

# Extract metadata from skill file
extract_metadata() {
    local skill_file="$1"
    local sdk_name="$2"
    local title=$(head -1 "$skill_file" | sed 's/^#\+[[:space:]]*//')
    local description=$(grep -A 1 "^#" "$skill_file" | tail -1)

    # Get list of all files in the package
    local pkg_dir=$(dirname "$skill_file")
    local files_json=$(cd "$pkg_dir/.." && find . -type f -name "*.md" | sed 's|^\./||' | awk '{printf "    \"%s\",\n", $0}' | sed '$ s/,$//')

    echo "{
  \"name\": \"temporal-${sdk_name}\",
  \"title\": \"${title}\",
  \"description\": \"${description}\",
  \"version\": \"1.0.0\",
  \"author\": \"Temporal Technologies\",
  \"created\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"format\": \"cloud-skill-v1\",
  \"files\": [
${files_json}
  ]
}"
}

# Create package structure for a specific SDK
create_package_structure() {
    local sdk_name="$1"
    local sdk_dir="$2"
    local package_name="temporal-${sdk_name}-skill"

    print_step "Creating package structure for ${sdk_name}..."

    local pkg_dir="${BUILD_DIR}/${package_name}"
    mkdir -p "${pkg_dir}"

    # Find and copy the main skill file
    local skill_file=$(find "$sdk_dir" -maxdepth 1 -name "temporal-*.md" | head -1)
    if [ -z "$skill_file" ]; then
        print_error "No skill file found in ${sdk_dir}"
        return 1
    fi
    cp "$skill_file" "${pkg_dir}/"
    print_success "Copied skill file: $(basename "$skill_file")"

    # Copy references directory if exists
    if [ -d "${sdk_dir}/references" ]; then
        cp -r "${sdk_dir}/references" "${pkg_dir}/"
        print_success "Copied references directory"
    fi

    # Generate metadata
    extract_metadata "$skill_file" "$sdk_name" > "${pkg_dir}/skill-metadata.json"
    print_success "Generated metadata file"

    # Create README for the package
    local skill_basename=$(basename "$skill_file")
    local skill_title=$(head -1 "$skill_file" | sed 's/^#\+[[:space:]]*//')
    local sdk_upper=$(echo "$sdk_name" | tr '[:lower:]' '[:upper:]')

    cat > "${pkg_dir}/README.md" <<EOF
# ${skill_title}

This skill provides guidance for working with Temporal.io using the ${sdk_upper} SDK.

## Installation

### For Claude Code (Local)
1. Copy \`${skill_basename}\` to your project's \`.claude/skills/\` directory
2. Reference the skill in your prompts: "Use the temporal-${sdk_name} skill"

### For Claude Cloud
Upload this skill package through the Claude Cloud interface.

## Usage

When working on Temporal ${sdk_upper} applications, mention this skill in your prompts:

\`\`\`
Create a Temporal workflow with activities. Use the temporal-${sdk_name} skill.
\`\`\`

The skill will guide Claude to:
- Reference official Temporal documentation
- Use correct Temporal SDK APIs
- Follow best practices for workflows and activities
- Structure projects according to language conventions

## Skill Contents

- **${skill_basename}**: Main skill file with documentation references
- **references/**: Additional reference documentation (if available)
- **skill-metadata.json**: Metadata for Cloud skill management
- **README.md**: This file

## Links

- Official Temporal Documentation: https://docs.temporal.io/
- SDK Documentation: https://docs.temporal.io/develop/${sdk_name}
EOF
    print_success "Created package README"

    # Copy license if exists
    if [ -f "${SCRIPT_DIR}/LICENSE" ]; then
        cp "${SCRIPT_DIR}/LICENSE" "${pkg_dir}/"
        print_success "Copied LICENSE"
    fi

    print_success "Package structure created for ${sdk_name}"
}

# Validate all URLs in skill
validate_urls() {
    local package_name="$1"
    print_step "Validating URLs in skill package..."

    local pkg_dir="${BUILD_DIR}/${package_name}"
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
    local package_name="$1"
    print_step "Creating zip package..."

    local pkg_dir="${BUILD_DIR}/${package_name}"
    local zip_name="${package_name}-${TIMESTAMP}.zip"
    local zip_path="${DIST_DIR}/${zip_name}"

    # Create zip from within the build directory
    (cd "${BUILD_DIR}" && zip -r -q "${zip_path}" "${package_name}")

    # Create a latest symlink
    ln -sf "${zip_name}" "${DIST_DIR}/${package_name}-latest.zip"

    local size=$(du -h "${zip_path}" | cut -f1)
    print_success "Created zip package: ${zip_name} (${size})"

    echo ""
    echo -e "${GREEN}Package created successfully!${NC}"
    echo -e "  Location: ${zip_path}"
    echo -e "  Size: ${size}"
    echo -e "  Latest link: ${DIST_DIR}/${package_name}-latest.zip"
}

# Generate build report
generate_report() {
    local package_name="$1"
    local sdk_name="$2"
    local sdk_upper=$(echo "$sdk_name" | tr '[:lower:]' '[:upper:]')
    print_step "Generating build report..."

    local report="${DIST_DIR}/build-report-${sdk_name}.txt"
    local zip_latest="${DIST_DIR}/${package_name}-latest.zip"
    local skill_file=$(find "${BUILD_DIR}/${package_name}" -maxdepth 1 -name "temporal-*.md" | head -1)
    local skill_basename=$(basename "$skill_file")

    cat > "${report}" <<EOF
Temporal ${sdk_upper} Skill Package Build Report
=========================================

Build Time: $(date)
Package Name: ${package_name}
SDK: ${sdk_name}
Build Directory: ${BUILD_DIR}
Distribution Directory: ${DIST_DIR}

Files Included:
$(cd "${BUILD_DIR}/${package_name}" && find . -type f | sed 's|^\./|  - |')

Package Size: $(du -h "${zip_latest}" | cut -f1)
Package Location: ${zip_latest}

Skill Metadata:
$(cat "${BUILD_DIR}/${package_name}/skill-metadata.json" | sed 's/^/  /')

Installation Instructions:
--------------------------
For Claude Cloud:
  1. Navigate to Claude Cloud skill management
  2. Upload: ${zip_latest}
  3. Activate the skill for your projects

For Claude Code (Local):
  1. Extract ${skill_basename} from the zip
  2. Copy to your project: .claude/skills/${skill_basename}
  3. Reference in prompts: "Use the temporal-${sdk_name} skill"

Build completed successfully!
EOF

    print_success "Build report created: ${report}"
}

# Build a specific SDK
build_sdk() {
    local sdk_name="$1"
    local skip_url_check="$2"

    local sdk_dir="${SDKS_DIR}/${sdk_name}"

    if [ ! -d "$sdk_dir" ]; then
        print_error "SDK not found: ${sdk_name}"
        echo "Available SDKs:"
        list_sdks
        return 1
    fi

    # Find the skill file
    local skill_file=$(find "$sdk_dir" -maxdepth 1 -name "temporal-*.md" | head -1)
    if [ -z "$skill_file" ]; then
        print_error "No skill file found in ${sdk_dir}"
        return 1
    fi

    print_header "$sdk_name"

    # Validate skill file
    validate_skill "$skill_file" || return 1

    # Create package structure
    create_package_structure "$sdk_name" "$sdk_dir" || {
        print_error "Failed to create package structure"
        return 1
    }

    # Construct package name
    local package_name="temporal-${sdk_name}-skill"

    # Validate URLs
    if [ "$skip_url_check" = false ]; then
        validate_urls "$package_name" || {
            print_error "URL validation failed. Use --skip-url-check to skip this check."
            return 1
        }
    else
        print_step "Skipping URL validation (--skip-url-check)"
    fi

    # Create zip and report
    create_zip "$package_name"
    generate_report "$package_name" "$sdk_name"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       BUILD COMPLETED SUCCESSFULLY!            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  • Upload to Cloud: ${DIST_DIR}/${package_name}-latest.zip"
    echo "  • View report: ${DIST_DIR}/build-report-${sdk_name}.txt"
    local skill_basename=$(basename "$skill_file")
    echo "  • Test locally: Copy ${skill_basename} to .claude/skills/"
    echo ""
}

# Main build process
main() {
    # Parse arguments
    SKIP_URL_CHECK=false
    SDK_NAME=""
    BUILD_ALL=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-url-check)
                SKIP_URL_CHECK=true
                shift
                ;;
            --sdk)
                SDK_NAME="$2"
                shift 2
                ;;
            --all)
                BUILD_ALL=true
                shift
                ;;
            --list)
                list_sdks
                exit 0
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --sdk <name>        Build specific SDK (e.g., --sdk java)"
                echo "  --all               Build all available SDKs"
                echo "  --list              List available SDKs"
                echo "  --skip-url-check    Skip URL validation (faster builds)"
                echo "  --help, -h          Show this help message"
                echo ""
                echo "Examples:"
                echo "  $0 --sdk java                 # Build Java SDK skill"
                echo "  $0 --all                      # Build all SDK skills"
                echo "  $0 --sdk java --skip-url-check  # Fast build for Java"
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

    # Clean build directories
    clean_build

    # Determine what to build
    if [ "$BUILD_ALL" = true ]; then
        # Build all SDKs
        print_header
        echo "Building all SDKs..."
        echo ""

        for sdk_dir in "${SDKS_DIR}"/*; do
            if [ -d "$sdk_dir" ]; then
                local sdk=$(basename "$sdk_dir")
                build_sdk "$sdk" "$SKIP_URL_CHECK" || {
                    print_error "Failed to build ${sdk}"
                    continue
                }
            fi
        done
    elif [ -n "$SDK_NAME" ]; then
        # Build specific SDK
        build_sdk "$SDK_NAME" "$SKIP_URL_CHECK"
    else
        # Default: build java (backwards compatibility)
        if [ -d "${SDKS_DIR}/java" ]; then
            build_sdk "java" "$SKIP_URL_CHECK"
        else
            print_error "No SDK specified and default 'java' not found"
            echo ""
            list_sdks
            echo "Use --sdk <name> to build a specific SDK or --all to build all"
            exit 1
        fi
    fi
}

# Run main
main "$@"
