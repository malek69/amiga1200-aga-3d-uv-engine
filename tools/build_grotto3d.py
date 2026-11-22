import os, shutil, subprocess, sys
sys.path.insert(0, "tools")
import build_demo as bd
gx = open("src/gfx_engine.i").read()
s_idx = gx.find("    move.l  #($01a2<<16)|$02e6,(a0)+")
e_idx = gx.find("    move.l  a0,cop_sky_ptr")
if s_idx != -1 and e_idx != -1:
    gx = gx[:s_idx] + gx[e_idx:]
gx = gx.replace("move.w  #$83ef,DMACON(a5)", "move.w  #$83cf,DMACON(a5)")
open("src/gfx_engine.i", "w").write(gx)
ap = open("src/pt_player.i").read()
ap = ap.replace("    bsr.w   update_eq_sprite\n", "")
open("src/pt_player.i", "w").write(ap)
mod_info = open("src/mod_credits.txt").read().strip() if os.path.exists("src/mod_credits.txt") else "1991-NOT A NUMBER (Aminet)"
sd, od = "src", "releases"
exe = os.path.abspath(f"{od}/GROTTO3D")
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "main.s", "-o", exe], cwd=sd, check=True)
os.chmod(exe, 0o755)
sz = os.path.getsize(exe)
em = ((sz + 0x120000 + 0xFFFF) & ~0xFFFF)
lo = em - sz - 256
pr = f"{od}/_tmp_grotto3d"
shutil.rmtree(pr, ignore_errors=True); os.makedirs(f"{pr}/Grotto3D", exist_ok=True)
shutil.copy2(exe, f"{pr}/Grotto3D/GROTTO3D")
credits = f"Code: malek69 & Gemini AI | Music: {mod_info}"[:75]
sl = open(f"{sd}/whdload_slave.s").read().replace("{EXP_MEM}", f"{em:08x}").replace("{LOAD_OFF}", f"{lo:08x}").replace("{DEMO_TITLE}", "Grotto 3D v2.0 [AGA + MOD]").replace("{DEMO_CREDITS}", credits).replace("{EXE_NAME}", "GROTTO3D")
open(f"{pr}/slave.s", "w").write(sl)
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", f"{pr}/slave.s", "-o", f"{pr}/Grotto3D/Grotto3D.slave"], check=True)
os.remove(f"{pr}/slave.s")
open(f"{pr}/Grotto3D.info", "wb").write(bd.mk_ico(2))
open(f"{pr}/Grotto3D/Grotto3D.info", "wb").write(bd.mk_ico(4, "WHDLoad", ["SLAVE=Grotto3D.slave", "NoMMU"]))
if os.path.exists(f"{od}/grotto3d.lha"): os.remove(f"{od}/grotto3d.lha")
bd.mk_lha(f"{od}/grotto3d.lha", pr)
shutil.rmtree(pr)
print(f"SUKCES: {exe} ({sz/1024:.1f} KB) | Paczka: releases/grotto3d.lha ({mod_info})!", flush=True)
