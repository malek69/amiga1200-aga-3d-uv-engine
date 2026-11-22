import os, struct

ASSETS = [
    ("PAL256  ", "demo_v1/pal256.bin"),
    ("UVTEX64 ", "demo_v1/uv_textures.bin"),
    ("TUNLUT  ", "demo_v1/tunnel_lut.bin"),
    ("MESH3D  ", "demo_v1/imported_mesh.bin"),
]

def build_pak(out_path="demo_v1/grotto_assets.pak"):
    blobs = list()
    for tag, path in ASSETS:
        data = open(path, "rb").read()
        blobs.append((tag.encode("ascii"), data))
    header_size = 8 + len(blobs) * 16
    offset = header_size
    toc = bytearray()
    payload = bytearray()
    for tag_b, data in blobs:
        toc.extend(tag_b)
        toc.extend(struct.pack(">II", offset, len(data)))
        payload.extend(data)
        offset += len(data)
    header = b"PAK0" + struct.pack(">I", len(blobs))
    open(out_path, "wb").write(header + toc + payload)
    print(f"PAK0 OK: {out_path} ({offset} B, {len(blobs)} sekcji)")

if __name__ == "__main__":
    build_pak()
