# Career Wiki — Claude Code Schema

This is an **LLM-maintained knowledge wiki** for career management. It follows Andrej Karpathy's LLM Wiki pattern (https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) with augmentations drawn from community implementations (Ar9av/obsidian-wiki, NicholasSpisak/second-brain, kytmanov/obsidian-llm-wiki-local) and Reddit feedback. Part of the **brainfreeze** multi-vault personal knowledge system.

Obsidian is the human reader. Claude Code is the writer. Plain markdown is the contract between them.

## Owner and scope

- **Owner:** {{Your Name}} — {{Job Title}} at {{Employer}}, {{Location}}.
- **Scope:** Career only (personal finance and health live in separate vaults).
- **Privacy:** Local-only. No remote git. No cloud sync. Resumes, offer letters, and performance reviews contain PII (home address, compensation figures, manager names). Last-4 only when referencing sensitive identifiers (employee IDs, badge numbers) in page bodies. Never store full SSN, home address, or personal phone number in any wiki page.

## Three layers

1. **Raw sources** (immutable) — the wiki reads from two locations:
   - **Shared with external tooling** (if applicable):
     - Resume source files, LinkedIn data exports, salary benchmarking CSVs, course completion records
     - Structured JSON/CSV extracted by any parsing scripts
   - **Vault-only** at `sources/`:
     - Resumes and CV drafts, LinkedIn profile exports, performance review PDFs, offer letters, salary data, job postings, course certificates, meeting notes with managers/mentors, 1:1 agendas, self-assessments, interview prep notes, side project READMEs, conference talk proposals
   - Both locations are **never edited** by wiki operations. They are the source of truth.

2. **The wiki** (LLM-owned) — everything under this vault except the raw `sources/` folder. Claude creates, updates, and cross-links pages. User edits are welcome.

3. **The schema** (this file) — the rules Claude follows when writing the wiki.

## Raw source policy

- When processed/structured data is available for a raw source (e.g., `linkedin_connections.csv` parsed from a LinkedIn export), **prefer the processed version** — higher signal, pre-parsed, verified.
- When a document is new: the user drops it into `sources/`. Ingest reads from there.
- The wiki's `sources/` folder is *owned by the user*, not Claude. Claude reads from it but never writes to it or moves files out of it.

## Page categories

Every wiki page lives in exactly one category folder. Categories define intent, not just topic.

| Folder | Contains | Example filenames |
|---|---|---|
| `entities/` | Employers, companies, people (managers, mentors, recruiters, sponsors), tools/platforms, universities, teams | `{{employer-slug}}.md`, `{{manager-name}}.md`, `{{university-slug}}.md`, `{{tool-name}}.md` |
| `concepts/` | Reusable career domain knowledge: negotiation tactics, equity compensation structures, career laddering, skill taxonomies, interview frameworks, management philosophies | `negotiation-anchoring.md`, `rsu-vesting-schedules.md`, `staff-engineer-archetype.md`, `star-method.md` |
| `decisions/` | Explicit choices the user is making or considering | `take-offer-{{company}}.md`, `pursue-promotion-to-{{level}}.md`, `switch-teams.md`, `start-side-project-{{name}}.md`, `negotiate-raise-{{year}}.md` |
| `events/` | Time-bounded occurrences: performance reviews, interviews, promotions, layoffs, conferences, project milestones | `performance-review-{{YYYY}}-h{{N}}.md`, `interview-at-{{company}}.md`, `promotion-to-{{level}}.md`, `layoff-round-{{YYYY-MM}}.md` |
| `strategy/` | Long-horizon plans that tie decisions together | `career-growth-plan.md`, `compensation-optimization.md`, `skill-development-roadmap.md`, `network-expansion-plan.md` |

Rule: if you cannot confidently place a new page in one category, ask the user before creating it.

## Special files and folders

