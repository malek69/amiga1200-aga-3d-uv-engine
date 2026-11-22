# Amiga 1200 / THEA1200 AGA 3D UV Engine — Grotto 3D [2026 Edition]

**Authors / Autorzy:** malek69 & **Gemini AI** *(Vibe Coding Edition, 2026)*  
**Target Hardware:** Commodore Amiga 1200 (MC68020+ / AGA Chipset / 2 MB Chip + Fast RAM) & THEA1200  
**Music:** *1991-Not A Number* (ProTracker 4-channel MOD, Aminet)


---

![Act I - 3D UV Tunnel](docs/tunnel.png)

## 1. Scene Breakdown & Polygon / Pixel Counts
* **Act I (`0.0s – 5.2s`) — Organic Round 3D Tunnel (`act1_round_tunnel`):**
  * **Resolution:** `160x128` chunky rendered per-pixel via `224x192` polar `(U, V)` ray-LUT, doubled via C2P to `320x256` 32-color AGA (5-bitplane) (**20,480 shaded texels/frame** at 50 Hz).
  * **Dynamic Point-Light Firefly:** Real-time squared Euclidean distance (`dx^2 + dy^2`) modulated by rock texture roughness, casting warm amber light along the tunnel walls.
* **Act II (`5.2s – 7.6s`) — Tunnel-to-Grotto Transition (`act2_tunnel_exit_scene`):**
  * Camera flies through a 3D rocky archway (`tunnel_arch_mesh`, 3 triangles) out of the tunnel into the underground cavern while the golden firefly meets the turquoise cavern firefly.
* **Act III (`7.6s+`) — 360° UV-Textured Underground Grotto (`act3_360_grotto`):**
  * **Total 3D Mesh Complexity:** **295 UV-textured 3D triangles** per frame (`74` environment triangles + `14` foreground island/tree triangles + `3` archway triangles) + pixel-accurate seated rusalka & dual animated fireflies.
  * **Environment (`cavern_env_mesh` — 74 triangles):** 12-sided 360° rock walls (`24` tris), 12-sided vaulted ceiling (`12` tris), 2-ring 360° shimmering lake (`36` tris), and animated UV-scrolling waterfall (`2` tris).
  * **Centerpiece (`cavern_fg_mesh` — 14 triangles):** Golden-sand island (`3` tris), tree trunk (`2` tris), and 3-tier emerald leafy tree crown (`9` tris) with a seated rusalka at the shore.

---

## 2. Engine Architecture & Key Functions
| Module | Key Functions | Responsibility |
| :--- | :--- | :--- |
| `src/main.s` | `start`, `mainloop`, `shutdown` | AmigaOS takeover, 50 Hz PAL VBL loop, Fast/Chip RAM section layout |
| `src/gfx_engine.i` | `sys_takeover`, `build_copper`, `swap_buffers`, `wait_vbl`, `blit_clear_full` | AGA 5-bitplane (`16-color`) setup, Copperlist generation, double-buffering |
| `src/c2p_chunky.i` | `clear_chunky`, `c2p_160x128_to_aga`, `draw_uv_tri`, `scan_uv_edge` | `160x128` -> `320x256` 5-bitplane Chunky-to-Planar converter & affine `64x64` UV triangle rasterizer |
| `src/realtime_3d.i` | `render_realtime_3d`, `act1_round_tunnel`, `act2_tunnel_exit_scene`, `act3_360_grotto`, `proj_uv_160`, `calc_cavern_light`, `draw_textured_firefly_2d` | 3-act choreography, orbital 3D camera, dual point-light shading, animated UV waterfall & fireflies |
| `src/pt_player.i` | `pt_init`, `pt_music`, `vbl_irq_handler` | Bare-metal 50 Hz ProTracker `M.K.` 4-channel Paula DMA music player |
| `src/whdload_slave.s` | `_start`, `s_tof`, `s_opn` | Custom WHDLoad v17+ slave with Kickstart-free hardware takeover |
| `tools/build_grotto3d.py` | `mk_lha`, `mk_ico` | Automated `vasmm68k_mot` build, WHDLoad slave assembly & `.lha` packaging |
| `tools/obj2amiga.py` | `convert_obj` | Blender `.obj` low-poly 3D mesh converter to M68k `dc.w` triangle tables |

---

## 3. Amiga 1200 (AGA / M68020) Hardware & Software Hacks Used
1. **Table-Driven Chunky-to-Planar (`c2p_160x128_to_aga` in `src/c2p_chunky.i`):**
   * Uses a 16-entry 32-bit bit-expansion LUT (`c2p_exp`) to convert 4 chunky pixels at once into 4 planar bitplanes (`BPL1..BPL4`) while doubling every scanline vertically (`40(a1)` + `(a1)+`) for full-screen `320x256` output.
2. **Padded Polar Ray-LUT with Zero-Trig Camera Sway (`act1_round_tunnel` in `src/realtime_3d.i` & `src/tunnel_lut.bin`):**
   * Precomputes a `224x192` `(angle, 1/Z)` lookup table (`86 KB`) with a `+-32 px` safety margin, allowing the 68020 to sway the 3D tunnel camera smoothly via pointer offset (`mulu.w #448,d0`) with zero per-pixel divisions.
3. **Lower Chip RAM Hard-Pinning & Copper Line-1 Race Guard (`sys_takeover` & `build_copper` in `src/gfx_engine.i`):**
   * Pins the 8 AGA bitplane buffers (`$080000–$095000`) and Copperlist (`$08F000`) in guaranteed Chip RAM and inserts a Copper `WAIT $0107,$FFFE` before `BPLxPT` loads so VBL `swap_buffers` never races Agnus DMA.
4. **AGA Palette Bank Reset (`build_copper` in `src/gfx_engine.i`):**
   * Explicitly clears `BPLCON3 ($dff106) = $0c00` and `BPLCON4 ($dff10c) = $0000` in the Copperlist to prevent leftover Kickstart/WHDLoad bitplane XOR masks.
5. **Fast RAM Execution & `bss` Relocation Isolation (`src/main.s`):**
   * Keeps the `16 KB` `64x64` UV texture bank (`uv_tex_bank`), `86 KB` `tunnel_lut`, and `20 KB` `chunky_buf` in Fast RAM sections (`uv_data`, `fastram_bss`), keeping `CODE` under `18 KB` so all `bsr.w` branches stay within `+-32 KB` PC-relative range.
6. **32-Bit Fixed-Point UV Edge Interpolation (`scan_uv_edge` & `draw_uv_tri` in `src/c2p_chunky.i`):**
   * Uses `16.16` fixed-point X slopes and `8.8` `(U, V)` texture gradients with `32-bit divs.l` to avoid 16-bit signed overflow on wide cavern walls and lake polygons.
