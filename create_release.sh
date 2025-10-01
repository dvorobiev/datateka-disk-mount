#!/bin/bash

# Script to create a GitHub release for the project
# Usage: ./create_release.sh <github_token>

# Check if token is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <github_token>"
    echo "Please provide a GitHub personal access token with 'repo' scope"
    exit 1
fi

GITHUB_TOKEN=$1
REPO_OWNER="dvorobiev"
REPO_NAME="datateka-disk-mount"
TAG_NAME="v1.1.0"
RELEASE_NAME="Version 1.1.0"
RELEASE_NOTES_FILE="RELEASE_NOTES_v1.1.0.md"
ASSET_FILE="datateka_disk_manager_light.tar.gz"

# Check if release notes file exists
if [ ! -f "$RELEASE_NOTES_FILE" ]; then
    echo "Release notes file not found: $RELEASE_NOTES_FILE"
    exit 1
fi

# Check if asset file exists
if [ ! -f "$ASSET_FILE" ]; then
    echo "Asset file not found: $ASSET_FILE"
    exit 1
fi

# Read release notes
RELEASE_NOTES=$(cat "$RELEASE_NOTES_FILE")

# Create release using GitHub API
echo "Creating release $TAG_NAME..."

RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases \
  -d @- <<EOF
{
  "tag_name": "$TAG_NAME",
  "name": "$RELEASE_NAME",
  "body": "$RELEASE_NOTES",
  "draft": false,
  "prerelease": false
}
EOF
)

# Check if release was created successfully
if echo "$RESPONSE" | grep -q '"id"'; then
    echo "Release created successfully!"
    RELEASE_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
    echo "Release ID: $RELEASE_ID"
    
    # Upload asset
    echo "Uploading asset $ASSET_FILE..."
    curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: application/gzip" \
      --data-binary @"$ASSET_FILE" \
      "https://uploads.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/$RELEASE_ID/assets?name=$(basename $ASSET_FILE)"
    
    echo "Asset uploaded successfully!"
    echo "Release URL: https://github.com/$REPO_OWNER/$REPO_NAME/releases/tag/$TAG_NAME"
else
    echo "Failed to create release:"
    echo "$RESPONSE" | grep -o '"message": "[^"]*"' | head -1
    exit 1
fi