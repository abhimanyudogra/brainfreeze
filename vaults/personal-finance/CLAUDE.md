# Personal Finance Wiki — Claude Code Schema

This is an **LLM-maintained knowledge wiki** for personal finance. It follows Andrej Karpathy's LLM Wiki pattern (https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) with augmentations drawn from community implementations (Ar9av/obsidian-wiki, NicholasSpisak/second-brain, kytmanov/obsidian-llm-wiki-local) and Reddit feedback.

Obsidian is the human reader. Claude Code is the writer. Plain markdown is the contract between them.

## Owner and scope

- **Owner:** {{Your Name}} — {{Your Role}} at {{Employer}}, {{City}}.
- **Scope:** Personal finance only (career and health live in separate vaults).
- **Privacy:** Local-only. No remote git. No cloud sync. Raw statements and PDFs never leave this machine. Last-4 digits only when referencing accounts in page bodies.

## Three layers

1. **Raw sources** (immutable) — the wiki reads from two locations:
   - **Shared with the reporting project** at `{{reporting-project-path}}`:
     - `data/archive/*` — raw PDFs, CSVs, XLSX (tax returns, paystubs, statements, 1099s)
     - `data/processed/*` — structured JSON/CSV extracted by the reporting project's Python scripts
     - `specialists/*/learnings.md` — domain expert notes from dashboard work
     - `SESSION_STATE.md`, `CHECKIN_WORKFLOW.md`, `CLAUDE.md` — project context
   - **Vault-only** at `{{vault-path}}/sources/`:
     - Articles, advisor letters, research notes, clipped pages, meeting transcripts, draft legal documents — anything the reporting project doesn't need
   - Both locations are **never edited** by wiki operations. They are the source of truth.

2. **The wiki** (LLM-owned) — everything under this vault (`{{vault-path}}`) except the raw `sources/` folder. Claude creates, updates, and cross-links pages. User edits are welcome.

3. **The schema** (this file) — the rules Claude follows when writing the wiki.

## Raw source policy

Configure the two raw-source locations by replacing the `{{placeholders}}` in the "Three layers" section above with your actual paths:
- `{{reporting-project-path}}` — the root of your finance reporting/dashboard project (e.g., `/home/user/projects/personal-finance/`)
- `{{vault-path}}` — the root of this Obsidian vault (e.g., `/home/user/vaults/personal-finance/`)

Policy:
- The wiki has **no dependency on the reporting pipeline**. It can ingest from raw PDFs/CSVs or from processed JSONs, whichever exists.
- When processed data is available for a raw source (e.g., `tax_summary_YYYY.json` exists for `YYYY_FEDERAL_RETURN.pdf`), **prefer the processed version** — higher signal, pre-parsed, verified.
- When a document is new: the user drops it wherever it naturally belongs. Finance documents that feed reporting go into `{{reporting-project-path}}/data/` by the existing check-in workflow. Vault-only documents go into `sources/`. Ingest works from either.
- The wiki's `sources/` folder is *owned by the user*, not Claude. Claude reads from it but never writes to it or moves files out of it.

## Page categories

Every wiki page lives in exactly one category folder. Categories define intent, not just topic.

| Folder | Contains | Example filenames |
|---|---|---|
| `entities/` | People, employers, accounts, institutions, legal entities | `{{employer-kebab}}.md`, `{{broker}}-stock-plan.md`, `{{bank}}-checking.md`, `{{accountant}}.md` |
| `concepts/` | Reusable domain knowledge: tax rules, investment concepts, definitions | `capital-loss-carryforward.md`, `espp-qualified-disposition.md`, `wash-sale-rule.md`, `safe-harbor-withholding.md` |
| `decisions/` | Explicit choices the user is making or considering | `max-401k-contribution.md`, `diversify-position.md`, `backdoor-roth-ira.md`, `rent-vs-buy.md` |
| `events/` | Time-bounded occurrences: tax years, vests, grants, windfalls, audits | `tax-year-YYYY.md`, `rsu-grant-XXXXXX.md`, `q1-YYYY-rsu-vest.md` |
| `strategy/` | Long-horizon plans that tie decisions together | `tax-optimization.md`, `retirement-plan.md`, `diversification-plan.md` |

Rule: if you cannot confidently place a new page in one category, ask the user before creating it.

## Special files and folders

