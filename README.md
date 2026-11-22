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
* **OBJ-to-Amiga Vertex Grid Clustering (`tools/make_showcase.py`):** Konwerter wielotysięcznych modeli `.obj` (`32 000+` wierzchołków) do zwartych brył UV pod M68020.
* **Demoscenowy kontener zasobów `PAK0` (`tools/pack_scenes.py`):** Pakowanie palet 24-bit (`PAL256`), tekstur (`UVTEX64`), tablic LUT (`TUNLUT`) i geometrii (`MESH3D`) w jeden plik binarny `demo_v1/grotto_assets.pak`.
* **Bare-Metal Audio & WHDLoad (`pt_player.i`, `whdload_slave.s`):** 4-kanałowy odtwarzacz ProTracker Paula DMA oraz gotowy slave WHDLoad v17+ (`releases/aura3d_demo_v1.lha`).

## Kompilacja / Build
```fish
python3 tools/make_showcase.py && python3 tools/pack_scenes.py && python3 tools/build_demo.py
```

## Narzędzia, konwertery i pakowanie / Converters & Asset Packing

### 1. Konwertery modeli 3D (`.obj` -> Amiga UV Mesh)
* **`tools/make_showcase.py` (High-Poly -> ~850 trójkątów):** Konwertuje gęste siatki z internetu (np. `30 000+` wierzchołków w `assets_raw/hero_scene.obj`) metodą **Vertex Grid Clustering**, łącząc sąsiednie wierzchołki w zwartą bryłę bez dziur, dodając cokół oraz mapując wysokość/promień na banki 256-kolorowej palety AGA.
* **`tools/obj2amiga.py` (Low-Poly + materiały `usemtl`):** Konwertuje lekkie modele `.obj` (do `260` trójkątów) i automatycznie przypisuje nazwy materiałów (`gold`, `green`, `sand`, `water`, `wood`, `cyan`, `white`) do odpowiednich tekstur i banków kolorów.
* **Pliki wyjściowe:** Oba konwertery generują jednocześnie plik binarny `demo_v1/imported_mesh.bin` (do paczki `PAK0`) oraz źródło asemblerowe `demo_v1/imported_mesh.i`.

### 2. Tworzenie paczki zasobów `PAK0` (`tools/pack_scenes.py`)
Skrypt `tools/pack_scenes.py` łączy wszystkie dane binarne silnika w jeden demoscenowy kontener **`demo_v1/grotto_assets.pak`**:
* **Nagłówek (8 B):** sygnatura ASCII `PAK0` + 32-bitowa liczba sekcji (`big-endian`).
* **Tablica offsetów TOC (`N * 16 B`):** dla każdej sekcji 8-bajtowa nazwa (`PAL256`, `UVTEX64`, `TUNLUT`, `MESH3D`), 32-bitowy offset i 32-bitowy rozmiar.
* **Dane surowe:** paleta 24-bit RGB (`1 024 B`), 4 tekstury `64x64` (`16 384 B`), tablica tunelu (`86 016 B`) oraz siatka 3D (`MESH3D`).

### 3. Jak wrzucić własną scenę `.obj` i zbudować paczkę krok po kroku
1. Zapisz swój model jako `assets_raw/hero_scene.obj` (lub podaj ścieżkę do `tools/obj2amiga.py`).
2. Uruchom konwersję, pakowanie `PAK0` i kompilację WHDLoad (`.lha`):
```fish
python3 tools/make_showcase.py && python3 tools/pack_scenes.py && python3 tools/build_demo.py
```
3. Gotowy plik wykonywalny oraz archiwum WHDLoad trafiają do katalogu `releases/` (`AURA3D_DEMO` oraz `aura3d_demo_v1.lha`).

## Możliwości silnika, funkcje i muzyka .MOD / Capabilities, Functions & .MOD Audio

### Co potrafi silnik / Engine Capabilities
* **Grafika 256-kolorowa AGA (`BPLCON0 = $0210`):** Pełne 8 bitplanów z 24-bitową paletą RGB (8 banków po 32 odcienie) ładowaną sprzętowo przez rejestr `BPLCON3`.
* **Teksturowanie UV i cieniowanie w czasie rzeczywistym:** Rysowanie oteksturowanych trójkątów `64x64` w buforze chunky `160x128` z konwersją C2P do `320x256` PAL (`16:9` letterbox) w pełnych `50 Hz`.
* **Sortowanie głębi `Shell Z-Sort` (`O(N log N)`):** Płynna obsługa złożonych brył 3D (`850+` trójkątów UV) bez przenikania tylnych ścian.
* **Wbudowana muzyka `.MOD` (ProTracker Paula DMA):** Silnik odtwarza w tle 4-kanałowe moduły Amigowe **ProTracker (`M.K.`)** bezpośrednio przez sprzętowe kanały DMA układu **Paula (`$dff0a0–$dff0df`)** w przerwaniu VBL `50 Hz` (bez udziału systemu operacyjnego).

### Kluczowe funkcje w kodzie / Core Assembly Functions
* `sys_takeover` / `sys_restore` (`demo_v1/gfx_engine.i`): Bezpieczne przejęcie sprzętu Amigi 1200, wyłączenie wielozadaniowości AmigaOS i przywrócenie systemu po naciśnięciu LPM lub `ESC`.
* `build_copper` / `swap_buffers` (`demo_v1/gfx_engine.i`): Budowa Copperlisty dla 8 bitplanów AGA oraz podwójne buforowanie ekranu bez rozrywania klatek.
* `load_aga_256_palette` (`demo_v1/gfx_engine.i`): Ładowanie 256 kolorów 24-bitowych RGB do banków palety AGA.
* `c2p_160x128_to_aga` (`demo_v1/c2p_chunky.i`): Szybki tablicowy konwerter Chunky-to-Planar (8 bitplanów) z podwajaniem linii w poziomie i pionie.
* `draw_uv_tri` / `scan_uv_edge` (`demo_v1/c2p_chunky.i`): Rasteryzator trójkątów 3D z mapowaniem tekstur UV `64x64` i 32-stopniowym cieniowaniem.
* `render_zsorted_hero` / `proj_uv_160` (`demo_v1/demo_scenes.i`): Rzutowanie perspektywiczne 3D, sortowanie głębi `Shell Z-Sort` oraz renderowanie gwiazd i krążących świetlików.
* `pt_init` / `pt_music` / `vbl_irq_handler` (`demo_v1/pt_player.i`): Sprzętowy odtwarzacz plików muzycznych `.mod` zsynchronizowany z przerwaniem ramki `50 Hz`.
