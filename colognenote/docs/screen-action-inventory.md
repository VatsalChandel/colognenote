# Phase 1 — Screen & Action Inventory

The complete list of screens and every action on them, built to convert directly into a
task list. Checkboxes = discrete units of work. Native mapping is SwiftUI (sheets,
`.contextMenu`, `NavigationStack`); backend is Supabase (`supabase-swift`).

Items marked **[NEW]** were missing from the earlier screen spec and are the gaps that would
otherwise ship a half-app.

---

## A. Auth & onboarding  **[NEW — entire section]**

### A1. Sign up
Purpose: create an account; a profile row is auto-created by the DB trigger.
- [ ] Email + password sign-up (Supabase auth)
- [ ] Choose username (unique) + display name
- [ ] Handle "username taken" / invalid email / weak password errors
- [ ] Email verification handling (if enabled)

### A2. Log in
- [ ] Email + password log-in
- [ ] "Forgot password" → reset flow (email link)
- [ ] Persist session / auto-login on relaunch
- [ ] Handle bad-credentials error

### A3. Profile setup (first run)
Purpose: fill in the profile the trigger stubbed out.
- [ ] Set/confirm username + display name
- [ ] Upload avatar (photo picker → Supabase storage)
- [ ] Continue → Empty state

### A4. Empty state
- [ ] Value one-liner + faded sample-shelf graphic
- [ ] "Add your first fragrance" → opens Add flow (step 1)

---

## B. Collection (home tab)

Purpose: the shelf and the hub.
- [ ] Render bottle grid (photo, name, house, rating indicator)
- [ ] Header: collection count + total value **[PRIVATE]**
- [ ] Tap a card → Bottle detail
- [ ] "+" → Add fragrance
- [ ] Gear → Settings
- [ ] Search (live filter of the grid)
- [ ] Sort (rating / most-recent / most-worn / house / accord / cost-per-wear)
- [ ] Filter (by house / accord / status)
- [ ] Long-press card → context menu: quick Log wear / Log compliment **[NEW]**
- [ ] Pull to refresh
- States: [ ] loading  [ ] empty (→ A4)  [ ] error

---

## C. Add / Edit fragrance (sheet, 2 steps)

### Step 1 — find it
- [ ] Search canonical fragrances (name/house)
- [ ] Select a canonical result
- [ ] "Add manually" → free-text name, house, concentration (creates a `personal`/`pending` fragrance)
- States: [ ] search loading  [ ] no results (→ manual)

### Step 2 — your details
- [ ] Enter price **[PRIVATE]**, size (ml), purchase date, location, batch code
- [ ] Set personal rating (1–5)
- [ ] Add photo (camera or library → Supabase storage)
- [ ] Save (create) → new CollectionItem (+ cost row)
- [ ] Save (edit) — same form, prefilled from an existing item **[NEW: edit path]**
- [ ] Cancel / dismiss
- States: [ ] save error

---

## D. Bottle detail

Purpose: everything about one owned bottle + the logging launchpad.
- [ ] Show photo, name/house/concentration, size, purchase info, batch, fill level, rating
- [ ] Show notes + accords (inherited from canonical, read-only; notes may be absent for less-common fragrances — show accords, hide the empty pyramid)
- [ ] Show stats: times worn, compliment count, cost-per-wear **[PRIVATE]**
- [ ] Show wear history list
- [ ] Show compliments list
- [ ] **Log wear** (primary, thumb-reachable) → sheet
- [ ] **Log compliment** (primary) → sheet
- [ ] Edit → Add/Edit flow prefilled
- [ ] Change status: active / finished / sold **[NEW: confirm on sold/finished]**
- [ ] Adjust fill level (slider)
- [ ] Delete item (mistake case, with confirmation) **[NEW]**
- [ ] Tap a wear in history → delete that wear (with confirm) **[NEW]**
- [ ] Tap a compliment → delete that compliment (with confirm) **[NEW]**
- States: [ ] empty wear history  [ ] empty compliments

---

## E. Log wear (sheet — fast)
- [ ] Date (defaults to today)
- [ ] Occasion picker (office / date / gym / formal / casual / night out)
- [ ] Weather auto-filled from location (display, not typed)
- [ ] SOTD toggle
- [ ] Optional pairing note
- [ ] Save → WearLog; dismiss
- [ ] Delete a wear (with confirm) **[NEW]**
- [ ] Cancel

## F. Log compliment (sheet — fast)
- [ ] Attach to a recent wear OR leave loose
- [ ] Optional "who" + "what they said"
- [ ] Date (defaults to today)
- [ ] Save → Compliment; dismiss
- [ ] Delete a compliment (with confirm) **[NEW]**
- [ ] Cancel

> v1 is **delete-only** for logged wears and compliments — no in-place editing. To fix a mislog, delete and re-log. Editing can come later.

---

## G. Insights (tab)

Purpose: the payoff. All **[PRIVATE]** in Phase 1.
- [ ] Header: collection value + item count
- [ ] Most-worn / most-neglected
- [ ] Best performers (most compliments)
- [ ] Cost-per-wear ranked
- [ ] Accord breakdown (bar/donut, by family not raw note)
- [ ] Wardrobe gaps (thin accords / seasons)
- [ ] Tap any row → that bottle's detail
- States: [ ] **not-enough-data empty state** (the first thing new users see) **[NEW]**  [ ] loading

---

## H. Wishlist (tab)

Purpose: the sampling funnel.
- [ ] Render sections by stage (sampled / considering / want bottle)
- [ ] Add item (search canonical or free text; stage; target price; notes)
- [ ] Edit an item
- [ ] Swipe → move stage
- [ ] Swipe → delete
- [ ] **Convert "want bottle" → Collection item** (buy it: opens Add flow prefilled) **[NEW]**
- States: [ ] empty  [ ] loading

---

## I. Settings

Purpose: small, but holds the privacy promise + account.
- [ ] Privacy: statement that price + value are always private
- [ ] Toggle: show collection value on profile (default off)
- [ ] Edit profile: username, display name, bio
- [ ] Change avatar
- [ ] **Log out** **[NEW]**
- [ ] Delete account (cascades all data) **[NEW]**
- [ ] Notification preferences (placeholder → Phase 2)

---

## J. Cross-cutting (not screens, but real tasks)

- [ ] Permissions: location (weather), photo library / camera **[NEW]**
- [ ] Supabase storage: upload + fetch images (avatars, bottle photos)
- [ ] Session handling: auto-login, token refresh, logout clears state
- [ ] Global loading / error / empty patterns (reusable components)
- [ ] Networking layer: typed models (`Codable`) mirroring the schema tables
- [ ] RLS-aware queries (owner-only reads in Phase 1)
- [ ] Derived values computed in-app: cost-per-wear, collection value, season-from-date

---

## K. Explicitly deferred to Phase 2 (name them so the agent doesn't build them now)

Public profile · activity feed · discovery/explore · canonical fragrance community page ·
SOTD "what should I wear today" picker · push notifications (SOTD reminder, new follower) ·
follow / unfollow · community aggregates · the public-read RLS policies.

---

### How to turn this into the task list
Group by section A–J, then order by the build sequence: **auth → collection/add/detail →
logging → insights → wishlist/settings → cross-cutting polish.** Each checkbox is roughly
one task (one SwiftUI view, one action, or one service function). The **[NEW]** items are the
ones most likely to be forgotten — keep them in.
