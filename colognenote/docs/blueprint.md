# Cologne Collection App — Build Blueprint

Everything decided so far, turned into a data model, a screen list, and a storage/stack plan.
Two ideas run through all of it:

- **Two layers.** A *canonical* layer (shared fragrances, notes, accords — what social counts) and a *personal* layer (the items you own, your logs, your wishlist).
- **Two speeds.** The *collection* changes rarely (you buy something). *Logging* is frequent and impulsive (a compliment, a wear, an SOTD). Logging must be one or two taps from a bottle — never a form.

---

## 1. Data Model

Legend: **[PRIVATE]** = owner-only, never in a public view or feed. **[DERIVED]** = computed, not stored (cache later if needed).

### Canonical layer (shared — load-bearing for social)

**AccordFamily** — the fixed list you just finalized (~14–18 rows, seeded once)
- `id`
- `name` (Citrus, Woody, Amber, …)

**Note** — the growing pick-list
- `id`
- `name` (bergamot, vetiver, ambroxan…)
- `family_id` → AccordFamily  *(each note maps to exactly one family)*

**Fragrance** — the canonical thing social counts
- `id`
- `name`
- `house` (brand)
- `concentration` (EDT / EDP / Parfum / EdC — controlled list)
- `year_released` *(optional)*
- `image_url` *(canonical bottle shot)*
- `tier` (**canonical** / **personal**) — personal entries work for the owner but don't feed community stats
- `status` (pending / verified) — the moderation gate for crowdsourced entries
- `submitted_by` → User *(for crowdsourced adds)*

**FragranceNote** — join, carries the pyramid
- `fragrance_id` → Fragrance
- `note_id` → Note
- `position` (top / middle / base)

> A fragrance's **accords are [DERIVED]**: the distinct set of families across its notes. Sauvage reads as citrus + aromatic + spicy + woody + amber + musky because its notes span those families. Compute this for v1; add manual accord tagging at the promotion step only if trace notes cause noise.

### User & social layer

**User**
- `id`, `username`, `display_name`, `avatar_url`, `bio`, `created_at`
- `show_collection_value` (bool, default **false**) — the one opt-in flex

**Follow**
- `follower_id` → User
- `followee_id` → User
- `created_at`

### Personal layer (what you own — one entry per fragrance owned)

**CollectionItem**
- `id`
- `user_id` → User
- `fragrance_id` → Fragrance *(canonical or personal)*
- `price` **[PRIVATE]** — what you paid *(implemented in a separate owner-only table, `collection_item_costs` — see schema — so it can stay private while the rest of the item goes public in Phase 2)*
- `size_ml`
- `purchase_date`, `purchase_location`, `batch_code` *(all optional)*
- `fill_level` (rough %, manual slider)
- `personal_rating` (1–5)
- `status` (active / finished / sold) — normally not deleted, so history survives; a hard delete exists only for the added-by-mistake case
- `photo_url` *(your own bottle shot, optional; falls back to canonical image)*
- `created_at`
- *cost_per_wear* **[DERIVED] [PRIVATE]** = `price / count(wears)`

### Logging layer

**WearLog** — the core event
- `id`
- `user_id` → User
- `collection_item_id` → CollectionItem
- `date`
- `occasion` (controlled: office / date / gym / formal / casual / night out)
- `season` **[DERIVED]** from date *(or explicit tag)*
- `weather_temp`, `weather_condition` — **auto-captured** at log time, snapshotted here
- `is_sotd` (bool) — SOTD is just a wear you posted publicly
- `pairing` *(free text, optional)*
- `created_at`

**Compliment**
- `id`
- `user_id` → User
- `collection_item_id` → CollectionItem *(which fragrance earned it)*
- `wear_log_id` → WearLog *(nullable — loose compliments allowed, attach later)*
- `date`
- `who`, `what_they_said` *(free text, optional)*
- `created_at`

### Wishlist layer

**WishlistItem**
- `id`
- `user_id` → User
- `fragrance_id` → Fragrance *(canonical or free text)*
- `stage` (sampled / considering / want full bottle) — the funnel
- `target_price`
- `notes` *(samples tried, thoughts)*

### Community aggregates — all [DERIVED]

