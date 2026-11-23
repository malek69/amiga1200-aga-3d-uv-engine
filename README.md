# AURA-3D AGA Engine v1.0 (Amiga 1200 / THEA1200) [EN / PL]

**Credits / Autorzy:** malek69 & **Gemini AI** *(Vibe Coding Edition, 2026 — Bare-Metal M68020+ 3D Engine & Python Toolchain)*

![AURA-3D Demo Preview](docs/preview.png)

## Download Baseline Release (v1.0) / Pobierz wersję bazową (v1.0)

| Package / Paczka | Target Platform / Docelowy system | Launch / Uruchomienie |
| :--- | :--- | :--- |
| **[aura3d_demo_v1_AGA.lha](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.0/aura3d_demo_v1_AGA.lha)** | **RetroArch (`PUAE` — Android / PC)**, **THEA1200 (Amiberry)**, **Amiga 1200** (8 MB Fast RAM) | **1-click:** Load Content directly on `.lha` (WHDLoad auto-boot). |
| **[aura3d_demo_v1_AGA_FSUAE.zip](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.0/aura3d_demo_v1_AGA_FSUAE.zip)** | **FS-UAE Launcher** (Linux / Windows / macOS) & **WinUAE** | **1-click:** Mount as Hard Drive (`DH0`) on A1200 (8 MB Fast RAM) and click **Start**. |
| **[aura3d_demo_v1_AGA.adf](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.0/aura3d_demo_v1_AGA.adf)** | Floppy Drive (`DF0:`) / Gotek / Amiga 1200 (8 MB Fast RAM) | Boot directly from floppy image (`S/startup-sequence`). |
| **[aura3d-aga-engine-v1.0-src.zip](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.0/aura3d-aga-engine-v1.0-src.zip)** | M68020+ Assembly & Python Developers | Complete engine source (`engine/`), demo scenes (`demo_v1/`), and `.obj` tools (`tools/`). |

## Engine Capabilities / Możliwości silnika v1.0 (`engine/aura3d_v2.i`)
- **Full M68020+ 3D Pipeline:** 3×3 Euler rotation matrices (Yaw / Pitch / Roll), multi-object world transforms, and perspective projection.
- **16-bit Fast-RAM Z-Buffer:** Per-pixel depth sorting eliminating polygon overlap artifacts across concave meshes and intersecting objects.
- **3D Vertex Morphing (`morph_verts_3d`):** Real-time linear interpolation between 3D meshes on 68020.
- **64×64×256 UV Texturing & Gouraud + Environment Mapping:** Directional lighting (`N · L`), 16-level AGA `shade_lut_v2`, chrome reflections, and 3D depth-sorted light orbs.
- **Wavefront `.obj` Toolchain (`tools/mesh_conv.py`):** Automatic conversion of `.obj` models (including the Space Shuttle 3D mesh) with smoothed vertex normals.
