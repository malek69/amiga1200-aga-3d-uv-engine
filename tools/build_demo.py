import os, shutil, struct, subprocess

def write_whdload_info(path, slave_name="Aura3DDemo.slave"):
    # Standardowy plik Amiga Workbench WBPROJECT .info dla WHDLoad (wymagany przez FS-UAE i THEA1200)
    hdr = struct.pack(">HH", 0xE310, 1)
    gad = struct.pack(">IHHHH", 0, 0, 0, 32, 16) + bytes(26)
    body = struct.pack(">BBIIIIIII", 4, 0, 1, 1, 0x80000000, 0x80000000, 0, 0, 8192)
    img = struct.pack(">hhhhhIBBbI", 0, 0, 32, 16, 1, 1, 1, 0, 0, 0) + (bytes((255, 0, 255, 0)) * 16)
    dt = b"WHDLoad\x00"
    tt = slave_name.encode("ascii") + b"\x00"
    dt_blk = struct.pack(">I", len(dt)) + dt
    tt_blk = struct.pack(">II", 8, len(tt)) + tt
    open(path, "wb").write(hdr + gad + body + img + dt_blk + tt_blk)

root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
dd, ed, rd = os.path.join(root, "demo_v1"), os.path.join(root, "engine"), os.path.join(root, "releases")
pkg = os.path.join(rd, "Aura3DDemo")
shutil.rmtree(pkg, ignore_errors=True)
os.makedirs(pkg, exist_ok=True)
exe = os.path.join(pkg, "AURA3D_DEMO")
slv = os.path.join(pkg, "Aura3DDemo.slave")
inf = os.path.join(pkg, "Aura3DDemo.info")
txt = os.path.join(pkg, "README.txt")
subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "-I../engine", "main.s", "-o", exe), cwd=dd, check=True)
subprocess.run(("vasmm68k_mot", "-m68020", "-Fbin", "-nosym", "-I.", "whdload_slave.s", "-o", slv), cwd=ed, check=True)
os.chmod(exe, 0o755)
write_whdload_info(inf, "SLAVE=Aura3DDemo.slave")
open(txt, "w").write("AURA-3D AGA ENGINE v1.0 - DEMO 1.0 (2026)\nEngine & Code: malek69 & Gemini AI\n3D Scene: malek69 & Gemini AI\nMusic (.MOD): 1991-Not A Number\nExit: LMB or ESC\n")
lha_path = os.path.join(rd, "aura3d_demo_v1.lha")
if os.path.exists(lha_path): os.remove(lha_path)
subprocess.run(("/usr/bin/lha", "ao5", lha_path, "Aura3DDemo"), cwd=rd, check=True)
adf_path = os.path.join(rd, "aura3d_demo_v1.adf")
if os.path.exists(adf_path): os.remove(adf_path)
ss = os.path.join(rd, "startup-sequence")
open(ss, "w").write("AURA3D_DEMO\n")
subprocess.run(("/usr/bin/xdftool", adf_path, "format", "AURA3D_DEMO", "+", "boot", "install", "+", "makedir", "S", "+", "write", exe, "AURA3D_DEMO", "+", "protect", "AURA3D_DEMO", "+e", "+", "write", txt, "README.txt", "+", "write", ss, "S/startup-sequence"), check=True)
os.remove(ss)
print("BUILD OK (WHDLOAD .INFO + AMIGA LHA -o5 + BOOTABLE ADF):", lha_path)
