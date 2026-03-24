# Parametric Electronics Enclosure — OpenSCAD

![Assembled](renders/enclosure-assembled.png)

A fully parametric, 3D-printable enclosure generator written entirely in OpenSCAD.
Edit a few variables at the top of the file and get a production-ready base + lid for any PCB in seconds.

---

## Problem & Solution

A custom enclosure for a small electronics board required several board size variants and multiple connector layouts. Instead of redrawing geometry in a GUI CAD tool, a single parametric script drives the entire model — PCB dimensions, wall thickness, corner radius, screw sizes, lid clearance, and optional cut-outs — all from top-level variables.

---

**Export workflow:**

```scad
// Assembled view
show_base = true;  show_lid = true;  explode_z = 0;

// Exploded view (lid lifted 20 mm)
show_base = true;  show_lid = true;  explode_z = 20;

// Export base STL
show_base = true;  show_lid = false;

// Export lid STL
show_base = false; show_lid = true;
```

---

## Features

| Feature | Details |
|---------|---------|
| Parametric base + lid | Both parts from the same variable set — no manual re-modelling |
| Rounded corners | `hull()` of corner cylinders — exact dimensions, no origin offset |
| PCB standoffs | Four bosses with through-holes; margin from PCB edge is parameterised |
| Press-fit lid | Downward lip slides into the base with configurable clearance |
| Lid fastening screws | Four corner bosses with countersunk (90°) through-holes for M3 flat-head screws |
| Cable cut-out | Optional centred slot in the front wall |
| Ventilation slots | Optional slot array on the lid top |
| Exploded view | One variable (`explode_z`) separates lid from base |

---

## Quick Start

**Requirements:** [OpenSCAD](https://openscad.org/) 2021.01 or later

```bash
git clone https://github.com/your-username/Enclosure-CAD.git
openscad enclosure.scad
```

`F5` — fast preview &nbsp;|&nbsp; 
`F6` — full render &nbsp;|&nbsp; File → Export → Export as STL

### Adapting to a new board

Open `enclosure.scad` and change the three PCB parameters:

```scad
pcb_len    = 100;  // board length (mm)
pcb_wid    = 60;   // board width  (mm)
pcb_height = 22;   // tallest component + clearance margin (mm)
```

Press `F5` — the entire enclosure regenerates instantly.

### Print settings

| Setting | Recommended |
|---------|-------------|
| Layer height | 0.2 mm |
| Infill | 20 – 40 % |
| Perimeters | 3 (matches `wall_thk = 2.5` at 0.4 mm nozzle) |
| Supports | None — base prints open-side-up, lid prints flat-side-down |
| Material | PLA or PETG |

---

## Parameter Reference

### PCB & Enclosure

| Parameter | Default | Description |
|-----------|---------|-------------|
| `pcb_len` | `80` | Board length — X axis (mm) |
| `pcb_wid` | `50` | Board width — Y axis (mm) |
| `pcb_height` | `18` | Internal clearance height — tallest component + margin (mm) |
| `wall_thk` | `2.5` | Wall, floor, and lid plate thickness (mm) |
| `corner_rad` | `4.0` | Horizontal corner rounding radius (mm) |
| `lid_clear` | `0.3` | Lid-to-base fit clearance, per side (mm) |

### Standoffs

| Parameter | Default | Description |
|-----------|---------|-------------|
| `screw_diam` | `3.0` | PCB screw shaft diameter — M3 (mm) |
| `standoff_h` | `5.0` | Standoff height — PCB sits this far above the floor (mm) |
| `standoff_d` | `6.0` | Standoff outer diameter (mm) |
| `standoff_m` | `8.0` | Distance from PCB edge to standoff centre (mm) |

### Lid

| Parameter | Default | Description |
|-----------|---------|-------------|
| `lid_lip_h` | `4.0` | Depth of the press-fit registration lip (mm) |
| `lid_screw_diam` | `3.0` | Lid fastening screw shaft — M3 (mm) |
| `lid_screw_head_d` | `6.0` | Countersunk head diameter — M3 flat head 90° (mm) |
| `lid_boss_d` | `6.0` | Outer diameter of corner screw boss (mm) |

### Cable Cut-out

| Parameter | Default | Description |
|-----------|---------|-------------|
| `cable_cutout` | `true` | Enable / disable |
| `cable_w` | `14` | Cut-out width (mm) |
| `cable_h` | `8` | Cut-out height (mm) |

### Ventilation Slots

| Parameter | Default | Description |
|-----------|---------|-------------|
| `vent_slots` | `true` | Enable / disable |
| `vent_count` | `5` | Number of slots |
| `vent_gap` | `5.0` | Centre-to-centre spacing (mm) |
| `vent_w` | `2.0` | Slot width (mm) |
| `vent_len` | `20.0` | Slot length (mm) |

---

## Assembly — Lid Fastening

The four corner bosses in the base accept M3 × 20 mm flat-head countersunk screws:

1. Place the lid on the base (press-fit lip aligns it).
2. Insert one M3 screw through each countersunk hole in the lid corners.
3. Tighten with M3 heat-set inserts in the bosses, can be adapted to use an M3 nut on the underside of the base floor.

> Tips: `lid_clear = 0.3` is a snug press-fit for a well-tuned printer. Increase to `0.4` for a looser fit; decrease to `0.2` for tighter friction.


## License

MIT — free to use, modify, and distribute.
