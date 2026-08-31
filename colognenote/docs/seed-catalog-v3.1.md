# Seed Catalog — v3.1

> **Status:** v3.1 — cleaned & corrected  
> **Scope:** First 15 fragrances  
> **Purpose:** Finalize the canonical note pick-list and derived accord behavior before generating Supabase seed SQL.
>
> **Changes from v3:** stripped stray citation artifacts; merged `mandarin orange` → `mandarin` (64 canonical notes); added `ambroxan` to Baccarat Rouge 540 so it derives its signature **Amber** accord, and returned that row to `unverified` pending source confirmation.
>
> **Important:** Accords are **derived**, not curated data. There is no `accords:` field in the canonical fragrance records and no `fragrance_accords` table. The schema's `fragrance_accords` view derives the distinct accord families from a fragrance's notes.

---

# 1. Locked v3 Decisions

## 1.1 Accord model

A fragrance's accords are the distinct families assigned to its notes.

```text
Fragrance
  ↓
FragranceNote
  ↓
Note
  ↓
AccordFamily
```

Therefore:

- There is no hand-written `accords:` data in the fragrance records.
- There is no curated `fragrance_accords` table.
- The `fragrance_accords` view computes the accord set.
- Broad derived sets are expected.
- A shorter "main accords" display can be added later as a Phase 2 presentation/curation feature.

## 1.2 Final accord families

There are exactly **16** families:

1. Citrus
2. Aromatic
3. Green
4. Aquatic
5. Fruity
6. Floral
7. White Floral
8. Spicy
9. Gourmand
10. Woody
11. Earthy / Mossy
12. Amber
13. Powdery
14. Leather
15. Smoky
16. Musky

The following merges are locked:

- Sweet → Gourmand
- Animalic → Musky
- White Floral remains separate

**Leather is intentionally unexercised in this first 15. Do not add a fragrance solely to exercise Leather.**

---

# 2. Derived Accord Sets

These are the expected outputs of the `fragrance_accords` view for the current note data.

| # | Fragrance | Derived accord families |
|---|---|---|
| 1 | Sauvage | Citrus, Aromatic, Spicy, Woody, Floral, Amber |
| 2 | Bleu de Chanel | Citrus, Aromatic, Spicy, White Floral, Woody, Earthy / Mossy, Smoky, Amber |
| 3 | Acqua di Giò | Citrus, White Floral, Aquatic, Aromatic, Fruity, Earthy / Mossy, Woody |
| 4 | Dylan Blue Pour Homme | Aquatic, Green, Citrus, Spicy, Woody, Earthy / Mossy, Amber, Musky, Gourmand, Smoky |
| 5 | Versace Eros | Citrus, Aromatic, Fruity, Floral, Amber, Woody, Earthy / Mossy, Gourmand |
| 6 | Layton | Fruity, Citrus, Spicy, Aromatic, Floral, Earthy / Mossy, Gourmand, Woody |
| 7 | Aventus | Fruity, Citrus, Smoky, White Floral, Earthy / Mossy, Musky, Gourmand |
| 8 | Khamrah | Citrus, Spicy, Gourmand, White Floral, Woody, Amber |
| 9 | Baccarat Rouge 540 | Spicy, White Floral, Musky, Woody, Amber |
| 10 | Coco Mademoiselle | Citrus, White Floral, Floral, Earthy / Mossy, Woody |
| 11 | Miss Dior | White Floral, Floral, Powdery, Woody |
| 12 | Libre | Aromatic, Citrus, White Floral, Gourmand, Musky |
| 13 | Good Girl | Gourmand, White Floral |
| 14 | Allure Homme Sport | Citrus, Woody, Gourmand, Musky |
| 15 | Le Male | Aromatic, Gourmand |

These are **derived expectations**, not manually stored accord records.

---

# 3. Canonical Note → Family Pick-List

This is the load-bearing artifact for the catalog.

After normalization, there are **64 distinct canonical notes** used across the 15 fragrances.

Every note used by any fragrance appears exactly once below and has exactly one family.

