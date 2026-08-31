# Phase 1 — iOS Screen Flow & Spec

The solo tracker. Ship this to a handful of TestFlight users before any social work.
Stack: SwiftUI (native iOS), Supabase backend via `supabase-swift`. Navigation via
`NavigationStack` (drill-in), `TabView` (the shell), and `.sheet` + `.presentationDetents` (fast actions).

The rule that shapes every screen: **the collection is slow, logging is fast.** Adding a
bottle can be a proper multi-field flow. Logging a wear or compliment must be a sheet you
dismiss in seconds — never a full screen, never a form you scroll.

---

## The app shell

**Bottom tab bar (3 tabs):**
- **Collection** *(home)* — the shelf; where you land.
- **Insights** — the stats that make logging worth it.
- **Wishlist** — the sampling funnel.

**Not tabs:**
- **Settings** — gear icon, top-right of the Collection nav bar.
- **Add** — "+" button, top-right of Collection (and the empty-state button). Opens as a sheet.
- **Log wear / Log compliment** — sheets launched from a bottle, never from the tab bar.

---

## First-session flow

```
Launch
  ├─ no bottles ──►  Empty state ──►  Add fragrance ──►  Collection
  └─ has bottles ─►  Collection

Collection ──tap bottle──►  Bottle detail ──►  Log wear (sheet)
     │                           └────────►  Log compliment (sheet)
     ├──"+"──►  Add fragrance (sheet)
     └──gear──►  Settings
```

---

## Screen specs

### 1. Empty state
*The first thing a new user sees. Its only job: one successful add.*
- **On screen:** a friendly one-liner ("Your shelf is empty — let's add your first fragrance"), a faded/sample shelf graphic behind it so they see the destination, and one prominent **Add your first fragrance** button.
- **Actions:** tap the button → opens Add fragrance (step 1, search).
- **Not here:** no tutorial carousel, no feature tour. Teach by doing. A short "how it works" link can sit underneath for the curious, but the add is the hero.
- **iOS note:** center the content vertically; big primary button in accent color. This is also your seed-100 database's audition — the first search has to return something satisfying.

### 2. Collection (home)
*The shelf, and the hub everything routes through.*
- **On screen:** a grid of bottle cards (photo, name, house; small rating indicator). Top bar shows collection count and **total value [PRIVATE]**. Sort / filter / search controls.
- **Sort/filter:** rating, most-recent add, most-worn, house, accord. (These are the *owner's* view, so cost-per-wear sorting is allowed here — it won't be on the public profile later.)
- **Actions:** tap a card → Bottle detail. "+" → Add fragrance. Gear → Settings. Search → filters the grid live.
- **iOS note:** large-title nav bar that collapses on scroll; `LazyVGrid` inside a `ScrollView`. **Long-press a card → `.contextMenu` with "Log wear" / "Log compliment"** — this is the native shortcut that honors the two-speed rule, letting a compliment get logged without even opening the bottle.

### 3. Add fragrance *(sheet, 2 steps)*
*Slow flow, that's fine — it happens rarely. Two clear steps.*
- **Step 1 — find it:** a search box queries the **canonical** database first. Results show name + house. If nothing matches: **"Add it manually"** → free-text name, house, concentration. Tag the tier automatically (canonical vs. personal).
- **Step 2 — your details:** price **[PRIVATE]**, size (ml), purchase date, purchase location, batch code (all optional except maybe price), personal rating (1–5), and a photo (camera or library). Everything but the fragrance identity is *yours*, not shared.
- **Actions:** Save → new CollectionItem, land back on Collection (card appears) or push straight to its Bottle detail.
- **iOS note:** present as a sheet with a large detent; the two steps as a short wizard or a single scrollable form with a clear "Save". PhotosUI (`PhotosPicker`) for the photo.

