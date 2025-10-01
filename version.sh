#!/bin/bash

# Script to manage project versioning

VERSION_FILE="VERSION"

# Display current version
current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Increment version
increment_version() {
    local version_type=$1
    local current=$(current_version)
    
    # Parse version parts
    IFS='.' read -ra VERSION_PARTS <<< "$current"
    major=${VERSION_PARTS[0]}
    minor=${VERSION_PARTS[1]}
    patch=${VERSION_PARTS[2]}
    
    case $version_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo "Usage: $0 {major|minor|patch}"
            exit 1
            ;;
    esac
    
    new_version="$major.$minor.$patch"
    echo "$new_version" > "$VERSION_FILE"
    echo "Version updated to $new_version"
    
    # Create git tag
    git add "$VERSION_FILE"
    git commit -m "Bump version to $new_version"
    git tag -a "v$new_version" -m "Version $new_version"
    echo "Created git tag v$new_version"
}

# Show usage
usage() {
    echo "Usage: $0 {show|major|minor|patch}"
    echo "  show   - Display current version"
    echo "  major  - Increment major version (X+1.0.0)"
    echo "  minor  - Increment minor version (X.Y+1.0)"
    echo "  patch  - Increment patch version (X.Y.Z+1)"
}

# Main
case $1 in
    show)
        current_version
        ;;
    major|minor|patch)
        increment_version $1
        ;;
    *)
        usage
        ;;
esac