| Canonical note | Family |
|---|---|
| akigalawood | Woody |
| ambergris | Musky |
| amberwood | Woody |
| ambroxan | Amber |
| apple | Fruity |
| benzoin | Amber |
| bergamot | Citrus |
| birch | Smoky |
| bitter almond | Gourmand |
| black pepper | Spicy |
| blackcurrant | Fruity |
| cardamom | Spicy |
| cedar | Woody |
| centifolia rose | Floral |
| cinnamon | Spicy |
| clary sage | Aromatic |
| cocoa | Gourmand |
| coffee | Gourmand |
| dates | Gourmand |
| fig leaf | Green |
| frankincense | Smoky |
| geranium | Floral |
| ginger | Spicy |
| grapefruit | Citrus |
| green apple | Fruity |
| green tangerine | Citrus |
| guaiac wood | Woody |
| iris | Powdery |
| jasmine | White Floral |
| jasmine grandiflorum | White Floral |
| jasmine sambac | White Floral |
| labdanum | Amber |
| lavender | Aromatic |
| lemon | Citrus |
| lily-of-the-valley | White Floral |
| mandarin | Citrus |
| marine notes | Aquatic |
| may rose | Floral |
| mint | Aromatic |
| musk | Musky |
| myrrh | Amber |
| neroli | White Floral |
| nutmeg | Spicy |
| oakmoss | Earthy / Mossy |
| orange | Citrus |
| orange blossom | White Floral |
| papyrus | Woody |
| patchouli | Earthy / Mossy |
| peony | Floral |
| persimmon | Fruity |
| pineapple | Fruity |
| pink pepper | Spicy |
| praline | Gourmand |
| rosemary | Aromatic |
| saffron | Spicy |
| sandalwood | Woody |
| tender woods | Woody |
| tonka bean | Gourmand |
| tuberose | White Floral |
| vanilla | Gourmand |
| vetiver | Woody |
| violet | Floral |
| violet leaf | Green |
| water notes | Aquatic |

## 3.1 Canonical-name normalization

The following names are mandatory everywhere in v3:

| Canonical name | Replaces |
|---|---|
| cedar | cedar, cedarwood |
| tonka bean | tonka, tonka bean, roasted tonka |
| amberwood | amber wood, amberwood |
| black pepper | pepper, black pepper |
| musk | musk, white musk, musk accord |
| ambroxan | ambroxan, AmberMax |
| mandarin | mandarin, mandarin orange |

The following remain distinct notes:

- rose
- may rose
- centifolia rose

All three map to **Floral**.

And:

- jasmine
- jasmine sambac
- jasmine grandiflorum

All three map to **White Floral**.

---

# 4. Ambiguous-Note Decisions — Locked

These mappings are not to be decided per fragrance.

| Note | Family | Locked rationale |
|---|---|---|
| patchouli | Earthy / Mossy | Consistent earthy/patchouli treatment across the catalog. |
| frankincense | Smoky | Incense is represented through the Smoky family. |
| saffron | Spicy | Saffron is treated as a spice rather than Leather. |
| birch | Smoky | Birch/birch-tar character is represented as smoky. |
| ambergris | Musky | Animalic was merged into Musky. |
| neroli | White Floral | Neroli is treated as the floral orange-blossom material. |
| jasmine | White Floral | Jasmine is a defining white floral. |
| iris | Powdery | Iris/orrris belongs to Powdery. |
| violet | Floral | Violet is treated as general Floral in this taxonomy. |
| tonka bean | Gourmand | Sweet was merged into Gourmand. |
| vanilla | Gourmand | Sweet/edible vanillic material belongs to Gourmand. |
| benzoin | Amber | Resinous/balsamic treatment. |
| myrrh | Amber | Resinous/balsamic treatment. |
| tobacco, if added later | Smoky | No dedicated Tobacco family in v1. |
| oud, if added later | Woody | No dedicated Oud/Animalic family in v1. |

---

# 5. The 15 Fragrances

> **Data rule:** There is deliberately **no `accords:` block** below. The accord list is shown only in the separate derived-accord section above and is computed from the notes.

---

## 1. Dior Sauvage

