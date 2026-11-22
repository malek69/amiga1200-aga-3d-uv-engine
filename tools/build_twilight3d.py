import os, random, shutil, subprocess, sys
sys.path.insert(0, "tools")
import build_demo as bd
twilight = [0x0001,0x0001,0x0112,0x0112,0x0113,0x0223,0x0224,0x0234,0x0335,0x0345,0x0446,0x0456,0x0557,0x0567,0x0456,0x0345,0x0334,0x0223,0x0223,0x0112,0x0112,0x0112,0x0112,0x0011,0x0011,0x0001,0x0001,0x0001,0x0001,0x0000,0x0000,0x0000]
rng = random.Random(202699)
seeds = [f"    dc.w {rng.randint(0,255)},{rng.randint(6,38)},{rng.randint(0,255)}" for _ in range(64)]
rt = open("src/realtime_3d.i").read()
idx = rt.find("    even\norb_x:")
if idx != -1: rt = rt[:idx]
tail = "\n    even\norb_x:    dc.w 0\norb_y:    dc.w 0\norb_z:    dc.w 200\norb_sx:   dc.w 160\norb_sy:   dc.w 122\ncur_px:   dc.w 0\ncur_pz:   dc.w 100\np_sx1:    dc.w 0\np_sx2:    dc.w 0\np_sy1:    dc.w 0\np_sy2:    dc.w 0\ntri_ymin: dc.w 0\ntri_ymax: dc.w 0\ntwilight_grad:\n    dc.w " + ",".join(f"${c:04x}" for c in twilight) + "\nsphere_seeds:\n" + "\n".join(seeds) + "\nvec_frame_count: dc.w 1\n    even\nvec_frame_table: dc.l 0\n"
open("src/realtime_3d.i", "w").write(rt + tail)
mod_info = open("src/mod_credits.txt").read().strip() if os.path.exists("src/mod_credits.txt") else "Aminet Demo MOD"
sd, od = "src", "releases"
exe = os.path.abspath(f"{od}/TWILIGHT3D_A1200")
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "main.s", "-o", exe], cwd=sd, check=True)
os.chmod(exe, 0o755)
sz = os.path.getsize(exe)
em = ((sz + 0x120000 + 0xFFFF) & ~0xFFFF)
lo = em - sz - 256
pr = f"{od}/_tmp_tw"
shutil.rmtree(pr, ignore_errors=True); os.makedirs(f"{pr}/TwilightFireflies3D", exist_ok=True)
shutil.copy2(exe, f"{pr}/TwilightFireflies3D/TWILIGHT3D_A1200")
credits = f"Code: malek69 & Gemini AI | Music: {mod_info}"[:75]
sl = open(f"{sd}/whdload_slave.s").read().replace("{EXP_MEM}", f"{em:08x}").replace("{LOAD_OFF}", f"{lo:08x}").replace("{DEMO_TITLE}", "Twilight Fireflies 3D v2.0 [AGA + MOD]").replace("{DEMO_CREDITS}", credits).replace("{EXE_NAME}", "TWILIGHT3D_A1200")
open(f"{pr}/slave.s", "w").write(sl)
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", f"{pr}/slave.s", "-o", f"{pr}/TwilightFireflies3D/Twilight3D.slave"], check=True)
os.remove(f"{pr}/slave.s")
open(f"{pr}/TwilightFireflies3D.info", "wb").write(bd.mk_ico(2))
open(f"{pr}/TwilightFireflies3D/TwilightFireflies3D.info", "wb").write(bd.mk_ico(4, "WHDLoad", ["SLAVE=Twilight3D.slave", "NoMMU"]))
if os.path.exists(f"{od}/TwilightFireflies3D_A1200_v2.lha"): os.remove(f"{od}/TwilightFireflies3D_A1200_v2.lha")
bd.mk_lha(f"{od}/TwilightFireflies3D_A1200_v2.lha", pr)
shutil.rmtree(pr)
print(f"SUKCES: {exe} ({sz/1024:.1f} KB) | Przelot kamery 3D w polmroku + Kula Swietlikow + {mod_info}!", flush=True)
