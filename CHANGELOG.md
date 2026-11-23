...
---

# AURA-3D AGA Engine v1.14

Bare-metal 3D software engine for Commodore Amiga 1200 (M68020+ / AGA).

## What is New in v1.14
- 8-Bitplane AGA Title Splash Screen (320x256, 256 colors) with RLE streaming decompression (F1).
- Real-Time Wavy Ocean Water Floor & Planar Mirror Reflections (M key).
- 3D Optical Lens Flare & Corona with 16-bit Z-Buffer occlusion (L key) + Specular Highlights.
- 3D Heightmap Terrain Flyover (64x64 procedural mountains & canyons with slope shading, F7).
- Multi-Material 576-Tri Space Shuttle (F3) & Network Wavefront .OBJ Suzanne Bust (968 tris, F6).
- Full Live Scene Switcher (F1-F8, Tab) and On-Screen Controls Overlay (K key).

---

# AURA-3D AGA Engine v1.13

Bare-metal 3D software engine for Commodore Amiga 1200 (M68020+ / AGA).

## What is New in v1.13
- Full-Screen 3D Perspective Checkered Floor with Z-Buffer & M68020 dbf optimization.
- Multi-Material High-Poly Space Shuttle (576 tris) & 1008-Tri Torus/Morphing pipeline.
- PNG to Amiga AGA Converter for 64x64 UV textures and 8-bitplane screens.
- Real-time FPS HUD, 3D Planar Shadows, satin chrome reflections, and Z-Fog.

---

# AURA-3D AGA Engine v1.3

Bare-metal 3D software engine for Commodore Amiga 1200 (M68020+ / AGA).

## What is New in v1.3
- 3D Perspective Checkered Floor Plane (engine/ground_grid.i): Raycasted ground plane at Y=62 with full 16-bit Z-Buffer depth sorting, horizon distance shading, and key G toggle.
- High-Polygon 3D Meshes & 2048-Vertex Pipeline (engine/aura3d_v2.i, tools/mesh_conv.py): Upgraded engine vertex buffers to 2048 vertices and generated 1008-triangle Torus/Morph meshes plus a 576-triangle subdivided Space Shuttle.
- PNG to Amiga AGA Converter (tools/png_to_aga.py): Converts .png images into 64x64 UV textures, 24-bit 256-color palettes + 16-level shade_lut_v2.bin, and raw 8-bitplane (320x256) AGA screens.
- Complete v1.2 Feature Set: Real-time FPS HUD (key H), 3D Planar Shadows (key C), satin chrome Environment Mapping, twin-nozzle particle trail, 24-bit Copper sky themes (keys 1-4), Z-Fog (key F), and Joystick Port 2 / keyboard controls.

---

# AURA-3D AGA Engine v1.2

Bare-metal 3D software engine for Commodore Amiga 1200 (M68020+ / AGA).

## What is New in v1.2
- Real-Time Native FPS HUD (engine/hud_fps.i): Crisp 320x256 bitplane counter (FPS:XX) in the top-right corner with key H toggle.
- 3D Planar Shadows (engine/planar_shadow.i): Real-time directional light shadow projection onto the ground plane with 16-bit Z-Buffer depth sorting and key C toggle.
- Satin Metallic Environment Map (demo_v1/chrome_tex.bin): Smooth steel, silver horizon, and warm sandstone reflections across all 3D meshes.
- Full v1.1 Feature Set: Twin-nozzle 3D particle trail, 24-bit AGA Copper sky gradient (4 themes), Z-Fog depth cueing, and Joystick Port 2 + CIA-A keyboard controls.

## Controls
- Arrow Keys / Joystick Port 2: Rotate 3D objects
- W / S or Fire + Up/Down: Zoom camera
- 1 - 4: Switch 24-bit Copper sky theme
- H: Toggle FPS HUD | C: Toggle 3D Shadows | F: Toggle Z-Fog
- Space / R: Reset camera | LMB / ESC: Exit

---

# AURA-3D AGA Engine v1.1

Bare-metal 3D software engine for **Commodore Amiga 1200 (M68020+ / AGA)**.

