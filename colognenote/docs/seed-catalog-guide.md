# Seed Catalog — How to Build It

Instructions for assembling the starter fragrance data (tasks 0.12 and 0b in the task list).
This is a **content task, not a coding task** — the goal is accurate, consistently-formatted
data that drops straight into the schema. Anyone (or any agent) following this should produce
the same shape of output.

## What you're producing

A list of real fragrances, each tagged so the app can display and analyze it:
- **First pass (task 0.12):** ~15–20 fragrances, fully done (accords **and** notes). This is
  what the build tests the Add-flow search against, so it has to exist before Milestone 2.
- **Full pass (task 0b):** ~100 fragrances with **accords for all**, and **notes only for the
  top ~20–30** most popular. The long tail stays accords-only until V2's crowdsourcing fills it in.

## Read these first

1. **`accord-families.md`** — the fixed list of accord families. Every accord tag and every
   note-to-family mapping MUST use a family from this list, exactly. This is the non-negotiable
   part; if a note doesn't map cleanly to one of these families, that's a flag for review, not
   an excuse to invent a new family.
2. **`supabase-schema.sql`** — look at four things so your output fits the database:
   - `fragrances` table → the fields (name, house, concentration, year_released).
   - the `concentration` CHECK values → you must use one of: `EDC, EDT, EDP, Parfum, Extrait, Eau Fraiche, Elixir`.
   - `notes` table → each note has one `family_id`.
   - `fragrance_notes` + the `pyramid_position` enum → notes are placed `top`, `middle`, or `base`.

## How to choose the fragrances

Pick what your **test users will actually own**, not what's rare or interesting:
- **Mainstream designer core first** — Dior, Chanel, YSL, Versace, Armani, Paco Rabanne,
  Jean Paul Gaultier, Dolce & Gabbana, Prada, Valentino, Hermès.
- **Then the popular niche / Middle-Eastern houses** that show up constantly — Creed, Lattafa,
  Armaf, Parfums de Marly, Xerjoff.
- **Coverage beats obscurity.** Fifteen bottles that appear in most collections are worth more
  than fifteen deep cuts. For the first 15–20, lean on the most-owned designer fragrances.
- **Watch flankers.** "Sauvage EDT," "Sauvage Elixir," and "Sauvage Parfum" are *separate*
  entries with different concentrations and notes — don't collapse them.

## The output format

Produce it as structured data (a table or JSON) with these fields per fragrance:

| Field | Rule |
|-------|------|
| `name` | The fragrance name only (e.g. "Sauvage"), house goes in its own field. |
| `house` | Brand (e.g. "Dior"). |
| `concentration` | Exactly one of the schema's allowed values. |
| `year_released` | Optional; include if known. |
| `accords` | **2–4** families from `accord-families.md`. Required for every fragrance. |
| `notes` | Top / middle / base lists. Required only for the top ~20–30; omit for the rest. |

### Worked example

```
name:          Sauvage
house:         Dior
concentration: EDT
year_released: 2015
accords:       [Citrus, Aromatic, Spicy, Amber]
notes:
  top:    [bergamot, pepper]
  middle: [lavender, pink pepper, vetiver, geranium]
  base:   [ambroxan, cedar, labdanum]
```

Every note listed must also map to a single accord family (bergamot→Citrus, vetiver→Woody,
ambroxan→Amber…). Keep a running note-to-family list as you go — that becomes the note
pick-list (task 0b.1), and it must exist before any fragrance references notes.

## Accuracy rules (this is where it goes wrong)

- **Don't invent notes or accords.** If you're unsure of a fragrance's composition, mark it for
  the human spot-check rather than guessing. Enthusiast users notice wrong notes immediately.
- **One family per note.** Even for ambiguous notes, pick a single primary family — clean
  roll-up is what makes the analytics work.
- **Concentrations must be right,** since flankers differ by exactly this field.
- **Accords should reflect the overall impression** — the 2–4 families that describe how the
  fragrance actually reads, which is usually derivable from its notes.

## Copyright boundary (important)

You **cannot copy** a fragrance database's exact note lists, descriptions, or text (Fragrantica
and similar are copyrighted). Individual notes are facts and fine to state, but assemble them
from general knowledge and your own phrasing — never paste a block from a source page. If in
doubt, write it in your own words.

## Definition of done

- [ ] 15–20 fragrances fully done (accords + notes), loaded as the minimal seed (0.12).
- [ ] ~100 fragrances total, **every one accord-tagged**.
- [ ] Notes present for the top ~20–30 most popular.
- [ ] Every note maps to exactly one accord family from the fixed list.
- [ ] Concentrations valid against the schema's allowed values.
- [ ] A human has spot-checked a sample for accuracy.
- [ ] Loaded as `INSERT`s or JSON import with tier `canonical`, status `verified`.
