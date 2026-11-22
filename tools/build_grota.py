import glob, os, shutil, subprocess, sys
sys.path.insert(0, "tools")
import build_demo as bd
gx = open("src/gfx_engine.i").read().replace("move.l  #(FMODE<<16)|,(a0)+", "move.l  #(FMODE<<16)|$0000,(a0)+")
open("src/gfx_engine.i", "w").write(gx)
rt = open("src/realtime_3d.i").read()
first = rt.find("    even\nlead_x:")
second = rt.find("    even\nlead_x:", first + 1)
if second != -1: open("src/realtime_3d.i", "w").write(rt[:second])
mod_info = open("src/mod_credits.txt").read().strip() if os.path.exists("src/mod_credits.txt") else "Aminet Demo MOD"
sd, od = "src", "releases"
for old in glob.glob(f"{od}/*"): shutil.rmtree(old) if os.path.isdir(old) else os.remove(old)
exe = os.path.abspath(f"{od}/GROTA")
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "main.s", "-o", exe], cwd=sd, check=True)
os.chmod(exe, 0o755)
sz = os.path.getsize(exe)
em = ((sz + 0x120000 + 0xFFFF) & ~0xFFFF)
lo = em - sz - 256
pr = f"{od}/_tmp_grota"
shutil.rmtree(pr, ignore_errors=True); os.makedirs(f"{pr}/Grota", exist_ok=True)
shutil.copy2(exe, f"{pr}/Grota/GROTA")
credits = f"Code: malek69 & Gemini AI | Music: {mod_info}"[:75]
sl = open(f"{sd}/whdload_slave.s").read().replace("{EXP_MEM}", f"{em:08x}").replace("{LOAD_OFF}", f"{lo:08x}").replace("{DEMO_TITLE}", "Grota 3D v2.0 [AGA + MOD]").replace("{DEMO_CREDITS}", credits).replace("{EXE_NAME}", "GROTA")
open(f"{pr}/slave.s", "w").write(sl)
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", f"{pr}/slave.s", "-o", f"{pr}/Grota/Grota.slave"], check=True)
os.remove(f"{pr}/slave.s")
open(f"{pr}/Grota.info", "wb").write(bd.mk_ico(2))
open(f"{pr}/Grota/Grota.info", "wb").write(bd.mk_ico(4, "WHDLoad", ["SLAVE=Grota.slave", "NoMMU"]))
bd.mk_lha(f"{od}/grota.lha", pr)
shutil.rmtree(pr)
print(f"SUKCES: {exe} ({sz/1024:.1f} KB) | Paczka: releases/grota.lha ({mod_info})!", flush=True)
