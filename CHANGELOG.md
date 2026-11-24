# Changelog

## [v1.14.4] - 2026-11-24
- **Pełny ekran PAL `320×256` 256 kolorów AGA (`-DFULL_RES`) dla profili `thea1200` i `060`:** 2× wyższa rozdzielczość pionowa C2P (`81 920 B` Chunky + `163 840 B` 16-bit Z-Buffer, pełne kadrowanie `DIWSTRT=$2C91` / `DIWSTOP=$2CD1`, `DDFSTRT=$0038` / `DDFSTOP=$00D0` bez czarnych pasów) dla wszystkich scen 3D, wody, odbić, cieni, terenu, flar, gwiazd i dolnego paska HUD (`Y=246`), przy zachowaniu szybkiego `320×128` dla profilu `standard` (`68EC020` / Android).
- **16× precyzja Z-Buffera tafli wody, mgła horyzontu i symetryczne odbicia (`FULL_RES`):** zrównano skalę głębi wody (`rz << 4`) z rasteryzerem brył 3D (bryły unoszą się wyraźnie nad wodą), dodano zanikanie kafelków we mgle przy horyzoncie (`214/206` → `204/198` → `196/192`), symetryczne odbicia względem `shadow_ground_y` oraz 32-bitowe adresowanie wierszy (`add.l`) w `draw_uv_tri` dla pełnej postaci w scenie finałowej `F8`.
- **Galeria zrzutów ekranu `320×256` (`docs/shot_v1144_*.png`):** dodano rzeczywiste zrzuty ekranu z profilu `THEA1200` w pełnej rozdzielczości PAL `320×256`.

<p>
  <img src="docs/shot_v1144_1.png" width="180" />
  <img src="docs/shot_v1144_2.png" width="180" />
  <img src="docs/shot_v1144_3.png" width="180" />
  <img src="docs/shot_v1144_4.png" width="180" /><br/>
  <img src="docs/shot_v1144_5.png" width="180" />
  <img src="docs/shot_v1144_6.png" width="180" />
  <img src="docs/shot_v1144_7.png" width="180" />
  <img src="docs/shot_v1144_8.png" width="180" />
</p>

## [v1.14.3] - 2026-11-24
- **Pełny ekran PAL `320×256` 256 kolorów AGA (`-DFULL_RES`) dla profili `thea1200` i `060`:** 2× wyższa rozdzielczość pionowa C2P (`81 920 B` Chunky + `163 840 B` 16-bit Z-Buffer, pełne kadrowanie `DIWSTRT=$2C91` / `DIWSTOP=$2CD1`, `DDFSTRT=$0038` / `DDFSTOP=$00D0` bez czarnych pasów) dla wszystkich scen 3D, wody, odbić, cieni, terenu, flar, gwiazd i dolnego paska HUD (`Y=246`), przy zachowaniu szybkiego `320×128` dla profilu `standard` (`68EC020` / Android).
- **16× precyzja Z-Buffera tafli wody, mgła horyzontu i symetryczne odbicia (`FULL_RES`):** zrównano skalę głębi wody (`rz << 4`) z rasteryzerem brył 3D (bryły unoszą się wyraźnie nad wodą), dodano zanikanie kafelków we mgle przy horyzoncie (`214/206` → `204/198` → `196/192`), symetryczne odbicia względem `shadow_ground_y` oraz 32-bitowe adresowanie wierszy (`add.l`) w `draw_uv_tri` dla pełnej postaci w scenie finałowej `F8`.
- **Trzy obozy wydawnicze (`--profile standard|thea1200|060`):** dedykowane paczki `.lha` i `*_FSUAE.zip` dla bazowej A1200 (`020`), konsoli THEA1200 oraz kart turbo `MC68060`, z hybrydowym startem WHDLoad + `S/startup-sequence`.

<p align="right"><a href="README.md">Polski</a> | <a href="README_EN.md">English</a> | <strong>Historia Zmian (PL)</strong> | <a href="CHANGELOG_EN.md">Changelog (EN)</a></p>

# Historia Zmian — AURA-3D AGA Engine

Chronologiczny rejestr rozwoju silnika **AURA-3D AGA Engine** dla Commodore Amiga 1200 (M68020+ / AGA / 256 kolorów).

---

## v1.14.3 — Experimental Hi-Res 320x128 (2026-11-24)

