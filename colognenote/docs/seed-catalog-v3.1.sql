-- ============================================================
--  Cologne Collection — minimal seed (task 0.12)
--  Source: docs/seed-catalog-v3.1.md  (first 15 fragrances, 64-note pick-list)
--
--  Run AFTER supabase-schema.sql, in the Supabase SQL editor.
--  Safe to re-run: every insert is guarded (ON CONFLICT / NOT EXISTS).
--
--  NOTE ON STATUS: the schema's fragrance_status enum is ('pending','verified')
--  only — there is no 'unverified'. All 15 rows load as tier='canonical',
--  status='verified' so the Milestone-2 Add-flow search has data to hit.
--  Four rows still owe a manufacturer-pyramid spot-check (task 0b.4) and are
--  flagged below; downgrade them to 'pending' if you'd rather hide them until
--  checked:  Bleu de Chanel · Aventus · Libre · Baccarat Rouge 540
--  accord_families (16 rows) are already seeded by supabase-schema.sql.
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 1. Note pick-list — 64 canonical notes, each mapped to ONE family
--    (task 0b.1). family_id is resolved by name, not hard-coded.
-- ------------------------------------------------------------
insert into notes (name, family_id)
select v.note_name, af.id
from (values
  ('akigalawood',          'Woody'),
  ('ambergris',            'Musky'),
  ('amberwood',            'Woody'),
  ('ambroxan',             'Amber'),
  ('apple',                'Fruity'),
  ('benzoin',              'Amber'),
  ('bergamot',             'Citrus'),
  ('birch',                'Smoky'),
  ('bitter almond',        'Gourmand'),
  ('black pepper',         'Spicy'),
  ('blackcurrant',         'Fruity'),
  ('cardamom',             'Spicy'),
  ('cedar',                'Woody'),
  ('centifolia rose',      'Floral'),
  ('cinnamon',             'Spicy'),
  ('clary sage',           'Aromatic'),
  ('cocoa',                'Gourmand'),
  ('coffee',               'Gourmand'),
  ('dates',                'Gourmand'),
  ('fig leaf',             'Green'),
  ('frankincense',         'Smoky'),
  ('geranium',             'Floral'),
  ('ginger',               'Spicy'),
  ('grapefruit',           'Citrus'),
  ('green apple',          'Fruity'),
  ('green tangerine',      'Citrus'),
  ('guaiac wood',          'Woody'),
  ('iris',                 'Powdery'),
  ('jasmine',              'White Floral'),
  ('jasmine grandiflorum', 'White Floral'),
  ('jasmine sambac',       'White Floral'),
  ('labdanum',             'Amber'),
  ('lavender',             'Aromatic'),
  ('lemon',                'Citrus'),
  ('lily-of-the-valley',   'White Floral'),
  ('mandarin',             'Citrus'),
  ('marine notes',         'Aquatic'),
  ('may rose',             'Floral'),
  ('mint',                 'Aromatic'),
  ('musk',                 'Musky'),
  ('myrrh',                'Amber'),
  ('neroli',               'White Floral'),
  ('nutmeg',               'Spicy'),
  ('oakmoss',              'Earthy / Mossy'),
  ('orange',               'Citrus'),
  ('orange blossom',       'White Floral'),
  ('papyrus',              'Woody'),
  ('patchouli',            'Earthy / Mossy'),
  ('peony',                'Floral'),
  ('persimmon',            'Fruity'),
  ('pineapple',            'Fruity'),
  ('pink pepper',          'Spicy'),
  ('praline',              'Gourmand'),
  ('rosemary',             'Aromatic'),
  ('saffron',              'Spicy'),
  ('sandalwood',           'Woody'),
  ('tender woods',         'Woody'),
  ('tonka bean',           'Gourmand'),
  ('tuberose',             'White Floral'),
  ('vanilla',              'Gourmand'),
  ('vetiver',              'Woody'),
  ('violet',               'Floral'),
  ('violet leaf',          'Green'),
  ('water notes',          'Aquatic')
) as v(note_name, family_name)
join accord_families af on af.name = v.family_name
on conflict (name) do nothing;

