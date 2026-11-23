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
