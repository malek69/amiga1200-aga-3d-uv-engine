<p align="right"><strong>Polski</strong> | <a href="README_EN.md">English</a> | <a href="CHANGELOG.md">Lista zmian</a></p>

<div align="center">
  <img src="docs/logo_aura3d.png" alt="AURA-3D AGA Engine" width="520" />
  <h1>AURA-3D AGA Engine v1.14.2</h1>
  <p><strong>Bare-metalowy silnik 3D dla Commodore Amiga 1200 (M68020+ / AGA / 256 kolorów)</strong></p>
  <p>
    <a href="https://github.com">Pobierz .LHA</a> &bull;
    <a href="https://github.com">Pobierz FS-UAE .ZIP</a> &bull;
    <a href="https://github.com">Pobierz .ADF</a>
  </p>
</div>

## Nowości w v1.14.2
- **Animowane tekstury UV (`v2_uv_anim_u/v`):** płynące tekstury energetyczne `64x64` na satelitach w Systemie Planetarnym bez narzutu w pętli pikseli.
- **Fresnel Rim-Edge Glow (`P`):** poświata krawędziowa na sylwetkach modeli 3D połączona z cieniowaniem Phonga i mapą normalnych.
- **Optymalizacja C2P (`engine/c2p_chunky.i`):** 32-bitowe maskowanie półbajtów (`and.l #$0f0f0f0f`) we wszystkich 8 grupach konwersji (do **25 FPS** w PAL).
- **Naprawa błędów:** usunięto „zęby piły” przy dolnej krawędzi terenu 3D i poprawiono trajektorię przelotu oraz smugę spalin wahadłowca nad terenem.

## Klawiszologia
- **`F1`–`F8` / `Tab`**: Wybór sceny (`F1` Tytuł, `F2` Morphing, `F3` Wahadłowiec, `F4` Planety, `F5` Torus 6DOF, `F6` Suzanne `.OBJ`, `F7` Teren 3D, `F8` Finał) / następna scena
- **`H` / `L` / `I`**: Panel pomocy (`H`), zmiana języka `PL/ENG` (`L`), przełączenie HUD FPS (`I`)
- **`P` / `M` / `K`**: Phong + Fresnel (`P`), lustro 3D (`M`), Lens Flare (`K`)
- **`G` / `C` / `F`**: Tafla wody (`G`), cienie 3D (`C`), mgła Z-Fog (`F`)
- **`1`–`4`**: Motyw nieba Coppera | **`Strzałki` / Joy2**: Obrót | **`W`/`S`**: Zoom | **`Spacja`/`R`**: Reset | **`LMB`/`ESC`**: Wyjście

## Kompilacja
`python3 tools/build_demo.py` (wymaga `vasmm68k_mot`, `lha`, opcjonalnie `xdftool`).
