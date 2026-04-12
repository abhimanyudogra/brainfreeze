# Career Wiki — Activity Log

Append-only chronological record of wiki operations. Entry types: `ingest`, `query` (only when a query produced a new page), `lint`, `refactor`, `prune`.

Format:
```
## [YYYY-MM-DD] <type> | <one-line-summary>
<body — what was read, what was created/updated, open questions surfaced>
```

Newest entries at the top.

---

## [2026-04-11] init | vault scaffolded with career wiki schema

Created directory structure (`entities/`, `concepts/`, `decisions/`, `events/`, `strategy/`, `templates/`, `sources/`, `.drafts/`). Wrote [[CLAUDE]] schema (v1) following the brainfreeze multi-vault pattern with six augmentations over Karpathy's base: drafts-folder change-preview, three-state provenance tagging (extracted/inferred/ambiguous), split lint (structural + semantic), conversational pre-ingest, source-to-page routing rules, and `.manifest.json` delta ingest. Five templates in `templates/` with provenance frontmatter. Stub [[index]]. Next step: drop source material into `sources/` and run first ingest.
