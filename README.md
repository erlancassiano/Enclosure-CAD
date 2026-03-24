# Parametric OpenSCAD Enclosure

Fully parametric enclosure generator in OpenSCAD, driven entirely by code and a small set of high‑level parameters (PCB length, width, height, wall thickness, corner radius, screw diameter, lid clearance, etc.).

## Features

- Programmatic generation of both base and lid
- Internal standoffs automatically aligned with PCB mounting holes
- Optional cable cut‑outs
- Optional ventilation slots
- Easy adjustment of:
  - PCB dimensions
  - Wall thickness
  - Corner radius
  - Screw size and clearance
  - Lid/fit tolerances

## Workflow

Instead of manually remodeling geometry in a GUI‑based CAD tool, the you only needs to tweak a few parameters in the script.  
New enclosures for different boards can be regenerated in seconds, making iterations and design changes much faster and less error‑prone.

## Benefits

- Highly reusable enclosure generator for multiple PCB designs
- Reduced modeling time for new variants
- Consistent geometry and mounting features across projects
- Ideal for rapid prototyping and small‑batch 3D‑printed enclosures
