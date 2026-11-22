import os, subprocess, zipfile

root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
dd = os.path.join(root, "demo_v1")
ed = os.path.join(root, "engine")
rd = os.path.join(root, "releases")
os.makedirs(rd, exist_ok=True)
exe = os.path.join(rd, "AURA3D_DEMO")
slv = os.path.join(rd, "Aura3DDemo.slave")
subprocess.run(("vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "-I../engine", "main.s", "-o", exe), cwd=dd, check=True)
subprocess.run(("vasmm68k_mot", "-m68020", "-Fbin", "-nosym", "-I.", "whdload_slave.s", "-o", slv), cwd=ed, check=True)
lha_path = os.path.join(rd, "aura3d_demo_v1.lha")
with zipfile.ZipFile(lha_path, "w", zipfile.ZIP_DEFLATED) as zf:
    zf.write(exe, "Aura3DDemo/AURA3D_DEMO")
    zf.write(slv, "Aura3DDemo/Aura3DDemo.slave")
print("BUILD OK:", lha_path)