- **`index.md`** — catalog of every active wiki page, grouped by category, one line per page: `- [[entities/{{employer}}]] — {{Employer}}, employer since YYYY, primary income source`. Updated on every ingest. Never contains claims; only pointers and summaries.
- **`log.md`** — append-only chronological record (newest first). One entry per ingest, query-that-became-a-page, lint run, refactor, or prune. Format:
  ```markdown
  ## [YYYY-MM-DD] ingest | seed from specialists/tax-strategist/learnings.md
  Created: concepts/capital-loss-carryforward.md, events/tax-year-YYYY.md, ...
  Updated: index.md
  Provenance: 12 extracted, 4 inferred, 1 ambiguous
  Notes: Flagged $X,XXX potential tax error for user review — see events/tax-year-YYYY#open-questions
  ```
- **`.drafts/`** — hidden staging folder (Obsidian hides dotfolders by default). All ingest writes go here first. User reviews drafts in Obsidian, then gives approval, then Claude promotes drafts to their live category folders. Never commit drafts to git — they are ephemeral.
- **`.manifest.json`** — source-to-page mapping used for delta ingests. See "Manifest" section below.
- **`templates/*.md`** — strict page skeletons. Claude must use these when creating new pages. Never skip required sections.
- **`sources/`** — vault-only raw material. User-owned, read-only for Claude.

## Frontmatter schema

Every non-special page has YAML frontmatter. Fields:

```yaml
---
title: Capital Loss Carryforward
category: concept               # entity | concept | decision | event | strategy
status: active                  # active | superseded | archived | draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tax, losses]
relations:
  supports: []                  # this page reinforces these pages
  contradicts: []               # this page is incompatible with these pages
  supersedes: []                # this page replaces these pages
  derives-from:                 # source pages/files that justify this page's claims
    - "{{reporting-project-relative-path}}/data/processed/tax_summary_YYYY.json"
  depends-on: []                # pages whose claims must be true for this page to hold
  relates-to: []                # weak association, no causal link
provenance:                     # rollup count of the inline citation tags (see below)
  extracted: 0
  inferred: 0
  ambiguous: 0
sources:                        # page-level source list, one entry per raw file cited inline
  - path: {{reporting-project-relative-path}}/data/processed/tax_summary_YYYY.json
    sha256:                     # filled by Claude when computing the manifest
    verified: YYYY-MM-DD
---
```

**Relation semantics** (use these precisely):
- `supports` — this page's claims reinforce another page's claims
- `contradicts` — this page says something incompatible with another page; one is wrong or stale
- `supersedes` — this page replaces another page (the old one becomes `status: superseded`)
- `derives-from` — this page's facts come from these raw sources or upstream wiki pages
- `depends-on` — this page is valid only while the referenced pages remain valid (e.g., `decisions/max-401k` depends on `concepts/401k-contribution-limits-YYYY`)
- `relates-to` — fuzzy association; prefer a stronger relation if one fits

**Status semantics:**
- `active` — currently correct and in use
- `superseded` — replaced by a newer page via `supersedes`; kept for history
- `archived` — no longer relevant, decided-against, or rolled back; kept for audit
- `draft` — work in progress, do not cite

## Provenance tagging (the three-state protocol)

Every factual claim in a page body carries an inline citation tag. Tags are footnote-style and declare **how** the claim is supported:

- `[^e<n>]` — **extracted**: the claim is directly copied or summarized from a raw source. The footnote body must cite the source file and quote the exact text.
- `[^i<n>]` — **inferred**: the claim is LLM synthesis. The definition line **must** begin with `inferred from [^X1], [^X2], ... — rationale`, where each `[^X]` is an existing parent tag (`[^e]`, `[^i]`, or `[^a]`) on the same page. This turns the provenance space into a small DAG — lint walks it to compute how deep each claim sits from extracted ground truth.
- `[^a<n>]` — **ambiguous**: two or more sources disagree about the claim. The footnote body must list all conflicting sources and their values; the page body must treat the claim as unresolved and link to an "open question."

Example body snippet:

```markdown
In YYYY, total federal tax was $XX,XXX [^e1], which implies an effective
federal rate of XX.X% on AGI of $XXX,XXX [^i1]. A potential $X,XXX
over-statement of capital loss [^a1] is under review.

[^e1]: extracted — {{reporting-project-relative-path}}/data/processed/tax_summary_YYYY.json
       field: `total_tax` = XXXXX
[^i1]: inferred from [^e1], [^e2] — effective federal rate = total_tax / AGI
       ([^e2] = tax_summary_YYYY.json field `agi` = XXXXXX)
[^a1]: ambiguous — tax_summary_YYYY.json reports capital_loss_carryforward = XXXXX
       (implied gross loss XXXXX); reconstruction from 1099-B + supplement totals
       XXXXX. Gap of $X,XXX traced to qualifying dispositions.
       See [[events/tax-year-YYYY#open-question-section]].
```

