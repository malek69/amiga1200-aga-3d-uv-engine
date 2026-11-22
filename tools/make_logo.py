import struct, zlib, math

W, H = 480, 136
FONT = {
    "A": ("01110","10001","10001","11111","10001","10001","10001"),
    "U": ("10001","10001","10001","10001","10001","10001","01110"),
    "R": ("11110","10001","10001","11110","10100","10010","10001"),
    "-": ("00000","00000","00000","11111","00000","00000","00000"),
    "3": ("11110","00001","00001","01110","00001","00001","11110"),
    "D": ("11100","10010","10001","10001","10001","10010","11100"),
    " ": ("00000","00000","00000","00000","00000","00000","00000"),
    "G": ("01110","10001","10000","10111","10001","10001","01110"),
    "E": ("11111","10000","10000","11110","10000","10000","11111"),
    "N": ("10001","11001","10101","10011","10001","10001","10001"),
    "I": ("01110","00100","00100","00100","00100","00100","01110"),
}
rows = list()
for y in range(H):
    row = bytearray()
    for x in range(W):
        r, g, b = 8, 12, 32
        if y in (6, 7, H-8, H-7): r, g, b = 255, 140, 20
        elif y in (9, H-10): r, g, b = 60, 180, 255
        elif y % 4 == 0 and 14 < y < H-14: r, g, b = 14, 22, 52
        dx, dy = x - 66, y - 68
        d2 = dx*dx + dy*dy
        if d2 <= 44*44:
            z = math.sqrt(max(0, 44*44 - d2))
            u = int((math.atan2(dx, z) + 1.5) * 4.5)
            v = int((math.asin(max(-1.0, min(1.0, dy / 44.0))) + 1.5) * 4.5)
            shade = 0.45 + 0.55 * (z / 44.0)
            if (u + v) % 2 == 0:
                r, g, b = int(245 * shade), int(35 * shade), int(45 * shade)
            else:
                r, g, b = int(248 * shade), int(248 * shade), int(252 * shade)
        row.extend((r, g, b))
    rows.append(row)

def draw_text(txt, x0, y0, sx, sy, c_top, c_bot):
    r0, g0, b0 = c_top
    r1, g1, b1 = c_bot
    for ci, ch in enumerate(txt):
        gl = FONT.get(ch, FONT.get(" "))
        for gy, line in enumerate(gl):
            for gx, bit in enumerate(line):
                if bit == "1":
                    t = gy / 6.0
                    cr, cg, cb = int(r0 + (r1 - r0) * t), int(g0 + (g1 - g0) * t), int(b0 + (b1 - b0) * t)
                    for py in range(sy):
                        for px in range(sx):
                            xx, yy = x0 + ci*(6*sx) + gx*sx + px, y0 + gy*sy + py
                            if 0 <= xx < W and 0 <= yy < H:
                                rows[yy][xx*3:xx*3+3] = bytes((cr, cg, cb))
                                if yy+2 < H and xx+2 < W:
                                    rows[yy+2][(xx+2)*3:(xx+2)*3+3] = bytes((10, 10, 25))

draw_text("AURA-3D AGA", 132, 26, 5, 6, (255, 230, 80), (235, 75, 25))
draw_text("ENGINE", 132, 82, 4, 4, (110, 235, 255), (40, 120, 230))

raw = b"".join(b"\x00" + bytes(r) for r in rows)
def ck(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
png = b"\x89PNG\r\n\x1a\n" + ck(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0)) + ck(b"IDAT", zlib.compress(raw)) + ck(b"IEND", b"")
open("docs/logo.png", "wb").write(png)
print("LOGO OK: docs/logo.png (480x136 Amiga Boing & Copper style)!")
