import sys, os, struct

MAT_MAP = {
    "gold": (0, 32), "yellow": (0, 32), "metal": (0, 32),
    "green": (2, 64), "leaf": (2, 64), "leaves": (2, 64), "grass": (2, 64),
    "sand": (0, 96), "ground": (0, 96), "terrain": (0, 96),
    "water": (1, 128), "blue": (1, 128), "glass": (1, 128), "ice": (1, 128),
    "wood": (0, 160), "bark": (0, 160), "brown": (0, 160),
    "cyan": (1, 192), "crystal": (1, 192),
    "white": (0, 224), "snow": (0, 224), "marble": (0, 224),
}

def make_sample_obj(path):
    lines = ["o TempleMonument"]
    verts = [(-50,0,-50),(50,0,-50),(50,0,50),(-50,0,50), (-42,12,-42),(42,12,-42),(42,12,42),(-42,12,42), (-28,55,-28),(28,55,-28),(28,55,28),(-28,55,28), (0,88,0)]
    for vx, vy, vz in verts:
        lines.append(f"v {vx} {vy} {vz}")
    faces = [
        ("sand", [(1,2,3),(1,3,4)]),
        ("stone", [(1,5,6),(1,6,2),(2,6,7),(2,7,3),(3,7,8),(3,8,4),(4,8,5),(4,5,1)]),
        ("wood", [(5,9,10),(5,10,6),(6,10,11),(6,11,7),(7,11,12),(7,12,8),(8,12,9),(8,9,5)]),
        ("gold", [(9,13,10),(10,13,11),(11,13,12),(12,13,9)]),
    ]
    for mat, flist in faces:
        lines.append(f"usemtl {mat}")
        for a, b, c in flist:
            lines.append(f"f {a} {b} {c}")
    open(path, "w").write(chr(10).join(lines) + chr(10))

def convert_obj(obj_path, max_tris=260, target_r=72.0):
    verts, tris = [], []
    cur_tex, cur_bank = 0, 96
    for raw in open(obj_path, "r", errors="ignore"):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        cmd = parts[0]
        if cmd == "v" and len(parts) >= 4:
            verts.append((float(parts[1]), float(parts[2]), float(parts[3])))
        elif cmd == "usemtl" and len(parts) >= 2:
            mname = parts[1].lower()
            cur_tex, cur_bank = 0, 0
            for k, val in MAT_MAP.items():
                if k in mname:
                    cur_tex, cur_bank = val
                    break
        elif cmd == "f" and len(parts) >= 4:
            idxs = []
            for p in parts[1:]:
                vi = int(p.split("/")[0])
                idxs.append(vi - 1 if vi > 0 else len(verts) + vi)
            for k in range(1, len(idxs) - 1):
                tris.append((cur_tex, cur_bank, idxs[0], idxs[k], idxs[k+1]))
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    zs = [v[2] for v in verts]
    cx, cy, cz = (min(xs)+max(xs))*0.5, (min(ys)+max(ys))*0.5, (min(zs)+max(zs))*0.5
    max_d = max(max(xs)-min(xs), max(ys)-min(ys), max(zs)-min(zs), 0.001)
    scale = (target_r * 2.0) / max_d
    if len(tris) > max_tris:
        step = len(tris) / float(max_tris)
        tris = [tris[int(i * step)] for i in range(max_tris)]
    amiga_tris = []
    bin_blob = bytearray(struct.pack(">H", len(tris) - 1))
    for tex_id, bank, i0, i1, i2 in tris:
        p0, p1, p2 = verts[i0], verts[i1], verts[i2]
        c0 = (int((p0[0]-cx)*scale), int(-(p0[1]-cy)*scale), int((p0[2]-cz)*scale))
        c1 = (int((p1[0]-cx)*scale), int(-(p1[1]-cy)*scale), int((p1[2]-cz)*scale))
        c2 = (int((p2[0]-cx)*scale), int(-(p2[1]-cy)*scale), int((p2[2]-cz)*scale))
        vals = (tex_id, bank, c0[0], c0[1], c0[2], c1[0], c1[1], c1[2], c2[0], c2[1], c2[2])
        amiga_tris.append(vals)
        bin_blob.extend(struct.pack(">11h", *vals))
    open("src/imported_mesh.bin", "wb").write(bin_blob)
    asm = ["    even", "imported_mesh:", f"    dc.w {len(amiga_tris)-1}"]
    asm += ["    dc.w " + ",".join(str(v) for v in t) for t in amiga_tris]
    open("src/imported_mesh.i", "w").write(chr(10).join(asm) + chr(10))
    print(f"OBJ2AMIGA OK: {obj_path} -> {len(amiga_tris)} trojkatow UV (src/imported_mesh.bin + src/imported_mesh.i)")

if __name__ == "__main__":
    src_obj = sys.argv[1] if len(sys.argv) > 1 else "assets_raw/sample_temple.obj"
    if not os.path.exists(src_obj):
        make_sample_obj(src_obj)
    convert_obj(src_obj)