Computed from the canonical link, per fragrance:
- owner count ("400 people own this")
- average wears / year, average compliments
- **community cost-per-wear** (aggregate is fine to show publicly — no individual's price leaks)
- "people who own X also own Y"

---

## 2. Relationships at a glance

```
User ──< CollectionItem >── Fragrance ──< FragranceNote >── Note ──> AccordFamily
 │            │                  │
 │            ├──< WearLog        └──< (canonical, verified)
 │            └──< Compliment >── WearLog
 │
 ├──< Follow >── User
 └──< WishlistItem >── Fragrance
```

---

## 3. Screens / Pages

Built solo-first, because the single-player game has to be great before social has anything to show.

*(Auth and onboarding — sign up, log in, profile setup — precede all of these. They're covered in full in the screen-action inventory and task list; the feature screens below assume a signed-in user.)*

### Phase 1 — the solo tracker (ship this first, make it excellent)

1. **Empty state** — drops onto "add your first fragrance" (opens search), a faded sample shelf behind it so they see the destination. Teach by getting them to one successful add.
2. **My Collection** *(home)* — grid of bottles; sort/filter/search (rating, most-recent, most-worn, house, accord). Collection value + insights entry point live here **[PRIVATE]**.
3. **Bottle detail** — every field, wear history, compliments, rating, fill level, cost-per-wear **[PRIVATE]**. One-tap **Log wear** and **Log compliment** live here.
4. **Add / edit fragrance** — search canonical → fall back to free text → then item details (price, size, date…). Tags the tier automatically.
5. **Log wear** *(fast sheet)* — date defaults to today, occasion, weather auto-filled, SOTD toggle. Two taps, not a form.
6. **Log compliment** *(fast sheet)* — attach to a wear or leave loose.
7. **Insights** **[PRIVATE]** — most-worn, most-neglected, best performers, cost-per-wear ranked, accord breakdown, wardrobe gaps.
8. **Wishlist** — the three funnel stages.
9. **Settings / privacy** — price private by default; opt-in to show collection value.

### Phase 2 — the social layer (once solo is solid)

10. **Public profile** — the shareable shelf: bottle grid, ratings, SOTD history, best performers. Sort/filter limited to **public fields only** (no price/CPW — those leak by inference).
11. **Feed** — following activity: new pickups, SOTDs, best performers.
12. **Discovery / Explore** — trending, most-owned, "own X also own Y," find users.
13. **Fragrance page (canonical)** — your community's version of a Fragrantica perfume page: pyramid, accords, community stats, who you follow that owns it.
14. **SOTD picker** ("what should I wear today") — suggests by weather / occasion / neglected; feeds the wear log automatically.
15. **Notifications** — SOTD reminder + new follower. Nothing guilt-based (no streaks, no "you've been away").

---

## 4. Storage & Tech Stack

### The database: relational, full stop

Your whole model is relationships — users own items that reference fragrances that have notes that roll up to families; people follow people. And your headline social features ("owners per fragrance," "own X also own Y," "breakdown by accord") are *joins and group-bys*. That is SQL's home turf and awkward in a document store. **Use Postgres.** The canonical/personal split is just a `tier` column; the moderation gate is a `status` column.

### The privacy rule can be enforced by the database, not just the app

This is the strong, concrete fit: **row-level security (RLS)** lets you write a rule like "price is only readable by the row's owner" *at the database level*. Your entire private cluster (price, collection value, cost-per-wear) gets protected by a policy instead of hoping no API endpoint ever leaks it. Given that price-privacy is a core promise of your app, that's worth leaning on.

### Images go in object storage, not the database

Bottle photos and avatars → an object store (S3, Cloudflare R2, or your BaaS's storage). Store the **URL** in Postgres. Never put binary image blobs in the DB.

### Weather is an external call, snapshotted

At log time, hit a weather API (OpenWeather or similar) using the user's location, and **save the result onto the WearLog**. Don't re-fetch — you want the weather *as it was that day*, forever.

### The stack: mobile + free tier (validation-first)

**Decision: native iOS (SwiftUI).** iOS-only to start — easier to build on a Mac, drops the cross-platform tax, and gives the most native feel for one-tap logging, lock-screen SOTD reminders, and a shelf people show off. The goal right now is to get something in people's hands and see if they want it — so the whole stack should cost **$0 until there's demand to justify spending.**

**Frontend — SwiftUI.** Native, code-based UI (no Storyboards — they're XML data files that fight both version control and AI agents). Free to develop; talks to Supabase via the `supabase-swift` SDK. Push notifications (SOTD reminder, new-follower) go through APNs, which you can trigger from a Supabase Edge Function when you get to Phase 2 — free at this scale.

**Backend — Supabase free tier.** It bundles Postgres + auth + file storage + row-level security in one place, all on $0. As of mid-2026 the free tier gives you roughly **500 MB database, 1 GB file storage, 5 GB egress, and 50,000 monthly active users** — orders of magnitude more than you need to prove the idea. (Limits change; check supabase.com/pricing before you rely on a number.)

**Weather — a free weather API tier** (OpenWeather and others have free tiers well above what you'll use), called at log time and snapshotted onto the WearLog.

So the entire backend + notifications + build tooling is free while you validate. Three honest gotchas so nothing surprises you:

- **Supabase free projects auto-pause after ~7 days of inactivity.** Your data survives, but the app goes dark until you manually resume it in the dashboard. Fine during solo development; once you have even a handful of testers poking at it, a small scheduled ping keeps it awake — or that's your first real signal it's worth the $25/mo Pro tier.
- **The free tier has no automated backups.** Don't lose sleep over it at the prototype stage, but don't put anything irreplaceable in there either.
- **The one unavoidable cost is Apple's Developer Program — $99/year.** Native iOS distribution runs through **TestFlight**, which (internal or external, up to 10,000 testers) requires that paid membership. You *can* build and run on your own device for free via Xcode while you develop, but the moment you want the app in other people's hands to validate demand, that's the $99. It's your one real pre-revenue cost — everything else (Supabase, weather, build tooling) stays free.

### Don't over-build day one

- **Search:** with ~100 seed fragrances growing slowly, Postgres full-text search (or even `ILIKE`) is plenty. You do not need a dedicated search service for a long time.
- **Stats:** compute cost-per-wear, collection value, and community aggregates *on read* for v1. Add caching or materialized views only when data volume actually demands it.
- **The whole social layer:** it's Phase 2 for a reason. Ship the solo tracker to a few testers first — if they don't love it empty, the social layer won't save it.

---

## 5. Deliberately deferred (so they don't stall you)

- **Autofill from a big fragrance DB** — manual + free text works; the canonical set grows by crowdsource-through-moderation.
- **Multiple bottles / decants / backups** — one entry = one fragrance owned, on purpose.
- **Performance ratings** (longevity, projection) — the single 1–5 rating covers v1.
- **Privacy granularity** beyond the price rule (per-bottle hiding, approve-followers).
- **Exact inventory decrementing** — keep fill level a rough manual slider; don't count sprays.
- **Fresh-spicy vs. warm-spicy accord split** — start merged, revisit first if you split anything.