<p>
  <img src="docs/shot_v1143_1.png" width="180" />
  <img src="docs/shot_v1143_2.png" width="180" />
  <img src="docs/shot_v1143_3.png" width="180" />
  <img src="docs/shot_v1143_4.png" width="180" /><br/>
  <img src="docs/shot_v1143_5.png" width="180" />
  <img src="docs/shot_v1143_6.png" width="180" />
  <img src="docs/shot_v1143_7.png" width="180" />
  <img src="docs/shot_v1143_8.png" width="180" />
</p>
- **Zwiększenie rozdzielczości renderowania 3D do `320x128` (1x2):** 2x większa ostrość pozioma wszystkich brył 3D, wody, cieni, flar i terenu z natywnym 32-bitowym konwerterem C2P (`32 px/iteracja`) oraz podwojonymi buforami Chunky (`40 KB`) i Z-Buffer (`80 KB`).
- **16-krotnie wyższa precyzja Z-Buffera (`sz << 4`):** wyeliminowano błędy zaokrągleń głębi na krzywiznach Torusa w scenach System Planetarny (`F4`) i Przelot przez Torus (`F5`).
- **Kompensacja proporcji `2:1` dla cząsteczek, Lens Flare i terenu 3D:** zachowano okrągły kształt spalin, proporcje anamorficznych promieni flary oraz odświeżono napisy na planszy tytułowej (`F1`).

## v1.14.2 (2026-11-24)

<p>
  <img src="docs/shot_v114_1.png" width="180" />
  <img src="docs/shot_v114_2.png" width="180" />
  <img src="docs/shot_v114_3.png" width="180" />
  <img src="docs/shot_v114_4.png" width="180" /><br/>
  <img src="docs/shot_v114_5.png" width="180" />
  <img src="docs/shot_v114_6.png" width="180" />
  <img src="docs/shot_v114_7.png" width="180" />
  <img src="docs/shot_v114_8.png" width="180" />
</p>
- **Nowy efekt 3D — Animowane tekstury UV (`v2_uv_anim_u/v`)**: płynące tekstury energetyczne na satelitach w Systemie Planetarnym z zerowym narzutem w pętli pikseli scanline.
- **Nowy efekt 3D — Fresnel Rim-Edge Glow**: poświata krawędziowa na sylwetkach modeli 3D zintegrowana z cieniowaniem Phonga i mapą normalnych.
- **Optymalizacja C2P (`c2p_chunky.i`)**: 32-bitowe maskowanie półbajtów (`and.l #$0f0f0f0f`) we wszystkich 8 grupach konwersji Chunky-to-Planar (wzrost do 22–25 FPS).
- **Naprawa błędów**: eliminacja artefaktów („zębów piły”) przy dolnej krawędzi terenu 3D, poprawa trajektorii przelotu i smugi spalin wahadłowca nad terenem oraz separacja statycznego EnvMap Torusa od animowanych UV satelitów.

## v1.14.1
- **Shader Phonga z Mapą Normalnych (`[P]`):** generator `tools/gen_phong_lut.py` + tablica `engine/phong_norm_lut.bin` (ostre rozbłyski lustrzane i mikro-perturbacja normalnych).
- **Dynamiczne Światło Punktowe na Terenie 3D (`engine/terrain_3d.i`):** ruchome źródło światła krążące nad kanionem i rozświetlające zbocza w czasie rzeczywistym.
- **Animowane Tekstury UV (`engine/aura3d_v2.i`):** płynne przesunięcie fazowe współrzędnych `(U, V)` w rasteryzatorze `draw_uv_z_tri`.
- **Dwujęzyczny HUD i Pasek Opisu Sceny (`[H]` / `[L]` / `[I]`):** stałe etykiety `H HELP` i `L LANG` pod licznikiem FPS, okno pomocy (`H`), przełącznik języka `PL <-> ENG` (`L`) oraz przełącznik widoczności HUD (`I`).
- **Optymalizacja Potoku M68020+:** dwuprzebiegowy 32-bitowy C2P (`c2p_chunky.i`), 14-rejestrowe czyszczenie buforów `movem.l` (`fast_clear.i`), 2048-wpisowa tablica odwrotności `1/x` zamiast `divs.l` (`gen_recip_table.py`), 4 MB `ExpMem` w WHDLoad Slave.

---

