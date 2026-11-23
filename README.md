# AURA-3D AGA Engine (Amiga 1200 / THEA1200)

Bare-metalowy **silnik 3D** z teksturowaniem UV w czasie rzeczywistym oraz konwersją Chunky-to-Planar (C2P) dla **Amigi 1200 (AGA / Motorola 68020+)**, **THEA1200** oraz emulatorów (**FS-UAE / RetroArch PUAE**).

## Założenia techniczne silnika 3D
- **Architektura:** 100% bare-metal M68020+ (WHDLoad Slave v17, `NoMMU`).
- **Grafika 3D:** Rasteryzator wielokątów z mapowaniem tekstur UV + szybki konwerter **Chunky-to-Planar (C2P)** w 256 kolorach (AGA 320x256 PAL @ 50 FPS).
- **Pamięć i dźwięk:** 2 MB Chip RAM + 8 MB Fast RAM, 4-kanałowy odtwarzacz Paula DMA.

## Pobierz / Downloads
Pełny kod źródłowy silnika oraz wydania demonstracyjne znajdziesz w repozytorium GitHub.

## Struktura repozytorium
- **`engine/`** — kod asemblera M68020+ (Copperlista AGA, C2P, rasteryzator 3D UV, Paula DMA, WHDLoad Slave).
- **`demo_v1/`** — zasoby 3D, tekstury i konfiguracja dema.
- **`tools/`** — skrypty Python do konwersji zasobów i pakowania archiwów `.lha`.
