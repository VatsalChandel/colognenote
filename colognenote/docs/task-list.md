# Cologne App — Phase 1 Build Task List

Agent-ready task list for the solo tracker (Phase 1). Work top to bottom — milestones are
dependency-ordered. Each box is one task; the italic line is what "done" means.

**Read alongside:** `supabase-schema.sql` (data + RLS), `phase-1-screens.md` (screen detail),
`screen-action-inventory.md` (full action list), `blueprint.md` (model + stack).

**Ground rules the agent must hold throughout:**
- SwiftUI only — no Storyboards. Backend is Supabase via `supabase-swift`.
- One SwiftUI `View` per screen; one file per view; feature-organized folders.
- RLS is owner-only in Phase 1 — every query runs as the signed-in user.
- **Price and collection value are private.** Price lives in `collection_item_costs`; never expose it in any shared/derived output.
- Logged wears and compliments are **delete-only** (no in-place edit).
- Do **not** build anything under "Deferred" — those are Phase 2.

**Working protocol:**
- Do tasks in order; finish one before starting the next.
- Build (`xcodebuild`) after every task and fix errors before moving on.
- Commit per task, with the task ID in the message (e.g. `2.4 Add flow — canonical search`).
- If a task is ambiguous, make the smallest reasonable assumption, note it in the commit, and keep going — don't silently expand scope.
- Never touch the Deferred section or the commented-out Phase 2 RLS policies.

