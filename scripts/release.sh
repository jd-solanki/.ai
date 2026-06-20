#!/usr/bin/env bash
set -euo pipefail

# bumpp updates text files (like README.md) by find-replacing the *current*
# version with the *new* version. So README must contain the current version
# before bumpp runs. Sync it here in case it has drifted from package.json.
CURRENT_VERSION=$(node -p "require('./package.json').version")
sed -i -E "s|(jd-solanki/\.ai@v)[0-9]+\.[0-9]+\.[0-9]+|\1${CURRENT_VERSION}|" README.md

# bumpp now bumps both files from CURRENT_VERSION -> new version in one
# release commit/tag, so README ends up with the bumped version.
bumpp package.json README.md