## v1.14
- **8-Bitplanowy Ekran Startowy AGA (`320x256`, 256 kolorów):** strumieniowa dekompresja RLE planszy tytułowej (`F1`).
- **Falująca Tafla Wody i Lustrzane Odbicia (`M`):** perspektywiczna woda z modulacją sinusoidalną oraz odbicia obiektów sortowane w 16-bitowym Z-Bufferze.
- **Rozbłyski Soczewkowe 3D / Lens Flare (`L`):** promienie anamorficzne i 3 krążki dyfrakcyjne z testem zasłonięcia w Z-Bufferze + błyski lustrzane (Specular Highlights).
- **Przelot nad Terenem 3D (`engine/terrain_3d.i`):** proceduralny teren `64x64` z mapy wysokości z cieniowaniem stoków, jeziorami i szczytami (`F7`).
- **Wielomateriałowy Wahadłowiec (`576` tris, `F3`) i Model `.OBJ` Suzanne (`968` tris, `F6`).**
- **Przełącznik Scen (`F1`–`F8`, `Tab`) oraz ekranowy panel pomocy.**

---

## v1.13
- Pełnoekranowa perspektywiczna podłoga szachownicowa 3D z Z-Bufferem i optymalizacją pętli `dbf` na M68020.
- Wielomateriałowy wahadłowiec (`576` trójkątów) oraz potok siatek `1008` trójkątów (Torus / Vertex Morphing).
- Konwerter `tools/png_to_aga.py` dla tekstur UV `64x64` oraz pełnoekranowych obrazów 8-bitplanowych AGA.
- Licznik FPS HUD, cienie rzucane 3D (Planar Shadows), satynowy chrom i mgła głębi Z-Fog.

---

## v1.3

<p>
  <img src="docs/shot_v13_1.png" width="180" />
  <img src="docs/shot_v13_2.png" width="180" />
  <img src="docs/shot_v13_3.png" width="180" />
  <img src="docs/shot_v13_4.png" width="180" />
</p>
- **Perspektywiczna Podłoga 3D (`engine/ground_grid.i`):** raycasting płaszczyzny na `Y=62` z pełnym sortowaniem głębi w 16-bitowym Z-Bufferze, cieniowaniem horyzontu i przełącznikiem `G`.
- **Siatki High-Poly i Potok 2048 Wierzchołków (`engine/aura3d_v2.i`, `tools/mesh_conv.py`):** powiększenie buforów wierzchołków do 2048 oraz generowanie siatek Torus/Morph (`1008` tris) i wahadłowca (`576` tris).
- **Konwerter PNG do Amiga AGA (`tools/png_to_aga.py`):** konwersja plików `.png` na tekstury UV `64x64`, 24-bitowe palety 256 kolorów + 16-poziomową tablicę `shade_lut_v2.bin` oraz surowe bitplany `320x256`.

---

## v1.2
- **Natywny Licznik FPS HUD (`engine/hud_fps.i`):** ostry licznik `FPS:XX` na 8 bitplanach `320x256` w prawym górnym rogu.
- **Cienie Rzucane 3D (`engine/planar_shadow.i`):** rzutowanie geometrii w czasie rzeczywistym na płaszczyznę podłoża z testem 16-bitowego Z-Buffera (`C`).
- **Satynowa Mapa Środowiskowa (`demo_v1/chrome_tex.bin`):** płynne metaliczne odbicia stali, srebrnego horyzontu i piaskowca na bryłach 3D.

---

## v1.1
- **System Cząsteczek 3D (`engine/particle_trail.i`):** emiter spalin z podwójnych dysz wahadłowca w przestrzeni świata z sortowaniem głębi w 16-bitowym Z-Bufferze.
- **24-Bitowy Gradient Nieba Coppera AGA (`engine/copper_sky.i`):** sprzętowa modulacja `COLOR00` dla 228 linii okna PAL przy **0 cykli CPU** (4 motywy atmosferyczne `1`–`4`).
- **Mgła Głębi Z-Fog (`engine/aura3d_v2.i`):** tłumienie jasności wierzchołków zależne od odległości `sz` (`F`).
- **Sterowanie w Czasie Rzeczywistym (`engine/input_ctrl.i`):** obsługa joysticka w Porcie 2 (`JOY1DAT` + Fire) oraz klawiatury CIA-A (`$BFEC01`).

---

## v1.0 — Baseline Release

<p>
  <img src="docs/demo_v1_preview.jpg" width="360" />
</p>
- **Architektura M68020+ / AGA:** potok zablokowany na `50.00 Hz PAL` (`wait_vbl`), podwójne buforowanie ekranów, wypełnianie wielokątów z tablicą prefiksów XOR (`fill_lut`) oraz sprzętowy antyaliasing Blitterem (`BLTCON0=$1dfc`).
- **Dźwięk Paula 4CH DMA i WHDLoad Slave v17:** odtwarzanie audio bez zależności od plików Kickstart ROM (`ws_KickSize=0`).