**Before you ship (deferred, but hard gates — don't forget):** a published privacy policy and Apple's privacy-label disclosures are required to submit to TestFlight/App Store. Not needed to build, but blocking at submission.

---

## Milestone 0 — Project & backend setup

- [x] **0.1 Create Xcode project** — SwiftUI app, iOS target, set minimum iOS version. *Builds and runs an empty app on simulator.* — min iOS 17.0.
- [x] **0.2 Tame the project file** — use file-system-synchronized folder groups (or SPM modules) so adding files doesn't churn `project.pbxproj`. *New files appear without manual pbxproj edits.* — synchronized root group + `.gitignore`.
- [x] **0.3 Command-line build loop** — confirm `xcodebuild` compiles + runs tests from the terminal. *Agent can build and read errors without the Xcode GUI.*
- [x] **0.4 Add `supabase-swift`** — via Swift Package Manager. *Package resolves and imports.* — v2.55.1; `Package.resolved` committed.
- [x] **0.5 Create the Supabase project** — run `supabase-schema.sql` on a fresh DB. *All tables, enums, the view, and RLS policies exist; accord families are seeded.*
- [x] **0.6 Storage buckets** — create `avatars` and `bottle-photos` buckets with owner-write / appropriate-read policies. *Authenticated users can upload; URLs resolve.* — private buckets + owner-folder RLS policies on `storage.objects`.
- [x] **0.7 Configure the Supabase client** — URL + anon key via config (not hard-coded secrets). *A test query returns.* — `Secrets.xcconfig` → `Config.xcconfig` → Info.plist → `SupabaseConfig`; anon-key-only client; verified live (16 accord families decoded on launch).
- [x] **0.8 Data models** — `Codable` structs mirroring every table + enums (Profile, Fragrance, Note, AccordFamily, CollectionItem, CollectionItemCost, WearLog, Compliment, Follow, WishlistItem; ItemStatus, WishlistStage, PyramidPosition, etc.). *Encode/decode round-trips against the schema.* — client coders do snake_case + ISO-8601; Postgres `date` → `String`.
- [x] **0.9 Data layer** — a repository/service per entity with RLS-aware CRUD. *Create/read/update/delete works for the signed-in user.* — Catalog, Fragrance, Profile, Collection, WearLog, Compliment, Wishlist. Follow = Phase 2 (model only); account deletion deferred to M5.
- [x] **0.10 Design system** — color tokens, typography, spacing, and reusable components: bottle card, primary button, and shared Loading / Empty / Error views. *Components render in previews.*
- [x] **0.11 Navigation shell** — root `TabView` (Collection · Insights · Wishlist) with auth-state routing (see 1.6). *Tabs switch; routing stub in place.* — `SessionStore` → `RootView` → `MainTabView` + stub feature screens.
- [x] **0.12 Minimal seed to build against** — the note pick-list (0b.1) plus ~15–20 fragrances with accords + notes, loaded as `canonical`/`verified`. *Enough real data that the Add-flow search (2.4) can be built and tested; the full catalog (0b) lands later.* — `docs/seed-catalog-v3.1.sql`: 15 fragrances, 64 notes, 123 placements; derived accords verified against the spec. Schema has no `unverified` status, so the 4 unconfirmed rows load as `verified` and are flagged for 0b.4.

### Milestone 0b — Full seed catalog *(parallel work — not a code blocker)*
> A **dataset**, not UI work, and it can be assembled alongside the build (by you or an agent) rather than up front. Only the minimal seed (0.12) is needed to start coding. Load the rest before the milestones that rely on it: **accords must be complete before Insights (M4)**; **notes only enrich the detail page and can land last**. Accord *families* are already seeded by the schema. Can't be copied from Fragrantica (copyrighted) — assemble it.
>
> **Ordering rule:** the note pick-list (0b.1) must exist before any fragrance references notes.
- [x] **0b.1 Note pick-list** — common notes (bergamot, pink pepper, ambroxan, vetiver…), each mapped to **one accord family**. *Every note has a `family_id`.* (Shared with 0.12.) — 64 notes loaded, every one with a `family_id`. Grows with 0b.2/0b.3.
- [ ] **0b.2 ~100 fragrances with accords** — mainstream designer core (Dior, Chanel, YSL, Versace, Armani…) plus a few popular niche houses; for each: name, house, concentration, **and its 2–4 accord families**. *Every seed fragrance is accord-tagged — this is the non-negotiable part that powers Insights.*
- [ ] **0b.3 Notes for the top ~20–30** — full top/middle/base pyramid for the most popular fragrances only (the ones that'll be in most test collections). *Popular bottles get rich detail pages; the long tail shows accords-only until V2.*
- [ ] **0b.4 Human spot-check** — verify accords/notes/concentrations on a sample (enthusiasts notice wrong ones). *Owner signs off on accuracy.*
- [ ] **0b.5 Load as seed** — `INSERT`s or JSON import, tier `canonical` / status `verified`. *Full catalog searchable in the Add flow.*
> The long tail of notes is intentionally left for **V2's crowdsourced** contributions — that's what the canonical/personal two-tier system is for.

---

## Milestone 1 — Auth & onboarding

- [ ] **1.1 Sign up** — email + password, choose username + display name; handle taken-username / invalid-email / weak-password errors. *New account creates an `auth.users` row and (via trigger) a profile.*
- [ ] **1.2 Log in** — email + password; "forgot password" → reset email. *Valid creds sign in; bad creds show a clear error.*
- [ ] **1.3 Session handling** — persist session, auto-login on relaunch, token refresh; logout clears all state. *Relaunch stays signed in; logout returns to auth.*
- [ ] **1.4 Profile setup (first run)** — confirm username/display name, upload avatar to storage. *Profile row is complete; avatar URL saved.*
- [ ] **1.5 Empty state** — value one-liner + faded sample-shelf; "Add your first fragrance" → Add flow. *Zero-bottle users land here with an obvious first action.*
- [ ] **1.6 Root routing** — unauthenticated → auth; authed + incomplete profile → setup; authed + zero bottles → empty state; else → Collection. *Each state routes correctly on launch.*

---

## Milestone 2 — Collection · Add · Detail (the catalog spine)

- [ ] **2.1 Collection grid** — `LazyVGrid` of bottle cards (photo, name, house, rating); header shows count + total value **[PRIVATE]**. *Owner's active items render.*
- [ ] **2.2 Sort / filter / search** — sort (rating / recent / most-worn / house / accord / cost-per-wear); filter (house / accord / status); live search. *Each control reorders/filters the grid.*
- [ ] **2.3 Long-press context menu** — `.contextMenu` on a card: quick Log wear / Log compliment. *Both open the correct sheet without opening detail.*
- [ ] **2.4 Add — step 1 (find it)** — search canonical; select a result; "add manually" → free-text name/house/concentration creating a `personal`/`pending` fragrance. *Both paths yield a fragrance to attach.*
- [ ] **2.5 Add — step 2 (your details)** — price → `collection_item_costs`, size, purchase date/location, batch, rating (1–5), photo upload; Save creates the CollectionItem. *New bottle appears in Collection.*
- [ ] **2.6 Edit fragrance** — reopen the form prefilled; update item + cost. *Edits persist.*
- [ ] **2.7 Bottle detail** — all fields, notes + accords (read-only, inherited), stats (worn, compliments, cost-per-wear **[PRIVATE]**), wear-history list, compliments list. *Everything about one bottle in one screen.*
- [ ] **2.8 Change status** — active / finished / sold, with confirm on finished/sold. *Status updates; item leaves the active value total but keeps history.*
- [ ] **2.9 Adjust fill level** — manual slider (0–100%). *Value persists.*
- [ ] **2.10 Delete item** — with confirmation (mistake case). *Item and its cost row are removed.*
- [ ] **2.11 States** — loading / empty / error for Collection and Detail. *No blank or crashing screens.*

---

## Milestone 3 — Logging (the fast loop)

- [ ] **3.1 Log wear sheet** — `.presentationDetents([.medium])`; date (default today), occasion picker, weather auto-filled, SOTD toggle, optional pairing; Save → WearLog. *Two-tap logging; history updates.*
- [ ] **3.2 Delete wear** — with confirm. *Wear removed; any attached compliment goes loose.*
- [ ] **3.3 Log compliment sheet** — attach to a recent wear or leave loose; optional who / comment; date; Save → Compliment. *Compliment appears on the bottle.*
- [ ] **3.4 Delete compliment** — with confirm. *Compliment removed.*
- [ ] **3.5 Wire quick-log** — connect the 2.3 context-menu entries to these sheets. *Long-press → log works end to end.*
- [ ] **3.6 Location permission** — request for weather; graceful fallback if denied (log without weather). *No blocking if permission is refused.*

---

## Milestone 4 — Insights

- [ ] **4.1 Insight queries** — most-worn, most-neglected, best performers, cost-per-wear ranked, accord breakdown (by family), wardrobe gaps, value + count. *All computed on read.*
- [ ] **4.2 Insights screen** — cards + charts (charts run on accord families, not raw notes). *Renders the queries above.*
- [ ] **4.3 Cold-start empty state** — "not enough data yet" shown to new users. *No broken charts on an empty collection.*
- [ ] **4.4 Tap-through** — any insight row → that bottle's detail. *Navigation works.*

---

## Milestone 5 — Wishlist & Settings

- [ ] **5.1 Wishlist list** — sections by stage (sampled / considering / want bottle). *Owner's wishlist renders.*
- [ ] **5.2 Add / edit wishlist item** — canonical search or free text; stage; target price; notes. *Create + edit persist.*
- [ ] **5.3 Swipe actions** — move stage / delete. *Both work from the list.*
- [ ] **5.4 Convert to collection** — "want bottle" → opens Add flow prefilled from the wishlist item. *Buying flows into the collection.*
- [ ] **5.5 Settings — privacy** — statement that price/value are always private + the show-collection-value toggle (default off). *Toggle persists to profile.*
- [ ] **5.6 Settings — edit profile** — username, display name, bio, avatar. *Changes persist.*
- [ ] **5.7 Settings — log out** — clears session and state; returns to auth. *Signs out cleanly.*
- [ ] **5.8 Settings — delete account** — confirm → cascade-delete all data → sign out. *Account and all owned rows are gone (test the cascade).*
- [ ] **5.9 States** — wishlist/settings loading / empty / error. *Consistent with 2.11.*

---

## Milestone 6 — Cross-cutting polish & pre-ship

- [ ] **6.1 Image helpers** — upload/fetch for avatars + bottle photos, with caching. *Images load quickly and don't re-fetch needlessly.*
- [ ] **6.2 Consistent state components** — apply shared Loading/Empty/Error everywhere. *One pattern across the app.*
- [ ] **6.3 Permissions strings** — Info.plist usage descriptions for photos + location. *No launch rejection; prompts read clearly.*
- [ ] **6.4 Derived-value helpers** — cost-per-wear, collection value, season-from-date. *Single source of truth for each calc.*
- [ ] **6.5 RLS verification** — confirm a second user cannot read your rows, and price never leaks via any query/view. *Manual cross-account test passes.*
- [ ] **6.6 Accessibility** — Dynamic Type, VoiceOver labels, tap-target sizes. *Usable with larger text + VoiceOver.*
- [ ] **6.7 App icon + launch screen.** *Present and correct.*
- [ ] **6.8 TestFlight build** — archive, upload, internal test. *Installs from TestFlight.* (Requires the $99 Apple Developer Program.)

---

## Deferred — DO NOT build in Phase 1 (this is Phase 2 of the product)

Public profile · activity feed · discovery / explore · canonical fragrance community page ·
SOTD "what should I wear today" picker · push notifications (SOTD reminder, new follower) ·
follow / unfollow · community aggregates · the public-read RLS policies (they stay commented
in the schema until then).

---

### Suggested working order for the agent
Do **0 fully first** (nothing works without setup), then **1 → 2 → 3** to get the core loop a
tester can actually use, then **4 → 5 → 6**. The app is demo-able to a tester after Milestone 3.