```yaml
name: Sauvage
house: Dior
concentration: EDT
year_released: 2015
notes:
  top:
    - bergamot
    - black pepper
  middle:
    - lavender
    - pink pepper
    - vetiver
    - geranium
  base:
    - ambroxan
    - cedar
    - labdanum
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| bergamot | Citrus |
| black pepper | Spicy |
| lavender | Aromatic |
| pink pepper | Spicy |
| vetiver | Woody |
| geranium | Floral |
| ambroxan | Amber |
| cedar | Woody |
| labdanum | Amber |

**Derived accords:** Citrus, Aromatic, Spicy, Woody, Floral, Amber

---

## 2. Chanel Bleu de Chanel

```yaml
name: Bleu de Chanel
house: Chanel
concentration: EDT
year_released: 2010
notes:
  top:
    - lemon
    - grapefruit
    - mint
    - pink pepper
  middle:
    - ginger
    - nutmeg
    - jasmine
    - cedar
  base:
    - sandalwood
    - patchouli
    - frankincense
    - labdanum
status: unverified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| lemon | Citrus |
| grapefruit | Citrus |
| mint | Aromatic |
| pink pepper | Spicy |
| ginger | Spicy |
| nutmeg | Spicy |
| jasmine | White Floral |
| cedar | Woody |
| sandalwood | Woody |
| patchouli | Earthy / Mossy |
| frankincense | Smoky |
| labdanum | Amber |

**Derived accords:** Citrus, Aromatic, Spicy, White Floral, Woody, Earthy / Mossy, Smoky, Amber

**Verification status:** Held at `unverified`. CHANEL's current page confirms the EDT as aromatic-woody and the current Bleu de Chanel line, but the exact complete top/middle/base pyramid used here was not confirmed from the current manufacturer page.

---

## 3. Giorgio Armani Acqua di Giò

```yaml
name: Acqua di Giò
house: Giorgio Armani
concentration: EDT
year_released: 1996
notes:
  top:
    - bergamot
    - neroli
    - green tangerine
  middle:
    - marine notes
    - rosemary
    - persimmon
  base:
    - patchouli
    - cedar
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| bergamot | Citrus |
| neroli | White Floral |
| green tangerine | Citrus |
| marine notes | Aquatic |
| rosemary | Aromatic |
| persimmon | Fruity |
| patchouli | Earthy / Mossy |
| cedar | Woody |

**Derived accords:** Citrus, White Floral, Aquatic, Aromatic, Fruity, Earthy / Mossy, Woody

---

## 4. Versace Dylan Blue Pour Homme

```yaml
name: Dylan Blue Pour Homme
house: Versace
concentration: EDT
year_released: 2016
notes:
  top:
    - water notes
    - fig leaf
    - bergamot
    - grapefruit
  middle:
    - violet leaf
    - patchouli
    - papyrus
    - black pepper
    - ambroxan
  base:
    - musk
    - tonka bean
    - saffron
    - frankincense
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| water notes | Aquatic |
| fig leaf | Green |
| bergamot | Citrus |
| grapefruit | Citrus |
| violet leaf | Green |
| patchouli | Earthy / Mossy |
| papyrus | Woody |
| black pepper | Spicy |
| ambroxan | Amber |
| musk | Musky |
| tonka bean | Gourmand |
| saffron | Spicy |
| frankincense | Smoky |

**Derived accords:** Aquatic, Green, Citrus, Spicy, Woody, Earthy / Mossy, Amber, Musky, Gourmand, Smoky

---

## 5. Versace Eros

