import os, shutil, struct, subprocess

def write_whdload_info(path, tooltypes=("SLAVE=Aura3DDemo.slave",)):
    # Standardowy plik Amiga Workbench WBPROJECT .info dla WHDLoad (PUAE / THEA1200 / FS-UAE)
    hdr = struct.pack(">HH", 0xE310, 1)
    gad = struct.pack(">IHHHH", 0, 0, 0, 32, 16) + bytes(26)
    body = struct.pack(">BBIIIIIII", 4, 0, 1, 1, 0x80000000, 0x80000000, 0, 0, 8192)
    img = struct.pack(">hhhhhIBBbI", 0, 0, 32, 16, 1, 1, 1, 0, 0, 0) + (bytes((255, 0, 255, 0)) * 16)
    dt = b"WHDLoad\x00"
    if len(dt) % 2:
        dt += b"\x00"
    dt_blk = struct.pack(">I", len(dt)) + dt

    tt_entries = b""
    for entry in tooltypes:
        raw = entry.encode("ascii") + b"\x00"
        if len(raw) % 2:
            raw += b"\x00"
        tt_entries += struct.pack(">I", len(raw)) + raw
    tt_blk = struct.pack(">I", (len(tooltypes) + 1) * 4) + tt_entries

    with open(path, "wb") as f:
        f.write(hdr + gad + body + img + dt_blk + tt_blk)

root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
dd, ed, rd = os.path.join(root, "demo_v1"), os.path.join(root, "engine"), os.path.join(root, "releases")

pkg_name = "Aura3DDemo_AGA"
pkg = os.path.join(rd, pkg_name)
top_inf = os.path.join(rd, f"{pkg_name}.info")

shutil.rmtree(pkg, ignore_errors=True)
if os.path.exists(top_inf):
    os.remove(top_inf)
os.makedirs(pkg, exist_ok=True)

exe = os.path.join(pkg, "AURA3D_DEMO")
slv = os.path.join(pkg, "Aura3DDemo.slave")
inner_inf = os.path.join(pkg, "Aura3DDemo.info")
txt = os.path.join(pkg, "README.txt")

subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "-I../engine", "main.s", "-o", exe), cwd=dd, check=True)
subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", "-I.", "whdload_slave.s", "-o", slv), cwd=ed, check=True)
os.chmod(exe, 0o755)

# Ikona wewnątrz katalogu oraz ikona nadrzędna obok katalogu (wymagana przez PUAE / THEA1200)
write_whdload_info(inner_inf, ("SLAVE=Aura3DDemo.slave",))
write_whdload_info(top_inf, ("SLAVE=Aura3DDemo.slave",))

with open(txt, "w") as f:
    f.write("AURA-3D AGA ENGINE v1.0 - DEMO 1.0 (2026)\nEngine & Code: malek69 & Gemini AI\n3D Scene: malek69 & Gemini AI\nMusic (.MOD): 1991-Not A Number\nExit: LMB or ESC\n")

lha_path = os.path.join(rd, "aura3d_demo_v1_AGA.lha")
if os.path.exists(lha_path):
    os.remove(lha_path)
subprocess.run(("/usr/bin/lha", "ao5", lha_path, pkg_name, f"{pkg_name}.info"), cwd=rd, check=True)

adf_path = os.path.join(rd, "aura3d_demo_v1_AGA.adf")
if os.path.exists(adf_path):
    os.remove(adf_path)
ss = os.path.join(rd, "startup-sequence")
with open(ss, "w") as f:
    f.write("AURA3D_DEMO\n")
subprocess.run(("/usr/bin/xdftool", adf_path, "format", "AURA3D_DEMO", "+", "boot", "install", "+", "makedir", "S", "+", "write", exe, "AURA3D_DEMO", "+", "protect", "AURA3D_DEMO", "+e", "+", "write", txt, "README.txt", "+", "write", ss, "S/startup-sequence"), check=True)
os.remove(ss)

print("BUILD OK (PUAE/THEA1200 WHDLOAD .INFO + AMIGA LHA -o5 + BOOTABLE ADF):", lha_path)
