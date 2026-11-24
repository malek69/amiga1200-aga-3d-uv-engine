import argparse, os, shutil, struct, subprocess, zipfile

def write_whdload_info(path, tooltypes):
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

def build_profile(root, profile):
    rd = os.path.join(root, "releases")
    os.makedirs(rd, exist_ok=True)
    tmp_w = f"/tmp/_aura3d_{profile}"
    shutil.rmtree(tmp_w, ignore_errors=True)
    dd, ed = os.path.join(tmp_w, "demo_v1"), os.path.join(tmp_w, "engine")
    shutil.copytree(os.path.join(root, "demo_v1"), dd)
    shutil.copytree(os.path.join(root, "engine"), ed)
    ms_p = os.path.join(dd, "main.s")
    ms = open(ms_p).read()
    if profile == "thea1200":
        ms = ms.replace("mulu.l  #2,d0", "mulu.l  #4,d0")
    elif profile == "060":
        ms = ms.replace("    mulu.l  #2,d0\n    divu.l  #5,d0\n", "")
    open(ms_p, "w").write(ms)
    sl_p = os.path.join(ed, "whdload_slave.s")
    sl = open(sl_p).read().replace("dc.w 17,$0024", "dc.w 17,$0026")
    if profile == "060":
        sl = sl.replace("dc.l $00400000", "dc.l $00780000").replace("or.w #$0909,d0", "or.w #$0909,d0")
    open(sl_p, "w").write(sl)
    sfx = {"standard": "_020", "thea1200": "_THEA1200", "060": "_060"}[profile]
    pkg_name = f"Aura3DDemo_AGA{sfx}"
    stage = os.path.join(tmp_w, "stage")
    pkg = os.path.join(stage, pkg_name)
    os.makedirs(pkg, exist_ok=True)
    exe = os.path.join(pkg, "AURA3D_DEMO")
    slv = os.path.join(pkg, f"{pkg_name}.slave")
    cpu = "-m68060" if profile == "060" else "-m68020"
    defs = ["-DFULL_RES"] if profile in ("thea1200", "060") else []
    if profile == "060":
        defs.append("-DM68060")
    subprocess.run(["vasmm68k_mot", cpu, *defs, "-Fhunkexe", *([] if profile in ("thea1200", "060") else ["-kick1hunks"]), "-nosym", "-I.", "-I../engine", "main.s", "-o", exe], cwd=dd, check=True)
    subprocess.run(["vasmm68k_mot", cpu, *defs, "-Fhunkexe", "-nosym", "-I.", "whdload_slave.s", "-o", slv], cwd=ed, check=True)
    os.chmod(exe, 0o755)
    tt = (f"SLAVE={pkg_name}.slave", "NoMMU")
    write_whdload_info(os.path.join(pkg, f"{pkg_name}.info"), tt)
    write_whdload_info(os.path.join(stage, f"{pkg_name}.info"), tt)
    os.makedirs(os.path.join(stage, "S"), exist_ok=True)
    with open(os.path.join(stage, "S", "startup-sequence"), "w") as f:
        f.write(f"cd {pkg_name}\nAURA3D_DEMO\n")
    with open(os.path.join(pkg, "README.txt"), "w") as f:
        f.write(f"AURA-3D AGA ENGINE v1.14.4.2 [{profile}] (2026)\nEngine & Code: malek69 & Gemini AI\nMusic (.MOD): 1991-Not A Number\nExit: LMB, Joy2 Fire or ESC\n")
    lha_bin = shutil.which("lha") or "/usr/bin/lha"
    lha_path = os.path.join(rd, f"aura3d_demo_v2_AGA{sfx}.lha")
    if os.path.exists(lha_path): os.remove(lha_path)
    env = os.environ.copy()
    env["TMPDIR"] = "/tmp"
    subprocess.run((lha_bin, "ao1w=/tmp", lha_path, pkg_name, f"{pkg_name}.info", "S"), cwd=stage, env=env, check=True)
    zip_path = os.path.join(rd, f"aura3d_demo_v2_AGA{sfx}_FSUAE.zip")
    if os.path.exists(zip_path): os.remove(zip_path)
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for r_dir, dirs, files in os.walk(stage):
            dirs.sort()
            for fn in sorted(files):
                fp = os.path.join(r_dir, fn)
                zf.write(fp, os.path.relpath(fp, stage))
    shutil.rmtree(tmp_w, ignore_errors=True)
    print(f"BUILD OK [{profile}]: {lha_path} | {zip_path}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", choices=("standard", "thea1200", "060", "all"), default="all")
    args = ap.parse_args()
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    subprocess.run(("python3", os.path.join(root, "tools", "gen_recip_table.py")), cwd=root, check=True)
    subprocess.run(("python3", os.path.join(root, "tools", "gen_phong_lut.py")), cwd=root, check=True)
    profs = ("standard", "thea1200", "060") if args.profile == "all" else (args.profile,)
    for p in profs: build_profile(root, p)

if __name__ == "__main__": main()