-- ------------------------------------------------------------
-- 2. Fragrances — 15 canonical rows. submitted_by = null (seed data).
--    Guarded by NOT EXISTS on (name, house) since there's no unique index.
-- ------------------------------------------------------------
insert into fragrances (name, house, concentration, year_released, tier, status)
select v.name, v.house, v.concentration, v.year_released, 'canonical'::fragrance_tier, 'verified'::fragrance_status
from (values
  ('Sauvage',             'Dior',                        'EDT', 2015::smallint),
  ('Bleu de Chanel',      'Chanel',                      'EDT', 2010),  -- spot-check pyramid
  ('Acqua di Giò',        'Giorgio Armani',              'EDT', 1996),
  ('Dylan Blue Pour Homme','Versace',                    'EDT', 2016),
  ('Eros',                'Versace',                     'EDT', 2012),
  ('Layton',              'Parfums de Marly',            'EDP', 2016),
  ('Aventus',             'Creed',                       'EDP', 2010),  -- spot-check pyramid
  ('Khamrah',             'Lattafa',                     'EDP', 2022),
  ('Baccarat Rouge 540',  'Maison Francis Kurkdjian',    'EDP', 2015),  -- spot-check pyramid
  ('Coco Mademoiselle',   'Chanel',                      'EDP', 2001),
  ('Miss Dior',           'Dior',                        'EDP', 2021),
  ('Libre',               'Yves Saint Laurent',          'EDP', 2019),  -- spot-check pyramid
  ('Good Girl',           'Carolina Herrera',            'EDP', 2016),
  ('Allure Homme Sport',  'Chanel',                      'EDT', 2004),
  ('Le Male',             'Jean Paul Gaultier',          'EDT', 1995)
) as v(name, house, concentration, year_released)
where not exists (
  select 1 from fragrances f where f.name = v.name and f.house = v.house
);

