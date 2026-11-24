<p align="right"><a href="README.md">Polski</a> | <strong>English</strong> | <a href="CHANGELOG_EN.md">Changelog</a></p>

<div align="center">
  <img src="docs/logo_aura3d.png" alt="AURA-3D AGA Engine" width="520" />
  <h1>AURA-3D AGA Engine v1.14.2</h1>
  <p><strong>Bare-metal 3D Software Engine for Commodore Amiga 1200 (M68020+ / AGA / 256 Colors)</strong></p>
  <p>
    <a href="https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d_demo_v1.14.2_AGA.lha">Download .LHA</a> &bull;
    <a href="https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d_demo_v1.14.2_AGA_FSUAE.zip">Download FS-UAE .ZIP</a> &bull;
    <a href="https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d_demo_v1.14.2_AGA.adf">Download .ADF</a> &bull;
    <a href="https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d-aga-engine-v1.14.2-src.zip">Source .ZIP</a>
  </p>
</div>

---

## Downloads (v1.14.2 Latest)

| Package | Target Platform & Usage | Link |
| :--- | :--- | :--- |
| **`aura3d_demo_v1.14.2_AGA.lha`** | **WHDLoad / THEA1200 / RetroArch (PUAE) / Amiga 1200 + Fast RAM** — ready-to-run directory with `.info` icons, WHDLoad Slave, and executable | [Download .LHA](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d_demo_v1.14.2_AGA.lha) |
| **`aura3d_demo_v1.14.2_AGA_FSUAE.zip`** | **FS-UAE Launcher / WinUAE** — pre-configured package for Amiga 1200 AGA emulators (`68020` + `8 MB Fast RAM`) | [Download FS-UAE .ZIP](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d_demo_v1.14.2_AGA_FSUAE.zip) |
| **`aura3d_demo_v1.14.2_AGA.adf`** | **Floppy Drive `DF0:` / Gotek FlashFloppy** — bootable 880 KB floppy disk image for real Amiga 1200 hardware | [Download .ADF](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d_demo_v1.14.2_AGA.adf) |
| **`aura3d-aga-engine-v1.14.2-src.zip`** | **Source Code (M68020 ASM + Python)** — complete `engine/` modules, `demo_v1/` scenes, and `tools/` asset converters | [Download Source .ZIP](https://github.com/malek69/aura3d-aga-engine/releases/download/v1.14.2/aura3d-aga-engine-v1.14.2-src.zip) |

---

## Gallery (8 Stages on the Real AGA Pipeline)

<table>
  <tr>
    <td align="center"><img src="docs/shot_v114_1.png" width="240" /><br/><sub><b>1. AGA Title Screen</b> (8-Bitplane RLE)</sub></td>
    <td align="center"><img src="docs/shot_v114_2.png" width="240" /><br/><sub><b>2. 3D Vertex Morphing</b> (1008 Triangles)</sub></td>
    <td align="center"><img src="docs/shot_v114_3.png" width="240" /><br/><sub><b>3. 3D Shuttle + Lens Flare</b> (576 Tris)</sub></td>
    <td align="center"><img src="docs/shot_v114_4.png" width="240" /><br/><sub><b>4. Planetary System</b> (1008-Tri Chrome + UV)</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/shot_v114_5.png" width="240" /><br/><sub><b>5. Torus Flythrough</b> (6DOF Camera)</sub></td>
    <td align="center"><img src="docs/shot_v114_6.png" width="240" /><br/><sub><b>6. Wavefront .OBJ Suzanne</b> (968 Triangles)</sub></td>
    <td align="center"><img src="docs/shot_v114_7.png" width="240" /><br/><sub><b>7. 3D Heightmap Terrain</b> (Point Light + Z-Fog)</sub></td>
    <td align="center"><img src="docs/shot_v114_8.png" width="240" /><br/><sub><b>8. 3D Finale &amp; Orbit</b> (Vector Character)</sub></td>
  </tr>
</table>

---

## Engine Features (v1.14.2)

- **8-Bitplane AGA Title Screen (`320x256`, 256 Colors):** converted from `.png` via `tools/png_to_aga.py` with streaming RLE decompression.
- **Waving Water Surface & Planar Reflections (`M`):** perspective water scanlines with sinusoidal wave modulation and 16-bit Z-Buffer sorted reflections.
- **3D Lens Flare (`K`):** anamorphic light streaks and 3 diffraction discs with Z-Buffer occlusion testing.
- **Specular Highlights:** sharp metallic light reflections (`transform_normals_envmap` optimized with M68020 `bfextu`).
- **3D Heightmap Terrain (`engine/terrain_3d.i`):** procedural `64x64` heightmap canyon with directional slope shading, dynamic point light, lakes, and peaks.
- **Multi-Material 3D Meshes + `.obj` / `.png` Converters:** up to four `64x64` textures per mesh (`tools/mesh_conv.py` and `tools/png_to_aga.py`).
- **24-Bit Copper Sky (`1`-`4`), Planar Shadows (`C`), Depth Z-Fog (`F`), Phong + Fresnel Rim Glow (`P`), Animated UV, Dynamic Point Light & Bilingual HUD (`H`, `L`, `I`).

---

## Scene Breakdown (`F1`–`F8` & `Tab`)

| Key | Scene | Content & Active Effects |
| :--- | :--- | :--- |
| **`F1`** | **AGA Title Screen** | `320x256` 8-bitplane (256-color) splash screen decompressed from RLE |
| **`F2`** | **Scene 1: 3D Vertex Morphing** | Smooth `1008`-triangle mesh morphing (Torus <-> Sphere <-> Star) over waving water with shadows |
| **`F3`** | **Scene 2: Multi-Material Shuttle** | `576`-triangle model (titanium, cyber-circuits, thermal shield), twin-nozzle trail, Lens Flare (`K`), and water reflection (`M`) |
| **`F4`** | **Scene 3: Planetary System** | Central Torus (`1008` triangles, satin chrome) + 2 orbiting satellites with animated UV textures over waving water |
| **`F5`** | **Scene 4: Torus Camera Flythrough** | Full 6DOF 3D camera flying through the center of a `1008`-triangle chrome Torus |
| **`F6`** | **Scene 5: Wavefront `.OBJ` Model (Suzanne)** | `968`-triangle mesh imported from `.obj` via `tools/mesh_conv.py` rendered in satin chrome + Fresnel Rim Glow |
| **`F7`** | **Scene 6: 3D Heightmap Terrain Flyover** | Procedural `64x64` heightmap terrain with dynamic point light, depth Z-Fog, and flying shuttle |
| **`F8`** | **Scene 7: 3D Finale & Orbit** | Classic 3D vector character on a rotating platform, starfield, and 4-channel ProTracker `.MOD` music |

---

## Controls (`H` Help, `L` Lang PL/EN, `P` Phong, `I` HUD)

| Key / Controller | Action |
| :--- | :--- |
| **`F1` – `F8`** | Jump directly to any scene (from title screen to 3D finale) |
| **`Tab`** | Cycle to the next scene |
| **`H`** | Toggle on-screen **Help Overlay (HELP)** |
| **`L`** | Switch language **PL / ENG** (Help + Scene Info) |
| **`P`** | Toggle **Phong + Fresnel Rim Glow Shader** |
| **`Arrow Keys` / Joystick Port 2** | Rotate camera and 3D objects (`Yaw` / `Pitch`) |
| **`W` / `S` or `Fire + Up/Down`** | Camera zoom in / out (`Zoom`) |
| **`1` – `4`** | Switch 24-bit Copper sky theme (Night, Sunset, Aurora, Nebula) |
| **`M`** | Toggle **3D Water Mirror Reflections** |
| **`K`** | Toggle **3D Lens Flare** |
| **`G`** | Toggle **Waving Water / 3D Ground Floor** |
| **`C`** | Toggle **3D Planar Shadows** |
| **`F`** | Toggle **Depth Z-Fog** |
| **`I`** | Toggle **FPS Counter & Info Bar (HUD)** |
| **`Space` / `R`** | Reset camera orientation and zoom |
| **`LMB` / `ESC`** | Exit cleanly back to AmigaOS / WHDLoad |

---

## Engine Architecture & Modules (`engine/`)

| Module | Role in Engine | Hardware Mechanisms & Algorithms |
| :--- | :--- | :--- |
| **`gfx_engine.i`** | AGA & Copper Initialization | System takeover (`sys_takeover`), 8 bitplanes (`320x256`, 256 colors), `50 Hz` VBL double buffering, 24-bit Copper sky (`1`-`4`) |
| **`c2p_chunky.i`** | Chunky-to-Planar Converter | Real-time 32-bit conversion of `160x128` 8-bit chunky buffer into 8 AGA bitplanes (`320x256`) on M68020+ |
| **`aura3d_v2.i`** | Core 3D Pipeline & Rasterizer | 3D matrix transforms, perspective projection, Gouraud + UV (`bfextu`), Phong + Fresnel Rim Glow, animated UV, `Z-Fog`, 16-bit **Z-Buffer** |
| **`ground_grid.i`** | Waving 3D Water Surface | Perspective scanline water renderer with sinusoidal modulation (`sin_tab`), Z-scrolling, and Z-Buffer writes (`G`) |
| **`mirror_reflect.i`** | 3D Planar Reflections | Mirrored vertex projection across the water plane with surface masking and Z-Buffer depth testing (`M`) |
| **`planar_shadow.i`** | 3D Cast Shadows | Ground-plane shadow projection with Z-Buffer depth sorting (`C`) |
| **`lens_flare.i`** | 3D Lens Flare | Light source projection, Z-Buffer occlusion test, anamorphic streaks, and diffraction discs (`K`) |
| **`terrain_3d.i`** | 3D Heightmap Terrain | Procedural `64x64` heightmap generator, directional slope shading, dynamic point light, and `Z-Fog` |
| **`particle_trail.i`** | 3D Particle System | World-space twin-nozzle exhaust emitter with lifetime fade in Z-Buffer |
| **`starfield.i`** | 3D Starfield Background | 256 multi-layer depth-parallax stars |
| **`hud_fps.i`** | Bilingual HUD & Help | `50 Hz` VBL frame rate counter (`FPS:XX`, key `I`), `PL/ENG` switcher (`L`), and help overlay (`H`) |
| **`input_ctrl.i`** | Keyboard & Joystick Input | Direct hardware reading of CIA-A (`$BFEC01` + `ACK` pulse) and Joystick Port 2 (`JOY1DAT` + `Fire`) |
| **`pt_player.i`** | ProTracker Music Player | 4-channel Paula audio DMA `.MOD` replayer (`16,497 Hz`) |

---

## Developer Tools (`tools/`)

- **`tools/mesh_conv.py`** — converts Wavefront **`.obj`** 3D models into native M68k assembly vertex, normal, and triangle tables (`--obj`, `--prefix`, `--out`, `--radius`, `--tex`).
- **`tools/png_to_aga.py`** — converts **`.png`** images into `64x64` chunky textures (`--mode texture`) or full-screen `320x256` 8-bitplane AGA images with 24-bit palettes (`--mode bitplanes`).
- **`tools/build_demo.py`** — automated build script assembling the M68020+ executable (`vasmm68k_mot`), WHDLoad Slave, and packaging **`.adf`**, **`.lha`**, and **`_FSUAE.zip`** releases.
