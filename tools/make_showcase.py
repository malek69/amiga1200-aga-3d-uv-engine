import math, struct

# 1. Wysokokontrastowa paleta 24-bit AGA (wyrazne cienie -> nasycone poltony -> jasne blyski specular)
grads = (
    ((18, 24, 48), (195, 215, 255)),   # Bank 0 (0..31): Polerowana stal / srebro-blekit
    ((45, 22, 4), (255, 238, 130)),    # Bank 1 (32..63): Krolewskie zloto
    ((10, 42, 24), (140, 255, 165)),   # Bank 2 (64..95): Szmaragd
    ((42, 24, 10), (245, 195, 115)),   # Bank 3 (96..127): Piaskowiec / mosiadz
    ((10, 38, 82), (165, 245, 255)),   # Bank 4 (128..159): Blekitna woda / szklo
    ((38, 16, 6), (225, 135, 65)),     # Bank 5 (160..191): Patynowany braz
    ((8, 48, 62), (150, 255, 250)),    # Bank 6 (192..223): Turkusowy rim-light
    ((150, 190, 230), (255, 255, 255)) # Bank 7 (224..255): Gwiazdy i blyski
)
pal = bytearray()
for (r0, g0, b0), (r1, g1, b1) in grads:
    for i in range(32):
        t = (i / 31.0) ** 0.85
        pal.extend(struct.pack(">BBBB", 0, int(r0+(r1-r0)*t), int(g0+(g1-g0)*t), int(b0+(b1-b0)*t)))
open("src/pal256.bin", "wb").write(pal)

# 2. Gladkie tekstury UV 64x64 (U = kat swiatla 0..63, V = delikatny marmur/metal -> brak szumu!)
tex = bytearray()
for tid in range(4):
    for y in range(64):
        for x in range(64):
            base = 3 + int((x / 63.0) * 26)
            vein = int(2.5 * math.sin(y * 0.22 + math.sin(x * 0.12) * 1.5))
            tex.append(max(2, min(31, base + vein)))
open("src/uv_textures.bin", "wb").write(tex)

# 3. Konwersja beast.obj z prawdziwym cieniowaniem od normalnych 3D (N dot L)
verts, faces = list(), list()
for raw in open("assets_raw/hero_scene.obj", "r", errors="ignore"):
    s = raw.strip()
    if not s or s.startswith("#"): continue
    p = s.split()
    if len(p) >= 4 and p.pop(0) == "v":
        verts.append((float(p.pop(0)), float(p.pop(0)), float(p.pop(0))))
    elif s.startswith("f "):
        parts = s.split(); parts.pop(0)
        idxs = [int(it.split("/").pop(0)) - 1 for it in parts]
        i0 = idxs.pop(0); prev = idxs.pop(0)
        for cur in idxs:
            faces.append((i0, prev, cur)); prev = cur

xs = tuple(x for x, y, z in verts)
ys = tuple(y for x, y, z in verts)
zs = tuple(z for x, y, z in verts)
cx, cy, cz = (min(xs)+max(xs))*0.5, (min(ys)+max(ys))*0.5, (min(zs)+max(zs))*0.5
scale = 158.0 / max(max(xs)-min(xs), max(ys)-min(ys), max(zs)-min(zs), 0.001)
norm_v = tuple(((x-cx)*scale, -(y-cy)*scale - 6.0, -(z-cz)*scale) for x, y, z in verts)

best_tris = list()
for grid in (14.0, 12.0, 10.0, 8.5, 7.2, 6.2, 5.4, 4.8):
    cell_sum, cell_cnt, v_to_cell = dict(), dict(), list()
    for x, y, z in norm_v:
        key = (int(round(x / grid)), int(round(y / grid)), int(round(z / grid)))
        v_to_cell.append(key)
        sx, sy, sz = cell_sum.get(key, (0.0, 0.0, 0.0))
        cell_sum[key] = (sx + x, sy + y, sz + z)
        cell_cnt[key] = cell_cnt.get(key, 0) + 1
    v_lut = dict(enumerate(v_to_cell))
    weld = {k: (int(sx/cell_cnt[k]), int(sy/cell_cnt[k]), int(sz/cell_cnt[k])) for k, (sx, sy, sz) in cell_sum.items()}
    seen, out_t = set(), list()
    for i0, i1, i2 in faces:
        c0, c1, c2 = v_lut[i0], v_lut[i1], v_lut[i2]
        if c0 != c1 and c1 != c2 and c0 != c2:
            sig = tuple(sorted((c0, c1, c2)))
            if sig not in seen:
                seen.add(sig)
                out_t.append((weld[c0], weld[c1], weld[c2]))
    if len(out_t) <= 880:
        best_tris = out_t
    else:
        break

amiga_tris = list()
for i in range(16):
    a0, a1 = i * math.pi / 8.0, (i + 1) * math.pi / 8.0
    bk = 128 if (i % 2 == 0) else 96
    amiga_tris.append((0, bk, 0,64,0, int(92*math.sin(a0)),64,int(92*math.cos(a0)), int(92*math.sin(a1)),64,int(92*math.cos(a1))))

for (x0, y0, z0), (x1, y1, z1), (x2, y2, z2) in best_tris:
    ux, uy, uz = x1 - x0, y1 - y0, z1 - z0
    vx, vy, vz = x2 - x0, y2 - y0, z2 - z0
    nx, ny, nz = uy*vz - uz*vy, uz*vx - ux*vz, ux*vy - uy*vx
    nl = math.hypot(nx, math.hypot(ny, nz)) or 1.0
    nx, ny, nz = nx / nl, ny / nl, nz / nl
    # Kierunek swiatla (gorny przod-prawo) -> jasnosc 0..63 zakodowana w wspolrzednej U!
    ndotl = max(0.0, nx * 0.55 - ny * 0.65 - nz * 0.52)
    rim = max(0.0, -nx * 0.85 - ny * 0.25)
    shade_u = min(63, max(4, int(10 + ndotl * 53)))
    avg_y = (y0 + y1 + y2) / 3.0
    if rim > 0.62:
        bank = 192  # Chlodny turkusowy kontur rim-light!
    elif avg_y < -22:
        bank = 32   # Zlote barki, rogi i glowa
    elif avg_y > 22:
        bank = 160  # Patynowany braz
    else:
        bank = 0    # Polerowana stal / srebro-blekit
    # Przechowujemy shade_u w gornych bitach banku (bank | (shade_u << 8))!
    amiga_tris.append((0, bank | (shade_u << 8), x0, y0, z0, x1, y1, z1, x2, y2, z2))

bin_blob = bytearray(struct.pack(">H", len(amiga_tris) - 1))
for t in amiga_tris:
    bin_blob.extend(struct.pack(">11h", *t))
open("src/imported_mesh.bin", "wb").write(bin_blob)
asm = ["    even", "imported_mesh:", f"    dc.w {len(amiga_tris)-1}"] + ["    dc.w " + ",".join(str(v) for v in t) for t in amiga_tris]
open("src/imported_mesh.i", "w").write(chr(10).join(asm) + chr(10))
print(f"SHOWCASE OK: {len(amiga_tris)} trojkatow z cieniowaniem normalnych 3D + 3-punktowe swiatlo!")
