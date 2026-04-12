---
title: {{Decision Title}}
category: decision
sensitivity: standard            # standard | elevated | restricted — elevated for medication/treatment decisions, restricted for therapy-related
status: active                   # active = in effect or under consideration; archived = decided-against or rolled-back
decision-state: open             # open | decided | rolled-back
decided-on:                      # date the decision was made, if applicable
created: {{date}}
updated: {{date}}
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

# {{Decision Title}}

## The question
_(one-sentence framing of the health choice to be made)_

## Context
_(why this decision is on the table now — symptoms, provider recommendation, fitness plateau, lifestyle change, insurance coverage shift. Cite relevant events and entities. Every claim tagged.)_

## Options

### Option 1: _(name)_
- Pro: _(...)_
- Con: _(...)_
- Expected impact: _(quantified where possible — e.g., expected recovery time, dosage effects, cost, lifestyle burden. Tagged.)_

### Option 2: _(name)_
- Pro: _(...)_
- Con: _(...)_
- Expected impact: _(quantified where possible. Tagged.)_

## Constraints
_(hard limits that rule out options — allergies, contraindications, insurance coverage, scheduling, cost, provider availability)_

## Provider input
_(what doctors, therapists, trainers, or other providers have recommended. Summarize advice in user's own words — never verbatim clinical quotes for restricted-sensitivity decisions.)_

## Decision
_(the chosen option, or "undecided" with the blocker. If decided, include date in frontmatter `decided-on`.)_

## Follow-up actions
_(concrete next steps — appointment to schedule, prescription to fill, program to start, labs to order. Owner and due date when known.)_

- [ ] _(no content yet)_

## Review triggers
_(conditions under which this decision should be revisited — symptom changes, next lab results, training milestone, medication side effects, insurance renewal)_

## Open questions & data gaps
- _(no content yet)_

## Citations
