import math, os, random, shutil, subprocess, sys
sys.path.insert(0, "tools")
import build_demo as bd
m_lines = ["moon_spans:"]
for y in range(30):
    dy = y - 14.5
    halo = core = 0
    for x in range(32):
        dx = x - 15.5
        r = math.hypot(dx, dy)
        if r <= 14.0: halo |= (1 << (31 - x))
        if r <= 10.5 and not (dx > 2 and dy < -1 and r > 6.5): core |= (1 << (31 - x))
    m_lines.append(f"    dc.l ${halo:08x},${core:08x}")
aurora = [0x0013,0x0014,0x0025,0x0026,0x0037,0x0048,0x0159,0x016a,0x017b,0x028c,0x029c,0x02ac,0x029b,0x0179,0x029c,0x03bd,0x029b,0x0168,0x0157,0x028b,0x03ae,0x04cf,0x03ae,0x027a,0x0158,0x0147,0x0136,0x0025,0x0024,0x0013,0x0012,0x0012]
a_lines = ["aurora_grad:", "    dc.w " + ",".join(f"${c:04x}" for c in aurora)]
rng = random.Random(261973)
leaves = []
for _ in range(36):
    lx = rng.randint(4, 145)
    ly = rng.randint(2, int(48 - lx * 0.24))
    leaves.append(f"    dc.w {lx},{ly},{1 if (lx+ly)%2==0 else 0}")
stars = [f"    dc.w {rng.randint(155,310)},{rng.randint(6,68)}" for _ in range(20)]
drops = [f"    dc.w {rng.randint(-38,38)},{rng.randint(0,63)}" for _ in range(56)]
mist = [f"    dc.w {rng.randint(-85,85)},{rng.randint(0,31)},{rng.randint(28,75)}" for _ in range(48)]
ff = [f"    dc.w {rng.randint(0,255)},{rng.randint(0,255)},{rng.randint(0,255)}" for _ in range(40)]
rt = open("src/realtime_3d.i").read()
idx = rt.find("    even\ns_x:")
if idx != -1: rt = rt[:idx]
geo = "    even\ns_x: dc.w 0\nc_x: dc.w 0\ns_y: dc.w 0\nc_y: dc.w 0\nlast_z: dc.w 0\nff_glow: dc.w 0\nproj_verts: ds.l 48\npoly_tmp: ds.w 20\n"
geo += "\n".join(m_lines) + "\n" + "\n".join(a_lines) + "\nleaf_clusters:\n" + "\n".join(leaves) + "\nsky_stars:\n" + "\n".join(stars) + "\n"
geo += """mesh_nature:\n    dc.w 37\n    dc.w -145,-75,10, -40,-62,15, -45,5,25, -145,15,25\n    dc.w 40,-62,15, 145,-80,10, 145,15,25, 45,5,25\n    dc.w -38,-62,18, 38,-62,18, 46,5,26, -46,5,26\n    dc.w -145,5,25, -52,5,28, -58,42,38, -145,42,38\n    dc.w 52,5,28, 145,5,25, 145,42,38, 58,42,38\n    dc.w -50,5,30, 50,5,30, 62,42,40, -62,42,40\n    dc.w -155,42,38, 155,42,38, 145,52,145, -145,52,145\n    dc.w -105,-72,12, -80,-70,12, -92,-115,12, 92,-118,12\n    dc.w -125,48,110, -55,48,115, -90,34,112\n    dc.w 60,48,120, 130,48,115, 95,36,118\n    dc.w 13\n    dc.w 0,4, 0,1,2,3\n    dc.w 0,4, 4,5,6,7\n    dc.w 0,4, 12,13,14,15\n    dc.w 0,4, 16,17,18,19\n    dc.w 0,3, 28,29,30\n    dc.w 0,3, 4,5,31\n    dc.w 2,4, 8,9,10,11\n    dc.w 2,4, 9,8,11,10\n    dc.w 2,4, 20,21,22,23\n    dc.w 2,4, 21,20,23,22\n    dc.w 2,4, 24,25,26,27\n    dc.w 2,4, 25,24,27,26\n    dc.w 0,3, 32,33,34\n    dc.w 0,3, 35,36,37\n"""
geo += "drop_seeds:\n" + "\n".join(drops) + "\nmist_seeds:\n" + "\n".join(mist) + "\nfirefly_seeds:\n" + "\n".join(ff) + "\nvec_frame_count: dc.w 1\n    even\nvec_frame_table: dc.l 0\n"
open("src/realtime_3d.i", "w").write(rt + geo)
dg = open("src/demo_gfx.i").read()
i1, i2 = dg.find("    ; 1. Kopiuj gorne logo AGA"), dg.find("    ; 2. Sine-Scroller")
if i1 != -1 and i2 != -1: open("src/demo_gfx.i", "w").write(dg[:i1] + dg[i2:])
sd, od = "src", "releases"
exe = os.path.abspath(f"{od}/WATERFALL3D_A1200")
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "main.s", "-o", exe], cwd=sd, check=True)
os.chmod(exe, 0o755)
sz = os.path.getsize(exe)
em = ((sz + 0x120000 + 0xFFFF) & ~0xFFFF)
lo = em - sz - 256
pr = f"{od}/_tmp_wf"
shutil.rmtree(pr, ignore_errors=True); os.makedirs(f"{pr}/Waterfall3D_A1200", exist_ok=True)
shutil.copy2(exe, f"{pr}/Waterfall3D_A1200/WATERFALL3D_A1200")
sl = open(f"{sd}/whdload_slave.s").read().replace("{EXP_MEM}", f"{em:08x}").replace("{LOAD_OFF}", f"{lo:08x}").replace("{DEMO_TITLE}", "Waterfall & Fireflies 3D v2.0 [AGA + MOD]").replace("{DEMO_CREDITS}", "Code: malek69 & Gemini AI | Music: Absys (Aminet)").replace("{EXE_NAME}", "WATERFALL3D_A1200")
open(f"{pr}/slave.s", "w").write(sl)
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", f"{pr}/slave.s", "-o", f"{pr}/Waterfall3D_A1200/Waterfall3D.slave"], check=True)
os.remove(f"{pr}/slave.s")
open(f"{pr}/Waterfall3D_A1200.info", "wb").write(bd.mk_ico(2))
open(f"{pr}/Waterfall3D_A1200/Waterfall3D_A1200.info", "wb").write(bd.mk_ico(4, "WHDLoad", ["SLAVE=Waterfall3D.slave", "NoMMU"]))
if os.path.exists(f"{od}/Waterfall3D_A1200_v2.lha"): os.remove(f"{od}/Waterfall3D_A1200_v2.lha")
bd.mk_lha(f"{od}/Waterfall3D_A1200_v2.lha", pr)
shutil.rmtree(pr)
print(f"SUKCES: {exe} ({sz/1024:.1f} KB) | Zwisajace liscie + animowana woda + mgielka nad woda + swietliki 3D + MOD Absysa!", flush=True)
