import os, struct

ASSETS = [
    ("PAL256  ", "src/pal256.bin"),
    ("UVTEX64 ", "src/uv_textures.bin"),
    ("TUNLUT  ", "src/tunnel_lut.bin"),
    ("MESH3D  ", "src/imported_mesh.bin"),
]

def build_pak(out_path="src/grotto_assets.pak"):
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
