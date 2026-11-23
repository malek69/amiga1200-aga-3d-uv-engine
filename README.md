# AURA-3D AGA Engine v1.0 (Amiga 1200 / THEA1200)

![AURA-3D Demo v1.0 Preview](docs/demo_v1_preview.jpg)

Bare-metalowy silnik 3D z teksturowaniem UV oraz konwersją Chunky-to-Planar (C2P) dla **Amigi 1200 (AGA / Motorola 68020+)**, **THEA1200** oraz emulatorów (**FS-UAE / RetroArch PUAE**).

## Pobierz / Downloads
- **[AURA-3D Demo 1.0](../../releases/tag/demo-v1.0)** — demo 256-kolorowe (320x256 PAL @ 50 FPS) z muzyką Paula DMA.
- **[AURA-3D AGA Engine v1.0](../../releases/tag/engine-v1.0)** — rdzeń silnika M68020, rasteryzator UV, C2P oraz narzędzia konwersji.

## Uruchamianie (THEA1200 / RetroArch PUAE / FS-UAE)
- **Wymagana konfiguracja:** Amiga 1200, CPU **68020+**, chipset **AGA**, **2 MB Chip RAM + 8 MB Fast RAM**.
- **RetroArch (PUAE na PC / Android):** W opcjach rdzenia ustaw `Model: A1200 (2MB Chip + 8MB Fast)`. Jeśli WHDLoad otworzy okno wyboru pliku, kliknij **Volumes**, wybierz wolumen z demem (`DH1:`) i wskaż plik `.slave`.

## Architektura i pliki
- **`engine/`** — kod asemblera M68020+ (Copperlista AGA, C2P, rasteryzator UV, obsługa Paula DMA, WHDLoad Slave v17).
- **`demo_v1/`** — zasoby i konfiguracja pierwszego dema.
- **`tools/`** — skrypty Python (OpenCV / NumPy) do przygotowania tekstur, siatek 3D i pakowania.
