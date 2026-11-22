#!/usr/bin/env python3
import sys

def convert_obj(obj_path, out_path, scale=50.0, z_offset=250, tex_id=0, lit_id=0):
    verts, faces = [], []
    for line in open(obj_path):
        p = line.strip().split()
        if not p: continue
        if p[0] == "v":
            verts.append((int(float(p[1])*scale), int(-float(p[2])*scale), int(float(p[3])*scale + z_offset)))
        elif p[0] == "f":
            idx = [int(x.split("/")[0]) - 1 for x in p[1:]]
            for i in range(1, len(idx) - 1):
                faces.append((idx[0], idx[i], idx[i+1]))
    out = [f"; Blender OBJ -> Amiga 1200 3D Mesh ({len(faces)} triangles)", f"    dc.w {len(faces)-1}"]
    for a, b, c in faces:
        v0, v1, v2 = verts[a], verts[b], verts[c]
        out.append(f"    dc.w {tex_id},{lit_id}, {v0[0]},{v0[1]},{v0[2]}, {v1[0]},{v1[1]},{v1[2]}, {v2[0]},{v2[1]},{v2[2]}")
    open(out_path, "w").write("
".join(out) + "
")
    print(f"OK: {obj_path} -> {out_path} ({len(faces)} trojkatow 3D)")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uzycie: python3 tools/obj2amiga.py model.obj src/model_mesh.i [skala] [z_offset] [tex_id] [lit_id]")
    else:
        convert_obj(sys.argv[1], sys.argv[2], *(float(x) if i==0 else int(x) for i, x in enumerate(sys.argv[3:])))
