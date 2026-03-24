// ============================================================
//  Parametric Electronics Enclosure
//  OpenSCAD — all dimensions in millimetres
//
//  Usage:
//    1. Set PCB dimensions (pcb_len, pcb_wid, pcb_height).
//    2. Adjust enclosure parameters as needed.
//    3. Set show_base / show_lid and explode_z for the view you want.
//    4. Render (F6) and export base and lid as separate STLs.
// ============================================================

/* [PCB Footprint] */
pcb_len    = 80;   // board length along X axis  [mm]
pcb_wid    = 50;   // board width  along Y axis  [mm]
pcb_height = 18;   // internal clearance height (tallest component + margin) [mm]

/* [Enclosure Geometry] */
wall_thk   = 2.5;  // wall / floor / lid plate thickness [mm]
corner_rad = 4.0;  // horizontal corner rounding radius  [mm]
lid_clear  = 0.3;  // fit clearance between lid lip and base walls (per side) [mm]

/* [Standoffs] */
screw_diam = 3.0;  // screw shaft diameter — M3 = 3.0 mm [mm]
standoff_h = 5.0;  // standoff height; PCB surface sits this far above the floor [mm]
standoff_d = 6.0;  // standoff outer diameter [mm]
standoff_m = 8.0;  // distance from PCB edge to standoff centre [mm]

/* [Lid Registration Lip] */
lid_lip_h  = 4.0;  // depth of the lid lip that registers down into the base [mm]

/* [Lid Fastening Screws] */
lid_screw_diam   = 3.0;  // countersunk screw shaft diameter — M3 = 3.0 mm [mm]
lid_screw_head_d = 6.0;  // flat-head countersunk head diameter — M3 90° = 6.0 mm [mm]
lid_boss_d       = 6.0;  // outer diameter of corner screw boss [mm]

/* [Cable Cut-out — front wall, Y = 0] */
cable_cutout = true;
cable_w      = 14; // cut-out width  [mm]
cable_h      =  8; // cut-out height [mm]

/* [Ventilation Slots — top lid surface] */
vent_slots = true;
vent_count = 5;    // number of slots
vent_gap   = 5.0;  // centre-to-centre slot spacing [mm]
vent_w     = 2.0;  // slot width  [mm]
vent_len   = 20.0; // slot length [mm]

/* [Render / Export Control] */
// Set show_base=true / show_lid=false when exporting the base STL, and vice-versa.
// Set explode_z > 0 for an exploded-view render.
show_base = true;
show_lid  = true;
explode_z = 0;     // extra Z gap added above base when showing lid [mm]

// ============================================================
//  Resolution
// ============================================================
$fn = 64;

// ============================================================
//  Derived values  (do not edit)
// ============================================================
outer_x = pcb_len + 2 * wall_thk;  // enclosure outer footprint X
outer_y = pcb_wid  + 2 * wall_thk; // enclosure outer footprint Y
base_z  = pcb_height + wall_thk;   // total base height (floor + internal clearance)

lid_boss_r       = lid_boss_d / 2;
lid_screw_cone_h = (lid_screw_head_d - lid_screw_diam) / 2;  // 90° countersink depth

// ============================================================
//  Helper: rounded rectangular prism
//    Uses hull() of four corner cylinders so the origin is
//    exactly [0,0,0] and outer dimensions are exactly x × y × z.
//    (Replaces the buggy Minkowski approach that offset the origin
//     by -corner_rad in X and Y.)
// ============================================================
module rounded_box(x, y, z, r) {
    hull()
        for (cx = [r, x - r], cy = [r, y - r])
            translate([cx, cy, 0])
                cylinder(r = r, h = z);
}

// ============================================================
//  Standoff layout
//    Positions are relative to the PCB origin (lower-left corner
//    of the inner cavity). wall_thk is added in each module.
// ============================================================
function so_pos() = [
    [standoff_m,           standoff_m          ],
    [pcb_len - standoff_m, standoff_m          ],
    [standoff_m,           pcb_wid - standoff_m],
    [pcb_len - standoff_m, pcb_wid - standoff_m]
];

// Solid cylinders added to the base union
module standoffs_solid() {
    for (p = so_pos())
        translate([wall_thk + p[0], wall_thk + p[1], wall_thk])
            cylinder(d = standoff_d, h = standoff_h);
}

// Through-holes subtracted from the base — run from below the floor,
// up through the standoff, so screws can be inserted from the bottom.
module standoffs_holes() {
    for (p = so_pos())
        translate([wall_thk + p[0], wall_thk + p[1], -0.01])
            cylinder(d = screw_diam, h = wall_thk + standoff_h + 0.02);
}

// ============================================================
//  Lid screw bosses
//    Four solid corner pillars inside the base that the lid
//    screws thread into.  They sit at the inner-cavity corners,
//    which means a plain cube() subtraction would erase them.
//    inner_cavity() is therefore carved to explicitly skip the
//    boss footprints so the pillars survive the boolean tree.
// ============================================================