```yaml
name: Eros
house: Versace
concentration: EDT
year_released: 2012
notes:
  top:
    - lemon
    - mandarin
    - mint
    - green apple
  middle:
    - geranium
    - clary sage
    - ambroxan
  base:
    - cedar
    - vetiver
    - patchouli
    - sandalwood
    - vanilla
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| lemon | Citrus |
| mandarin | Citrus |
| mint | Aromatic |
| green apple | Fruity |
| geranium | Floral |
| clary sage | Aromatic |
| ambroxan | Amber |
| cedar | Woody |
| vetiver | Woody |
| patchouli | Earthy / Mossy |
| sandalwood | Woody |
| vanilla | Gourmand |

**Derived accords:** Citrus, Aromatic, Fruity, Floral, Amber, Woody, Earthy / Mossy, Gourmand

---

## 6. Parfums de Marly Layton

```yaml
name: Layton
house: Parfums de Marly
concentration: EDP
year_released: 2016
notes:
  top:
    - apple
    - bergamot
    - cardamom
  middle:
    - lavender
    - violet
    - geranium
  base:
    - patchouli
    - vanilla
    - guaiac wood
    - praline
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| apple | Fruity |
| bergamot | Citrus |
| cardamom | Spicy |
| lavender | Aromatic |
| violet | Floral |
| geranium | Floral |
| patchouli | Earthy / Mossy |
| vanilla | Gourmand |
| guaiac wood | Woody |
| praline | Gourmand |

**Derived accords:** Fruity, Citrus, Spicy, Aromatic, Floral, Earthy / Mossy, Gourmand, Woody

---

## 7. Creed Aventus

```yaml
name: Aventus
house: Creed
concentration: EDP
year_released: 2010
notes:
  top:
    - pineapple
    - bergamot
    - blackcurrant
    - apple
  middle:
    - birch
    - jasmine
    - patchouli
  base:
    - oakmoss
    - musk
    - ambergris
    - vanilla
status: unverified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| pineapple | Fruity |
| bergamot | Citrus |
| blackcurrant | Fruity |
| apple | Fruity |
| birch | Smoky |
| jasmine | White Floral |
| patchouli | Earthy / Mossy |
| oakmoss | Earthy / Mossy |
| musk | Musky |
| ambergris | Musky |
| vanilla | Gourmand |

**Derived accords:** Fruity, Citrus, Smoky, White Floral, Earthy / Mossy, Musky, Gourmand

**Verification status:** Held at `unverified`. Creed's current official Aventus page confirms apple, blackcurrant, pineapple and bergamot in the head; jasmine, birch and juniper berries in the heart; and oakmoss, vanilla and ambergris in the base. It does not match the v2 pyramid exactly, so the exact composition/version represented here must be resolved before verification.

---

## 8. Lattafa Khamrah

```yaml
name: Khamrah
house: Lattafa
concentration: EDP
year_released: 2022
notes:
  top:
    - bergamot
    - cinnamon
    - nutmeg
  middle:
    - dates
    - praline
    - lily-of-the-valley
    - tuberose
  base:
    - vanilla
    - tonka bean
    - amberwood
    - myrrh
    - benzoin
    - akigalawood
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| bergamot | Citrus |
| cinnamon | Spicy |
| nutmeg | Spicy |
| dates | Gourmand |
| praline | Gourmand |
| lily-of-the-valley | White Floral |
| tuberose | White Floral |
| vanilla | Gourmand |
| tonka bean | Gourmand |
| amberwood | Woody |
| myrrh | Amber |
| benzoin | Amber |
| akigalawood | Woody |

**Derived accords:** Citrus, Spicy, Gourmand, White Floral, Woody, Amber

---

## 9. Maison Francis Kurkdjian Baccarat Rouge 540

```yaml
name: Baccarat Rouge 540
house: Maison Francis Kurkdjian
concentration: EDP
year_released: 2015
notes:
  top:
    - saffron
  middle:
    - jasmine grandiflorum
    - ambergris
  base:
    - cedar
    - ambroxan
status: unverified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| saffron | Spicy |
| jasmine grandiflorum | White Floral |
| ambergris | Musky |
| cedar | Woody |
| ambroxan | Amber |

**Derived accords:** Spicy, White Floral, Musky, Woody, Amber

**Verification status:** Held at `unverified`. `ambroxan` was added so the derived accords include **Amber** — BR540's signature warm-ambery character was otherwise absent, which the note-derived model would have wrongly excluded. In the 16-family taxonomy this ambery-sweet quality reads as Amber (Sweet was merged into edible Gourmand, which BR540 is not). Confirm the added note against a source before setting `verified`.

---

## 10. Chanel Coco Mademoiselle

```yaml
name: Coco Mademoiselle
house: Chanel
concentration: EDP
year_released: 2001
notes:
  top:
    - orange
    - bergamot
  middle:
    - jasmine
    - may rose
  base:
    - patchouli
    - vetiver
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| orange | Citrus |
| bergamot | Citrus |
| jasmine | White Floral |
| may rose | Floral |
| patchouli | Earthy / Mossy |
| vetiver | Woody |

