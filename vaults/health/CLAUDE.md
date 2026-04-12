# Health Wiki — Claude Code Schema

This is an **LLM-maintained knowledge wiki** for personal health tracking across mental and physical domains. It follows Andrej Karpathy's LLM Wiki pattern (https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) with augmentations drawn from community implementations (Ar9av/obsidian-wiki, NicholasSpisak/second-brain, kytmanov/obsidian-llm-wiki-local) and Reddit feedback.

This is part of the **brainfreeze** open-source multi-vault personal knowledge system. This schema is generic — it contains no personal data. Users should fill in their own details after forking.

Obsidian is the human reader. Claude Code is the writer. Plain markdown is the contract between them.

## Owner and scope

- **Owner:** `{{YOUR_NAME}}` — fill in after forking.
- **Scope:** Personal health only — mental health, physical fitness, medical history, nutrition, sleep, insurance/benefits, preventive care. Career and finance live in separate vaults.
- **Privacy:** Local-only. No remote git. No cloud sync. This vault contains **HIPAA-level sensitive data** — medical records, therapy notes, lab results, prescription history. Stronger protections than other vaults. **Cryptomator is strongly recommended** (not optional) for this vault. Raw medical documents and exports never leave this machine.

## Three layers

1. **Raw sources** (immutable) — the wiki reads from:
   - **`sources/medical/`** — doctor visit notes, lab result PDFs, imaging reports, prescription records, insurance EOBs, referral letters
   - **`sources/fitness/`** — workout logs, training program PDFs, body composition scan results, gym records
   - **`sources/devices/`** — Apple Health exports, Fitbit exports, Oura Ring data, sleep tracker CSVs, HRV logs, wearable data dumps
   - **`sources/therapy/`** — **RESTRICTED.** User-written session summaries only. Never raw transcripts, never verbatim therapist quotes. See "Therapy notes privacy rule" below.
   - **`sources/nutrition/`** — meal plan documents, macro tracking exports (MyFitnessPal, Cronometer), dietitian notes
   - **`sources/insurance/`** — EOBs, benefit summaries, coverage documents, HSA/FSA statements
   - All locations are **never edited** by wiki operations. They are the source of truth.

2. **The wiki** (LLM-owned) — everything under this vault except the raw `sources/` folder. Claude creates, updates, and cross-links pages. User edits are welcome.

3. **The schema** (this file) — the rules Claude follows when writing the wiki.

## Raw source policy

- When a document is new: the user drops it into the appropriate `sources/` subfolder. Ingest works from there.
- The wiki's `sources/` folder tree is *owned by the user*, not Claude. Claude reads from it but never writes to it or moves files out of it.
- For device exports (Apple Health XML, Fitbit JSON, etc.): prefer structured exports over screenshots. If a user provides a screenshot, ask for the export file instead.
- For lab results: prefer the structured lab report (PDF with values table) over a portal screenshot when both exist.

## Page categories

Every wiki page lives in exactly one category folder. Categories define intent, not just topic.

| Folder | Contains | Example filenames |
|---|---|---|
| `entities/` | People, providers, facilities, insurance plans, apps, devices | `primary-care-doctor.md`, `therapist.md`, `gym-name.md`, `pharmacy.md`, `insurance-plan.md`, `apple-watch.md`, `fitbit.md` |
| `concepts/` | Reusable health/fitness knowledge: techniques, metrics, protocols | `sleep-hygiene.md`, `progressive-overload.md`, `cbt-techniques.md`, `macro-tracking.md`, `hrv.md`, `vo2-max.md`, `bmi-vs-body-comp.md` |
| `decisions/` | Explicit health choices the user is making or considering | `start-therapy.md`, `switch-medications.md`, `change-workout-program.md`, `try-intermittent-fasting.md`, `get-surgery.md` |
| `events/` | Time-bounded occurrences: appointments, labs, injuries, milestones | `annual-physical-YYYY.md`, `blood-panel-YYYY-QN.md`, `therapy-session-YYYY-MM-DD.md`, `injury-left-knee-YYYY.md` |
| `strategy/` | Long-horizon plans that tie decisions together | `mental-health-maintenance.md`, `fitness-progression.md`, `sleep-optimization.md`, `preventive-care-schedule.md` |