-- ------------------------------------------------------------
-- 3. Pyramid placements. Accords are DERIVED from these via the
--    fragrance_accords view — nothing else to insert for accords.
-- ------------------------------------------------------------
insert into fragrance_notes (fragrance_id, note_id, position)
select f.id, n.id, v.position::pyramid_position
from (values
  -- Sauvage
  ('Sauvage','Dior','bergamot','top'),
  ('Sauvage','Dior','black pepper','top'),
  ('Sauvage','Dior','lavender','middle'),
  ('Sauvage','Dior','pink pepper','middle'),
  ('Sauvage','Dior','vetiver','middle'),
  ('Sauvage','Dior','geranium','middle'),
  ('Sauvage','Dior','ambroxan','base'),
  ('Sauvage','Dior','cedar','base'),
  ('Sauvage','Dior','labdanum','base'),
  -- Bleu de Chanel
  ('Bleu de Chanel','Chanel','lemon','top'),
  ('Bleu de Chanel','Chanel','grapefruit','top'),
  ('Bleu de Chanel','Chanel','mint','top'),
  ('Bleu de Chanel','Chanel','pink pepper','top'),
  ('Bleu de Chanel','Chanel','ginger','middle'),
  ('Bleu de Chanel','Chanel','nutmeg','middle'),
  ('Bleu de Chanel','Chanel','jasmine','middle'),
  ('Bleu de Chanel','Chanel','cedar','middle'),
  ('Bleu de Chanel','Chanel','sandalwood','base'),
  ('Bleu de Chanel','Chanel','patchouli','base'),
  ('Bleu de Chanel','Chanel','frankincense','base'),
  ('Bleu de Chanel','Chanel','labdanum','base'),
  -- Acqua di Giò
  ('Acqua di Giò','Giorgio Armani','bergamot','top'),
  ('Acqua di Giò','Giorgio Armani','neroli','top'),
  ('Acqua di Giò','Giorgio Armani','green tangerine','top'),
  ('Acqua di Giò','Giorgio Armani','marine notes','middle'),
  ('Acqua di Giò','Giorgio Armani','rosemary','middle'),
  ('Acqua di Giò','Giorgio Armani','persimmon','middle'),
  ('Acqua di Giò','Giorgio Armani','patchouli','base'),
  ('Acqua di Giò','Giorgio Armani','cedar','base'),
  -- Dylan Blue Pour Homme
  ('Dylan Blue Pour Homme','Versace','water notes','top'),
  ('Dylan Blue Pour Homme','Versace','fig leaf','top'),
  ('Dylan Blue Pour Homme','Versace','bergamot','top'),
  ('Dylan Blue Pour Homme','Versace','grapefruit','top'),
  ('Dylan Blue Pour Homme','Versace','violet leaf','middle'),
  ('Dylan Blue Pour Homme','Versace','patchouli','middle'),
  ('Dylan Blue Pour Homme','Versace','papyrus','middle'),
  ('Dylan Blue Pour Homme','Versace','black pepper','middle'),
  ('Dylan Blue Pour Homme','Versace','ambroxan','middle'),
  ('Dylan Blue Pour Homme','Versace','musk','base'),
  ('Dylan Blue Pour Homme','Versace','tonka bean','base'),
  ('Dylan Blue Pour Homme','Versace','saffron','base'),
  ('Dylan Blue Pour Homme','Versace','frankincense','base'),
  -- Eros
  ('Eros','Versace','lemon','top'),
  ('Eros','Versace','mandarin','top'),
  ('Eros','Versace','mint','top'),
  ('Eros','Versace','green apple','top'),
  ('Eros','Versace','geranium','middle'),
  ('Eros','Versace','clary sage','middle'),
  ('Eros','Versace','ambroxan','middle'),
  ('Eros','Versace','cedar','base'),
  ('Eros','Versace','vetiver','base'),
  ('Eros','Versace','patchouli','base'),
  ('Eros','Versace','sandalwood','base'),
  ('Eros','Versace','vanilla','base'),
  -- Layton
  ('Layton','Parfums de Marly','apple','top'),
  ('Layton','Parfums de Marly','bergamot','top'),
  ('Layton','Parfums de Marly','cardamom','top'),
  ('Layton','Parfums de Marly','lavender','middle'),
  ('Layton','Parfums de Marly','violet','middle'),
  ('Layton','Parfums de Marly','geranium','middle'),
  ('Layton','Parfums de Marly','patchouli','base'),
  ('Layton','Parfums de Marly','vanilla','base'),
  ('Layton','Parfums de Marly','guaiac wood','base'),
  ('Layton','Parfums de Marly','praline','base'),
  -- Aventus
  ('Aventus','Creed','pineapple','top'),
  ('Aventus','Creed','bergamot','top'),
  ('Aventus','Creed','blackcurrant','top'),
  ('Aventus','Creed','apple','top'),
  ('Aventus','Creed','birch','middle'),
  ('Aventus','Creed','jasmine','middle'),
  ('Aventus','Creed','patchouli','middle'),
  ('Aventus','Creed','oakmoss','base'),
  ('Aventus','Creed','musk','base'),
  ('Aventus','Creed','ambergris','base'),
  ('Aventus','Creed','vanilla','base'),
  -- Khamrah
  ('Khamrah','Lattafa','bergamot','top'),
  ('Khamrah','Lattafa','cinnamon','top'),
  ('Khamrah','Lattafa','nutmeg','top'),
  ('Khamrah','Lattafa','dates','middle'),
  ('Khamrah','Lattafa','praline','middle'),
  ('Khamrah','Lattafa','lily-of-the-valley','middle'),
  ('Khamrah','Lattafa','tuberose','middle'),
  ('Khamrah','Lattafa','vanilla','base'),
  ('Khamrah','Lattafa','tonka bean','base'),
  ('Khamrah','Lattafa','amberwood','base'),
  ('Khamrah','Lattafa','myrrh','base'),
  ('Khamrah','Lattafa','benzoin','base'),
  ('Khamrah','Lattafa','akigalawood','base'),
  -- Baccarat Rouge 540
  ('Baccarat Rouge 540','Maison Francis Kurkdjian','saffron','top'),
  ('Baccarat Rouge 540','Maison Francis Kurkdjian','jasmine grandiflorum','middle'),
  ('Baccarat Rouge 540','Maison Francis Kurkdjian','ambergris','middle'),
  ('Baccarat Rouge 540','Maison Francis Kurkdjian','cedar','base'),
  ('Baccarat Rouge 540','Maison Francis Kurkdjian','ambroxan','base'),
  -- Coco Mademoiselle
  ('Coco Mademoiselle','Chanel','orange','top'),
  ('Coco Mademoiselle','Chanel','bergamot','top'),
  ('Coco Mademoiselle','Chanel','jasmine','middle'),
  ('Coco Mademoiselle','Chanel','may rose','middle'),
  ('Coco Mademoiselle','Chanel','patchouli','base'),
  ('Coco Mademoiselle','Chanel','vetiver','base'),
  -- Miss Dior
  ('Miss Dior','Dior','lily-of-the-valley','top'),
  ('Miss Dior','Dior','peony','top'),
  ('Miss Dior','Dior','centifolia rose','middle'),
  ('Miss Dior','Dior','iris','middle'),
  ('Miss Dior','Dior','tender woods','base'),
  -- Libre
  ('Libre','Yves Saint Laurent','lavender','top'),
  ('Libre','Yves Saint Laurent','mandarin','top'),
  ('Libre','Yves Saint Laurent','orange blossom','middle'),
  ('Libre','Yves Saint Laurent','jasmine','middle'),
  ('Libre','Yves Saint Laurent','vanilla','base'),
  ('Libre','Yves Saint Laurent','musk','base'),
  -- Good Girl
  ('Good Girl','Carolina Herrera','bitter almond','top'),
  ('Good Girl','Carolina Herrera','coffee','top'),
  ('Good Girl','Carolina Herrera','jasmine sambac','middle'),
  ('Good Girl','Carolina Herrera','tuberose','middle'),
  ('Good Girl','Carolina Herrera','tonka bean','base'),
  ('Good Girl','Carolina Herrera','cocoa','base'),
  -- Allure Homme Sport
  ('Allure Homme Sport','Chanel','mandarin','top'),
  ('Allure Homme Sport','Chanel','cedar','middle'),
  ('Allure Homme Sport','Chanel','tonka bean','base'),
  ('Allure Homme Sport','Chanel','musk','base'),
  -- Le Male
  ('Le Male','Jean Paul Gaultier','mint','top'),
  ('Le Male','Jean Paul Gaultier','lavender','middle'),
  ('Le Male','Jean Paul Gaultier','vanilla','base')
) as v(frag_name, frag_house, note_name, position)
join fragrances f on f.name = v.frag_name and f.house = v.frag_house and f.tier = 'canonical'
join notes n on n.name = v.note_name
on conflict (fragrance_id, note_id, position) do nothing;

commit;

-- ------------------------------------------------------------
-- Quick checks (run after commit):
--   select count(*) from notes;                        -- expect 64
--   select count(*) from fragrances where tier='canonical';  -- expect 15
--   select count(*) from fragrance_notes;              -- expect 123
--   select f.name, string_agg(fa.family_name, ', ' order by fa.family_name)
--     from fragrances f
--     join fragrance_accords fa on fa.fragrance_id = f.id
--     group by f.name order by f.name;                 -- derived accords per fragrance
-- ------------------------------------------------------------