- **`index.md`** — catalog of every active wiki page, grouped by category, one line per page: `- [[entities/{{employer-slug}}]] — {{Employer Name}}, employer since YYYY, {{role summary}}`. Updated on every ingest. Never contains claims; only pointers and summaries.
- **`log.md`** — append-only chronological record (newest first). One entry per ingest, query-that-became-a-page, lint run, refactor, or prune. Format:
  ```markdown
  ## [2026-04-11] ingest | seed from resume and performance reviews
  Created: entities/{{employer}}.md, events/performance-review-2025-h1.md, ...
  Updated: index.md
  Provenance: 8 extracted, 3 inferred, 1 ambiguous
  Notes: Flagged conflicting title between resume and LinkedIn export — see entities/{{employer}}#open-questions
  ```
- **`.drafts/`** — hidden staging folder (Obsidian hides dotfolders by default). All ingest writes go here first. User reviews drafts in Obsidian, then gives approval, then Claude promotes drafts to their live category folders. Never commit drafts to git — they are ephemeral.
- **`.manifest.json`** — source-to-page mapping used for delta ingests. See "Manifest" section below.
- **`templates/*.md`** — strict page skeletons. Claude must use these when creating new pages. Never skip required sections.
- **`sources/`** — vault-only raw material. User-owned, read-only for Claude.

## Frontmatter schema

Every non-special page has YAML frontmatter. Fields:

```yaml
---
title: Staff Engineer Archetype
category: concept               # entity | concept | decision | event | strategy
status: active                  # active | superseded | archived | draft
created: 2026-04-11
updated: 2026-04-11
tags: [career-ladder, engineering, ic-track]
relations:
  supports: []                  # this page reinforces these pages
  contradicts: []               # this page is incompatible with these pages
  supersedes: []                # this page replaces these pages
  derives-from:                 # source pages/files that justify this page's claims
    - "sources/performance-review-2025-h1.pdf"
  depends-on: []                # pages whose claims must be true for this page to hold
  relates-to: []                # weak association, no causal link
provenance:                     # rollup count of the inline citation tags (see below)
  extracted: 0
  inferred: 0
  ambiguous: 0
sources:                        # page-level source list, one entry per raw file cited inline
  - path: sources/performance-review-2025-h1.pdf
    sha256:                     # filled by Claude when computing the manifest
    verified: 2026-04-11
---
```

**Relation semantics** (use these precisely):
- `supports` — this page's claims reinforce another page's claims
- `contradicts` — this page says something incompatible with another page; one is wrong or stale
- `supersedes` — this page replaces another page (the old one becomes `status: superseded`)
- `derives-from` — this page's facts come from these raw sources or upstream wiki pages
- `depends-on` — this page is valid only while the referenced pages remain valid (e.g., `decisions/negotiate-raise` depends on `concepts/market-rate-for-role`)
- `relates-to` — fuzzy association; prefer a stronger relation if one fits

**Status semantics:**
- `active` — currently correct and in use
- `superseded` — replaced by a newer page via `supersedes`; kept for history
- `archived` — no longer relevant, decided-against, or rolled back; kept for audit
- `draft` — work in progress, do not cite

## Provenance tagging (the three-state protocol)

Every factual claim in a page body carries an inline citation tag. Tags are footnote-style and declare **how** the claim is supported:

- `[^e<n>]` — **extracted**: the claim is directly copied or summarized from a raw source. The footnote body must cite the source file and quote the exact text.
- `[^i<n>]` — **inferred**: the claim is LLM synthesis across one or more extracted facts. The footnote body must show the derivation (which extracted claims it combines).
- `[^a<n>]` — **ambiguous**: two or more sources disagree about the claim. The footnote body must list all conflicting sources and their values; the page body must treat the claim as unresolved and link to an "open question."

Example body snippet:

```markdown
Promoted to {{Level}} in {{Month YYYY}} [^e1], after N months at the
previous level — faster than the median M months for that band [^i1].
The performance review cites "exceeds expectations" but the calibration
doc lists "meets expectations" [^a1], which is under review.

[^e1]: extracted — sources/promotion-letter-YYYY-MM.pdf
       "Effective {{date}}, your title is {{Level}}."
[^i1]: inferred — computed from [^e1] promotion date minus [^e2] hire date
       ([^e2] = sources/offer-letter-YYYY.pdf start date = {{date}})
[^a1]: ambiguous — sources/performance-review-YYYY-hN.pdf says "exceeds"
       in Section 3; sources/calibration-notes-YYYY.md says "meets."
       See [[events/performance-review-YYYY-hN#rating-discrepancy]].
```