**Roll-up to frontmatter.** The `provenance:` block in frontmatter is just the count of each tag type in the body. Lint will enforce that the counts match.

**Hard rules:**
- Every numeric value or dated fact in the body must have a tag. No tag, no claim.
- A page with `provenance.extracted == 0` and `inferred > 0` is a synthesis-only page (e.g., `strategy/`) and is acceptable, but the inferred tags must point at pages that *do* have extracted backing.
- Every `[^i]` definition must cite its parents via `inferred from [^X1], [^X2]`. A `[^i]` with no parents, unknown parents, or a chain deeper than 3 hops to any `[^e]` leaf is a lint error — either ground the inference in a new `[^e]` or split the page so the deep inference becomes its own concept page with its own extracted backing.
- A page with `ambiguous > 0` is automatically flagged by lint and must have at least one `open questions` entry naming the discrepancy.

## Source-to-page routing rules

When ingesting common finance document types, follow these deterministic routing rules. These make ingest predictable and lintable. If a document type is not listed, ask the user during the pre-ingest conversation.

| Source type | Folder pattern | Creates / updates |
|---|---|---|
| W-2 (PDF or JSON) | `data/archive/w2/`, `data/processed/w2_*.json` | UPDATE `events/tax-year-<YYYY>.md` income section; UPDATE `entities/{{employer}}.md` history |
| Paystub (PDF) | `data/archive/paystubs/` | APPEND to `events/tax-year-<current>.md` YTD totals; UPDATE `entities/{{employer}}.md` if first stub of the year |
| Tax return (PDF or JSON summary) | `data/archive/tax-returns/`, `data/processed/tax_summary_*.json` | CREATE/UPDATE `events/tax-year-<YYYY>.md`; UPDATE `concepts/capital-loss-carryforward.md` if applicable; UPDATE `concepts/safe-harbor-withholding.md` |
| 1099 (any) | `data/archive/*/1099*`, `data/processed/1099_*.json` | UPDATE `events/tax-year-<YYYY>.md` investment income section; UPDATE `entities/<broker>.md` |
| Bank statement CSV | `data/archive/{{bank}}-checking/` | UPDATE `entities/{{bank}}-checking.md` latest-balance section; append to `events/cashflow-<YYYY-MM>.md` if month-level event page exists |
| Credit card CSV | `data/archive/{{card-issuer}}-*/` | UPDATE `entities/{{card-issuer}}-*.md` latest-balance; feed into spending concept pages if relevant |
| 401(k) statement | `data/archive/{{401k-custodian}}/`, `data/processed/401k_*.{csv,json}` | UPDATE `entities/{{401k-custodian}}.md` balance + allocation; update `decisions/max-401k-contribution.md` status section |
| Brokerage holdings / equity plan | `data/archive/{{broker}}/`, `data/processed/{{broker}}_*.json` | UPDATE `entities/{{broker}}-stock-plan.md`; UPDATE RSU grant event pages; UPDATE relevant concept pages |
| Other brokerage holdings | `data/archive/{{broker}}/`, `data/processed/{{broker}}_*.{csv,json}` | UPDATE `entities/{{broker}}.md` positions + income |
| Advisor letter / meeting notes | `sources/` | Ask user — these often trigger new `decisions/` or `strategy/` pages |
| News article / research clip | `sources/` | Append to a relevant `concepts/` page as supporting material; may not warrant its own page |

**Rule:** A single ingest should never touch more than ~15 pages. If a routing rule expands beyond that, batch by time window (e.g., one quarter at a time) and split into multiple ingests.

## The five operations

### 1. Ingest — add facts from a new or updated raw source

1. **Identify sources.** The user names specific files or provides a batch. Compute SHA-256 of each source file. Check `.manifest.json`:
   - If a source's hash matches and it has been ingested before, skip it (unless user forces re-ingest with `--force`).
   - Print the skip list to the user so they know nothing is lost.