## Nowości w v1.1
- **3D World-Space Particle Trail (`engine/particle_trail.i`)**: emiter cząsteczek z podwójnych dysz wahadłowca `(-9,0,-36)` i `(+9,0,-36)` w przestrzeni świata z turbulentnym odrzutem i sortowaniem głębi przez 16-bitowy Z-Buffer (`draw_z_orb_v2`).
- **24-bitowy gradient nieba i horyzontu Coppera AGA (`engine/copper_sky.i`)**: sprzętowa modulacja `COLOR00` (`BPLCON3` LOCT 0/1) dla 228 linii okna PAL przy **0 cykli CPU**, z 4 wbudowanymi motywami atmosferycznymi.
- **Z-Fog / Depth Cueing (`engine/aura3d_v2.i`)**: tłumienie jasności wierzchołków zależne od głębi `sz` (`zfog_start = 118`, `zfog_shift = 2`) w potoku Gouraud + Environment Mapping.
- **Sterowanie w czasie rzeczywistym (`engine/input_ctrl.i`)**: obsługa joysticka w porcie 2 (`JOY1DAT` + Fire) oraz klawiatury CIA-A (`$BFEC01` ze sprzętowym handshake `$BFEE01`).

## Sterowanie na żywo (Demo v1.1)
- **Strzałki / Joystick Port 2**: obrót 3D obiektu (`user_yaw`, `user_pitch`)
- **W / S** lub **Fire + Góra/Dół**: przybliżenie / oddalenie kamery (`user_zoom`)
- **1 – 4**: zmiana motywu 24-bitowego gradientu Coppera (`Cosmic Horizon`, `Solaris Dusk`, `Emerald Nebula`, `Pure Black`)
- **F**: przełącznik Z-Fog ON/OFF
- **Spacja / R**: reset pozycji i obrotu kamery użytkownika
- **LMB / ESC**: wyjście do AmigaOS

---

# Amiga 1200 / THEA1200 Bare-Metal Vector Engine v1.0

> **Credits / Autorzy:** `malek69` & **Gemini AI** *(Vibe Coding Edition, 2026 — AI-assisted M68020 bare-metal code & Python toolchain)*


## 1. Architecture & Memory Map
- **CPU Target:** Motorola 68020+ (14 MHz stock A1200 / THEA1200), 32-bit aligned loops.
- **Chip RAM (~66 KB):** Double-buffered 3-bitplane PAL screens (`320x256`, `3 x 10240 B` x 2), dynamic Copperlist, and dual 2048 B Paula DMA audio buffers.
- **Fast RAM (~545 KB BSS + Stream):** 512 KB XOR prefix table (`fill_lut`), `320x256` CPU backbuffer (`fast_bpl1`), `edge_buf` (`10240 B`), and compressed polygon/PCM stream.

## 2. Locked 50.00 Hz PAL Frame Pipeline
1. `wait_vbl` — Waits for raster beam line `Y=260` and swaps `draw_bpl` / `view_bpl` pointers in Copper.
2. `blit_clear_full` — Clears `draw_bpl2` (red accent plane) asynchronously via Blitter.
3. `play_vector_frame` — Reads frame stream (`cur_frame = vbl_tick`), updates foreground AGA color, and dispatches polygons.
4. `draw_polygon_mode` — Clips edges (`0..319 x 0..255`), steps X via 32-bit `inv_tab` (`1/dy`), toggles `edge_buf` bits, and resolves scanlines via `fill_lut` (`op=0` fill, `op=1` cutout, `op=2` BPL2).
5. `Fast -> Chip Copy` — Unrolled `move.l (a0)+,(a1)+` loop transfers `fast_bpl1` to `draw_bpl1` and clears Fast-RAM backbuffer.
6. `apply_blitter_aa` — Blitter shifts `draw_bpl1` by 1px (`BLTCON0=$1dfc`) into `draw_bpl3` (`COLOR04`) for hardware anti-aliasing.

## 3. Audio & Kickstart-Free Boot
- **Paula 4CH DMA (`audio_player.i`):** Channels 0-3 driven in lockstep from Fast-RAM PCM via Level 4 IRQ (`AUD0`), hardware low-pass LED filter disabled (`bset #1,$bfe001`).
- **WHDLoad Slave v17 (`whdload_slave.s`):** `ws_KickSize=0` relocates Hunk segments directly into Fast/Chip RAM without Kickstart ROM files.
