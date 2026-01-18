#!/bin/bash
set -e  # Exit immediately on error

# ---- Configuration ----
REMOTE="turbo-units"          # Name of the units remote
URL="https://github.com/pappscalle/turbo-units.git"  # Remote URL
BRANCH="main"                 # Branch to use
PREFIX="src/external"         # Where the subtree will live

# ---- Step 0: Check working tree ----
if ! git diff-index --quiet HEAD --; then
    echo "Error: working tree has uncommitted changes."
    echo "Commit or stash your changes before running this script."
    exit 1
fi

# ---- Step 1: Add remote if missing ----
if ! git remote get-url $REMOTE >/dev/null 2>&1; then
    echo "Adding remote $REMOTE..."
    git remote add $REMOTE $URL
fi

# ---- Step 2: Remove existing folder if present ----
if [ -d "$PREFIX" ]; then
    echo "Removing existing $PREFIX to prepare for subtree..."
    rm -rf "$PREFIX"
fi

# ---- Step 3: Fetch and add subtree ----
echo "Fetching $REMOTE/$BRANCH..."
git fetch $REMOTE $BRANCH

echo "Adding turbo-units subtree at $PREFIX..."
git subtree add --prefix=$PREFIX $REMOTE $BRANCH --squash

echo "Subtree setup complete! $PREFIX is now a proper subtree."
