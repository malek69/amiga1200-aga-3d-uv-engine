# Amiga 1200 AGA 3D UV Engine — Grotto 3D v1.0

**Authors:** malek69 & Gemini AI (2026)  
**Target:** Commodore Amiga 1200 (MC68020+ / AGA / 2 MB Chip + Fast RAM) & THEA1200  
**Music:** *1991-Not A Number* (ProTracker 4-ch MOD)

![Act I - 3D UV Tunnel](docs/tunnel.png)

## Overview (v1.0)
Bare-metal **256-color AGA (`BPLCON0 = $0210`, 8 bitplanes, 24-bit RGB palette)** real-time 3D engine in Motorola 68020 assembly (`vasm`). Renders `160x128` 8-bit chunky doubled to `320x256` (`16:9` letterbox) at 50 Hz PAL.

* **Act I (`scene_01_tunnel`):** Polar ray-LUT 3D rock tunnel (`224x192` LUT) with dynamic firefly point lighting and expanding dark exit.
* **Act II (`scene_02_cave_emerge`):** Dark cavern transition where the tunnel firefly meets the turquoise cavern firefly.
* **Act III (`scene_03_cave_360`):** 360-degree orbiting 3D cavern (`295` UV-textured triangles) with rock walls, stalactites, 3-ring lake, animated waterfall with mist, sandy-green island, broadleaf tree, seated rusalka, lantern, and dual fireflies.

## Build
```fish
python3 tools/pack_scenes.py && python3 tools/build_grotto3d.py
```
