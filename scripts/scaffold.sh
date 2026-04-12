#!/bin/bash
# scaffold.sh — Create a new brainfreeze vault
#
# Usage: ./scripts/scaffold.sh <vault-name> [parent-dir]
# Example: ./scripts/scaffold.sh personal-finance ~/vaults
#          ./scripts/scaffold.sh career ~/vaults

set -euo pipefail

VAULT_NAME="${1:?Usage: scaffold.sh <vault-name> [parent-dir]}"
PARENT_DIR="${2:-$(pwd)}"
VAULT_PATH="$PARENT_DIR/$VAULT_NAME"

if [ -d "$VAULT_PATH" ]; then
    echo "Error: $VAULT_PATH already exists"
    exit 1
fi

echo "Creating vault: $VAULT_PATH"

# Create directory structure
mkdir -p "$VAULT_PATH"/{entities,concepts,decisions,events,strategy,templates,sources,.drafts}

# Create .gitignore
cat > "$VAULT_PATH/.gitignore" << 'EOF'
.obsidian/workspace*
.obsidian/workspace.json
.trash/
*.tmp
EOF

# Create empty manifest
cat > "$VAULT_PATH/.manifest.json" << 'EOF'
{
  "version": 1,
  "updated": "",
  "sources": {}
}
EOF

# Create stub index.md
cat > "$VAULT_PATH/index.md" << 'EOF'
# Wiki Index

Catalog of every active page, grouped by category. Updated on every ingest.

## Entities

_(no entries yet)_

## Concepts

_(no entries yet)_

## Decisions

_(no entries yet)_

## Events

_(no entries yet)_

## Strategy

_(no entries yet)_

---

## Archived

_(no archived pages yet)_
EOF

# Create stub log.md
cat > "$VAULT_PATH/log.md" << EOF
# Activity Log

Append-only record. Newest first.

---

## [$(date +%Y-%m-%d)] init | vault scaffolded

Created directory structure from brainfreeze template. No wiki pages yet. Next step: copy a vault-specific CLAUDE.md from the brainfreeze repo, customize it, and run the first ingest.
EOF

# Initialize git
cd "$VAULT_PATH"
git init -q
git add -A
git commit -q -m "init: scaffold from brainfreeze template"

echo ""
echo "Vault created at: $VAULT_PATH"
echo ""
echo "Next steps:"
echo "  1. Copy a CLAUDE.md from brainfreeze/vaults/<type>/ into $VAULT_PATH/"
echo "  2. Copy templates from brainfreeze/vaults/<type>/templates/ into $VAULT_PATH/templates/"
echo "  3. Edit CLAUDE.md — fill in {{placeholders}} with your info"
echo "  4. Open $VAULT_PATH in Obsidian (File → Open folder as vault)"
echo "  5. Open Claude Code: cd $VAULT_PATH && claude"
echo "  6. Drop a source file and say 'ingest this'"