2. **Read sources fully.** Do not skim. For binary formats the reporting project has already parsed (PDFs to JSON), prefer the processed JSON.
3. **Have a pre-write conversation.** Before touching the drafts folder, report to the user in plain chat:
   - Key facts extracted (bulleted)
   - Surprises or findings (bulleted)
   - Open questions / ambiguities (bulleted)
   - Planned page changes (create/update list per routing table)
   - Anything that looks like a contradiction with existing wiki pages

   Wait for user response. The user may correct emphasis, redirect scope, flag data you missed, or veto pages. **This is the "don't delegate understanding" checkpoint — it is not optional.**
4. **Write drafts to `.drafts/`.** For every planned change:
   - New pages: write the full markdown using the matching template, with frontmatter, provenance tags, and body content.
   - Updates to existing pages: write BOTH the old version (as `.drafts/<path>.before`) AND the proposed new version (as `.drafts/<path>`). This lets the user diff visually in Obsidian.
   - Mirror the live folder structure inside `.drafts/` (e.g., new `entities/example.md` goes to `.drafts/entities/example.md`).
5. **Report drafts ready.** Tell the user: "N drafts written to `.drafts/`; review in Obsidian." Give the list of paths.
6. **Wait for approval.** The user reads the drafts in Obsidian. They may:
   - Approve all: reply "merge" or "looks good"
   - Approve selectively: "merge everything except `decisions/foo.md`, reject that one"
   - Edit drafts directly in Obsidian, then say "merge" — Claude must read the edited drafts, not regenerate
   - Reject all: "scrap this ingest"
7. **Promote to live.** Move approved drafts from `.drafts/` to their live locations. Overwrite existing pages. Delete any `.before` companions. Delete rejected drafts.
8. **Update bookkeeping.**
   - Update `index.md` — add/update catalog lines for every touched page.
   - Append to `log.md` — one entry summarizing source, created/updated counts, provenance mix, open questions.
   - Update `.manifest.json` — record source hash, timestamp, and the list of pages produced.
9. **Git commit.** One commit per ingest, message format: `ingest: <source-short-name> — <N> pages (<created> created, <updated> updated)`.
10. **Run structural lint.** Report findings; offer fixes but do not auto-apply.

### 2. Query — answer a question from the wiki

1. Read `index.md` to locate relevant pages.
2. Grep the wiki for additional matches beyond the index.
3. Answer the question in plain prose, with **inline citations back to wiki pages** (e.g., `[[events/tax-year-YYYY]]`).
4. If a relevant claim has no wiki source, do NOT answer from raw files silently — tell the user the wiki is missing coverage and suggest an ingest.
5. If the answer is high-value and synthesizes across multiple pages, offer to file it back as a new `strategy/` or `concepts/` page. Use the ingest procedure (drafts + approval) to write it.
6. Log the query in `log.md` only if a new page resulted.

### 3. Lint — audit wiki integrity

Lint runs in two tiers.

**Structural lint** — runs automatically at the end of every ingest. Zero LLM cost; pure grep and YAML parsing. Checks:

