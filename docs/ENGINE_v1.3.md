# AURA-3D AGA Engine v1.3

Bare-metal 3D software engine for Commodore Amiga 1200 (M68020+ / AGA).

## What is New in v1.3
- 3D Perspective Checkered Floor Plane (engine/ground_grid.i): Raycasted ground plane at Y=62 with full 16-bit Z-Buffer depth sorting, horizon distance shading, and key G toggle.
- High-Polygon 3D Meshes & 2048-Vertex Pipeline (engine/aura3d_v2.i, tools/mesh_conv.py): Upgraded engine vertex buffers to 2048 vertices and generated 1008-triangle Torus/Morph meshes plus a 576-triangle subdivided Space Shuttle.
- PNG to Amiga AGA Converter (tools/png_to_aga.py): Converts .png images into 64x64 UV textures, 24-bit 256-color palettes + 16-level shade_lut_v2.bin, and raw 8-bitplane (320x256) AGA screens.
- Complete v1.2 Feature Set: Real-time FPS HUD (key H), 3D Planar Shadows (key C), satin chrome Environment Mapping, twin-nozzle particle trail, 24-bit Copper sky themes (keys 1-4), Z-Fog (key F), and Joystick Port 2 / keyboard controls.
