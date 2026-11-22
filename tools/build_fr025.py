import glob, os, re, shutil, subprocess, sys, zipfile, cv2, numpy as np
sys.path.insert(0, "tools")
import build_demo as bd
vid = glob.glob(os.path.expanduser("~/Pobrane/*fr-025*.mp4")).pop(0)
sd, od = "src", "releases"
os.makedirs(od, exist_ok=True)
dur = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", vid], capture_output=True, text=True, check=True).stdout.strip())
hz = max(8000, min(16497, int(980000 / max(1.0, dur))))
per = round(3546895 / hz)
hz_r = 3546895.0 / per
open(f"{sd}/audio_player.i", "w").write(re.sub(r"#\d+(?=,AUD\dPER)", f"#{per}", re.sub(r"#\d+(?=,AUD\dVOL)", "#20", open(f"{sd}/audio_player.i").read())))
subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", vid, "-vn", "-af", f"highpass=f=40,lowpass=f={int(hz_r*0.42)},alimiter=limit=0.88,aresample={int(round(hz_r))}:resampler=soxr,volume=0.82", "-f", "s8", "-ac", "1", "-ar", str(int(round(hz_r))), f"{sd}/median_audio.raw"], check=True)
proc = subprocess.Popen(["ffmpeg", "-v", "error", "-i", vid, "-vf", "scale=312:248:flags=area,fps=20", "-f", "rawvideo", "-pix_fmt", "bgr24", "-"], stdout=subprocess.PIPE)
def rgb12(bgr): return ((int(bgr.item(2)) >> 4) << 8) | ((int(bgr.item(1)) >> 4) << 4) | (int(bgr.item(0)) >> 4)
def mix12(c0, c1):
    r = (((c0 >> 8) & 15) + ((c1 >> 8) & 15)) >> 1
    g = (((c0 >> 4) & 15) + ((c1 >> 4) & 15)) >> 1
    b = ((c0 & 15) + (c1 & 15)) >> 1
    return (r << 8) | (g << 4) | b
fb, uniq, fl, pr_raw, pr_lbl = 312 * 248 * 3, {}, list(), None, None
k3 = np.ones((3, 3), dtype=np.uint8)
while True:
    raw = proc.stdout.read(fb)
    if len(raw) < fb: break
    if raw == pr_raw: fl.append(pr_lbl); continue
    img = np.frombuffer(raw, dtype=np.uint8).reshape((248, 312, 3))
    blur = cv2.GaussianBlur(img, (9, 9), 0)
    lum = (blur[:, :, 2].astype(np.int16)*30 + blur[:, :, 1].astype(np.int16)*59 + blur[:, :, 0].astype(np.int16)*11) // 100
    bg_mask = (lum >= 65) & (lum <= 205)
    bg_bgr = np.median(blur[bg_mask], axis=0) if np.sum(bg_mask) > 400 else np.median(blur.reshape(-1, 3), axis=0)
    c0 = rgb12(bg_bgr) & 0x0eee & 0x0eee
    c1 = 0x0111
    c2 = 0x0fff
    c4 = mix12(c0, c1)
    dark_m = (lum < 72).astype(np.uint8) * 255
    bright_m = (lum > 205).astype(np.uint8) * 255
    dp = list()
    for op_base, mask in ((2, bright_m), (0, dark_m)):
        if not np.any(mask): continue
        cnts, hier = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        if hier is None: continue
        hr = hier.reshape(-1, 4)
        items = list()
        for i in range(len(cnts)):
            d, par = 0, int(hr.item(i, 3))
            while par != -1: d += 1; par = int(hr.item(par, 3))
            items.append((d, i))
        items.sort()
        for eps in (2.4, 4.2, 4.2):
            cur, v_tot = list(), 0
            for d, i in items:
                if op_base == 2 and (d & 1): continue
                if cv2.contourArea(cnts[i]) < (14.0 if (d & 1) else 9.0): continue
                pts = cv2.approxPolyDP(cnts[i], eps, True).reshape(-1, 2)
                m = list()
                for (x, y) in pts:
                    pt = (int(x) + 4, int(y) + 4)
                    if not m or m[-1] != pt: m.append(pt)
                while len(m) >= 3 and m[:1] == m[-1:]: m.pop()
                if len(m) >= 3:
                    cur.append((2 if op_base == 2 else (d & 1), tuple(m)))
                    v_tot += len(m)
            if v_tot <= 115 or eps == 4.2: dp.extend(cur); break
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
print(f"GOTOWE: {exe} ({sz/1048576:.2f} MB) | ExpMem = {em/1048576:.2f} MB (50.00 FPS Dynamic AGA)!", flush=True)
