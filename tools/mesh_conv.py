#!/usr/bin/env python3
import argparse
import math
import os

def normalize(vx, vy, vz):
    l = math.sqrt(vx * vx + vy * vy + vz * vz)
    if l < 1e-9:
        return (0.0, 0.0, -1.0)
    return (vx / l, vy / l, vz / l)

def generate_torus(major_r=36.0, minor_r=15.0, major_seg=16, minor_seg=12, tex_id=0):
    verts = []
    norms = []
    tris = []
    for i in range(major_seg):
        theta = (2.0 * math.pi * i) / major_seg
        ct, st = math.cos(theta), math.sin(theta)
        for j in range(minor_seg):
            phi = (2.0 * math.pi * j) / minor_seg
            cp, sp = math.cos(phi), math.sin(phi)
            r = major_r + minor_r * cp
            x = r * ct
            y = minor_r * sp
            z = r * st
            nx = cp * ct
            ny = sp
            nz = cp * st
            verts.append((int(round(x)), int(round(y)), int(round(z))))
            norms.append((int(round(nx * 255)), int(round(ny * 255)), int(round(nz * 255))))

    for i in range(major_seg):
        ni = (i + 1) % major_seg
        for j in range(minor_seg):
            nj = (j + 1) % minor_seg
            v0 = i * minor_seg + j
            v1 = ni * minor_seg + j
            v2 = ni * minor_seg + nj
            v3 = i * minor_seg + nj
            tris.append((v0, v2, v1, tex_id))
            tris.append((v0, v3, v2, tex_id))
    return verts, norms, tris

def load_obj(path, radius=52.0, tex_id=0):
    raw_v = []
    tris = []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            parts = line.strip().split()
            if not parts or parts[0].startswith("#"):
                continue
            if parts[0] == "v" and len(parts) >= 4:
                raw_v.append((float(parts[1]), float(parts[2]), float(parts[3])))
            elif parts[0] == "f" and len(parts) >= 4:
                idxs = [int(p.split("/")[0]) - 1 for p in parts[1:]]
                for k in range(1, len(idxs) - 1):
                    tris.append((idxs[0], idxs[k], idxs[k + 1], tex_id))

    if not raw_v:
        raise ValueError("Plik OBJ nie zawiera wierzcholkow.")

    cx = sum(v[0] for v in raw_v) / len(raw_v)
    cy = sum(v[1] for v in raw_v) / len(raw_v)
    cz = sum(v[2] for v in raw_v) / len(raw_v)
    centered = [(v[0] - cx, v[1] - cy, v[2] - cz) for v in raw_v]
    max_r = max(math.sqrt(v[0]**2 + v[1]**2 + v[2]**2) for v in centered) or 1.0
    scale = radius / max_r

    verts = [(int(round(v[0] * scale)), int(round(v[1] * scale)), int(round(v[2] * scale))) for v in centered]
    acc_n = [[0.0, 0.0, 0.0] for _ in verts]

    for i0, i1, i2, _ in tris:
        x0, y0, z0 = centered[i0]
        x1, y1, z1 = centered[i1]
        x2, y2, z2 = centered[i2]
        ux, uy, uz = x1 - x0, y1 - y0, z1 - z0
        vx, vy, vz = x2 - x0, y2 - y0, z2 - z0
        nx = uy * vz - uz * vy
        ny = uz * vx - ux * vz
        nz = ux * vy - uy * vx
        for idx in (i0, i1, i2):
            acc_n[idx][0] += nx
            acc_n[idx][1] += ny
            acc_n[idx][2] += nz

    norms = []
    for nx, ny, nz in acc_n:
        ux, uy, uz = normalize(nx, ny, nz)
        norms.append((int(round(ux * 255)), int(round(uy * 255)), int(round(uz * 255))))

    return verts, norms, tris

def write_asm_include(out_path, prefix, verts, norms, tris):
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(f"; Wygenerowano przez tools/mesh_conv.py ({len(verts)} verts, {len(tris)} tris)\n")
        f.write("    even\n")
        f.write(f"{prefix}_vert_count equ {len(verts)}\n\n")
        f.write(f"{prefix}_verts:\n")
        for x, y, z in verts:
            f.write(f"    dc.w    {x},{y},{z}\n")
        f.write(f"\n{prefix}_norms:\n")
        for nx, ny, nz in norms:
            f.write(f"    dc.w    {nx},{ny},{nz}\n")
        f.write(f"\n{prefix}_env_mesh:\n")
        f.write(f"    dc.w    {len(tris)}\n")
        for i0, i1, i2, tid in tris:
            f.write(f"    dc.w    {i0},{i1},{i2},{tid}\n")

def main():
    ap = argparse.ArgumentParser(description="Konwerter OBJ / generator brył 3D dla AURA-3D v2.0")
    ap.add_argument("--obj", help="Sciezka do pliku Wavefront .obj")
    ap.add_argument("--preset", default="torus", choices=["torus"], help="Preset proceduralny")
    ap.add_argument("--prefix", default="torus3d", help="Prefiks etykiet w asemblerze")
    ap.add_argument("--out", default="demo_v1/torus_mesh.i", help="Plik wyjsciowy .i")
    ap.add_argument("--radius", type=float, default=52.0, help="Docelowy promien obiektu")
    ap.add_argument("--tex", type=int, default=0, help="ID tekstury (0..N)")
    args = ap.parse_args()

    if args.obj:
        verts, norms, tris = load_obj(args.obj, radius=args.radius, tex_id=args.tex)
    else:
        verts, norms, tris = generate_torus(tex_id=args.tex)

    if len(verts) > 512:
        raise ValueError(f"Za duzo wierzcholkow ({len(verts)} > 512 limit bufora v2_proj_buf).")

    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    write_asm_include(args.out, args.prefix, verts, norms, tris)
    print(f"OK: {args.out} -> {len(verts)} wierzcholkow, {len(tris)} trojkatow")

if __name__ == "__main__":
    main()
