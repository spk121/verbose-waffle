#!/bin/bash

#
# Script Name: update_repo.sh
#
# Description:
#   Updates a destination file in a Git submodule directory (DATADIR) with content from a source file
#   and commits the change to Git if necessary. Ensures the submodule is on the master branch and
#   up to date with origin's master branch using a rebase before committing.
#
# Usage:
#   $0 DATADIR DEST_FILE SRC_FILE COMMIT_MSG
#
# Arguments:
#   DATADIR     - The submodule directory where the destination file is stored.
#   DEST_FILE   - The filename in DATADIR to be updated or created.
#   SRC_FILE    - The full path to the source file providing the content.
#   COMMIT_MSG  - The message for the Git commit if a commit is performed.
#
# Behavior:
#   - Assumes DATADIR is an initialized Git submodule (does not handle initialization).
#   - Switches DATADIR to the master branch and updates it to origin/master with rebase.
#   - Exits with an error if SRC_FILE does not exist or Git operations fail.
#   - Updates DEST_FILE with SRC_FILE content and commits if changes are detected.
#   - If DEST_FILE is identical to SRC_FILE, exits without changes.
#
# Exit Codes:
#   0 - Success (files identical or update committed).
#   1 - Error (invalid arguments, file not found, Git failure).
#

# Check for correct number of arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 DATADIR DEST_FILE SRC_FILE COMMIT_MSG"
    exit 1
fi

# Assign arguments to variables
DATADIR="$1"
DEST_FILE="$2"
SRC_FILE="$3"
COMMIT_MSG="$4"

# Change to DATADIR
cd "$DATADIR" || {
    echo "Error: Failed to change to directory $DATADIR"
    exit 1
}

# Fetch the latest changes from origin
git fetch origin
if [ $? -ne 0 ]; then
    echo "Error: Git fetch failed in $DATADIR"
    exit 1
fi

# Try to checkout master; if it fails, create it from origin/master
if ! git checkout master 2>/dev/null; then
    git checkout -b master origin/master
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create master branch in $DATADIR"
        exit 1
    fi
fi

# Pull with rebase to update to origin/master
git pull --rebase origin master
if [ $? -ne 0 ]; then
    echo "Error: Git pull --rebase failed in $DATADIR"
    exit 1
fi

# Check if SRC_FILE exists
if [ ! -f "$SRC_FILE" ]; then
    echo "Error: Source file $SRC_FILE does not exist"
    exit 1
fi

# Update and commit logic
if [ -f "$DEST_FILE" ]; then
    # Destination exists; compare with source
    if cmp -s "$SRC_FILE" "$DEST_FILE"; then
        echo "Destination file $DEST_FILE is identical to source file $SRC_FILE"
        exit 0
    else
        # Files differ; update and commit
        cp "$SRC_FILE" "$DEST_FILE" || {
            echo "Error: Failed to copy $SRC_FILE to $DEST_FILE"
            exit 1
        }
        git add "$DEST_FILE"
        git commit -m "$COMMIT_MSG" || {
            echo "Error: Git commit failed"
            exit 1
        }
        echo "Updated $DEST_FILE and committed changes"
    fi
else
    # Destination doesn’t exist; copy and commit
    cp "$SRC_FILE" "$DEST_FILE" || {
        echo "Error: Failed to copy $SRC_FILE to $DEST_PATH"
        exit 1
    }
    git add "$DEST_FILE"
    git commit -m "$COMMIT_MSG" || {
        echo "Error: Git commit failed"
        exit 1
    }
    echo "Created $DEST_FILE and committed changes"
fi

exit 0