# ASSET_SPEC_IMAGES.md — Telvar's Test of Fire

> Every image asset required by the game. Each entry includes filename, path,
> dimensions, frame layout, format, an AI generation prompt, and notes.

**Master Style Prompt Prefix (prepend to all generation prompts):**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette`

---

## Table of Contents

1. [Player (Telvar)](#1-player-telvar)
2. [Ghost Sprites (5 types)](#2-ghost-sprites)
3. [Level Tilesets (6 levels)](#3-level-tilesets)
4. [Spell Page Icons](#4-spell-page-icons)
5. [Sphere of Darkness](#5-sphere-of-darkness)
6. [Bonus Item Sprites](#6-bonus-item-sprites)
7. [HUD Elements](#7-hud-elements)
8. [UI Panels](#8-ui-panels)
9. [Backgrounds](#9-backgrounds)
10. [Effects](#10-effects)
11. [Palette Guide](#palette-guide)

---

## 1. Player (Telvar)

### 1.1 Walk Sprite Sheet

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/player/telvar_walk.png` |
| **Dimensions** | 128×32 px (4 columns × 1 row per direction; 4 rows total = 128×128 final sheet if stacked, but spec calls for 128×32 single-direction) |
| **Layout** | 4 directions (down, left, right, up) × 4 frames each. Grid: 16 columns × 1 row = 128×32 OR 4 columns × 4 rows = 128×128. **Recommended: 4 cols × 4 rows = 128×128 px, 32×32 per frame.** |
| **Frame size** | 32×32 px |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of a young male wizard named Telvar, dark blue robes with gold trim, pointed wizard hat, glowing staff in right hand, 4-frame walk cycle animation, side view, 32x32 pixel character, transparent background, pixel-perfect grid alignment`

**Variations needed:**
- Row 1: facing down (4 frames)
- Row 2: facing left (4 frames)
- Row 3: facing right (4 frames)
- Row 4: facing up (4 frames)

### 1.2 Idle Sprite

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/player/telvar_idle.png` |
| **Dimensions** | 64×32 px (2 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 2 (subtle breathing/glow animation) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Single pixel art sprite of a young wizard named Telvar standing idle, dark blue robes with gold trim, pointed hat, staff with soft glow, front-facing, 32x32 pixels, 2-frame idle animation sheet, transparent background`

### 1.3 Death Animation

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/player/telvar_death.png` |
| **Dimensions** | 256×32 px (8 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 8 (collapse + dissolve into particles) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. 8-frame death animation sprite sheet of a pixel art wizard, showing the character spinning, shrinking, and dissolving into magical sparks, 32x32 per frame, horizontal strip layout, transparent background`

---

## 2. Ghost Sprites

All ghost sprites follow the same structure: 4-frame walk animation × 4 directions, plus frightened and eaten variants.

**Per-ghost sheet layout:** 32×32 per frame.

### 2.1 Aemon Guardian (Blinky — aggressive chase)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/aemon_guardian.png` |
| **Dimensions** | 128×128 px (4 cols × 4 rows, 32×32 per frame) |
| **Frame size** | 32×32 px |
| **Frames** | 16 (4 directions × 4 walk frames) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of a spectral red guardian spirit, glowing crimson eyes, flowing ethereal robes, aggressive hovering pose, 4-frame walk animation, 32x32 pixels per frame, 4 directions (down/left/right/up), transparent background, arcade ghost style`

### 2.2 Abyssal Creature (Pinky — ambush)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/abyssal_creature.png` |
| **Dimensions** | 128×128 px |
| **Frame size** | 32×32 px |
| **Frames** | 16 |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of a dark purple abyssal creature, tentacle-like wisps, glowing violet eyes, shadowy amorphous body, 4-frame walk animation, 32x32 pixels per frame, 4 directions, transparent background, arcade ghost style`

### 2.3 Hound of Fenrir (special — levels 4-6)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/hound_fenrir.png` |
| **Dimensions** | 128×128 px |
| **Frame size** | 32×32 px |
| **Frames** | 16 |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of a fierce spectral wolf hound, dark grey fur with glowing orange cracks, fiery eyes, snarling fangs, 4-frame walk animation, 32x32 pixels per frame, 4 directions, transparent background, menacing arcade enemy style`

### 2.4 Undead (Inky — slow then fast)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/undead.png` |
| **Dimensions** | 128×128 px |
| **Frame size** | 32×32 px |
| **Frames** | 16 |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of an undead skeleton spirit, cyan-tinted bones, ghostly blue aura, hollow glowing eye sockets, tattered hood, 4-frame walk animation, 32x32 pixels per frame, 4 directions, transparent background, arcade ghost style`

### 2.5 Elemental Guardian (Clyde — random, Level 4 only)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/elemental_guardian.png` |
| **Dimensions** | 128×128 px |
| **Frame size** | 32×32 px |
| **Frames** | 16 |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of an elemental guardian made of swirling orange and yellow energy, crackling lightning core, rocky fragments orbiting body, 4-frame walk animation, 32x32 pixels per frame, 4 directions, transparent background, arcade ghost style`

### 2.6 Frightened Ghost (shared — all types)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/ghost_frightened.png` |
| **Dimensions** | 128×32 px (4 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 4 (wobble animation) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of a frightened ghost turning deep blue, wobbling, wide panicked eyes, 4-frame trembling animation, 32x32 pixels per frame, single row horizontal strip, transparent background, classic arcade frightened ghost`

**Notes:** Used for all 5 ghost types when player activates banish mode. Last 2 frames flash white to warn banish is ending.

### 2.7 Eaten Ghost (shared — all types)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/ghosts/ghost_eaten.png` |
| **Dimensions** | 128×128 px (4 cols × 4 rows) |
| **Frame size** | 32×32 px |
| **Frames** | 16 (4 directions × 4 frames) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Sprite sheet of ghost eyes only floating back to spawn, two small glowing blue-white eyes, no body, 4-frame bobbing animation, 32x32 pixels per frame, 4 directions, transparent background`

---

## 3. Level Tilesets

All tiles are 32×32 px. Each level tileset contains at least 8 tile variants arranged in a grid. Recommended layout: 8 columns × 2 rows = 256×64 px per tileset.

### Tile Variants (per tileset)
1. Wall (solid)
2. Wall corner (top-left)
3. Wall corner (top-right)
4. Wall edge (horizontal)
5. Wall edge (vertical)
6. Floor (walkable)
7. Floor variant (decorative crack/pattern)
8. Decorative tile (level-specific feature)

### 3.1 Level 1 — Alchemical Labs

| Field | Value |
|---|---|
| **Filename** | `assets/tilesets/level1_alchemical_labs.png` |
| **Dimensions** | 256×64 px (8 cols × 2 rows, 32×32 per tile) |
| **Tile size** | 32×32 px |
| **Tile count** | 16 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Tileset for an alchemical laboratory dungeon, orange and dark red color scheme, stone brick walls with bubbling potion stains, cracked floor tiles with glowing rune circles, brass pipe decorations, 32x32 pixel tiles, seamless tileable, top-down perspective`

### 3.2 Level 2 — Binding Chamber

| Field | Value |
|---|---|
| **Filename** | `assets/tilesets/level2_binding_chamber.png` |
| **Dimensions** | 256×64 px |
| **Tile size** | 32×32 px |
| **Tile count** | 16 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Tileset for a mystical binding chamber, deep purple and silver color scheme, polished obsidian walls with arcane binding circles, gem-studded pedestals, crystalline floor tiles, glowing ward lines, 32x32 pixel tiles, seamless tileable, top-down perspective`

### 3.3 Level 3 — Magic Library

| Field | Value |
|---|---|
| **Filename** | `assets/tilesets/level3_magic_library.png` |
| **Dimensions** | 256×64 px |
| **Tile size** | 32×32 px |
| **Tile count** | 16 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Tileset for a magical library, warm brown and gold color scheme, tall wooden bookshelf walls filled with glowing tomes, marble floor with carpet runner tiles, floating candle decorations, locked ornate door tile, 32x32 pixel tiles, seamless tileable, top-down perspective`

### 3.4 Level 4 — Lens Complex

| Field | Value |
|---|---|
| **Filename** | `assets/tilesets/level4_lens_complex.png` |
| **Dimensions** | 256×64 px |
| **Tile size** | 32×32 px |
| **Tile count** | 16 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Tileset for a crystalline lens complex, blue and cyan color scheme, translucent crystal walls refracting light beams, smooth glass floor tiles with prismatic reflections, mounted lens apparatus decorations, 32x32 pixel tiles, seamless tileable, top-down perspective`

### 3.5 Level 5 — The Vaults

| Field | Value |
|---|---|
| **Filename** | `assets/tilesets/level5_vaults.png` |
| **Dimensions** | 256×64 px |
| **Tile size** | 32×32 px |
| **Tile count** | 16 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Tileset for underground treasure vaults, dark green and bronze color scheme, reinforced iron-banded stone walls, heavy vault door tiles, cobblestone floor with moss, wall-mounted torch sconces, treasure chest decorations, 32x32 pixel tiles, seamless tileable, top-down perspective`

### 3.6 Level 6 — Grand Hall

| Field | Value |
|---|---|
| **Filename** | `assets/tilesets/level6_grand_hall.png` |
| **Dimensions** | 256×64 px |
| **Tile size** | 32×32 px |
| **Tile count** | 16 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Tileset for a grand ceremonial hall, royal crimson and gold color scheme, ornate marble pillared walls, polished checkered floor tiles, banner and tapestry wall decorations, stained glass window tiles, throne platform tiles, 32x32 pixel tiles, seamless tileable, top-down perspective`

---

## 4. Spell Page Icons

12 individual spell page sprites, each 32×32 with a 2-frame glow animation (idle + glow pulse). Each sheet is 64×32 px.

### Master Prompt for Spell Pages
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Small glowing magical scroll page icon, 32x32 pixels, 2-frame animation (normal and bright glow), transparent background, top-down RPG collectible style`

| # | Name | Filename | Color Accent | Prompt Addendum |
|---|---|---|---|---|
| 1 | Page of Binding | `assets/sprites/pages/page_binding.png` | Purple | `purple arcane binding sigil on the page, violet glow` |
| 2 | Page of Flame | `assets/sprites/pages/page_flame.png` | Orange-red | `fire rune inscribed on parchment, orange ember glow` |
| 3 | Page of Frost | `assets/sprites/pages/page_frost.png` | Ice blue | `frost crystal pattern on the page, icy blue shimmer` |
| 4 | Page of Thunder | `assets/sprites/pages/page_thunder.png` | Yellow | `lightning bolt symbol, electric yellow crackle glow` |
| 5 | Page of Shadow | `assets/sprites/pages/page_shadow.png` | Dark grey | `shadow wisp mark on dark parchment, faint grey-purple glow` |
| 6 | Page of Light | `assets/sprites/pages/page_light.png` | White-gold | `radiant sun symbol, warm white-gold glow` |
| 7 | Page of Earth | `assets/sprites/pages/page_earth.png` | Brown-green | `stone and vine motif, earthy green-brown glow` |
| 8 | Page of Wind | `assets/sprites/pages/page_wind.png` | Light cyan | `swirling air current symbol, pale cyan glow` |
| 9 | Page of Water | `assets/sprites/pages/page_water.png` | Deep blue | `wave pattern rune, deep blue ripple glow` |
| 10 | Page of Spirit | `assets/sprites/pages/page_spirit.png` | Silver | `ethereal ghost sigil, silvery-white glow` |
| 11 | Page of Time | `assets/sprites/pages/page_time.png` | Bronze | `hourglass symbol on aged parchment, bronze shimmer glow` |
| 12 | Page of Void | `assets/sprites/pages/page_void.png` | Dark purple-black | `dark void portal symbol, deep purple-black pulsing glow` |

**Dimensions per sheet:** 64×32 px (2 frames × 32×32)
**Format:** PNG, transparent background

---

## 5. Sphere of Darkness

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/items/sphere_of_darkness.png` |
| **Dimensions** | 128×32 px (4 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 4 (pulsing dark energy animation) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. 4-frame animation sprite sheet of a sphere of darkness, swirling black and deep purple orb with crackling dark energy tendrils, pulsing glow cycle from dim to bright, 32x32 pixels per frame, horizontal strip, transparent background`

**Notes:** Power pellet equivalent. Triggers banish mode (ghosts become frightened for 8 seconds).

---

## 6. Bonus Item Sprites

### 6.1 Aten's Grace (ghost radar 5s)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/items/atens_grace.png` |
| **Dimensions** | 64×32 px (2 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 2 (idle + glow) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Small golden sun medallion item, ornate Eye of Aten design, radiating warm golden light rays, 32x32 pixels, 2-frame shimmer animation, transparent background, collectible RPG item style`

### 6.2 Coronium Shard (2x points 10s)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/items/coronium_shard.png` |
| **Dimensions** | 64×32 px (2 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 2 (idle + sparkle) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Glowing teal crystal shard, jagged prismatic gem fragment, emitting bright cyan sparkles, 32x32 pixels, 2-frame sparkle animation, transparent background, collectible RPG item style`

### 6.3 Sabatha's Heirloom (hidden per-level)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/items/sabathas_heirloom.png` |
| **Dimensions** | 64×32 px (2 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 2 (hidden shimmer + revealed) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Ancient ornate locket pendant, dark silver filigree with a tiny red gemstone center, faint magical aura, 32x32 pixels, 2-frame animation showing subtle red pulse, transparent background, collectible RPG item style`

---

## 7. HUD Elements

### 7.1 Life Icon (Telvar head)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/hud/life_icon.png` |
| **Dimensions** | 16×16 px |
| **Frames** | 1 (static) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, no anti-aliasing, limited palette. Tiny 16x16 pixel wizard head icon, pointed blue hat, friendly face, used as a life counter icon in HUD, transparent background`

### 7.2 Rank Gem Icons (5 ranks)

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/hud/rank_gems.png` |
| **Dimensions** | 80×16 px (5 gems × 16×16) |
| **Frame size** | 16×16 px |
| **Frames** | 5 (one per rank) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, no anti-aliasing, limited palette. 5 small rank gem icons in a horizontal row, 16x16 each: bronze rough gem, silver cut gem, gold polished gem, diamond brilliant gem, rainbow prismatic gem, each progressively more ornate and glowing, transparent background`

**Gem order (left to right):**
1. Bronze (Apprentice)
2. Silver (Journeyman)
3. Gold (Adept)
4. Diamond (Master)
5. Rainbow/Prismatic (Archmage)

### 7.3 Spell Meter Ring

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/hud/spell_meter_ring.png` |
| **Dimensions** | 96×96 px |
| **Frames** | 1 (fill level controlled by shader/code) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Circular spell meter ring UI element, 96x96 pixels, ornate golden frame with arcane rune markings around the border, empty center area, designed to be filled with glowing blue energy via code, transparent background`

**Notes:** The fill animation is handled in code/shader — this is the frame/border asset only.

---

## 8. UI Panels

### 8.1 Parchment Popup Background

| Field | Value |
|---|---|
| **Filename** | `assets/ui/parchment_popup.png` |
| **Dimensions** | 512×384 px |
| **Frames** | 1 (static, 9-slice compatible) |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Aged parchment scroll panel, 512x384 pixels, torn edges, wax seal in corner, faint arcane watermark, warm cream background suitable for overlaying text, decorative border with rune patterns, designed for 9-slice scaling`

### 8.2 Title Logo

| Field | Value |
|---|---|
| **Filename** | `assets/ui/title_logo.png` |
| **Dimensions** | 512×128 px |
| **Frames** | 1 (static) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Game title logo reading "TELVAR'S TEST OF FIRE" in bold fantasy pixel font, fiery orange and gold gradient letters, magical flame effects on letters, dark shadowed outline, 512x128 pixels, transparent background, retro arcade title screen style`

### 8.3 Button Sprites

| Field | Value |
|---|---|
| **Filename** | `assets/ui/buttons.png` |
| **Dimensions** | 192×64 px (3 states × 64×64: normal, hover, pressed) |
| **Frame size** | 64×64 px |
| **Frames** | 3 |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, no anti-aliasing, limited palette. 3 button states in a horizontal strip: normal (stone grey with gold border), hover (slightly glowing gold), pressed (darker indented stone), 64x64 pixels each, ornate fantasy RPG menu button style, suitable for text overlay`

**Notes:** Text is rendered on top by the engine. These are base button textures. Minimum 44×44 px touch target met.

---

## 9. Backgrounds

### 9.1 Title Screen Background

| Field | Value |
|---|---|
| **Filename** | `assets/backgrounds/title_screen_bg.png` |
| **Dimensions** | 1280×720 px |
| **Frames** | 1 (static) |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Title screen background for a wizard arcade game, 1280x720 pixels, dark stone hall interior with towering magical bookshelves, floating candles, distant glowing portal archway, ambient purple and orange magical lighting, slightly blurred to not distract from foreground UI elements`

### 9.2 Level Transition Screen

| Field | Value |
|---|---|
| **Filename** | `assets/backgrounds/level_transition_bg.png` |
| **Dimensions** | 1280×720 px |
| **Frames** | 1 (static) |
| **Format** | PNG |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. Level transition screen background, 1280x720 pixels, dark swirling magical vortex tunnel, arcane runes floating in the void, deep blue and purple color scheme, suitable for overlaying level name text and score`

---

## 10. Effects

### 10.1 Death Particle Sprite

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/effects/death_particle.png` |
| **Dimensions** | 64×16 px (4 frames × 16×16) |
| **Frame size** | 16×16 px |
| **Frames** | 4 (spark → fade) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, no anti-aliasing, limited palette. 4-frame particle animation, small magical spark that fades out, bright white-blue center dimming to transparent, 16x16 pixels per frame, horizontal strip, transparent background`

### 10.2 Page Collect Sparkle

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/effects/page_collect_sparkle.png` |
| **Dimensions** | 128×32 px (4 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 4 (burst → dissipate) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. 4-frame sparkle burst effect, golden magical stars exploding outward then fading, played when collecting a spell page, 32x32 pixels per frame, horizontal strip, transparent background`

### 10.3 Ghost Eaten Poof

| Field | Value |
|---|---|
| **Filename** | `assets/sprites/effects/ghost_eaten_poof.png` |
| **Dimensions** | 128×32 px (4 frames × 32×32) |
| **Frame size** | 32×32 px |
| **Frames** | 4 (poof cloud → vanish) |
| **Format** | PNG, transparent background |

**Generation Prompt:**
`16-bit retro pixel art, 1990s SNES style, high fantasy wizard academy, warm magical lighting with glowing runes, no anti-aliasing, limited palette. 4-frame ghost banish poof effect, blue-white smoke cloud expanding then fading, spectral wisps dissipating, 32x32 pixels per frame, horizontal strip, transparent background`

---

## Palette Guide

Master style: warm magical tones with per-level accent colors. All palettes use a limited 16-color-per-level approach consistent with SNES-era hardware.

### Shared Base Palette

| Color | Hex | Usage |
|---|---|---|
| True Black | `#0D0D0D` | Outlines, shadows |
| Dark Grey | `#2A2A3A` | Secondary shadows |
| Off-White | `#F0E6D2` | Highlights, text |
| Gold Accent | `#D4A84B` | UI borders, collectible glow |
| Staff Blue | `#4A7BF7` | Telvar's staff glow, spell meter fill |
| Frightened Blue | `#2244AA` | Frightened ghost base |
| Frightened White | `#EEEEFF` | Frightened ghost flash (warning) |

### Level 1 — Alchemical Labs (Orange/Red)

| Color | Hex | Usage |
|---|---|---|
| Wall Primary | `#8B3A1A` | Dark brick red-brown |
| Wall Highlight | `#C45A2A` | Brick edge highlights |
| Floor Base | `#3D2B1F` | Dark stone floor |
| Floor Accent | `#5C4033` | Floor variation |
| Rune Glow | `#FF6B2A` | Glowing rune orange |
| Potion Stain | `#44BB44` | Green alchemical splashes |
| Brass Pipe | `#B8860B` | Decorative pipes |
| Flame Accent | `#FF4500` | Torch/burner flames |

### Level 2 — Binding Chamber (Purple/Silver)

| Color | Hex | Usage |
|---|---|---|
| Wall Primary | `#2E1A47` | Deep purple stone |
| Wall Highlight | `#5A3D7A` | Purple edge highlights |
| Floor Base | `#1A1A2E` | Dark obsidian |
| Floor Accent | `#2D2D4A` | Obsidian variation |
| Ward Glow | `#AA66FF` | Binding circle glow |
| Silver Trim | `#C0C0C0` | Metallic accents |
| Gem Red | `#CC2244` | Pedestal gems |
| Crystal | `#88CCEE` | Crystal formations |

### Level 3 — Magic Library (Brown/Gold)

| Color | Hex | Usage |
|---|---|---|
| Wall Primary | `#5C3A1E` | Dark wood shelves |
| Wall Highlight | `#8B6914` | Wood grain highlight |
| Floor Base | `#D2C5A0` | Marble floor |
| Floor Accent | `#A0522D` | Carpet runner |
| Book Glow | `#FFD700` | Magical tome spines |
| Candle Light | `#FFE4B5` | Floating candles |
| Lock Gold | `#DAA520` | Locked door hardware |
| Ink Dark | `#191970` | Ink splatter accents |

### Level 4 — Lens Complex (Blue/Cyan)

| Color | Hex | Usage |
|---|---|---|
| Wall Primary | `#1A3A5C` | Dark blue crystal |
| Wall Highlight | `#3A7CA5` | Crystal edge refraction |
| Floor Base | `#0D2137` | Deep glass floor |
| Floor Accent | `#1A4466` | Prismatic reflection |
| Lens Glow | `#00FFFF` | Active lens cyan |
| Beam White | `#E0FFFF` | Light beam paths |
| Prism Rainbow | `#FF69B4` | Prismatic scatter |
| Metal Frame | `#708090` | Lens apparatus frame |

### Level 5 — The Vaults (Green/Bronze)

| Color | Hex | Usage |
|---|---|---|
| Wall Primary | `#2F4F2F` | Dark green stone |
| Wall Highlight | `#556B2F` | Mossy highlight |
| Floor Base | `#3B3B2F` | Cobblestone |
| Floor Accent | `#4A6741` | Moss patches |
| Iron Band | `#696969` | Vault door reinforcement |
| Bronze Trim | `#CD7F32` | Bronze hardware |
| Torch Fire | `#FF8C00` | Wall sconce flames |
| Treasure Gold | `#FFD700` | Chest accents |

### Level 6 — Grand Hall (Crimson/Gold)

| Color | Hex | Usage |
|---|---|---|
| Wall Primary | `#4A0000` | Deep crimson marble |
| Wall Highlight | `#8B0000` | Marble vein highlights |
| Floor Base | `#1A0A0A` | Dark polished floor |
| Floor Accent | `#F5F5DC` | Checkered light tiles |
| Royal Gold | `#FFD700` | Pillar and trim gold |
| Banner Red | `#DC143C` | Hanging banners |
| Stained Glass | `#FF6347` | Window light warm |
| Throne Purple | `#4B0082` | Throne accent |

---

## Asset Summary

| Category | Asset Count | Total Files |
|---|---|---|
| Player sprites | 3 sheets | 3 |
| Ghost sprites | 7 sheets (5 normal + frightened + eaten) | 7 |
| Level tilesets | 6 sheets | 6 |
| Spell pages | 12 sprites | 12 |
| Sphere of Darkness | 1 sheet | 1 |
| Bonus items | 3 sprites | 3 |
| HUD elements | 3 files | 3 |
| UI panels | 3 files | 3 |
| Backgrounds | 2 files | 2 |
| Effects | 3 sheets | 3 |
| **Total** | | **43 files** |

---

## Directory Structure

```
assets/
├── backgrounds/
│   ├── level_transition_bg.png
│   └── title_screen_bg.png
├── sprites/
│   ├── effects/
│   │   ├── death_particle.png
│   │   ├── ghost_eaten_poof.png
│   │   └── page_collect_sparkle.png
│   ├── ghosts/
│   │   ├── abyssal_creature.png
│   │   ├── aemon_guardian.png
│   │   ├── elemental_guardian.png
│   │   ├── ghost_eaten.png
│   │   ├── ghost_frightened.png
│   │   ├── hound_fenrir.png
│   │   └── undead.png
│   ├── hud/
│   │   ├── life_icon.png
│   │   ├── rank_gems.png
│   │   └── spell_meter_ring.png
│   ├── items/
│   │   ├── atens_grace.png
│   │   ├── coronium_shard.png
│   │   ├── sabathas_heirloom.png
│   │   └── sphere_of_darkness.png
│   ├── pages/
│   │   ├── page_binding.png
│   │   ├── page_earth.png
│   │   ├── page_flame.png
│   │   ├── page_frost.png
│   │   ├── page_light.png
│   │   ├── page_shadow.png
│   │   ├── page_spirit.png
│   │   ├── page_thunder.png
│   │   ├── page_time.png
│   │   ├── page_void.png
│   │   ├── page_water.png
│   │   └── page_wind.png
│   └── player/
│       ├── telvar_death.png
│       ├── telvar_idle.png
│       └── telvar_walk.png
├── tilesets/
│   ├── level1_alchemical_labs.png
│   ├── level2_binding_chamber.png
│   ├── level3_magic_library.png
│   ├── level4_lens_complex.png
│   ├── level5_vaults.png
│   └── level6_grand_hall.png
└── ui/
    ├── buttons.png
    ├── parchment_popup.png
    └── title_logo.png
```