1. **Broken wikilinks** — any `[[...]]` target that does not exist.
2. **Orphan pages** — pages with zero backlinks and not listed in `index.md`.
3. **Missing provenance** — pages with numeric values or dated facts in the body but no `[^e]`/`[^i]`/`[^a]` tags.
4. **Provenance rollup mismatch** — `provenance:` counts in frontmatter don't match inline tag counts in body.
5. **Empty required sections** — template required sections left as `_(no content yet)_` past a threshold (warn, don't fail).
6. **Stale index** — index.md out of sync with actual pages on disk.
7. **Frontmatter validation** — required fields present, enums valid, dates parseable.
8. **Contradiction map** — pages whose `relations.contradicts` targets are both still `status: active`.
9. **Ambiguous without question** — pages with `provenance.ambiguous > 0` but no open-questions entry.
10. **Archived referenced as active** — a live page cites an archived page without going through `supersedes`.
11. **Inference-chain depth** — parse each page's `[^i]` definitions and walk the DAG formed by `inferred from [^...]` citations. Warn when max depth > 2 (synthesis stacking on synthesis). Error when max depth > 3 (claim rooted 5+ levels from extracted ground) or when a cited parent tag is missing/malformed.
12. **Orphan inferences** — `[^i]` definitions with no `inferred from [^...]` clause, or whose parent chain never reaches an `[^e]` leaf (the claim is inference-only with no extracted root).

Structural lint reports a text diff-friendly summary. Failures do not block ingest; they are flagged for the user.

**Semantic lint** — runs on user request (`lint --semantic`) or on a cadence the user defines. LLM cost. Checks:

1. **Drift check** — for every page with `sources:`, re-read the cited raw files and verify the extracted values still match. Flag pages where the raw number changed but the wiki didn't.
2. **Freshness check** — pages whose `verified:` date is older than the threshold for their category (default: concepts 90d, events 30d, decisions 60d, entities 180d, strategy 30d).
3. **Cross-page contradiction detection** — scan for numeric claims about the same entity that disagree across pages.
4. **Inference regeneration** — for each `[^i]` claim, re-derive it from the extracted leaves in its parent chain and flag pages where the original rationale no longer holds (parent source values have changed, or the synthesis no longer follows).

Semantic lint produces an issue list; fixes go through the normal ingest procedure (drafts + approval + commit).

### 4. Refactor — restructure pages

When a page grows too large, splits into multiple topics, or an old decision is reversed:

1. Produce a change preview via the same drafts procedure as ingest.
2. On approval, mark old pages `status: superseded` with `relations.supersedes` filled in.
3. Update all backlinks to point to the new pages.
4. Update `index.md`, `log.md`.
5. Commit: `refactor: <what> — <pages-affected>`.

Refactors never delete pages.

### 5. Prune — archive stale material

When a decision is rolled back, an event is long past relevance, or a concept is no longer used:

1. Set `status: archived`.
2. Add a `## Archived reason` section in the body explaining why and when.
3. Move from `index.md` active sections to the archived section.
4. Append to `log.md`: `prune: <page> — <reason>`.
5. Commit: `prune: <page>`.

Never delete files from disk.

## Manifest

`.manifest.json` is the source-of-truth for what has been ingested. Structure:

```json
{
  "version": 1,
  "updated": "YYYY-MM-DDTHH:MM:SSZ",
  "sources": {
    "{{reporting-project-relative-path}}/data/processed/tax_summary_YYYY.json": {
      "sha256": "abc123...",
      "size_bytes": 2145,
      "last_ingested": "YYYY-MM-DDTHH:MM:SSZ",
      "produced_pages": [
        "events/tax-year-YYYY.md",
        "concepts/capital-loss-carryforward.md"
      ]
    }
  }
}
```

**Keys are paths relative to the vault root** (so `{{reporting-project-relative-path}}/...` for reporting sources, `sources/...` for vault-only sources).

On every ingest, Claude:
1. Computes SHA-256 of each source file.
2. Compares against `.manifest.json`.
3. If the hash matches the stored hash, the source is skipped (it is idempotent).
4. After successful promotion to live, updates the manifest with new hash, timestamp, and produced-pages list.

This guarantees monthly re-ingests (drop new paystubs, re-run monthly update) are idempotent — unchanged files don't regenerate pages.

## Git

The vault is a git repo, local-only.

- **No remote.** Never add one. Never push.
- **One commit per operation.** Ingest, refactor, prune, and lint-fix each produce exactly one commit.
- **Commit message format:** `<op>: <short-summary> — <pages-touched>`. Examples:
  - `ingest: tax-year-YYYY seed — 8 pages (6 created, 2 updated)`
  - `refactor: split concepts/tax-rates into federal + state — 4 pages`
  - `prune: decisions/hold-stock-long — rolled back`
- **`.drafts/` and `.manifest.json`** are committed. `.drafts/` because promotion is a separate commit; the manifest because it's the load-bearing idempotency record.
- **Undo**: `git reset --hard HEAD~1` reverts the last operation. Claude will never run this without explicit user instruction.
- **`.gitignore`** excludes: `.obsidian/workspace*`, `.trash/`, any `*.tmp` files.

## Security posture

This vault is local-only, single-user. Defenses in layer order:

1. **Disk encryption (assumed baseline)** — BitLocker (Windows) or LUKS/FileVault (Linux/macOS) on the drive containing the vault. User should verify this is active. Without full-disk encryption, every other defense is moot.
2. **Content discipline (enforced here)** — last-4 digits only for account numbers in page bodies. Never full SSN, routing, or card numbers anywhere in a wiki page. This rule is a hard-fail in structural lint.
3. **Network isolation (enforced here)** — no remote git, no cloud sync, no plugin-initiated network calls in Obsidian. User should disable Obsidian Sync.
4. **OS permissions** — vault is under the user's home dir; filesystem ACLs apply.

**Optional v2 opt-in: Cryptomator.** Open-source, cross-platform. Creates a password-protected encrypted container; you mount it before opening Obsidian, unmount when done. Adds a password to vault access without touching the vault's file format. Pick this up after the first draft is working — retrofitting mid-setup is friction.

**Not being done:** no git-crypt (fights Obsidian live-preview), no per-file encryption (breaks graph view), no app-level encryption inside the vault itself.

## Naming conventions

- All filenames: `lowercase-kebab-case.md`.
- Entity pages: canonical name. Use `{{employer}}.md`, not `{{employer}}-inc.md`. Use `{{broker}}-stock-plan.md` to disambiguate from a hypothetical personal brokerage account.
- Concept pages: noun form. `wash-sale-rule.md`, not `what-is-wash-sale.md`.
- Decision pages: imperative or noun phrase. `max-401k-contribution.md`, not `should-i-max-401k.md`. The question lives in the body.
- Event pages: include the time qualifier. `tax-year-YYYY.md`, `rsu-grant-XXXXXX.md`, `q1-YYYY-rsu-vest.md`.
- Strategy pages: short noun phrases. `tax-optimization.md`, `retirement-plan.md`.

## Linking conventions

- Use Obsidian wikilinks: `[[entities/{{employer}}]]`, `[[concepts/wash-sale-rule|wash sale]]` (alias after pipe).
- Link on first mention in a page body; don't over-link. Obsidian backlinks handle the rest.
- Typed relations go in frontmatter, not prose. Prose links are neutral associations; semantic weight lives in `relations:`.

## Templates

Required skeletons live in `templates/`:

- `templates/entity.md`
- `templates/concept.md`
- `templates/decision.md`
- `templates/event.md`
- `templates/strategy.md`

Every new page starts as a copy of the matching template. Claude may not skip required sections. If a section has no content yet, write `_(no content yet)_` explicitly so the gap is visible during lint.

## Relationship to the reporting project

The reporting project at `{{reporting-project-path}}` is **separate** but **adjacent**:

- Reporting project produces dashboards (React + Chart.js + Recharts), runs Python extraction scripts, owns `data/archive/` and `data/processed/`.
- Wiki reasons about meaning, strategy, and open questions; owns wiki pages and cross-references.

The wiki **reads from** the reporting project's `data/` tree but never writes to it. The wiki **does not run** the reporting project's scripts, regenerate JSONs, or touch the dashboard. If an ingest needs numbers that don't exist yet in `data/processed/`, the wiki can:
- Read the raw file directly (PDF, CSV, XLSX) and extract what it needs, OR
- Flag the gap and ask the user to run the reporting pipeline first

Either is valid. Prefer the processed JSON when it exists (higher signal, verified by the reporting project's QA pass).

## Hard rules

- **Never edit raw sources.** Not even to fix typos. Raw is immutable.
- **Never state a factual claim without a provenance tag.** `[^e]`, `[^i]`, or `[^a]` on every number or dated fact.
- **Never write a live page during ingest.** All writes go through `.drafts/` then user approval then promote. The only exception is `index.md` and `log.md` updates at the end of an approved ingest (they are bookkeeping, not facts).
- **Never delete files.** Archive instead. Even rejected drafts are deleted, not staged for later — but live pages never get `rm`-ed.
- **Never create a page outside the five categories.** Stop and ask.
- **Never use plugin-specific link syntax.** Keep the vault portable: plain Obsidian wikilinks, plain YAML frontmatter, plain markdown.
- **Relations are YAML block-lists of quoted wikilink strings.** Always write `depends-on:\n  - "[[entities/x]]"` — never `depends-on: [[entities/x], [entities/y]]`. The inline flow form is a YAML nested array, not a wikilink string, and every downstream consumer (lint, Dataview, this plugin's index) breaks on it. Same rule for `sources:` and every relation type.
- **Never invent cross-references.** Search before linking.
- **Last-4 digits only** for account numbers. No full account numbers, SSN, or routing numbers in any page body. This is a lint-enforced rule.
- **Never auto-fix lint findings.** Report them and offer fixes; apply only on user approval through the ingest procedure.

## Starting a new session

When opening this vault, first:

1. Read this file (`CLAUDE.md`).
2. Read `index.md` to understand the current wiki scope.
3. Read the last 20 entries in `log.md` for recent activity.
4. Read `.manifest.json` to know what sources have already been ingested.
5. Then respond to the user.

Do not read every page on every session. Use `index.md` summaries to decide what to fetch.