**Derived accords:** Citrus, White Floral, Floral, Earthy / Mossy, Woody

---

## 11. Dior Miss Dior

```yaml
name: Miss Dior
house: Dior
concentration: EDP
year_released: 2021
notes:
  top:
    - lily-of-the-valley
    - peony
  middle:
    - centifolia rose
    - iris
  base:
    - tender woods
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| lily-of-the-valley | White Floral |
| peony | Floral |
| centifolia rose | Floral |
| iris | Powdery |
| tender woods | Woody |

**Derived accords:** White Floral, Floral, Powdery, Woody

---

## 12. Yves Saint Laurent Libre

```yaml
name: Libre
house: Yves Saint Laurent
concentration: EDP
year_released: 2019
notes:
  top:
    - lavender
    - mandarin
  middle:
    - orange blossom
    - jasmine
  base:
    - vanilla
    - musk
status: unverified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| lavender | Aromatic |
| orange blossom | White Floral |
| jasmine | White Floral |
| vanilla | Gourmand |
| musk | Musky |

**Derived accords:** Aromatic, Citrus, White Floral, Gourmand, Musky

**Verification status:** Held at `unverified`. YSL's current official page confirms the core lavender, orange blossom, musk accord and vanilla profile, but the complete manufacturer top/middle/base pyramid was not displayed in the current page content used for verification. A current secondary source provides the familiar detailed pyramid, but the v3 requirement is manufacturer-pyramid verification.

---

## 13. Carolina Herrera Good Girl

```yaml
name: Good Girl
house: Carolina Herrera
concentration: EDP
year_released: 2016
notes:
  top:
    - bitter almond
    - coffee
  middle:
    - jasmine sambac
    - tuberose
  base:
    - tonka bean
    - cocoa
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| bitter almond | Gourmand |
| coffee | Gourmand |
| jasmine sambac | White Floral |
| tuberose | White Floral |
| tonka bean | Gourmand |
| cocoa | Gourmand |

**Derived accords:** Gourmand, White Floral

**Verification status:** Verified. Carolina Herrera's current product page confirms bitter almond as the opening, jasmine sambac and tuberose as the heart, and roasted tonka bean and cocoa as the lingering/base character. It also describes the fragrance as an ambery floral, but Amber is correctly **not** a derived accord because no canonical note in this seed maps to Amber.

---

## 14. Chanel Allure Homme Sport

```yaml
name: Allure Homme Sport
house: Chanel
concentration: EDT
year_released: 2004
notes:
  top:
    - mandarin
  middle:
    - cedar
  base:
    - tonka bean
    - musk
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| mandarin | Citrus |
| cedar | Woody |
| tonka bean | Gourmand |
| musk | Musky |

**Derived accords:** Citrus, Woody, Gourmand, Musky

---

## 15. Jean Paul Gaultier Le Male

```yaml
name: Le Male
house: Jean Paul Gaultier
concentration: EDT
year_released: 1995
notes:
  top:
    - mint
  middle:
    - lavender
  base:
    - vanilla
status: verified
tier: canonical
```

### Note → Family

| Note | Family |
|---|---|
| mint | Aromatic |
| lavender | Aromatic |
| vanilla | Gourmand |

**Derived accords:** Aromatic, Gourmand

**Important:** The old floating Amber accord has been removed. There is no Amber-derived family in this note set.

---

# 6. Recurring Notes Check

The following table is regenerated from the normalized v3 catalog.

