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
