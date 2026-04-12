# Security & Encryption Guide

Your wiki contains personal data — financial records, medical history, career details. This guide covers how to protect it.

## Threat model

You're defending against:

1. **Laptop theft / loss** — someone gets physical access to your disk
2. **Accidental exposure** — pushing a vault to a public repo, cloud-syncing sensitive files
3. **LLM data leakage** — the LLM sending your data to external services
4. **Household access** — someone borrowing your laptop and opening Obsidian

You're probably NOT defending against:

- Nation-state adversaries (if you are, you need more than this guide)
- Insider threats at your LLM provider (use local models if this concerns you)

## Layer 1: Disk encryption (baseline — do this first)

Full-disk encryption protects against physical theft. Without it, every other defense is theater.

| OS | Tool | How to verify |
|---|---|---|
| Windows | BitLocker | Settings → Privacy & Security → Device Encryption |
| macOS | FileVault | System Settings → Privacy & Security → FileVault |
| Linux | LUKS | `lsblk -o NAME,FSTYPE,MOUNTPOINT` — look for `crypto_LUKS` |

**Action:** Verify disk encryption is ON. If it's not, enable it now. Everything else in this guide assumes this is done.

## Layer 2: Content discipline (enforced by CLAUDE.md)

Even with encryption, limit what's stored in plain text:

- **Account numbers:** last-4 digits only. Never full account numbers in page bodies.
- **SSN:** Never. Not even last-4 in wiki text. If you need it, reference the raw source file.
- **Passwords / API keys:** Never in the vault. Use a password manager.
- **Full addresses:** City + state is fine; omit apartment/unit numbers.

These rules are in every vault's `CLAUDE.md` as hard rules. Structural lint checks for common patterns (sequences of 9+ digits, "SSN", etc.) and flags violations.

## Layer 3: Network isolation

- **No remote git.** Personal vaults are `git init` with no `git remote add`. Ever. If you want to share the wiki *structure* (not data), create a separate clean repo like brainfreeze.
- **No Obsidian Sync.** Disable it in Obsidian Settings → Core Plugins → Sync (off).
- **No cloud backup of vault folders.** Exclude your vault directory from OneDrive, iCloud, Google Drive, Dropbox. These services sync files to their servers.
- **LLM network calls:** Claude Code sends prompts to Anthropic's API. If your vault contains data you don't want leaving your machine, use a local model (Ollama, llama.cpp) instead. See [kytmanov/obsidian-llm-wiki-local](https://github.com/kytmanov/obsidian-llm-wiki-local) for a local-only setup.

## Layer 4: Vault-level encryption (optional, recommended for health/finance)

[Cryptomator](https://cryptomator.org/) (open-source, cross-platform) creates a password-protected encrypted container that looks like a regular folder when mounted.

### Setup

1. Install Cryptomator (free on desktop; paid on mobile)
2. Create a new vault in Cryptomator pointing at your wiki folder (e.g., `~/vaults/personal-finance/`)
3. Cryptomator encrypts the folder contents; you get a virtual drive that decrypts on mount
4. Open the *mounted* drive path in Obsidian (not the encrypted folder)
5. When done, lock the vault in Cryptomator — files are encrypted at rest

### Workflow

```
Start session:
  1. Open Cryptomator → unlock vault → mount drive
  2. Open Obsidian → vault is at the mount point
  3. Open Claude Code → cd to the mount point
  4. Work normally

End session:
  1. Close Obsidian
  2. Lock vault in Cryptomator
  3. Files are encrypted on disk
```

### Which vaults need it?

| Vault | Sensitivity | Recommendation |
|---|---|---|
| Health | High (medical records, therapy notes) | Strongly recommended |
| Personal Finance | High (tax returns, account numbers, net worth) | Recommended |
| Career | Medium (compensation, reviews) | Optional |

## Layer 5: Per-category sensitivity (health vault)

The health vault's `CLAUDE.md` adds a `sensitivity` field to frontmatter:

- `standard` — fitness logs, nutrition, general wellness
- `elevated` — lab results, prescriptions, diagnoses
- `restricted` — therapy notes, mental health details

Therapy notes have a special rule: **never store verbatim therapist quotes or session transcripts**. Only your own summaries of insights and action items. The wiki aids reflection; it's not a clinical record.

## What NOT to do

- Don't push a personal vault to GitHub (even private repos can leak via collaborator invites, GitHub support access, or account compromise)
- Don't use Obsidian plugins that phone home with your vault contents (check plugin source if unsure)
- Don't store raw source files (PDFs, tax returns) in a cloud-synced folder — keep them local
- Don't share your vault's `.git` directory (it contains full history of every page, including deleted content)
- Don't use `--no-verify` on git hooks that check for sensitive patterns

## Incident response

If you suspect your vault was exposed:

1. **Change passwords** for any accounts whose identifiers appear in the vault (even last-4 can narrow an attack)
2. **Rotate API keys** if any were accidentally stored
3. **Monitor financial accounts** for unusual activity (enable alerts)
4. **Review git history** — `git log --all --oneline` to see if sensitive data was ever committed, even if later removed (it's still in history). Use `git filter-repo` to scrub if needed.
5. **Enable credit monitoring** if SSN exposure is possible