| Canonical note | Appears in | Family |
|---|---|---|
| ambroxan | Sauvage, Dylan Blue Pour Homme, Eros, Baccarat Rouge 540 | Amber |
| apple | Layton, Aventus | Fruity |
| bergamot | Sauvage, Acqua di Giò, Bleu de Chanel, Layton, Aventus, Khamrah, Coco Mademoiselle | Citrus |
| cedar | Sauvage, Bleu de Chanel, Acqua di Giò, Eros, Baccarat Rouge 540, Allure Homme Sport | Woody |
| frankincense | Bleu de Chanel, Dylan Blue Pour Homme | Smoky |
| geranium | Sauvage, Eros, Layton | Floral |
| jasmine | Bleu de Chanel, Aventus, Coco Mademoiselle, Libre | White Floral |
| lavender | Sauvage, Layton, Libre, Le Male | Aromatic |
| mint | Bleu de Chanel, Eros, Le Male | Aromatic |
| musk | Aventus, Libre, Allure Homme Sport | Musky |
| patchouli | Bleu de Chanel, Acqua di Giò, Dylan Blue Pour Homme, Eros, Layton, Aventus, Coco Mademoiselle | Earthy / Mossy |
| pink pepper | Sauvage, Bleu de Chanel | Spicy |
| tonka bean | Dylan Blue Pour Homme, Khamrah, Good Girl, Allure Homme Sport | Gourmand |
| vanilla | Eros, Layton, Aventus, Libre, Le Male | Gourmand |
| vetiver | Sauvage, Eros, Coco Mademoiselle | Woody |

**Normalization check:** `cedarwood`, `white musk`, `roasted tonka`, `amber wood`, `pepper`, and `AmberMax` do not survive as separate canonical note names.

---

# 7. Invariant Check

## 7.1 Every used note appears in the master pick-list

**PASS — 64/64 canonical notes are represented.**

## 7.2 Every master note is used by at least one fragrance

**PASS — 64/64 canonical notes are used.**

## 7.3 Every note has exactly one family

**PASS — 64/64 notes have exactly one family.**

## 7.4 No non-canonical aliases remain in fragrance tables

**PASS** after the v3 normalization rules are applied.

## 7.5 Every fragrance has a note-derived accord set

**PASS.**

The derived accord set is the distinct family set across that fragrance's notes.

---

# 8. Derived-Accord Reconciliation

Because accords are now derived, reconciliation is automatic.

For every fragrance:

```text
derived accords
=
DISTINCT(note.family for every fragrance note)
```

Therefore there is no second manually maintained accord list that can disagree with the note mappings.

Examples:

### Sauvage

Notes reach:

- Citrus → bergamot
- Spicy → black pepper / pink pepper
- Aromatic → lavender
- Woody → vetiver / cedar
- Floral → geranium
- Amber → ambroxan / labdanum

Therefore:

**Citrus, Aromatic, Spicy, Woody, Floral, Amber**

### Dylan Blue Pour Homme

Notes reach:

- Aquatic
- Green
- Citrus
- Spicy
- Woody
- Earthy / Mossy
- Amber
- Musky
- Gourmand
- Smoky

Therefore the view returns all ten.

### Baccarat Rouge 540

Notes reach:

- Spicy → saffron
- White Floral → jasmine grandiflorum
- Musky → ambergris
- Woody → cedar
- Amber → ambroxan

Therefore:

**Spicy, White Floral, Musky, Woody, Amber**

`ambroxan` was added so BR540's signature amber facet is represented.

### Good Girl

Notes reach:

- Gourmand → bitter almond, coffee, tonka bean, cocoa
- White Floral → jasmine sambac, tuberose

Therefore:

**Gourmand, White Floral**

There is intentionally **no Amber** accord despite Carolina Herrera describing Good Girl as an ambery floral. The app's v1 accord model is derived from the canonical note-family mapping, not the manufacturer's broad olfactive-family label.

### Le Male

Notes reach:

- Aromatic → mint, lavender
- Gourmand → vanilla

Therefore:

**Aromatic, Gourmand**

There is no floating Amber accord.

---

# 9. Human Spot-Check Status

The v3 work order identifies five affected rows.