### 4. Bottle detail
*Everything about one owned bottle — and the launchpad for logging.*
- **On screen:** photo, name/house/concentration, size, purchase info, batch, fill level, **personal rating**, and the fragrance's notes + accords (inherited from canonical — read-only; note that less-common fragrances may be accords-only, so show accords and hide the empty pyramid gracefully). Stats block: times worn, compliment count, **cost-per-wear [PRIVATE]**. Below: **wear history** (recent wears with date/occasion) and **compliments** list.
- **Primary actions (must be thumb-reachable):** **Log wear** and **Log compliment** — big, obvious, open sheets.
- **Secondary:** Edit (reopens Add flow, prefilled), change **status** (active / finished / sold — never delete, so history survives), adjust fill level.
- **iOS note:** the two log buttons pinned where the thumb lands (bottom, or a sticky action row) — this is the screen the whole two-speed idea lives or dies on.

### 5. Log wear *(sheet — the fast one)*
*Two taps, then gone.*
- **On screen:** date (defaults to **today**), occasion picker (office / date / gym / formal / casual / night out), **weather auto-filled** from location (shown, not typed), an **SOTD toggle** (mark this wear public later), optional pairing note.
- **Actions:** Save → creates a WearLog; sheet dismisses back to the bottle with history updated. Season is derived from the date — not asked.
- **iOS note:** `.presentationDetents([.medium])`; everything visible without scrolling. CoreLocation for weather at save time, snapshotted onto the record. Nothing punishes gaps — no streaks, no guilt.

### 6. Log compliment *(sheet — the other fast one)*
*Capture the moment before it's forgotten.*
- **On screen:** attach to a recent wear (short list of the last few wears) **or** leave it loose; optional "who said it" and "what they said"; date defaults to today.
- **Actions:** Save → creates a Compliment (linked to a WearLog if attached). Attaching is one tap, never required.
- **iOS note:** reachable from the bottle *and* from the long-press context menu on the Collection grid — because compliments are the most impulsive log of all.

### 7. Insights
*The payoff. This is why logging is worth the effort.*
- **On screen (all [PRIVATE] in Phase 1):** top block with collection value + count. Then cards: most-worn, most-neglected (haven't worn in a while), best performers (most compliments), **cost-per-wear ranked**, accord breakdown (bar/donut by family), and wardrobe gaps (which accords/seasons are thin).
- **Actions:** tap any insight row → jumps to that bottle's detail.
- **iOS note:** a scroll of cards. Charts run **on accords, not raw notes** — a dozen families read clean; hundreds of notes would be noise. Compute on read for v1.

### 8. Wishlist
*The sampling funnel — sampled → considering → want full bottle.*
- **On screen:** sections by stage. Each item: fragrance (canonical or free text), target price, short notes ("tried the sample, loved the drydown").
- **Actions:** "+" to add (search or free text, pick stage, target price, notes). Tap an item to edit. **Swipe** a row to move stage or delete.
- **iOS note:** grouped list with swipe actions — very native, very cheap.

### 9. Settings
*Small, but it holds your core promise.*
- **On screen:** privacy — a plain statement that **price and collection value are always private**, plus the one opt-in toggle: **show my collection value on my profile** (default off). Account basics: username, display name, avatar, bio. A placeholder for notification prefs (SOTD reminder, follows) that lights up in Phase 2.
- **iOS note:** standard grouped settings list. The privacy copy matters — this is the trust you're asking testers to extend.

---

## Build order within Phase 1

Don't build the screens in numbered order — build the spine that proves the loop, then the payoff:

1. **Add fragrance + Collection + Bottle detail** — you can now store a collection. The catalog works.
2. **Log wear + Log compliment** — the two-speed loop is alive; the app has a reason to reopen.
3. **Empty state** — polish the very first impression once the destination exists.
4. **Insights** — turns the logged data into the reason to keep going.
5. **Wishlist + Settings** — round it out.

If testers don't love steps 1–4 with an empty social graph, the social layer won't rescue it —
so this is exactly the right thing to put in their hands first.
