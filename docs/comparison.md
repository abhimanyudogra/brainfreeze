# Performance Comparison: Base Karpathy vs brainfreeze

_This page will contain benchmarks once we have enough data. Contributions welcome — see below._

## Planned benchmarks

| Metric | What it measures | How to test |
|---|---|---|
| Retrieval accuracy | Given a question, does the system find the right wiki page? | 50 questions against a 100-page vault, scored by human rater |
| Provenance auditability | Can a human verify a claim's source in <30 seconds? | Time 20 random claims across both systems |
| Ingest idempotency | Does re-ingesting an unchanged file create duplicates? | Re-ingest 10 files, count delta pages |
| Drift detection rate | After N ingests, what % of stale claims does lint catch? | Introduce 10 known stale claims, run lint, measure recall |
| Time-to-first-page | How fast from clone to first ingested page? | Timed on a clean machine with prerequisites installed |

## How to contribute

If you're running brainfreeze on a real vault and want to share benchmarks:

1. Open an issue with your vault size (page count), domain (finance, health, career, other), and LLM used
2. Run the benchmark protocol (TBD — we'll publish a script)
3. Share results in the issue

We'll aggregate anonymized results here.
