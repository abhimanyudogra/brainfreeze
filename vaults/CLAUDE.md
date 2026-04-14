# LLM Wiki Vaults — Orchestration

Top-level instructions for LLM sessions working across your personal knowledge vaults. Each vault follows [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) with the brainfreeze augmentations (see README.md). Read this file first, then the relevant vault's `CLAUDE.md`.

## Owner

**{{Your Name}}** — update this section with your role, location, and any context that helps the LLM tailor recommendations across vaults.

## Vaults

| Vault | Path | Status | Description |
|---|---|---|---|
| Personal Finance | `vaults/personal-finance/` | Ready to use | Income, taxes, investments, budgeting, insurance, estate planning |
| Career | `vaults/career/` | Ready to use | Jobs, skills, compensation, networking, performance, growth |
| Health | `vaults/health/` | Ready to use | Physical fitness, mental health, medical, nutrition, sleep |

## Shared augmentation pattern

All vaults use:

1. `.drafts/` dotfolder for change-preview before writes
2. Three-state provenance with inference-DAG tracking (`[^e]` extracted / `[^i]` inferred from explicit parents / `[^a]` ambiguous)
3. Typed YAML relations (`supports`, `contradicts`, `supersedes`, `derives-from`, `depends-on`, `relates-to`)
4. Source-to-page routing rules (vault-specific, in each vault's CLAUDE.md)
5. `.manifest.json` for delta ingest (SHA-256 per source)
6. Split lint: structural (every ingest) + semantic (on-demand)
7. Conversational pre-ingest before any drafts are written
8. Five page categories: `entities/`, `concepts/`, `decisions/`, `events/`, `strategy/`
9. One git commit per operation (local-only, no remote for personal vaults)
10. Strict templates with required sections

## Cross-vault context

Record facts here that span multiple vaults:

- _Example: "Employer compensation data lives in the finance vault but is also relevant for career salary benchmarking"_
- _Example: "HSA eligibility depends on health insurance plan (health vault) but the tax benefit lives in finance"_
- _Example: "Work stress patterns (career vault) connect to mental health tracking (health vault)"_

## User context

Durable facts about you that inform recommendations across all vaults. Update when things change.

- _Example: "Cash flow is tighter than gross income suggests — factor this into any savings recommendations"_
- _Example: "Prefers action over lengthy discussion — don't over-plan when the path is clear"_
- _Example: "Target retirement age: ~60"_

## Resume state

Updated by the LLM after each session. New sessions read this to know where to pick up.

### Personal Finance
- **Last activity:** _(not yet started)_
- **Next steps:** Drop first raw source into `sources/`, run first ingest

### Career
- **Last activity:** _(not yet started)_
- **Next steps:** Drop resume or LinkedIn export, run first ingest

### Health
- **Last activity:** _(not yet started)_
- **Next steps:** Drop first health document, run first ingest

## Starting a new session

1. Read this file.
2. Check "Resume state" for what was done last and what's next.
3. If working in a specific vault, also read that vault's `CLAUDE.md`, `index.md`, and recent entries in `log.md`.
4. Respond to the user.
