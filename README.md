![AURA-3D AGA Engine Logo](docs/logo_aura3d.png)

# AURA-3D AGA Engine v1.1 (Amiga 1200 / THEA1200) [EN / PL]

**Credits / Autorzy:** malek69 & **Gemini AI** *(Vibe Coding Edition, 2026 — Bare-Metal M68020+ 3D Engine & Python Toolchain)*

## Live Hardware / FS-UAE Showcase (v1.1)

| 3D Vertex Morphing | Space Shuttle 3D + Particle Trail | 16-bit Z-Buffer Torus + Copper Sky |
| :---: | :---: | :---: |
| ![3D Morph](docs/shot_morph.png?v=11) | ![Space Shuttle](docs/shot_shuttle.png?v=11) | ![Z-Buffer Torus](docs/shot_torus.png?v=11) |

## Download Latest Release (v1.1) / Pobierz najnowszą wersję (v1.1)

| Package / Paczka | Target Platform / Docelowy system | Launch / Uruchomienie |
| :--- | :--- | :--- |
| **[aura3d_demo_v1.1_AGA.lha](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.1/aura3d_demo_v1.1_AGA.lha)** | **RetroArch (`PUAE` — Android / PC)**, **THEA1200 (Amiberry)**, **Amiga 1200** (8 MB Fast RAM) | **1-click:** Load Content directly on `.lha` (WHDLoad auto-boot). |
| **[aura3d_demo_v1.1_AGA_FSUAE.zip](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.1/aura3d_demo_v1.1_AGA_FSUAE.zip)** | **FS-UAE Launcher** (Linux / Windows / macOS) & **WinUAE** | **1-click:** Mount as Hard Drive (`DH0`) on A1200 (8 MB Fast RAM) and click **Start**. |
| **[aura3d_demo_v1.1_AGA.adf](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.1/aura3d_demo_v1.1_AGA.adf)** | Floppy Drive (`DF0:`) / Gotek / Amiga 1200 (8 MB Fast RAM) | Boot directly from floppy image (`S/startup-sequence`). |
| **[aura3d-aga-engine-v1.1-src.zip](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.1/aura3d-aga-engine-v1.1-src.zip)** | M68020+ Assembly & Python Developers | Complete engine source (`engine/`), demo scenes (`demo_v1/`), and `.obj` tools (`tools/`). |

## What's New in v1.1 / Nowości w wersji v1.1
- **3D World-Space Particle Trail (`engine/particle_trail.i`):** Twin-nozzle exhaust emitter `(-9,0,-36)` & `(+9,0,-36)` on the Space Shuttle with turbulent thrust vectors and full 16-bit Z-Buffer depth sorting (`draw_z_orb_v2`).
- **24-bit AGA Copper Sky & Horizon Gradient (`engine/copper_sky.i`):** Zero-CPU-cycle per-scanline 24-bit `COLOR00` gradient (`BPLCON3` LOCT 0/1) across 228 PAL display lines with 4 switchable atmospheric themes.
- **Z-Fog / Depth Cueing (`engine/aura3d_v2.i`):** Per-vertex depth-based luminance attenuation (`zfog_start = 118`, `zfog_shift = 2`) integrated into the Gouraud + Environment Mapping pipeline.
- **Real-Time Joystick (Port 2) & Keyboard Controls (`engine/input_ctrl.i`):** Live 3D object rotation, camera zoom, sky theme switching, and Z-Fog toggle via `JOY1DAT` (`$DFF00C`) and `CIA-A` (`$BFEC01` with hardware `$BFEE01` handshake).

## Live Interactive Controls / Sterowanie na żywo (v1.1)

| Input / Klawisz lub Joystick | Action / Działanie |
| :--- | :--- |
| **Arrow Keys / Joystick Port 2** | Rotate 3D objects in real time (`user_yaw`, `user_pitch`) |
| **W / S** or **Fire + Up/Down** | Zoom camera in / out (`user_zoom`) |
| **1 – 4** | Switch 24-bit Copper sky theme (`Cosmic Horizon`, `Solaris Dusk`, `Emerald Nebula`, `Pure Black`) |
| **F** | Toggle Z-Fog (Depth Cueing) ON / OFF |
| **Space / R** | Reset user camera rotation and zoom |
| **LMB / ESC** | Exit cleanly to AmigaOS |

## Engine Capabilities / Możliwości silnika (`engine/`)
- **Full M68020+ 3D Pipeline (`engine/aura3d_v2.i`):** 3×3 Euler rotation matrices (Yaw / Pitch / Roll), multi-object world transforms, 6DOF camera, and perspective projection.
- **16-bit Fast-RAM Z-Buffer:** Per-pixel depth sorting eliminating polygon overlap artifacts across concave meshes, particle trails, and intersecting objects.
- **3D Vertex Morphing (`morph_verts_3d`):** Real-time linear interpolation between 3D meshes on 68020.
- **64×64×256 UV Texturing & Gouraud + Environment Mapping:** Directional lighting (`N · L`), 16-level AGA `shade_lut_v2`, chrome reflections, and 3D depth-sorted light orbs.
- **Wavefront `.obj` Toolchain (`tools/mesh_conv.py`):** Automatic conversion of `.obj` models (including the Space Shuttle 3D mesh) with smoothed vertex normals.
