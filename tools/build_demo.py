import os, subprocess, zipfile

root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
dd = os.path.join(root, "demo_v1")
ed = os.path.join(root, "engine")
rd = os.path.join(root, "releases")
os.makedirs(rd, exist_ok=True)
exe = os.path.join(rd, "AURA3D_DEMO")
slv = os.path.join(rd, "Aura3DDemo.slave")
txt = os.path.join(rd, "README.txt")
subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "-I../engine", "main.s", "-o", exe), cwd=dd, check=True)
subprocess.run(("vasmm68k_mot", "-m68020", "-Fbin", "-nosym", "-I.", "whdload_slave.s", "-o", slv), cwd=ed, check=True)
credits = "AURA-3D AGA ENGINE v1.0 - DEMO 1.0 (2026)\nEngine & M68020 Code: malek69 & Gemini AI\n3D Scene & Lighting: malek69 & Gemini AI (Base mesh: Beast / Common 3D Test Models)\nMusic (.MOD): 1991-Not A Number (ProTracker 4-ch, Aminet)\nExit: LMB or ESC\n"
open(txt, "w").write(credits)
lha_path = os.path.join(rd, "aura3d_demo_v1.lha")
with zipfile.ZipFile(lha_path, "w", zipfile.ZIP_DEFLATED) as zf:
    zf.write(exe, "Aura3DDemo/AURA3D_DEMO")
    zf.write(slv, "Aura3DDemo/Aura3DDemo.slave")
    zf.write(txt, "Aura3DDemo/README.txt")
print("BUILD OK:", lha_path)
