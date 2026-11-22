<p align="center"><img src="docs/logo.png" alt="AURA-3D AGA Engine Logo"></p>

# AURA-3D AGA Engine (Amiga 1200 / THEA1200)

**Authors / Autorzy:** malek69 & Gemini AI (2026)  
**Platform:** Commodore Amiga 1200 (MC68020+ / AGA / 2 MB Chip + Fast RAM) & THEA1200  
**Music:** *1991-Not A Number* (ProTracker 4-ch MOD)

## O silniku / About AURA-3D AGA Engine
**AURA-3D AGA Engine** to napisany od zera w czystym asemblerze **Motorola 68020 (`vasm`)** silnik grafiki 3D czasu rzeczywistego dla **Commodore Amiga 1200** i **THEA1200**, pracujący w pełnych **256 kolorach AGA (`BPLCON0 = $0210`, 8 bitplanów, 24-bitowa paleta RGB)**.

### Kluczowe możliwości / Key Features
* **256-Color AGA Chunky-to-Planar (`c2p_160x128_to_aga`):** Szybki konwerter tablicowy 8 bitplanów (`160x128` 8-bit chunky -> `320x256` PAL 16:9 letterbox w `50 Hz`).
* **Fast 68020 Shell Z-Sort (`render_zsorted_hero`):** Sortowanie głębi `O(N log N)` obsługujące ponad **850 oteksturowanych trójkątów 3D UV** w czasie rzeczywistym z ciągłym mapowaniem UV.
* **OBJ-to-Amiga Vertex Grid Clustering (`tools/cluster_obj.py`):** Konwerter wielotysięcznych modeli `.obj` (`32 000+` wierzchołków) do zwartych brył UV pod M68020.
* **Demoscenowy kontener zasobów `PAK0` (`tools/pack_scenes.py`):** Pakowanie palet 24-bit (`PAL256`), tekstur (`UVTEX64`), tablic LUT (`TUNLUT`) i geometrii (`MESH3D`) w jeden plik binarny `src/grotto_assets.pak`.
* **Bare-Metal Audio & WHDLoad (`pt_player.i`, `whdload_slave.s`):** 4-kanałowy odtwarzacz ProTracker Paula DMA oraz gotowy slave WHDLoad v17+ (`releases/grotto3d.lha`).

## Kompilacja / Build
```fish
python3 tools/cluster_obj.py && python3 tools/pack_scenes.py && python3 tools/build_grotto3d.py
```
