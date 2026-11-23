import os, shutil, struct, subprocess, zipfile

def write_whdload_info(path, tooltypes=("SLAVE=Aura3DDemo_AGA.slave",)):
    hdr = struct.pack(">HH", 0xE310, 1)
    gad = struct.pack(">IhhhhHHHIIIIIHI", 0, 0, 0, 32, 16, 4, 3, 1, 1, 0, 0, 0, 0, 0, 0)
    body = struct.pack(">BBIIIIIII", 4, 0, 1, 1, 0x80000000, 0x80000000, 0, 0, 8192)
    img = struct.pack(">hhhhhIBBI", 0, 0, 32, 16, 1, 1, 1, 0, 0) + (bytes((255, 0, 255, 0)) * 16)
    dt = b"WHDLoad\x00"
    dt_blk = struct.pack(">I", len(dt)) + dt
    tt_entries = b"".join(struct.pack(">I", len(e) + 1) + e.encode("ascii") + b"\x00" for e in tooltypes)
    tt_blk = struct.pack(">I", (len(tooltypes) + 1) * 4) + tt_entries
    with open(path, "wb") as f:
        f.write(hdr + gad + body + img + dt_blk + tt_blk)

root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
subprocess.run(("python3", os.path.join(root, "tools", "gen_recip_table.py")), cwd=root, check=True)
subprocess.run(("python3", os.path.join(root, "tools", "gen_phong_lut.py")), cwd=root, check=True)
dd, ed, rd = os.path.join(root, "demo_v1"), os.path.join(root, "engine"), os.path.join(root, "releases")
os.makedirs(rd, exist_ok=True)

pkg_name = "Aura3DDemo_AGA"
pkg = os.path.join(rd, pkg_name)
top_inf = os.path.join(rd, f"{pkg_name}.info")
shutil.rmtree(pkg, ignore_errors=True)
if os.path.exists(top_inf): os.remove(top_inf)
os.makedirs(pkg, exist_ok=True)

exe = os.path.join(pkg, "AURA3D_DEMO")
slv = os.path.join(pkg, "Aura3DDemo_AGA.slave")
inner_inf = os.path.join(pkg, "Aura3DDemo_AGA.info")
txt = os.path.join(pkg, "README.txt")

subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "-I../engine", "main.s", "-o", exe), cwd=dd, check=True)
subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", "-I.", "whdload_slave.s", "-o", slv), cwd=ed, check=True)
os.chmod(exe, 0o755)

write_whdload_info(inner_inf, ("SLAVE=Aura3DDemo_AGA.slave",))
write_whdload_info(top_inf, ("SLAVE=Aura3DDemo_AGA.slave",))

with open(txt, "w") as f:
    f.write("AURA-3D AGA ENGINE v1.14.3 (2026)\nEngine & Code: malek69 & Gemini AI\nMusic (.MOD): 1991-Not A Number\nExit: LMB or ESC\n")

lha_bin = shutil.which("lha") or "/usr/bin/lha"
lha_path = os.path.join(rd, "aura3d_demo_v2_AGA.lha")
if os.path.exists(lha_path): os.remove(lha_path)
env = os.environ.copy()
env["TMPDIR"] = os.environ.get("TMPDIR", "/tmp")
subprocess.run((lha_bin, f"ao1w=/tmp", lha_path, pkg_name, f"{pkg_name}.info"), cwd=rd, env=env, check=True)

zip_path = os.path.join(rd, "aura3d_demo_v2_AGA_FSUAE.zip")
if os.path.exists(zip_path): os.remove(zip_path)
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    zf.writestr("S/startup-sequence", f"cd {pkg_name}" + chr(10) + "AURA3D_DEMO" + chr(10))
    for fn in sorted(os.listdir(pkg)):
        zf.write(os.path.join(pkg, fn), os.path.join(pkg_name, fn))
    zf.write(top_inf, f"{pkg_name}.info")

xdftool_bin = shutil.which("xdftool")
if xdftool_bin:
    adf_path = os.path.join(rd, "aura3d_demo_v2_AGA.adf")
    if os.path.exists(adf_path): os.remove(adf_path)
    ss = os.path.join(rd, "startup-sequence")
    with open(ss, "w") as f:
        f.write("AURA3D_DEMO\n")
    subprocess.run((xdftool_bin, adf_path, "format", "AURA3D_DEMO", "+", "boot", "install", "+", "makedir", "S", "+", "write", exe, "AURA3D_DEMO", "+", "protect", "AURA3D_DEMO", "+rwed", "+", "write", txt, "README.txt", "+", "write", ss, "S/startup-sequence"), check=True)
    os.remove(ss)

print("BUILD OK:", lha_path, "|", zip_path)
