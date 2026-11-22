import os, random, re, shutil, subprocess, sys
sys.path.insert(0, "tools")
import build_demo as bd
grotto_grad = [0x0001,0x0001,0x0011,0x0012,0x0112,0x0112,0x0123,0x0123,0x0123,0x0112,0x0112,0x0012,0x0011,0x0011,0x0001,0x0001,0x0011,0x0012,0x0123,0x0134,0x0135,0x0146,0x0135,0x0124,0x0023,0x0012,0x0012,0x0011,0x0001,0x0001,0x0000,0x0000]
rng = random.Random(7788)
mist_s = [f"    dc.w {rng.randint(-120,120)},{rng.randint(0,63)}" for _ in range(60)]
geo = """    even\nlead_x: dc.w 0\nlead_y: dc.w 16\ncam_x:  dc.w 0\nff1_x:  dc.w 0\nff1_y:  dc.w 0\nff1_z:  dc.w 220\nff2_x:  dc.w 0\nff2_y:  dc.w 0\nff2_z:  dc.w 280\ncur_px: dc.w 0\ncur_pz: dc.w 100\np_sx1:  dc.w 0\np_sx2:  dc.w 0\np_sy1:  dc.w 0\np_sy2:  dc.w 0\ntri_ymin: dc.w 0\ntri_ymax: dc.w 0\n"""
geo += "grotto_grad:\n    dc.w " + ",".join(f"${c:04x}" for c in grotto_grad) + "\n"
geo += """rusalka_bitmap:\n    dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60\ngrotto_walls:\n    dc.w -180,-120,260, -85,-120,260, -115,52,260\n    dc.w -180,-120,260, -115,52,260, -180,52,260\n    dc.w 95,-120,260, 180,-120,260, 120,52,260\n    dc.w 180,-120,260, 180,52,260, 120,52,260\n    dc.w -95,-120,260, -55,-120,260, -75,-65,260\n    dc.w 45,-120,260, 88,-120,260, 66,-70,260\nlake_poly:\n    dc.w -155,48,220, 155,48,220, 165,86,330\n    dc.w -155,48,220, 165,86,330, -165,86,330\nthin_waterfall:\n    dc.w 78,-55,275, 86,-55,275, 88,48,275\n    dc.w 78,-55,275, 88,48,275, 76,48,275\nisland_and_tree_b1:\n    dc.w -52,48,250, 52,48,250, 38,38,250\n    dc.w -52,48,250, 38,38,250, -38,38,250\n    dc.w -4,40,250, 5,40,250, 3,-18,250\n    dc.w -4,40,250, 3,-18,250, -3,-18,250\ntree_crown_glow:\n    dc.w -48,-12,250, 48,-12,250, 0,-56,250\n    dc.w -36,-28,250, 36,-28,250, 0,-68,250\n"""
geo += "mist_seeds:\n" + "\n".join(mist_s) + "\nvec_frame_count: dc.w 1\n    even\nvec_frame_table: dc.l 0\n"
with open("src/realtime_3d.i", "a") as f: f.write(geo)
mod_info = open("src/mod_credits.txt").read().strip() if os.path.exists("src/mod_credits.txt") else "Aminet Demo MOD"
dg = open("src/demo_gfx.i").read()
sc = f"   *** GROTTO OF THE RUSALKA 3D V2.0 *** STORY: FOLLOW THE FIREFLY THROUGH THE TUNNEL INTO THE MOONLIT GROTTO WITH LAKE, ISLAND TREE, RUSALKA & 2 COLORFUL FIREFLIES *** MUSIC: {mod_info.upper()} VIA AMINET *** CODE: MALEK69 & GEMINI AI ***   "
dg = re.sub(r"scroll_text: dc\.b \"[^\"]+\"", f"scroll_text: dc.b \"{sc}\"", dg)
open("src/demo_gfx.i", "w").write(dg)
sd, od = "src", "releases"
exe = os.path.abspath(f"{od}/GROTTO3D_A1200")
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "main.s", "-o", exe], cwd=sd, check=True)
os.chmod(exe, 0o755)
sz = os.path.getsize(exe)
em = ((sz + 0x120000 + 0xFFFF) & ~0xFFFF)
lo = em - sz - 256
pr = f"{od}/_tmp_gr"
shutil.rmtree(pr, ignore_errors=True); os.makedirs(f"{pr}/GrottoRusalka3D", exist_ok=True)
shutil.copy2(exe, f"{pr}/GrottoRusalka3D/GROTTO3D_A1200")
credits = f"Code: malek69 & Gemini AI | Music: {mod_info}"[:75]
sl = open(f"{sd}/whdload_slave.s").read().replace("{EXP_MEM}", f"{em:08x}").replace("{LOAD_OFF}", f"{lo:08x}").replace("{DEMO_TITLE}", "Grotto of the Rusalka 3D v2.0 [AGA + MOD]").replace("{DEMO_CREDITS}", credits).replace("{EXE_NAME}", "GROTTO3D_A1200")
open(f"{pr}/slave.s", "w").write(sl)
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", f"{pr}/slave.s", "-o", f"{pr}/GrottoRusalka3D/Grotto3D.slave"], check=True)
os.remove(f"{pr}/slave.s")
open(f"{pr}/GrottoRusalka3D.info", "wb").write(bd.mk_ico(2))
open(f"{pr}/GrottoRusalka3D/GrottoRusalka3D.info", "wb").write(bd.mk_ico(4, "WHDLoad", ["SLAVE=Grotto3D.slave", "NoMMU"]))
if os.path.exists(f"{od}/GrottoRusalka3D_A1200_v2.lha"): os.remove(f"{od}/GrottoRusalka3D_A1200_v2.lha")
bd.mk_lha(f"{od}/GrottoRusalka3D_A1200_v2.lha", pr)
shutil.rmtree(pr)
print(f"SUKCES: {exe} ({sz/1024:.1f} KB) | Gotowe: GrottoRusalka3D_A1200_v2.lha ({mod_info})!", flush=True)
