import math, struct

verts, faces = list(), list()
for raw in open("assets_raw/hero_scene.obj", "r", errors="ignore"):
    s = raw.strip()
    if not s or s.startswith("#"): continue
    p = s.split()
    if p[0] == "v" and len(p) >= 4:
        verts.append((float(p[1]), float(p[2]), float(p[3])))
    elif p[0] == "f" and len(p) >= 4:
        idxs = [int(x.split("/")[0]) - 1 if int(x.split("/")[0]) > 0 else len(verts) + int(x.split("/")[0]) for x in p[1:]]
        for k in range(1, len(idxs) - 1):
            faces.append((idxs[0], idxs[k], idxs[k+1]))

xs, ys, zs = [v[0] for v in verts], [v[1] for v in verts], [v[2] for v in verts]
cx, cy, cz = (min(xs)+max(xs))*0.5, (min(ys)+max(ys))*0.5, (min(zs)+max(zs))*0.5
scale = 156.0 / max(max(xs)-min(xs), max(ys)-min(ys), max(zs)-min(zs), 0.001)
norm_v = [((v[0]-cx)*scale, -(v[1]-cy)*scale - 6.0, -(v[2]-cz)*scale) for v in verts]

best_tris = list()
for grid in range(18, 6, -1):
    cell_sum, cell_cnt, v_to_cell = dict(), dict(), list()
    for x, y, z in norm_v:
        key = (int(round(x / grid)), int(round(y / grid)), int(round(z / grid)))
        v_to_cell.append(key)
        if key not in cell_sum:
            cell_sum[key] = [0.0, 0.0, 0.0]
            cell_cnt[key] = 0
        cell_sum[key][0] += x; cell_sum[key][1] += y; cell_sum[key][2] += z
        cell_cnt[key] += 1
    weld = {k: (int(s[0]/cell_cnt[k]), int(s[1]/cell_cnt[k]), int(s[2]/cell_cnt[k])) for k, s in cell_sum.items()}
    seen, out_t = set(), list()
    for i0, i1, i2 in faces:
        c0, c1, c2 = v_to_cell[i0], v_to_cell[i1], v_to_cell[i2]
        if c0 != c1 and c1 != c2 and c0 != c2:
            sig = tuple(sorted((c0, c1, c2)))
            if sig not in seen:
                seen.add(sig)
                out_t.append((weld[c0], weld[c1], weld[c2]))
    if len(out_t) <= 340:
        best_tris = out_t
    else:
        break

amiga_tris = list()
for i in range(16):
    a0, a1 = i * math.pi / 8.0, (i + 1) * math.pi / 8.0
    bk = 128 if (i % 2 == 0) else 96
    tx = 1 if (i % 2 == 0) else 0
    amiga_tris.append((tx, bk, 0,64,0, int(92*math.sin(a0)),64,int(92*math.cos(a0)), int(92*math.sin(a1)),64,int(92*math.cos(a1))))

for p0, p1, p2 in best_tris:
    avg_y = (p0[1] + p1[1] + p2[1]) / 3.0
    avg_r = math.hypot((p0[0]+p1[0]+p2[0])/3.0, (p0[2]+p1[2]+p2[2])/3.0)
    if avg_y < -26 or avg_r > 44:
        tex_id, bank = 0, 32
    elif avg_y > 24:
        tex_id, bank = 0, 160
    else:
        tex_id, bank = 0, 0
    amiga_tris.append((tex_id, bank, p0[0], p0[1], p0[2], p1[0], p1[1], p1[2], p2[0], p2[1], p2[2]))

bin_blob = bytearray(struct.pack(">H", len(amiga_tris) - 1))
for t in amiga_tris:
    bin_blob.extend(struct.pack(">11h", *t))
open("src/imported_mesh.bin", "wb").write(bin_blob)
asm = ["    even", "imported_mesh:", f"    dc.w {len(amiga_tris)-1}"] + ["    dc.w " + ",".join(str(v) for v in t) for t in amiga_tris]
open("src/imported_mesh.i", "w").write(chr(10).join(asm) + chr(10))
print(f"SUKCES: Zwarta rzezba 3D (Vertex Clustering -> {len(amiga_tris)} polaczonych trojkatow)!")
