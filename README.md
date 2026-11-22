<p align="center"><img src="docs/logo.png" alt="AURA-3D AGA Engine Logo"></p>

# AURA-3D AGA Engine v1.0 (Amiga 1200 / THEA1200)

## Pobierz / Downloads (Releases)
* **[AURA-3D Demo 1.0 (`aura3d_demo_v1.lha`)](../../releases/tag/demo-v1.0)** — gotowe demo WHDLoad na Amigę 1200 / THEA1200 / FS-UAE (rozpakuj `.lha` i uruchom przez WHDLoad lub bezpośrednio plik `AURA3D_DEMO`; wyjście: LPM lub `ESC`).
* **[AURA-3D AGA Engine v1.0 (`aura3d_engine_v1.0.zip`)](../../releases/tag/engine-v1.0)** — czysty rdzeń silnika w asemblerze M68020 (`engine/`) wraz z konwerterami `.obj` i pakerem `PAK0` (`tools/`).

## Twórcy / Credits
* **Silnik i kod M68020 / Engine:** malek69 & Gemini AI (2026)
* **Scena 3D i oświetlenie / 3D Scene:** malek69 & Gemini AI (baza siatki: *Beast* / Common 3D Test Models)
* **Muzyka / Music (`.MOD`):** *1991-Not A Number* (4-kanałowy moduł ProTracker Paula DMA, Aminet)

## Struktura i możliwości / Structure & Features
* `engine/` — 256-kolorowy silnik AGA (`BPLCON0 = $0210`, 8 bitplanów, 24-bit RGB), konwerter `c2p_160x128_to_aga` (`320x256` PAL `16:9` w `50 Hz`), rasteryzator UV `64x64`, odtwarzacz `.MOD` (`pt_player.i`) i WHDLoad v17+ slave.
* `demo_v1/` — 3-aktowe Demo 1.0 (`850+` trójkątów UV, sortowanie głębi `Shell Z-Sort`, 3-punktowe cieniowanie normalnych `N dot L`, kontener zasobów `PAK0`).
* `tools/` — konwertery modeli 3D (`make_showcase.py`, `obj2amiga.py`), paker kontenera `PAK0` (`pack_scenes.py`) oraz skrypt kompilacji (`build_demo.py`).

## Kompilacja / Build
```fish
python3 tools/pack_scenes.py && python3 tools/build_demo.py
```