// Boss positions in absolute enclosure XY coords
function lid_boss_pos() = [
    [wall_thk + lid_boss_r,           wall_thk + lid_boss_r          ],  // front-left
    [outer_x - wall_thk - lid_boss_r, wall_thk + lid_boss_r          ],  // front-right
    [wall_thk + lid_boss_r,           outer_y - wall_thk - lid_boss_r],  // back-left
    [outer_x - wall_thk - lid_boss_r, outer_y - wall_thk - lid_boss_r]   // back-right
];

// Solid boss cylinders — added to the base union before any subtraction
module lid_bosses_solid() {
    for (p = lid_boss_pos())
        translate([p[0], p[1], wall_thk])
            cylinder(d = lid_boss_d, h = pcb_height);
}

// Through-holes through every boss and the enclosure floor.
// Screw is inserted from above (through the lid); a nut sits in a recess
// or is trapped beneath the floor — see README for assembly notes.
module lid_boss_holes() {
    for (p = lid_boss_pos())
        translate([p[0], p[1], -0.01])
            cylinder(d = lid_screw_diam, h = base_z + 0.02);
}

// Inner cavity with corner boss footprints preserved.
// Works by subtracting (full_cube − boss_cylinders) from the union,
// which is equivalent to leaving the boss volumes untouched.
module inner_cavity() {
    difference() {
        cube([pcb_len, pcb_wid, pcb_height + 0.01]);
        for (p = lid_boss_pos())
            translate([p[0] - wall_thk, p[1] - wall_thk, -0.01])
                cylinder(d = lid_boss_d, h = pcb_height + 0.1);
    }
}

// ============================================================
//  Base
// ============================================================
module enclosure_base() {
    difference() {
        union() {
            // Outer rounded shell
            rounded_box(outer_x, outer_y, base_z, corner_rad);
            // Standoff bosses
            standoffs_solid();
            // Corner screw bosses for lid attachment
            lid_bosses_solid();
        }

        // Internal cavity — corner boss volumes are preserved by inner_cavity()
        translate([wall_thk, wall_thk, wall_thk])
            inner_cavity();

        // Screw pilot holes through the floor and standoffs
        standoffs_holes();

        // Through-holes through corner screw bosses (+ enclosure floor)
        lid_boss_holes();

        // Optional cable cut-out centred on the front wall
        if (cable_cutout)
            translate([(outer_x - cable_w) / 2, -0.01, wall_thk])
                cube([cable_w, wall_thk + 0.02, cable_h]);
    }
}

// ============================================================
//  Lid
// ============================================================
module vent_cuts() {
    // Centre the slot array over the lid plate
    total_span = (vent_count - 1) * vent_gap;
    ox = (outer_x - total_span) / 2;
    oy = (outer_y - vent_len)   / 2;
    for (i = [0 : vent_count - 1])
        translate([ox + i * vent_gap - vent_w / 2, oy, -0.01])
            cube([vent_w, vent_len, wall_thk + 0.02]);
}

// Countersunk holes in the lid plate and lip, aligned with base corner bosses.
// The 90° cone opens flush with the top surface so the screw head sits flat.
module lid_screw_holes() {
    for (p = lid_boss_pos())
        // Translate to bottom of lid lip in local lid coords (z = -lid_lip_h)
        translate([p[0], p[1], -lid_lip_h - 0.01]) {
            // Shaft through the full lid depth (lip + plate)
            cylinder(d = lid_screw_diam, h = lid_lip_h + wall_thk + 0.02);
            // Countersink cone at the top surface — d1 narrow (shaft) at bottom,
            // d2 wide (head) at top, so the head sits flush with the lid surface.
            translate([0, 0, lid_lip_h + wall_thk - lid_screw_cone_h])
                cylinder(d1 = lid_screw_diam, d2 = lid_screw_head_d,
                         h = lid_screw_cone_h + 0.02);
        }
}

module enclosure_lid() {
    difference() {
        union() {
            // Flat top plate
            rounded_box(outer_x, outer_y, wall_thk, corner_rad);

            // Registration lip — modelled at negative Z so it hangs
            // down into the base cavity when the lid is placed at base_z.
            // Inset by lid_clear on every side for a press-fit.
            translate([wall_thk + lid_clear,
                       wall_thk + lid_clear,
                       -lid_lip_h])
                cube([pcb_len - 2 * lid_clear,
                      pcb_wid - 2 * lid_clear,
                      lid_lip_h]);
        }

        // Ventilation slots
        if (vent_slots) vent_cuts();

        // Countersunk lid-attachment screw holes
        lid_screw_holes();
    }
}

// ============================================================
//  Scene assembly
// ============================================================
if (show_base)
    enclosure_base();

if (show_lid)
    translate([0, 0, base_z + explode_z])
        enclosure_lid();
