# Accord Families — the fixed vocabulary

This is the small, stable list your analytics run on. Finalize it now; touch it rarely.
Individual **notes** (bergamot, vetiver, ambroxan…) grow over time and each one files
under exactly one family here. Everything rolls up to this set, so gaps, breakdowns, and
"what does my collection lean toward" keep working no matter how big the note list gets.

---

## Final list — 16 families (locked)

Each family has a one-line scope and a few example notes. Those example notes double as
seeds of your note pick-list — and they show the note → family mapping in action.

| # | Family | What it covers | Example notes that file under it |
|---|--------|----------------|-----------------------------------|
| 1 | **Citrus** | Bright, zesty, peel-forward | bergamot, lemon, grapefruit, mandarin, orange |
| 2 | **Aromatic** | Herbal / lavender / the fougère backbone | lavender, sage, rosemary, basil, mint |
| 3 | **Green** | Crushed leaves, stems, sap | galbanum, violet leaf, grass, tomato leaf |
| 4 | **Aquatic** | Marine, watery, ozonic freshness | sea notes, calone, water lily, salt |
| 5 | **Fruity** | Non-citrus fruit | apple, peach, blackcurrant, pineapple, berries |
| 6 | **Floral** | General florals | rose, geranium, iris, violet, peony |
| 7 | **White Floral** | Heady, narcotic white blooms | jasmine, tuberose, orange blossom, gardenia, ylang-ylang |
| 8 | **Spicy** | Warm and fresh spices | pepper, cinnamon, cardamom, clove, nutmeg |
| 9 | **Gourmand** | Edible / dessert / sweet | vanilla, chocolate, coffee, caramel, tonka, honey |
| 10 | **Woody** | Dry and creamy woods | cedar, sandalwood, vetiver, oud, cypress |
| 11 | **Earthy / Mossy** | Damp forest floor, the chypre backbone | oakmoss, patchouli, mushroom |
| 12 | **Amber** | Warm, resinous, balsamic ("oriental") | ambroxan, labdanum, benzoin, myrrh, frankincense |
| 13 | **Powdery** | Soft, cosmetic, orris-driven | orris/iris, heliotrope, almond |
| 14 | **Leather** | Tanned hide, suede | leather, suede, birch tar, styrax |
| 15 | **Smoky** | Incense, burnt, tarry | incense, guaiac wood, birch tar, tobacco |
| 16 | **Musky** | Clean, skin, and animalic musks | white musk, ambrette, ambergris, civet |

**Merges applied to reach 16** (from an original 18): **Sweet → Gourmand** (sweet is a modifier, not a family — it double-counted), and **Animalic → Musky** (rare in mainstream fragrances; split it back out later if niche shelves need it — that's the cheap direction). **White Floral is kept separate** — it's a basic, high-frequency distinction across feminine and unisex scents, and collapsing it loses real signal.

Deferred splits (start merged, revisit only if the data demands): Fresh vs. Warm Spicy, and dedicated Tobacco / Boozy families (filed under Smoky / Gourmand for now).

---

## One modeling note (affects the schema)

Two different things are easy to conflate:

- **A note maps to ONE family.** bergamot → Citrus, vetiver → Woody, ambroxan → Amber. Pick a single primary even for ambiguous notes (pink pepper → Spicy), because clean roll-up is the whole point.
- **A fragrance ends up with MANY accords.** It has notes spanning several families, so its "accord profile" is the *set* of families its notes touch. That's expected and correct — e.g. Sauvage reads as citrus + aromatic + spicy + woody + amber + musky all at once. Your analytics run on this per-fragrance accord set.

**For v1, derive the fragrance's accords from its notes' families** — free, no extra curation. If a trace note ends up overweighting a family, you can add manual accord tagging at the canonical/promotion step later. Start derived; curate only if it gets noisy.

---

## Where this lives

Both lists sit at the **canonical layer**, attached to the shared fragrance — never to a
user's owned item. Users never type a note or an accord. When you promote a crowd-sourced
fragrance into canonical, tagging its notes (from the pick-list) is part of that same
moderation step; its accords are then **derived** from those notes' families automatically.
