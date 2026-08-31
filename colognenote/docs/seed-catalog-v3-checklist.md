# Seed Catalog — v3 Build Instructions

**All decisions are locked.** This is an execution work order, not a decision doc — apply the
steps below to the v2 catalog to produce v3. Do not generate SQL until sections 1–3 are done
and section 4's spot-checks are either complete or the affected rows are held back from
`verified`.

---

## Locked decisions (reference — do not reopen)

- **Accords: DERIVED.** A fragrance's accords are the distinct families across its notes,
  computed by the schema's `fragrance_accords` view. There is **no curated accord list** and
  **no `fragrance_accords` table**. The hand-written `accords:` blocks in v2 are removed as data.
- **Families: 16** (Sweet→Gourmand, Animalic→Musky, White Floral kept). `accord-families.md`
  and `supabase-schema.sql` are **already updated** — section F from the old checklist is done.
- **Canonical note names** and **missing-note families** are fixed below.
- **Leather** is intentionally unexercised in the first 15 — do not pad the list.

---

## 1. Apply the derived accords model

Replace each fragrance's `accords:` block with the derived set below (the distinct families of
its notes). By construction there are **no note-unsupported accords** — Baccarat Rouge 540 and
Good Girl lose their old "Amber" tag because no note supports it, and Sauvage gains Woody + Floral.

| Fragrance | Derived accords |
|---|---|
| Sauvage | Citrus, Aromatic, Spicy, Woody, Floral, Amber |
| Bleu de Chanel | Citrus, Aromatic, Spicy, White Floral, Woody, Earthy / Mossy, Smoky, Amber |
| Acqua di Giò | Citrus, White Floral, Aquatic, Aromatic, Fruity, Earthy / Mossy, Woody |
| Dylan Blue | Aquatic, Green, Citrus, Spicy, Woody, Earthy / Mossy, Amber, Musky, Gourmand, Smoky |
| Eros | Citrus, Aromatic, Fruity, Floral, Amber, Woody, Earthy / Mossy, Gourmand |
| Layton | Fruity, Citrus, Spicy, Aromatic, Floral, Earthy / Mossy, Gourmand, Woody |
| Aventus | Fruity, Citrus, Smoky, White Floral, Earthy / Mossy, Musky, Gourmand |
| Khamrah | Citrus, Spicy, Gourmand, White Floral, Woody, Amber |
| Baccarat Rouge 540 | Spicy, White Floral, Musky, Woody |
| Coco Mademoiselle | Citrus, White Floral, Floral, Earthy / Mossy, Woody |
| Miss Dior | White Floral, Floral, Powdery, Woody |
| Libre | Aromatic, Citrus, White Floral, Gourmand, Musky |
| Good Girl | Gourmand, White Floral |
| Allure Homme Sport | Citrus, Woody, Gourmand, Musky |
| Le Male | Aromatic, Gourmand |

> Derived accords can be broad (Dylan Blue reaches 10 families) — that's expected and fine for
> gap/lean analytics. If a *display* wants a shorter "main accords" chip later, that's a Phase-2
> curation task, not a v1 concern.

---

## 2. Complete & normalize the note pick-list

### 2a. Add these missing notes (they're in per-fragrance tables but not the master list)

| Note | Family |
|---|---|
| cardamom | Spicy |
| peony | Floral |
| centifolia rose | Floral |
| tender woods | Woody |
| bitter almond | Gourmand |

### 2b. Apply these canonical note names everywhere (master list AND every per-fragrance table)

| Use this name | Replaces |
|---|---|
| cedar | cedar, cedarwood |
| tonka bean | tonka, tonka bean, roasted tonka |
| amberwood | amber wood, amberwood |
| black pepper | pepper, black pepper |
| musk | musk, white musk, musk accord |
| ambroxan | ambroxan, AmberMax |

Keep these **distinct** (they're different materials), families as shown:
- rose, may rose, centifolia rose → all **Floral**
- jasmine, jasmine sambac, jasmine grandiflorum → all **White Floral**

### 2c. Verify the invariant
Every note used anywhere in the 15 appears **exactly once** in the master pick-list, with
**exactly one** family. Confirm this is actually true after 2a/2b (in v2 it was not).

---

## 3. Re-run the consistency checks

- **Recurring-notes table:** regenerate to include the added/normalized notes.
- **Reconciliation:** now automatic — accords *are* the derived note-families, so accords equal
  their notes' families by definition. Replace v2's subset-style reconciliation with the derived
  list from section 1.
- **Definition-of-Done boxes:** un-check anything that isn't actually true yet (v2 checked
  "every note included" while notes were missing).

---

## 4. Human spot-checks (verification, not decisions)

Verify these pyramids against a source before setting `status = verified`; hold them at
unverified until checked. This is the only remaining human step.

- Bleu de Chanel — full top/middle/base pyramid
- Creed Aventus — which version/composition
- YSL Libre (EDP) — current manufacturer pyramid
- Baccarat Rouge 540 — editorial pyramid positions
- Good Girl — pyramid confirmation

---

## 5. Leather coverage

Intentionally unexercised in the first 15. **No action.** A popular leather scent can join a
later batch; do not add one just to fill the coverage table.

---

## Definition of Done for v3

- [ ] Section 1 applied — every fragrance's accords replaced with its derived set; no curated lists remain.
- [ ] Section 2 applied — missing notes added, canonical names applied everywhere, invariant verified.
- [ ] Section 3 done — consistency checks regenerated; false checkmarks corrected.
- [ ] Section 4 — spot-checks completed, or those rows left `status` un-verified.
- [ ] Then generate SQL: `notes`, `fragrances`, `fragrance_notes` (tier `canonical`; `status` `verified` only for spot-checked rows). `accord_families` is already seeded with 16 in the schema.
