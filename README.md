# Amiga 1200 / THEA1200 AGA 3D UV Engine & Grotto 3D [DEV]

**Authors / Autorzy:** malek69 & **Gemini AI** *(Vibe Coding Edition, 2026)*

Bare-metal **Motorola 68020+ & AGA** real-time 3D UV-textured engine (`160x128` -> `320x256` 16-color Chunky-to-Planar) for **Commodore Amiga 1200 (2 MB Chip + 8 MB Fast RAM)** and **THEA1200**.

## Features / Możliwości silnika
* **Full-Screen Round 3D Tunnel:** Real-time ray-LUT UV tunnel with dynamic circular point-light illumination from a flying firefly.
* **Tunnel-to-Grotto Transition Scene:** Seamless exit through a rocky 3D archway into the underground cavern.
* **360-Degree UV-Textured Cavern (110+ Polygons):** 16-sided rock cavern walls, vaulted ceiling, 2-ring shimmering lake, glowing waterfall, central island, multi-layered emerald 3D tree, seated rusalka, and dual orbiting fireflies.
* **16-Color AGA C2P Pipeline:** Fast 68020 Chunky-to-Planar converter with 8-level distance & dual-light shading LUT.
* **Blender `.obj` Converter:** Includes `tools/obj2amiga.py` for importing low-poly 3D meshes.

## Build & Run / Kompilacja i uruchomienie
```fish
python3 tools/build_grotto3d.py
```
Output WHDLoad-ready archive: `releases/grotto3d.lha` (Music: *1991-Not A Number*, Aminet).
