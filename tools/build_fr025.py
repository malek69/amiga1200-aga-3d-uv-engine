import glob, os, re, shutil, subprocess, sys, cv2, numpy as np
sys.path.insert(0, "tools")
import build_demo as bd
vid = glob.glob(os.path.expanduser("~/Pobrane/*fr-025*.mp4")).pop(0)
sd, od = "src", "releases"
os.makedirs(od, exist_ok=True)
per = 322
hz_r = 3546895.0 / per
subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", vid, "-vn", "-af", f"highpass=f=60,treble=g=5:f=3000,lowpass=f=5200,acompressor=threshold=-14dB:ratio=3:makeup=2dB,aresample={int(round(hz_r))}:resampler=soxr,volume=0.88", "-f", "s8", "-ac", "1", "-ar", str(int(round(hz_r))), f"{sd}/median_audio.raw"], check=True)
proc = subprocess.Popen(["ffmpeg", "-v", "error", "-i", vid, "-vf", "scale=312:248:flags=lanczos,fps=20", "-f", "rawvideo", "-pix_fmt", "bgr24", "-"], stdout=subprocess.PIPE)
def rgb12(bgr): return ((int(bgr.item(2)) >> 4) << 8) | ((int(bgr.item(1)) >> 4) << 4) | (int(bgr.item(0)) >> 4)
def mix12(c0, c1):
    return (((((c0>>8)&15)+((c1>>8)&15))>>1)<<8) | (((((c0>>4)&15)+((c1>>4)&15))>>1)<<4) | (((c0&15)+(c1&15))>>1)
fb, uniq, fl, pr_raw, pr_lbl = 312 * 248 * 3, {}, list(), None, None
while True:
    raw = proc.stdout.read(fb)
    if len(raw) < fb: break
    if raw == pr_raw: fl.append(pr_lbl); continue
    img = np.frombuffer(raw, dtype=np.uint8).reshape((248, 312, 3))
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    sat_m = (hsv[:, :, 1] > 45) & (hsv[:, :, 2] > 50) & (hsv[:, :, 2] < 245)
    mid_m = (hsv[:, :, 2] >= 50) & (hsv[:, :, 2] <= 235)
    bg_bgr = np.median(img[sat_m], axis=0) if np.sum(sat_m) > 300 else (np.median(img[mid_m], axis=0) if np.sum(mid_m) > 300 else np.median(img.reshape(-1, 3), axis=0))
    c0 = rgb12(bg_bgr) & 0x0eee
    c1, c2 = 0x0111, 0x0fff
    c4 = mix12(c0, c1)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    loc_bg = cv2.GaussianBlur(gray, (31, 31), 0)
    diff = gray.astype(np.int16) - loc_bg.astype(np.int16)
    dark_m = ((diff < -22) | (gray < 42)).astype(np.uint8) * 255
    bright_m = ((diff > 28) & (gray > 165)).astype(np.uint8) * 255
    dp = list()
    for op_base, mask in ((2, bright_m), (0, dark_m)):
        if not np.any(mask): continue
        cnts, hier = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        if hier is None: continue
        hr = hier.reshape(-1, 4)
        items = list()
        for i in range(len(cnts)):
            area = cv2.contourArea(cnts[i])
            d, par = 0, int(hr.item(i, 3))
            while par != -1: d += 1; par = int(hr.item(par, 3))
            if area < (16.0 if (d & 1) else 14.0): continue
            items.append((d, -area, i))
        items.sort()
        for eps in (1.25, 1.7, 2.2):
            cur, v_tot = list(), 0
            for d, _, i in items:
                if op_base == 2 and (d & 1): continue
                pts = cv2.approxPolyDP(cnts[i], eps, True).reshape(-1, 2)
                m = list()
                for (x, y) in pts:
                    pt = (int(x) + 4, int(y) + 4)
                    if not m or m[-1] != pt: m.append(pt)
                while len(m) >= 3 and m[:1] == m[-1:]: m.pop()
                if len(m) >= 3:
                    if v_tot + len(m) > 165 and eps == 2.2: continue
                    cur.append((2 if op_base == 2 else (d & 1), tuple(m)))
                    v_tot += len(m)
            if v_tot <= 165 or eps == 2.2: dp.extend(cur); break
    key = (c0, c1, c2, c4, tuple(dp))
    if key not in uniq: uniq[key] = f"vf_{len(uniq)}"
    pr_raw, pr_lbl = raw, uniq[key]
    fl.append(pr_lbl)
    if len(fl) % 1000 == 0: print(f"  Klatka {len(fl)}...", flush=True)
proc.wait()
lines = [f"vec_frame_count: dc.w {len(fl)}", "    even", "vec_frame_table:"] + [f"    dc.l {l}" for l in fl]
for (c0, c1, c2, c4, dp), l in uniq.items():
    lines += [f"{l}:", f"    dc.w ${c0:04x},${c1:04x},${c2:04x},${c4:04x}"]
    for op, p in dp: lines.append(f"    dc.w {op},{len(p)}," + ",".join(f"{x},{y}" for x, y in p))
    lines.append("    dc.w -1")
open(f"{sd}/scene_data.i", "w").write("\n".join(lines) + "\n")
exe = os.path.abspath(f"{od}/FR025_A1200")
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-kick1hunks", "-nosym", "-I.", "main.s", "-o", exe], cwd=sd, check=True)
os.chmod(exe, 0o755)
sz = os.path.getsize(exe)
em = ((sz + 0x088000 + 0xFFFF) & ~0xFFFF)
lo = em - sz - 256
pr = f"{od}/_tmp_fr"
shutil.rmtree(pr, ignore_errors=True); os.makedirs(f"{pr}/FR025_A1200", exist_ok=True)
shutil.copy2(exe, f"{pr}/FR025_A1200/FR025_A1200")
sl = open(f"{sd}/whdload_slave.s").read().replace("{EXP_MEM}", f"{em:08x}").replace("{LOAD_OFF}", f"{lo:08x}").replace("{DEMO_TITLE}", "fr-025: the.popular.demo A1200 [v2.0]").replace("{DEMO_CREDITS}", "Orig: Farbrausch (2003) | Port: malek69 & Gemini AI").replace("{EXE_NAME}", "FR025_A1200")
open(f"{pr}/slave.s", "w").write(sl)
subprocess.run(["vasmm68k_mot", "-m68020", "-Fhunkexe", "-nosym", f"{pr}/slave.s", "-o", f"{pr}/FR025_A1200/FR025_A1200.slave"], check=True)
os.remove(f"{pr}/slave.s")
open(f"{pr}/FR025_A1200.info", "wb").write(bd.mk_ico(2))
open(f"{pr}/FR025_A1200/FR025_A1200.info", "wb").write(bd.mk_ico(4, "WHDLoad", ["SLAVE=FR025_A1200.slave", "NoMMU"]))
bd.mk_lha(f"{od}/FR025_A1200_THEA1200.lha", pr)
shutil.rmtree(pr)
print(f"SUKCES: {exe} ({sz/1048576:.2f} MB) | ExpMem = {em/1048576:.2f} MB (Local BG Subtraction + Crisp Silhouettes)!", flush=True)
