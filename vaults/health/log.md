# Health Wiki — Activity Log

Append-only chronological record of wiki operations. Entry types: `ingest`, `query` (only when a query produced a new page), `lint`, `refactor`, `prune`.

Format:
```
## [YYYY-MM-DD] <type> | <one-line-summary>
<body — what was read, what was created/updated, open questions surfaced>
```

Newest entries at the top.

---

## [YYYY-MM-DD] init | vault scaffolded with health wiki schema

Created directory structure (`entities/`, `concepts/`, `decisions/`, `events/`, `strategy/`, `templates/`, `sources/`, `.drafts/`). Wrote [[CLAUDE]] schema (v1) adapted from personal-finance vault pattern with health-specific augmentations: sensitivity classification (standard/elevated/restricted), therapy notes privacy rule, HIPAA-level security posture, PHI leak lint check, health-specific source-to-page routing rules, and adjusted freshness thresholds. Five templates in `templates/` with sensitivity frontmatter field. Stub [[index]]. Next step: user populates `sources/` subfolders and initiates first ingest.
