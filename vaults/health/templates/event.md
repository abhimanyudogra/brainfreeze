---
title: {{Event Name}}
category: event
sensitivity: standard            # standard | elevated | restricted — elevated for lab results/medical visits, restricted for therapy sessions
status: active
created: {{date}}
updated: {{date}}
event-date: {{date or date range}}
tags: []
relations:
  supports: []
  contradicts: []
  supersedes: []
  derives-from: []
  depends-on: []
  relates-to: []
provenance:
  extracted: 0
  inferred: 0
  ambiguous: 0
sources: []
---

# {{Event Name}}

## Summary
_(one-paragraph description: what happened, when, why it matters to the user's health. Every claim tagged. For therapy sessions: user-written reflection only — no verbatim quotes, no session transcripts.)_

## Timeline
_(chronological facts with dates — trigger/symptoms, appointment, procedure/session, follow-up, outcome)_

- _(no content yet)_

## Key measurements
_(the concrete health data attached to this event — lab values, vitals, body metrics, workout numbers, mood scores. Each with `[^e]`/`[^i]`/`[^a]` tag. For lab results, include reference ranges.)_

| Metric | Value | Reference range | Tag |
|---|---|---|---|
| _(e.g., Total cholesterol)_ | _(mg/dL)_ | _(desirable range)_ | _(`[^e1]`)_ |

## Action items
_(next steps arising from this event — follow-up appointment, medication change, training adjustment, lifestyle modification)_

- [ ] _(no content yet)_

## Impact on other pages
_(how this event changes other wiki pages — entities affected, concepts triggered, decisions that need revisiting, strategies that need updating)_

## Open questions & data gaps
_(anything unresolved about this event — pending test results, unclear readings, conflicting provider opinions. Required when `provenance.ambiguous > 0`.)_

- _(no content yet)_

## Citations
