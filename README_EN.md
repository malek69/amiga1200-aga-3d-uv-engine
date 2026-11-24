<p align="right"><a href="README.md">Polski</a> | <strong>English</strong> | <a href="CHANGELOG_EN.md">Changelog</a></p>

<div align="center">
  <img src="docs/logo_aura3d.png" alt="AURA-3D AGA Engine" width="520" />
  <h1>AURA-3D AGA Engine v1.14.2</h1>
  <p><strong>Bare-metal 3D Software Engine for Commodore Amiga 1200 (M68020+ / AGA / 256 Colors)</strong></p>
  <p>
    <a href="https://github.com">Download .LHA</a> &bull;
    <a href="https://github.com">Download FS-UAE .ZIP</a> &bull;
    <a href="https://github.com">Download .ADF</a>
  </p>
</div>

## What is New in v1.14.2
- **Animated UV Textures (`v2_uv_anim_u/v`):** scrolling `64x64` energy textures on orbiting satellites in the Planetary System with zero per-pixel overhead.
- **Fresnel Rim-Edge Glow (`P`):** silhouette edge rim lighting integrated into the Phong + normal map shader.
- **C2P Optimization (`engine/c2p_chunky.i`):** 32-bit nibble masking (`and.l #$0f0f0f0f`) across all 8 conversion groups (up to **25 FPS** on PAL).
- **Bug Fixes:** eliminated sawtooth artifacts at the bottom edge of the 3D terrain and fixed shuttle flight trajectory and twin-nozzle particle trail over the terrain.

## Controls
- **`F1`–`F8` / `Tab`**: Jump to scene (`F1` Title, `F2` Morphing, `F3` Shuttle, `F4` Planetary, `F5` Torus 6DOF, `F6` Suzanne `.OBJ`, `F7` 3D Terrain, `F8` Finale) / next scene
- **`H` / `L` / `I`**: Help overlay (`H`), switch `PL/ENG` (`L`), toggle FPS HUD (`I`)
- **`P` / `M` / `K`**: Phong + Fresnel (`P`), 3D mirror (`M`), Lens Flare (`K`)
- **`G` / `C` / `F`**: Water floor (`G`), 3D shadows (`C`), depth Z-Fog (`F`)
- **`1`–`4`**: Copper sky theme | **`Arrows` / Joy2**: Rotate | **`W`/`S`**: Zoom | **`Space`/`R`**: Reset | **`LMB`/`ESC`**: Exit

## Building from Source
`python3 tools/build_demo.py` (requires `vasmm68k_mot`, `lha`, and optionally `xdftool`).