**Roll-up to frontmatter.** The `provenance:` block in frontmatter is just the count of each tag type in the body. Lint will enforce that the counts match.

**Hard rules:**
- Every numeric value or dated fact in the body must have a tag. No tag, no claim.
- A page with `provenance.extracted == 0` and `inferred > 0` is a synthesis-only page (e.g., `strategy/`) and is acceptable, but the inferred tags must point at pages that *do* have extracted backing.
- A page with `ambiguous > 0` is automatically flagged by lint and must have at least one `open questions` entry naming the discrepancy.

## Source-to-page routing rules

When ingesting common career document types, follow these deterministic routing rules. These make ingest predictable and lintable. If a document type is not listed, ask the user during the pre-ingest conversation.

| Source type | Folder pattern | Creates / updates |
|---|---|---|
| Resume / CV (PDF, DOCX) | `sources/resumes/` | UPDATE `entities/{{your-name}}.md` skills + experience; CREATE/UPDATE `events/career-milestone-*` for any new roles or promotions |
| LinkedIn profile export | `sources/linkedin/` | UPDATE `entities/{{your-name}}.md` headline + summary; UPDATE `entities/{{employer}}.md` for each listed role |
| LinkedIn connections export | `sources/linkedin/` | CREATE/UPDATE `entities/{{person}}.md` for key connections (managers, mentors, recruiters); UPDATE `index.md` |
| Performance review (PDF, DOCX) | `sources/performance-reviews/` | CREATE `events/performance-review-{{YYYY}}-h{{N}}.md`; UPDATE `entities/{{employer}}.md` tenure section; UPDATE `strategy/career-growth-plan.md` if growth areas identified |
| Self-assessment / brag doc | `sources/self-assessments/` | UPDATE the corresponding `events/performance-review-*.md`; may trigger new `entities/` pages for projects cited |
| Offer letter (PDF) | `sources/offers/` | CREATE `decisions/take-offer-{{company}}.md`; CREATE/UPDATE `entities/{{company}}.md` with comp details; UPDATE `strategy/compensation-optimization.md` |
| Salary / comp benchmarking data | `sources/compensation/` | UPDATE `concepts/market-rate-for-{{role}}.md`; UPDATE relevant `decisions/negotiate-*` pages |
| Job posting (PDF, HTML save) | `sources/job-postings/` | CREATE/UPDATE `entities/{{company}}.md` with role details; may trigger `decisions/apply-to-{{company}}.md` |
| Course certificate / transcript | `sources/education/` | UPDATE `entities/{{institution}}.md`; UPDATE `strategy/skill-development-roadmap.md` skills inventory |
| 1:1 / meeting notes (MD, TXT) | `sources/meeting-notes/` | Ask user — these often trigger updates to `entities/{{person}}.md`, `events/`, or new `decisions/` pages |
| Interview prep / debrief notes | `sources/interviews/` | CREATE/UPDATE `events/interview-at-{{company}}.md`; UPDATE relevant `concepts/` pages (e.g., system design patterns) |
| Conference / talk notes | `sources/conferences/` | CREATE `events/conference-{{name}}-{{YYYY}}.md`; UPDATE `strategy/network-expansion-plan.md` |
| Side project README / docs | `sources/side-projects/` | CREATE/UPDATE `entities/{{project-name}}.md`; UPDATE `strategy/skill-development-roadmap.md` |

**Rule:** A single ingest should never touch more than ~15 pages. If a routing rule expands beyond that, batch by time window (e.g., one quarter at a time) and split into multiple ingests.

## The five operations

### 1. Ingest — add facts from a new or updated raw source

1. **Identify sources.** The user names specific files or provides a batch. Compute SHA-256 of each source file. Check `.manifest.json`:
   - If a source's hash matches and it has been ingested before, skip it (unless user forces re-ingest with `--force`).
   - Print the skip list to the user so they know nothing is lost.
2. **Read sources fully.** Do not skim. For binary formats that have been pre-parsed (PDFs to structured text), prefer the processed version.
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
   - Mirror the live folder structure inside `.drafts/` (e.g., new `entities/{{employer}}.md` goes to `.drafts/entities/{{employer}}.md`).
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
3. Answer the question in plain prose, with **inline citations back to wiki pages** (e.g., `[[events/performance-review-2025-h1]]`).
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