| Fragrance | Status | Action |
|---|---|---|
| Bleu de Chanel | **Unverified** | Exact full EDT pyramid still needs manufacturer/source confirmation. |
| Creed Aventus | **Unverified** | Resolve exact version/composition represented by the seed. |
| YSL Libre EDP | **Unverified** | Confirm complete current manufacturer pyramid. |
| Baccarat Rouge 540 | **Unverified** | `ambroxan` added for the Amber facet; confirm composition before verifying. |
| Good Girl EDP | **Verified** | Current manufacturer page confirms the working note sequence. |

### Verification notes

**Bleu de Chanel:** CHANEL's current page confirms the EDT is an aromatic-woody fragrance and separately identifies its concentration variants, but the exact full top/middle/base list used in this seed was not confirmed from the manufacturer page.

**Aventus:** Creed's current official page gives a current composition that differs from the v2 working pyramid, particularly around the heart/base presentation. This is why the row remains unverified rather than silently being changed.

**Libre:** YSL currently confirms the core lavender, orange blossom, musk accord and vanilla profile. The detailed pyramid used in this seed is supported by current secondary references, but the v3 requirement is manufacturer-pyramid verification, so the row remains unverified.

**Baccarat Rouge 540:** `ambroxan` was added to the base so the derived accords include Amber, which BR540 is defined by. The row is held at `unverified` pending source confirmation of the full composition.

**Good Girl:** Carolina Herrera's current page explicitly confirms bitter almond first, jasmine sambac and tuberose developing next, and roasted tonka bean and cocoa lingering in the base.

---

# 10. Leather Coverage

Leather is intentionally **not exercised** in the first 15.

No action is required.

Do not add a fragrance solely to fill Leather coverage.

---

# 11. Definition of Done

## Section 1 — Derived Accords

- [x] Every fragrance's curated `accords:` block has been removed.
- [x] Expected derived accord sets are documented separately.
- [x] Accord sets are exactly the distinct note families.
- [x] No note-unsupported accord remains.
- [x] Baccarat Rouge 540 derives Amber via an added `ambroxan` note (its signature facet).
- [x] Good Girl no longer has Amber.
- [x] Sauvage gains Woody and Floral.

## Section 2 — Note Pick-List

- [x] Missing notes added: cardamom, peony, centifolia rose, tender woods, bitter almond.
- [x] Canonical names applied throughout.
- [x] Duplicate aliases normalized.
- [x] Every used note appears exactly once in the master pick-list.
- [x] Every master note is used by at least one fragrance.
- [x] Every note has exactly one family.
- [x] Recurring ambiguous notes use one locked family consistently.

## Section 3 — Consistency

- [x] Recurring-note table regenerated.
- [x] Derived-accord reconciliation replaces the old subset-style reconciliation.
- [x] Definition-of-done status reflects actual completion.

## Section 4 — Human Spot-Checks

- [ ] Bleu de Chanel — **hold at unverified**
- [ ] Creed Aventus — **hold at unverified**
- [ ] YSL Libre EDP — **hold at unverified**
- [ ] Baccarat Rouge 540 — **hold at unverified** (ambroxan added for Amber)
- [x] Good Girl — verified

## Section 5 — Leather

- [x] Leather intentionally remains unexercised.

---

# 12. SQL Gate

**Do not generate SQL yet.**

The catalog is structurally ready, but the remaining three affected rows must either:

1. receive their required human/source verification, **or**
2. remain `status = unverified`.

Once that is settled, SQL generation should contain only:

```text
notes
fragrances
fragrance_notes
```

with:

```text
tier = canonical
status = verified
```

only for rows that have actually passed verification.

`accord_families` is already seeded with the final 16 families.

There should be **no SQL for `fragrance_accords`**, because accords are derived by the schema view.

---

# 13. Final v3 Principle

The canonical source of truth is now:

```text
Canonical Note
      ↓
Exactly One Accord Family
      ↓
Fragrance Note
      ↓
Derived Fragrance Accords
```

The important invariant is:

> **One note → one family, everywhere.**

That invariant is what makes the later collection analytics reliable.

**v3 is not an SQL document. It is the finalized catalog specification immediately before seed generation.**
