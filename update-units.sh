#!/bin/bash
set -e  # Exit on error

# ---- Configuration ----
REMOTE="turbo-units"          # Remote name of the units repo
BRANCH="main"                 # Branch to pull from
PREFIX="src/external"         # Where subtree lives in TEMPLATE

# ---- Fetch latest changes ----
echo "Fetching latest from $REMOTE..."
git fetch $REMOTE $BRANCH

# ---- Pull updates into subtree ----
echo "Updating subtree at $PREFIX..."
git subtree pull --prefix=$PREFIX $REMOTE $BRANCH --squash

echo "Subtree update complete!"
