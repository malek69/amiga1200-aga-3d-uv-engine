import math, struct

verts, faces = list(), list()
for raw in open("assets_raw/hero_scene.obj", "r", errors="ignore"):
    s = raw.strip()
    if not s or s.startswith("#"): continue
    p = s.split()
    if len(p) >= 4 and p.pop(0) == "v":
        vx, vy, vz = float(p.pop(0)), float(p.pop(0)), float(p.pop(0))
        verts.append((vx, vy, vz))
    elif s.startswith("f "):
        parts = s.split()
        parts.pop(0)
        idxs = list()
        for item in parts:
            vi = int(item.split("/").pop(0))
            idxs.append(vi - 1 if vi > 0 else len(verts) + vi)
        i0 = idxs.pop(0)
        prev = idxs.pop(0)
        for cur in idxs:
            faces.append((i0, prev, cur))
            prev = cur

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
    v_map = tuple(v_to_cell)
    weld = {k: (int(sx/cell_cnt[k]), int(sy/cell_cnt[k]), int(sz/cell_cnt[k])) for k, (sx, sy, sz) in cell_sum.items()}
    seen, out_t = set(), list()
    v_lut = dict(enumerate(v_map))
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
    tx = 1 if (i % 2 == 0) else 0
    amiga_tris.append((tx, bk, 0,64,0, int(92*math.sin(a0)),64,int(92*math.cos(a0)), int(92*math.sin(a1)),64,int(92*math.cos(a1))))

for (x0, y0, z0), (x1, y1, z1), (x2, y2, z2) in best_tris:
    avg_y = (y0 + y1 + y2) / 3.0
    avg_r = math.hypot((x0+x1+x2)/3.0, (z0+z1+z2)/3.0)
    if avg_y < -26 or avg_r > 44:
        tex_id, bank = 0, 32
    elif avg_y > 24:
        tex_id, bank = 0, 160
    else:
        tex_id, bank = 0, 0
    amiga_tris.append((tex_id, bank, x0, y0, z0, x1, y1, z1, x2, y2, z2))

bin_blob = bytearray(struct.pack(">H", len(amiga_tris) - 1))
for t in amiga_tris:
    bin_blob.extend(struct.pack(">11h", *t))
open("src/imported_mesh.bin", "wb").write(bin_blob)
asm = ["    even", "imported_mesh:", f"    dc.w {len(amiga_tris)-1}"] + ["    dc.w " + ",".join(str(v) for v in t) for t in amiga_tris]
open("src/imported_mesh.i", "w").write(chr(10).join(asm) + chr(10))
print(f"SUKCES: Gestosc podniesiona -> {len(amiga_tris)} trojkatow UV 3D!")
