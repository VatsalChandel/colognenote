# Cologne Collection App — Project Summary

A one-read overview of what this project is, the decisions behind it, and where it stands.
For anyone (or any agent) picking this up cold.

---

## What it is

A native iOS app for fragrance collectors to catalog what they own and track how they use it.
A user stores each fragrance with details (house, concentration, size, notes, a photo, and the
price they paid), then logs the two things collectors care about: **times worn** and
**compliments received**. From that data the app surfaces the metric the hobby obsesses over —
**cost-per-wear** — plus insights like most-worn, most-neglected, best performers, and what a
collection leans toward by scent family.

## The core strategic split: V1 vs V2

- **V1 — the single-player game (what we're building now).** A private, polished personal
  tracker: collection, logging, insights, wishlist. Fully useful with zero followers. It's
  also the validation instrument — put it in front of testers to learn whether people actually
  want to track their collection this way.
- **V2 — the social game (later).** Public profiles, an activity feed, following, discovery,
  community stats ("400 people own this"), a scent-of-the-day picker, notifications.

The order is deliberate: a social network cold-starts empty, so the solo experience has to be
great on its own first. V2 is designed to layer on **without a rewrite** — the canonical
fragrance link, the follows table, the isolated-price design, and RLS policies that turn social
on by *uncommenting* are all already in the foundation.

## Key decisions (already made — don't relitigate)

- **Native iOS, SwiftUI** (no Storyboards), talking to **Supabase** via `supabase-swift`.
- **Ownership:** one entry = one fragrance owned (no decants/backups in v1).
- **Lifecycle:** items have a status (active / finished / sold), so history survives; hard
  delete only for the added-by-mistake case.
- **Price is private**, isolated in its own table so the rest of the shelf can go public in V2
  while price never does. Cost-per-wear is private by extension.
- **Two-tier fragrance database:** a *canonical* shared set (what community stats will count)
  vs. *personal* free-text entries. Users never type notes/accords — those are attached to the
  canonical fragrance.
- **16 fixed accord families;** every note maps to exactly one. **Accords are derived** from a
  fragrance's notes, not stored.
- **Seed catalog:** ~100 canonical fragrances, accord-tagged, with full notes for the popular
  ~20–30; the long tail of notes fills in via V2 crowdsourcing. First 15 are drafted.
- **Free-tier stack** to validate cheaply; the one real pre-revenue cost is the $99/yr Apple
  Developer Program (needed for TestFlight).

## The document set

- `project-summary.md` — this file.
- `blueprint.md` — data model, screen list, stack, build phasing.
- `accord-families.md` — the 16 accord families and the note→family concept.
- `supabase-schema.sql` — the runnable database with RLS.
- `phase-1-screens.md` — screen-by-screen spec with iOS patterns.
- `screen-action-inventory.md` — exhaustive screens × actions.
- `task-list.md` — the dependency-ordered build plan (start at Milestone 0).
- `seed-catalog-guide.md` — how to build the fragrance seed data.
- `seed-catalog-v3.1.md` — the drafted first 15 fragrances, cleaned.
- `CLAUDE.md` — project memory / ground rules for the coding agent.

## Current status

**Planning and specification: complete and internally consistent.** The eight-plus documents
above all agree with each other.

**Backend:** the Supabase project exists and the schema has been run.

**App code:** not started. This is the transition from planning to building.

**Immediate next step:** execute **Milestone 0** of `task-list.md` (project setup, config/secrets
machinery, models, data layer, navigation shell), then proceed through the milestones in order.
The app is demo-able to a tester after Milestone 3.

## Open items (known, not blocking)

- Four seed fragrances (Bleu de Chanel, Aventus, Libre, Baccarat Rouge 540) are marked
  `unverified` pending a source check — fine until the Add-flow search in Milestone 2.
- Deferred to ship-time (hard gates for the App Store, not for building): a published privacy
  policy and Apple's privacy-label disclosures.
- Deferred by choice for v1: usage analytics, automated testing depth, in-place editing of logs.
