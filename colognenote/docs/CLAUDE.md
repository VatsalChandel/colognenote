# CLAUDE.md — Cologne Collection App

This file is project memory. Read it fully at the start of every session, then read the
documents in `/docs` before writing any code. The planning is done — your job is to build
Phase 1 by executing the task list, not to re-decide the architecture.

---

## What this project is

A native iOS app for fragrance collectors to catalog their collection and log wears and
compliments. **Phase 1 (V1) is a private, single-player tracker.** The social layer (public
profiles, feed, following, community stats) is **Phase 2 / V2 and must NOT be built now.**
See `docs/project-summary.md` for the full picture.

## Read these before coding (in order)

1. `docs/project-summary.md` — what we're building and why.
2. `docs/blueprint.md` — data model, screen list, stack.
3. `docs/accord-families.md` — the fixed 16-family vocabulary.
4. `docs/supabase-schema.sql` — the database (already run on Supabase; this is the source of truth for data shape).
5. `docs/phase-1-screens.md` — detailed screen specs with iOS patterns.
6. `docs/screen-action-inventory.md` — every screen and action.
7. `docs/task-list.md` — **the build plan you execute.** Start at Milestone 0.
8. `docs/seed-catalog-guide.md` + `docs/seed-catalog-v3.1.md` — the fragrance seed data.

---

## Ground rules (do not violate)

- **SwiftUI only.** No Storyboards. Backend is Supabase via the `supabase-swift` SDK.
- **One SwiftUI `View` per screen; one file per view; feature-organized folders.**
- **RLS is owner-only in Phase 1.** Every query runs as the signed-in user.
- **Price and collection value are private.** Price lives in `collection_item_costs`. Never expose it in any shared or derived output.
- **Logged wears and compliments are delete-only** — no in-place editing.
- **Do NOT build anything under "Deferred"** in the task list, or the commented-out Phase 2 RLS policies in the schema.
- **Accords are DERIVED** from a fragrance's notes via the `fragrance_accords` view. There is no stored accord list and no `fragrance_accords` table.

## Secret handling (critical)

- **Never hardcode Supabase keys in Swift source.** Read them from a git-ignored config (`Config.xcconfig` → Info.plist → a `SupabaseConfig` accessor).
- **Only ever use the `anon` public key.** Never request, use, or reference the `service_role` key — it bypasses RLS and must never touch the app.
- The Supabase **base project URL** is `https://<project>.supabase.co` (no `/rest/v1/` suffix — the SDK appends paths itself).
- Confirm `.gitignore` excludes the real config file before the first commit.

## Working protocol

- Do tasks in task-list order; finish one before starting the next.
- Build (`xcodebuild`) after every task and fix errors before moving on.
- Commit per task, with the task ID in the message (e.g. `2.4 Add flow — canonical search`).
- If a task is ambiguous, make the smallest reasonable assumption, note it in the commit, and keep going — don't silently expand scope.
- Avoid churning the Xcode project file: prefer file-system-synchronized folder groups or SPM.

## Where to start

**Milestone 0** in `docs/task-list.md` — Xcode project setup, `supabase-swift`, the config/secrets
machinery (you build the machinery and `.gitignore`; the human supplies the real key value),
`Codable` models mirroring the schema, the data layer, design system, and navigation shell.

The Supabase project and schema already exist. The seed catalog (`seed-catalog-v3.1.md`) has
four rows still marked `unverified` — that's fine; it doesn't block the build until the
Add-flow search in Milestone 2.