Rule: if you cannot confidently place a new page in one category, ask the user before creating it.

## Therapy notes privacy rule

**This is the most important privacy rule in this vault.**

Therapy session event pages (`events/therapy-session-*.md`) must **never** contain:
- Verbatim therapist quotes
- Session transcripts or near-transcripts
- Audio/video recordings or references to them
- Clinical assessment language copied from a therapist's notes

Therapy session pages **may only** contain:
- User-written summaries of personal insights gained
- Action items and homework assignments (in the user's own words)
- Mood/state self-assessments before and after the session
- Topics discussed (brief, high-level list — not a blow-by-blow)

The wiki is an **aid to reflection**, not a clinical record. If the user provides raw therapy session notes or transcripts in `sources/therapy/`, Claude must summarize into the permitted format during ingest and flag to the user that verbatim content was redacted.

## Special files and folders

- **`index.md`** — catalog of every active wiki page, grouped by category, one line per page: `- [[entities/primary-care-doctor]] — PCP, {{specialty}}, seen since YYYY`. Updated on every ingest. Never contains claims; only pointers and summaries.
- **`log.md`** — append-only chronological record (newest first). One entry per ingest, query-that-became-a-page, lint run, refactor, or prune. Format:
  ```markdown
  ## [YYYY-MM-DD] ingest | blood panel Q2 results
  Created: events/blood-panel-YYYY-QN.md
  Updated: entities/primary-care-doctor.md, strategy/preventive-care-schedule.md, index.md
  Provenance: 8 extracted, 3 inferred, 1 ambiguous
  Notes: Flagged elevated LDL for user review — see events/blood-panel-YYYY-QN#open-questions
  ```
- **`.drafts/`** — hidden staging folder (Obsidian hides dotfolders by default). All ingest writes go here first. User reviews drafts in Obsidian, then gives approval, then Claude promotes drafts to their live category folders. Never commit drafts to git — they are ephemeral.
- **`.manifest.json`** — source-to-page mapping used for delta ingests. See "Manifest" section below.
- **`templates/*.md`** — strict page skeletons. Claude must use these when creating new pages. Never skip required sections.
- **`sources/`** — vault-only raw material. User-owned, read-only for Claude. Subfolders: `medical/`, `fitness/`, `devices/`, `therapy/`, `nutrition/`, `insurance/`.

## Frontmatter schema

Every non-special page has YAML frontmatter. Fields:

```yaml
---
title: Sleep Hygiene
category: concept               # entity | concept | decision | event | strategy
sensitivity: standard           # standard | elevated | restricted
status: active                  # active | superseded | archived | draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [sleep, recovery, habits]
relations:
  supports: []                  # this page reinforces these pages
  contradicts: []               # this page is incompatible with these pages
  supersedes: []                # this page replaces these pages
  derives-from:                 # source pages/files that justify this page's claims
    - "sources/devices/sleep-export-YYYY-MM.csv"
  depends-on: []                # pages whose claims must be true for this page to hold
  relates-to: []                # weak association, no causal link
provenance:                     # rollup count of the inline citation tags (see below)
  extracted: 0
  inferred: 0
  ambiguous: 0
sources:                        # page-level source list, one entry per raw file cited inline
  - path: sources/devices/sleep-export-YYYY-MM.csv
    sha256:                     # filled by Claude when computing the manifest
    verified: YYYY-MM-DD
---
```

**Sensitivity levels** (enforced by lint):
- `standard` — general fitness, nutrition, sleep data. No special handling beyond vault-level encryption.
- `elevated` — lab results, medical conditions, medications, body metrics. Avoid identifiers in page body; use entity references instead.
- `restricted` — therapy notes, psychiatric records, substance use history, deeply personal health events. Applies the therapy notes privacy rule. These pages should contain the **minimum detail needed** for personal reflection. When in doubt, leave it out.

**Sensitivity defaults by page type:**
- Therapy session events: always `restricted`
- Lab results / blood panels: `elevated`
- Medical condition entities: `elevated`
- Medication entities: `elevated`
- Fitness / workout events: `standard`
- Nutrition concepts: `standard`
- Sleep data: `standard`
- Insurance entities: `elevated`
- Mental health strategies: `elevated`

**Relation semantics** (use these precisely):
- `supports` — this page's claims reinforce another page's claims
- `contradicts` — this page says something incompatible with another page; one is wrong or stale
- `supersedes` — this page replaces another page (the old one becomes `status: superseded`)
- `derives-from` — this page's facts come from these raw sources or upstream wiki pages
- `depends-on` — this page is valid only while the referenced pages remain valid (e.g., `decisions/switch-medications` depends on `concepts/condition-being-treated`)
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
Resting heart rate averaged 58 bpm over Q2 [^e1], down from 64 bpm in Q1 [^e2],
suggesting improved cardiovascular fitness [^i1]. VO2 max estimates from the
watch (44 ml/kg/min) and the lab test (41 ml/kg/min) disagree [^a1].

[^e1]: extracted — sources/devices/apple-health-export-YYYY-Q2.csv
       field: `resting_hr_avg` = 58
[^e2]: extracted — sources/devices/apple-health-export-YYYY-Q1.csv
       field: `resting_hr_avg` = 64
[^i1]: inferred — computed from [^e1] vs [^e2]; 6 bpm decrease over 3 months
       consistent with aerobic adaptation
[^a1]: ambiguous — Apple Watch reports VO2 max = 44 (sources/devices/apple-health-export-YYYY-Q2.csv);
       lab cardiopulmonary test reports 41 (sources/medical/vo2-max-test-YYYY-MM-DD.pdf).
       Gap of 3 ml/kg/min. Watch estimates are known to skew high.
       See [[events/blood-panel-YYYY-QN#vo2-discrepancy]].
```

**Roll-up to frontmatter.** The `provenance:` block in frontmatter is just the count of each tag type in the body. Lint will enforce that the counts match.

**Hard rules:**
- Every numeric value or dated fact in the body must have a tag. No tag, no claim.
- A page with `provenance.extracted == 0` and `inferred > 0` is a synthesis-only page (e.g., `strategy/`) and is acceptable, but the inferred tags must point at pages that *do* have extracted backing.
- A page with `ambiguous > 0` is automatically flagged by lint and must have at least one `open questions` entry naming the discrepancy.

## Source-to-page routing rules

When ingesting common health document types, follow these deterministic routing rules. These make ingest predictable and lintable. If a document type is not listed, ask the user during the pre-ingest conversation.

| Source type | Folder pattern | Creates / updates |
|---|---|---|
| Lab results / blood panel (PDF) | `sources/medical/lab-*`, `sources/medical/blood-panel-*` | CREATE `events/blood-panel-YYYY-QN.md`; UPDATE `entities/primary-care-doctor.md` last-visit; UPDATE relevant `concepts/` pages for flagged biomarkers |
| Doctor visit notes | `sources/medical/visit-*` | CREATE/UPDATE `events/doctor-visit-YYYY-MM-DD.md`; UPDATE `entities/<doctor>.md` last-visit; UPDATE relevant `decisions/` if treatment plan changed |
| Prescription record | `sources/medical/rx-*` | UPDATE `entities/medication-<name>.md` (create if new); UPDATE `concepts/<condition>.md` treatment section; UPDATE `entities/pharmacy.md` |
| Therapy session summary | `sources/therapy/session-*` | CREATE `events/therapy-session-YYYY-MM-DD.md` (**RESTRICTED** — apply therapy notes privacy rule); UPDATE `strategy/mental-health-maintenance.md` if new patterns |
| Workout log | `sources/fitness/workout-*`, `sources/fitness/training-*` | APPEND to `events/training-block-YYYY-QN.md`; UPDATE `strategy/fitness-progression.md` progress section |
| Body composition / weigh-in | `sources/fitness/body-comp-*`, `sources/fitness/dexa-*` | UPDATE `events/body-comp-YYYY-QN.md`; UPDATE relevant `concepts/` (e.g., `bmi-vs-body-comp.md`) |
| Sleep tracker export | `sources/devices/sleep-*` | UPDATE `events/sleep-review-YYYY-QN.md`; UPDATE `strategy/sleep-optimization.md`; UPDATE `concepts/sleep-hygiene.md` current-values |
| Apple Health / Fitbit export | `sources/devices/apple-health-*`, `sources/devices/fitbit-*` | UPDATE `entities/apple-watch.md` or `entities/fitbit.md`; fan out to relevant event pages by metric type (HR, steps, sleep, workouts) |
| Meal plan / nutrition log | `sources/nutrition/meal-plan-*`, `sources/nutrition/macro-*` | UPDATE `events/nutrition-review-YYYY-QN.md`; UPDATE `concepts/macro-tracking.md` |
| Insurance EOB | `sources/insurance/eob-*` | UPDATE `entities/insurance-plan.md` claims history; UPDATE relevant `events/` for the visit the EOB covers |
| Insurance benefit summary | `sources/insurance/benefits-*` | UPDATE `entities/insurance-plan.md` coverage details; UPDATE `strategy/preventive-care-schedule.md` covered-services |
| Imaging / scan results | `sources/medical/imaging-*`, `sources/medical/xray-*`, `sources/medical/mri-*` | CREATE `events/<scan-type>-YYYY-MM-DD.md`; UPDATE relevant `entities/<doctor>.md`; UPDATE relevant injury/condition pages |
| Annual physical summary | `sources/medical/annual-physical-*` | CREATE/UPDATE `events/annual-physical-YYYY.md`; UPDATE `entities/primary-care-doctor.md`; UPDATE `strategy/preventive-care-schedule.md` |

**Rule:** A single ingest should never touch more than ~15 pages. If a routing rule expands beyond that, batch by time window (e.g., one quarter at a time) and split into multiple ingests.

## The five operations

### 1. Ingest — add facts from a new or updated raw source

1. **Identify sources.** The user names specific files or provides a batch. Compute SHA-256 of each source file. Check `.manifest.json`:
   - If a source's hash matches and it has been ingested before, skip it (unless user forces re-ingest with `--force`).
   - Print the skip list to the user so they know nothing is lost.
2. **Read sources fully.** Do not skim. For binary formats (PDFs), extract tables and values systematically.
3. **Check sensitivity.** Before drafting, classify each source by sensitivity level. Flag any `restricted` sources and remind the user of the therapy notes privacy rule.
4. **Have a pre-write conversation.** Before touching the drafts folder, report to the user in plain chat:
   - Key facts extracted (bulleted)
   - Health findings or trends worth noting (bulleted)
   - Open questions / ambiguities (bulleted)
   - Planned page changes (create/update list per routing table)
   - Anything that looks like a contradiction with existing wiki pages
   - **Sensitivity classification** of each planned page

   Wait for user response. The user may correct emphasis, redirect scope, flag data you missed, or veto pages. **This is the "don't delegate understanding" checkpoint — it is not optional.**
5. **Write drafts to `.drafts/`.** For every planned change:
   - New pages: write the full markdown using the matching template, with frontmatter, provenance tags, and body content.
   - Updates to existing pages: write BOTH the old version (as `.drafts/<path>.before`) AND the proposed new version (as `.drafts/<path>`). This lets the user diff visually in Obsidian.
   - Mirror the live folder structure inside `.drafts/` (e.g., new `entities/therapist.md` goes to `.drafts/entities/therapist.md`).
   - For `restricted` pages: apply extra redaction — strip any verbatim quotes, session transcripts, or clinical language that slipped through.
6. **Report drafts ready.** Tell the user: "N drafts written to `.drafts/`; review in Obsidian." Give the list of paths, highlighting any `restricted` pages.
7. **Wait for approval.** The user reads the drafts in Obsidian. They may:
   - Approve all: reply "merge" or "looks good"
   - Approve selectively: "merge everything except `decisions/foo.md`, reject that one"
   - Edit drafts directly in Obsidian, then say "merge" — Claude must read the edited drafts, not regenerate
   - Reject all: "scrap this ingest"
8. **Promote to live.** Move approved drafts from `.drafts/` to their live locations. Overwrite existing pages. Delete any `.before` companions. Delete rejected drafts.
9. **Update bookkeeping.**
   - Update `index.md` — add/update catalog lines for every touched page.
   - Append to `log.md` — one entry summarizing source, created/updated counts, provenance mix, open questions.
   - Update `.manifest.json` — record source hash, timestamp, and the list of pages produced.
10. **Git commit.** One commit per ingest, message format: `ingest: <source-short-name> — <N> pages (<created> created, <updated> updated)`.
11. **Run structural lint.** Report findings; offer fixes but do not auto-apply.

### 2. Query — answer a question from the wiki

1. Read `index.md` to locate relevant pages.
2. Grep the wiki for additional matches beyond the index.
3. Answer the question in plain prose, with **inline citations back to wiki pages** (e.g., `[[events/blood-panel-YYYY-QN]]`).
4. If a relevant claim has no wiki source, do NOT answer from raw files silently — tell the user the wiki is missing coverage and suggest an ingest.
5. If the answer is high-value and synthesizes across multiple pages, offer to file it back as a new `strategy/` or `concepts/` page. Use the ingest procedure (drafts + approval) to write it.
6. Log the query in `log.md` only if a new page resulted.
7. **Never surface `restricted` content in query answers beyond what the user explicitly asks for.** If a query touches therapy notes, confirm the user wants that level of detail before including it.

### 3. Lint — audit wiki integrity

Lint runs in two tiers.

**Structural lint** — runs automatically at the end of every ingest. Zero LLM cost; pure grep and YAML parsing. Checks:

1. **Broken wikilinks** — any `[[...]]` target that does not exist.
2. **Orphan pages** — pages with zero backlinks and not listed in `index.md`.
3. **Missing provenance** — pages with numeric values or dated facts in the body but no `[^e]`/`[^i]`/`[^a]` tags.
4. **Provenance rollup mismatch** — `provenance:` counts in frontmatter don't match inline tag counts in body.
5. **Empty required sections** — template required sections left as `_(no content yet)_` past a threshold (warn, don't fail).
6. **Stale index** — index.md out of sync with actual pages on disk.
7. **Frontmatter validation** — required fields present, enums valid, dates parseable, `sensitivity` field present.
8. **Contradiction map** — pages whose `relations.contradicts` targets are both still `status: active`.
9. **Ambiguous without question** — pages with `provenance.ambiguous > 0` but no open-questions entry.
10. **Archived referenced as active** — a live page cites an archived page without going through `supersedes`.
11. **Sensitivity audit** — therapy session pages missing `sensitivity: restricted`; medical pages missing at least `elevated`. Any page with raw clinical language flagged for redaction.
12. **PHI leak check** — scan for patterns that look like full SSN, insurance member IDs, medical record numbers, or provider NPI numbers in page bodies. Warn on match.

Structural lint reports a text diff-friendly summary. Failures do not block ingest; they are flagged for the user.

**Semantic lint** — runs on user request (`lint --semantic`) or on a cadence the user defines. LLM cost. Checks:

1. **Drift check** — for every page with `sources:`, re-read the cited raw files and verify the extracted values still match. Flag pages where the raw number changed but the wiki didn't.
2. **Freshness check** — pages whose `verified:` date is older than the threshold for their category:
   - **Entities** (doctors, providers): **365 days** — provider relationships change slowly
   - **Concepts** (health knowledge): **180 days** — medical guidelines update periodically
   - **Decisions** (active health choices): **60 days** — treatment decisions need regular reassessment
   - **Events** (appointments, labs): **30 days** — recent events should be current
   - **Strategy** (long-term health plans): **90 days** — strategies need quarterly review
3. **Cross-page contradiction detection** — scan for numeric claims about the same metric that disagree across pages (e.g., two pages reporting different resting HR for the same period).

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

When a decision is rolled back, a medication is discontinued, an old injury is fully resolved, or a provider relationship ends:

1. Set `status: archived`.
2. Add a `## Archived reason` section in the body explaining why and when.
3. Move from `index.md` active sections to the archived section.
4. Append to `log.md`: `prune: <page> — <reason>`.
5. Commit: `prune: <page>`.

Never delete files from disk. This is especially important for medical history — even discontinued treatments and resolved conditions may be relevant in future medical contexts.

## Manifest

`.manifest.json` is the source-of-truth for what has been ingested. Structure:

```json
{
  "version": 1,
  "updated": "YYYY-MM-DDTHH:MM:SSZ",
  "sources": {
    "sources/medical/lab-results-YYYY-QN.pdf": {
      "sha256": "abc123...",
      "size_bytes": 45210,
      "last_ingested": "YYYY-MM-DDTHH:MM:SSZ",
      "produced_pages": [
        "events/blood-panel-YYYY-QN.md",
        "entities/primary-care-doctor.md"
      ]
    }
  }
}
```

**Keys are paths relative to the vault root** (so `sources/medical/...`, `sources/fitness/...`, etc.).

On every ingest, Claude:
1. Computes SHA-256 of each source file.
2. Compares against `.manifest.json`.
3. If the hash matches the stored hash, the source is skipped (it is idempotent).
4. After successful promotion to live, updates the manifest with new hash, timestamp, and produced-pages list.

This guarantees periodic re-ingests (drop new lab results, re-export device data) are idempotent — unchanged files don't regenerate pages.

## Git

The vault is a git repo, local-only.

- **No remote.** Never add one. Never push.
- **One commit per operation.** Ingest, refactor, prune, and lint-fix each produce exactly one commit.
- **Commit message format:** `<op>: <short-summary> — <pages-touched>`. Examples:
  - `ingest: blood-panel-2025-Q2 — 4 pages (2 created, 2 updated)`
  - `refactor: split concepts/sleep-hygiene into sleep-hygiene + sleep-environment — 3 pages`
  - `prune: entities/old-therapist — switched providers`
- **`.drafts/` and `.manifest.json`** are committed. `.drafts/` because promotion is a separate commit; the manifest because it's the load-bearing idempotency record.
- **Undo**: `git reset --hard HEAD~1` reverts the last operation. Claude will never run this without explicit user instruction.
- **`.gitignore`** excludes: `.obsidian/workspace*`, `.trash/`, any `*.tmp` files.

## Security posture

This vault contains **HIPAA-level sensitive health data**. Defenses in layer order:

1. **Disk encryption (assumed baseline)** — BitLocker on the Windows drive. User should verify this is active. Without BitLocker, every other defense is moot.
2. **Vault-level encryption (strongly recommended)** — **Cryptomator** creates a password-protected encrypted container. Mount before opening Obsidian, unmount when done. For this vault — unlike finance — this is **not optional**. Medical records, therapy notes, and prescription history warrant the extra layer. Set this up before first ingest.
3. **Content discipline (enforced here):**
   - Never full insurance member IDs, medical record numbers, SSN, or provider NPI numbers in page bodies. Use entity references instead.
   - Therapy notes follow the restricted privacy rule (user-written summaries only).
   - Lab values are fine in page bodies (they have no meaning without identity context), but identifiers must be scrubbed.
   - `sensitivity` field in frontmatter is mandatory and enforced by lint.
4. **Network isolation (enforced here)** — no remote git, no cloud sync, no plugin-initiated network calls in Obsidian. User should disable Obsidian Sync. **Do not use health-tracking Obsidian plugins that phone home.**
5. **OS permissions** — vault is under the user's home dir; filesystem ACLs apply.

**Per-section encryption note:** True per-file or per-section encryption inside the vault is not practical (breaks Obsidian graph view and search). Instead, the sensitivity classification system + Cryptomator vault-level encryption provides equivalent protection with better usability. If a user needs to share specific pages with a doctor, export a single-page PDF — do not grant access to the vault.

**Not being done:** no git-crypt (fights Obsidian live-preview), no per-file encryption (breaks graph view), no app-level encryption inside the vault itself.

## Naming conventions

- All filenames: `lowercase-kebab-case.md`.
- Entity pages: role-based canonical name. Use `primary-care-doctor.md`, not `dr-{{lastname}}.md`. Use `therapist.md` unless the user has multiple (then: `therapist-cbt.md`, `therapist-emdr.md`). Use `apple-watch.md`, `fitbit.md` for devices.
- Concept pages: noun form. `sleep-hygiene.md`, not `what-is-sleep-hygiene.md`. `progressive-overload.md`, not `how-to-progressive-overload.md`.
- Decision pages: imperative or noun phrase. `start-therapy.md`, not `should-i-start-therapy.md`. The question lives in the body.
- Event pages: include the time qualifier. `annual-physical-YYYY.md`, `blood-panel-YYYY-QN.md`, `therapy-session-YYYY-MM-DD.md`, `injury-left-knee-YYYY.md`.
- Strategy pages: short noun phrases. `mental-health-maintenance.md`, `fitness-progression.md`, `sleep-optimization.md`.

## Linking conventions

- Use Obsidian wikilinks: `[[entities/primary-care-doctor]]`, `[[concepts/sleep-hygiene|sleep hygiene]]` (alias after pipe).
- Link on first mention in a page body; don't over-link. Obsidian backlinks handle the rest.
- Typed relations go in frontmatter, not prose. Prose links are neutral associations; semantic weight lives in `relations:`.
- Cross-vault links (to finance or career vaults) are not supported by Obsidian wikilinks. Use plain prose references: "see the finance vault's `decisions/open-hsa.md`" when relevant (e.g., HSA decisions span both health and finance).

## Templates

Required skeletons live in `templates/`:

- `templates/entity.md`
- `templates/concept.md`
- `templates/decision.md`
- `templates/event.md`
- `templates/strategy.md`

Every new page starts as a copy of the matching template. Claude may not skip required sections. If a section has no content yet, write `_(no content yet)_` explicitly so the gap is visible during lint.

## Hard rules

- **Never edit raw sources.** Not even to fix typos. Raw is immutable.
- **Never state a factual claim without a provenance tag.** `[^e]`, `[^i]`, or `[^a]` on every number or dated fact.
- **Never write a live page during ingest.** All writes go through `.drafts/` -> user approval -> promote. The only exception is `index.md` and `log.md` updates at the end of an approved ingest (they are bookkeeping, not facts).
- **Never delete files.** Archive instead. Even rejected drafts are deleted, not staged for later — but live pages never get `rm`-ed. Medical history pages are especially important to retain.
- **Never create a page outside the five categories.** Stop and ask.
- **Never use plugin-specific link syntax.** Keep the vault portable: plain Obsidian wikilinks, plain YAML frontmatter, plain markdown.
- **Never invent cross-references.** Search before linking.
- **Never include verbatim therapist quotes or session transcripts.** This is a hard-fail in lint. See therapy notes privacy rule above.
- **Never include full insurance member IDs, medical record numbers, SSN, or provider NPI numbers in any page body.** This is a lint-enforced rule (PHI leak check).
- **Never auto-fix lint findings.** Report them and offer fixes; apply only on user approval through the ingest procedure.
- **Always set the `sensitivity` field in frontmatter.** Missing sensitivity is a structural lint failure.
- **Never surface restricted content in query answers without explicit user confirmation.**

## Starting a new session

When opening this vault, first:

1. Read this file (`CLAUDE.md`).
2. Read `index.md` to understand the current wiki scope.
3. Read the last 20 entries in `log.md` for recent activity.
4. Read `.manifest.json` to know what sources have already been ingested.
5. Then respond to the user.

Do not read every page on every session. Use `index.md` summaries to decide what to fetch.
