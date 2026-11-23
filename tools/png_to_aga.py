#!/usr/bin/env python3
import argparse
import os
import struct
from PIL import Image

def load_aga_palette(pal_path):
    raw = open(pal_path, "rb").read()
    if len(raw) < 1024:
        raise ValueError(f"Plik palety {pal_path} musi miec 1024 bajty (256 x 4B).")
    palette = list()
    for i in range(256):
        _, r, g, b = struct.unpack(">BBBB", raw[i * 4:(i + 1) * 4])
        palette.append((r, g, b))
    return palette

def save_aga_palette(palette, out_path):
    blob = bytearray()
    for r, g, b in palette[:256]:
        blob.extend(struct.pack(">BBBB", 0, int(r), int(g), int(b)))
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    open(out_path, "wb").write(blob)

def nearest_color_idx(r, g, b, palette, min_idx=1):
    best_i = min_idx
    best_dist = 1 << 30
    for i in range(min_idx, len(palette)):
        pr, pg, pb = palette[i]
        dr = r - pr
        dg = g - pg
        db = b - pb
        dist = 3 * dr * dr + 4 * dg * dg + 2 * db * db
        if dist < best_dist:
            best_dist = dist
            best_i = i
            if dist == 0:
                break
    return best_i

def build_shade_lut(palette, out_path):
    lut = bytearray(16 * 256)
    for level in range(16):
        factor = 0.12 + (level / 15.0) * 0.88
        for idx in range(256):
            if idx == 0:
                lut[level * 256 + idx] = 0
                continue
            r, g, b = palette[idx]
            sr = min(255, int(round(r * factor)))
            sg = min(255, int(round(g * factor)))
            sb = min(255, int(round(b * factor)))
            lut[level * 256 + idx] = nearest_color_idx(sr, sg, sb, palette, min_idx=1)
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    open(out_path, "wb").write(lut)

def convert_textures(inputs, pal_path, out_path):
    palette = load_aga_palette(pal_path)
    out_blob = bytearray()
    for img_path in inputs:
        im = Image.open(img_path).convert("RGB").resize((64, 64), Image.Resampling.LANCZOS)
        cache = dict()
        for y in range(64):
            for x in range(64):
                rgb = im.getpixel((x, y))
                if rgb not in cache:
                    cache[rgb] = nearest_color_idx(rgb[0], rgb[1], rgb[2], palette, min_idx=1)
                out_blob.append(cache[rgb])
        print(f"  + Tekstura 64x64: {img_path}")
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    open(out_path, "wb").write(out_blob)
    print(f"OK: Zapisano bank tekstur ({len(inputs)} szt., {len(out_blob)} B) -> {out_path}")

def extract_palette_and_lut(img_path, out_pal, out_lut):
    im = Image.open(img_path).convert("RGB")
    quant = im.quantize(colors=254, method=Image.Quantize.MEDIANCUT)
    raw_pal = quant.getpalette() or list()
    palette = [(0, 0, 0)]
    for i in range(254):
        base = i * 3
        if base + 2 < len(raw_pal):
            palette.append((raw_pal[base], raw_pal[base + 1], raw_pal[base + 2]))
        else:
            palette.append((i, i, i))
    palette.append((255, 255, 255))
    save_aga_palette(palette, out_pal)
    print(f"OK: Zapisano 24-bitowa palete AGA (1024 B) -> {out_pal}")
    if out_lut:
        build_shade_lut(palette, out_lut)
        print(f"OK: Wygenerowano 16-poziomowa tablice cieniowania (4096 B) -> {out_lut}")

def convert_bitplanes(img_path, out_bpl, out_pal, width=320, height=256):
    im = Image.open(img_path).convert("RGB").resize((width, height), Image.Resampling.LANCZOS)
    quant = im.quantize(colors=256, method=Image.Quantize.MEDIANCUT)
    raw_pal = quant.getpalette() or list()
    palette = list()
    for i in range(256):
        base = i * 3
        if base + 2 < len(raw_pal):
            palette.append((raw_pal[base], raw_pal[base + 1], raw_pal[base + 2]))
        else:
            palette.append((0, 0, 0))
    save_aga_palette(palette, out_pal)
    row_bytes = width // 8
    plane_size = row_bytes * height
    planes = [bytearray(plane_size) for _ in range(8)]
    for y in range(height):
        row_off = y * row_bytes
        for x in range(width):
            px = quant.getpixel((x, y)) & 0xFF
            byte_idx = row_off + (x >> 3)
            bit_mask = 1 << (7 - (x & 7))
            for bpl in range(8):
                if px & (1 << bpl):
                    planes[bpl][byte_idx] |= bit_mask
    os.makedirs(os.path.dirname(os.path.abspath(out_bpl)), exist_ok=True)
    with open(out_bpl, "wb") as f:
        for bpl in range(8):
            f.write(planes[bpl])
    print(f"OK: Zapisano 8 bitplanow AGA ({width}x{height}, {8 * plane_size} B) -> {out_bpl}")

def main():
    ap = argparse.ArgumentParser(description="Konwerter PNG -> Amiga 1200 AGA (AURA-3D Engine)")
    ap.add_argument("--mode", required=True, choices=["texture", "palette", "bitplanes"], help="Tryb konwersji")
    ap.add_argument("--input", nargs="+", required=True, help="Plik(i) wejsciowe .png")
    ap.add_argument("--pal", default="demo_v1/pal256.bin", help="Plik palety AGA 256 kolorow (1024 B)")
    ap.add_argument("--lut", default="demo_v1/shade_lut_v2.bin", help="Wyjsciowy plik shade_lut_v2.bin (4096 B)")
    ap.add_argument("--out", required=True, help="Plik wyjsciowy (.bin)")
    args = ap.parse_args()
    if args.mode == "texture":
        convert_textures(args.input, args.pal, args.out)
    elif args.mode == "palette":
        extract_palette_and_lut(args.input, args.out, args.lut)
    elif args.mode == "bitplanes":
        convert_bitplanes(args.input, args.out, args.pal)

if __name__ == "__main__":
    main()