Structural lint reports a text diff-friendly summary. Failures do not block ingest; they are flagged for the user.

**Semantic lint** — runs on user request (`lint --semantic`) or on a cadence the user defines. LLM cost. Checks:

1. **Drift check** — for every page with `sources:`, re-read the cited raw files and verify the extracted values still match. Flag pages where the raw data changed but the wiki didn't.
2. **Freshness check** — pages whose `verified:` date is older than the threshold for their category:
   - `entities` (companies, people): **180 days** — company info changes slowly; re-verify twice a year
   - `concepts` (frameworks, tactics): **90 days** — domain knowledge evolves; quarterly refresh
   - `decisions`: **60 days** — active decisions need regular revisiting
   - `events`: **30 days** — recent events should be verified promptly while context is fresh
   - `strategy`: **30 days** — strategy pages tie everything together; monthly review keeps them current
3. **Cross-page contradiction detection** — scan for claims about the same entity that disagree across pages (e.g., title or level mismatch between an entity page and an event page).

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
  "updated": "2026-04-11T18:15:00Z",
  "sources": {
    "sources/performance-reviews/review-2025-h1.pdf": {
      "sha256": "abc123...",
      "size_bytes": 52430,
      "last_ingested": "2026-04-11T18:15:00Z",
      "produced_pages": [
        "events/performance-review-2025-h1.md",
        "entities/{{employer}}.md"
      ]
    }
  }
}
```

**Keys are paths relative to the vault root** (so `sources/...` for vault-only sources).

On every ingest, Claude:
1. Computes SHA-256 of each source file.
2. Compares against `.manifest.json`.
3. If the hash matches the stored hash, the source is skipped (it is idempotent).
4. After successful promotion to live, updates the manifest with new hash, timestamp, and produced-pages list.

This guarantees periodic re-ingests (drop updated resume, re-run quarterly review) are idempotent — unchanged files don't regenerate pages.

## Git

The vault is a git repo, local-only.

- **No remote.** Never add one. Never push.
- **One commit per operation.** Ingest, refactor, prune, and lint-fix each produce exactly one commit.
- **Commit message format:** `<op>: <short-summary> — <pages-touched>`. Examples:
  - `ingest: performance-review-2025-h1 — 4 pages (2 created, 2 updated)`
  - `refactor: split entities/{{employer}} into parent-co + team-page — 3 pages`
  - `prune: decisions/take-offer-{{company}} — offer declined`
- **`.drafts/` and `.manifest.json`** are committed. `.drafts/` because promotion is a separate commit; the manifest because it's the load-bearing idempotency record.
- **Undo**: `git reset --hard HEAD~1` reverts the last operation. Claude will never run this without explicit user instruction.
- **`.gitignore`** excludes: `.obsidian/workspace*`, `.trash/`, any `*.tmp` files.

## Security posture

This vault is local-only, single-user. Defenses in layer order:

1. **Disk encryption (assumed baseline)** — BitLocker (Windows) or LUKS (Linux). User should verify this is active. Without disk encryption, every other defense is moot.
2. **Content discipline (enforced here)** — last-4 digits only for employee IDs, badge numbers, or other sensitive identifiers in page bodies. Never full SSN, home address, personal phone number, or bank routing numbers anywhere in a wiki page. Compensation figures use relative terms or ranges in page bodies (exact numbers only in provenance footnotes citing a specific source). This rule is a hard-fail in structural lint.
3. **Network isolation (enforced here)** — no remote git, no cloud sync, no plugin-initiated network calls in Obsidian. User should disable Obsidian Sync.
4. **OS permissions** — vault is under the user's home dir; filesystem ACLs apply.

**PII-heavy source types:**
- **Resumes** — contain home address, phone number, email. Extract role history and skills only; never copy address/phone into wiki pages.
- **Offer letters** — contain compensation, equity grants, signing bonuses, home address. Compensation goes into decision pages with provenance tags but never into page titles or index summaries. Use `$XXX,XXX` or relative terms in index.md.
- **Performance reviews** — contain manager feedback, ratings, peer names. Ratings and growth areas are extractable; direct quotes from peers require their consent or anonymization (e.g., "a peer noted..." not "{{Peer Name}} said...").

**Optional v2 opt-in: Cryptomator.** Open-source, cross-platform. Creates a password-protected encrypted container; you mount it before opening Obsidian, unmount when done. Adds a password to vault access without touching the vault's file format.

**Not being done:** no git-crypt (fights Obsidian live-preview), no per-file encryption (breaks graph view), no app-level encryption inside the vault itself.

## Naming conventions

- All filenames: `lowercase-kebab-case.md`.
- Entity pages: canonical name. Use `{{employer-slug}}.md`, not `{{employer-slug}}-inc.md`. Use `{{person-first-last}}.md` for people. Use `{{tool-name}}.md` for platforms.
- Concept pages: noun form. `negotiation-anchoring.md`, not `how-to-anchor-a-negotiation.md`.
- Decision pages: imperative or noun phrase. `take-offer-{{company}}.md`, not `should-i-take-the-offer.md`. The question lives in the body.
- Event pages: include the time qualifier. `performance-review-2025-h1.md`, `interview-at-{{company}}-2026-03.md`, `promotion-to-{{level}}-2025.md`.
- Strategy pages: short noun phrases. `career-growth-plan.md`, `compensation-optimization.md`.

## Linking conventions

- Use Obsidian wikilinks: `[[entities/{{employer}}]]`, `[[concepts/negotiation-anchoring|anchoring]]` (alias after pipe).
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

## Relationship to other brainfreeze vaults

This career vault is one component of the **brainfreeze** multi-vault system. Other vaults (personal-finance, health, etc.) are **separate** but **adjacent**:

- Each vault has its own `CLAUDE.md`, `index.md`, `log.md`, templates, and `.manifest.json`.
- Cross-vault references use plain text mentions, not wikilinks (Obsidian wikilinks don't resolve across vaults).
- When a career event has financial implications (e.g., new offer with equity), note the cross-reference in the page body: "See personal-finance vault `decisions/evaluate-equity-offer.md`." Do not duplicate financial analysis here.
- When a career decision affects health (e.g., benefits enrollment), note: "See health vault." Do not duplicate health data here.

The career wiki **does not read from or write to** other vaults. Cross-references are advisory pointers only.

## Hard rules

- **Never edit raw sources.** Not even to fix typos. Raw is immutable.
- **Never state a factual claim without a provenance tag.** `[^e]`, `[^i]`, or `[^a]` on every number or dated fact.
- **Never write a live page during ingest.** All writes go through `.drafts/` -> user approval -> promote. The only exception is `index.md` and `log.md` updates at the end of an approved ingest (they are bookkeeping, not facts).
- **Never delete files.** Archive instead. Even rejected drafts are deleted, not staged for later — but live pages never get `rm`-ed.
- **Never create a page outside the five categories.** Stop and ask.
- **Never use plugin-specific link syntax.** Keep the vault portable: plain Obsidian wikilinks, plain YAML frontmatter, plain markdown.
- **Never invent cross-references.** Search before linking.
- **Last-4 digits only** for sensitive identifiers (employee IDs, badge numbers). No full SSN, home address, or personal phone number in any page body. This is a lint-enforced rule.
- **Never auto-fix lint findings.** Report them and offer fixes; apply only on user approval through the ingest procedure.
- **Anonymize peer feedback.** Never attribute performance review quotes to named peers without user consent. Use "a peer noted..." or "feedback from N peers indicated..."
- **Compensation discipline.** Exact compensation figures appear only in provenance footnotes citing a source document. Page bodies and index.md use ranges (`$XXX,XXX`) or relative terms ("above market median"). This prevents casual browsing from exposing exact numbers.

## Starting a new session

When opening this vault, first:

1. Read this file (`CLAUDE.md`).
2. Read `index.md` to understand the current wiki scope.
3. Read the last 20 entries in `log.md` for recent activity.
4. Read `.manifest.json` to know what sources have already been ingested.
5. Then respond to the user.

Do not read every page on every session. Use `index.md` summaries to decide what to fetch.
