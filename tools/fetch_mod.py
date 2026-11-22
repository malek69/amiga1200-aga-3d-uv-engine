import glob, os, re, shutil, subprocess, urllib.request
base = "https://aminet.net"
os.makedirs("/tmp/aminet_new", exist_ok=True)
saved = False
for cat in ("/mods/demo/", "/mods/melod/"):
    if saved: break
    html = urllib.request.urlopen(base + cat, timeout=15).read().decode("latin1", "ignore")
    paths = [p for p in re.findall(rf"href=\"({cat}[^\"]+\.lha)\"", html) if len(p) < 70]
    for p in paths[:30]:
        try:
            data = urllib.request.urlopen(base + p, timeout=15).read()
            if not (45000 <= len(data) <= 320000): continue
            open("/tmp/aminet_new/in.lha", "wb").write(data)
            shutil.rmtree("/tmp/aminet_new/out", ignore_errors=True)
            os.makedirs("/tmp/aminet_new/out", exist_ok=True)
            subprocess.run(["7z", "x", "-y", "/tmp/aminet_new/in.lha", "-o/tmp/aminet_new/out"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            for fp in glob.glob("/tmp/aminet_new/out/**/*", recursive=True):
                if os.path.isfile(fp) and os.path.getsize(fp) > 25000:
                    raw = open(fp, "rb").read()
                    if len(raw) > 1084 and raw[1080:1084] == b"M.K.":
                        title = re.sub(r"[^A-Za-z0-9 ._-]", "", raw[:20].decode("ascii", "ignore")).strip()
                        if "absys" in title.lower(): continue
                        open("src/demo_tune.mod", "wb").write(raw)
                        smp_txt = " ".join(re.sub(r"[^A-Za-z0-9 ._@()-]", "", raw[20+i*30:42+i*30].decode("ascii", "ignore")).strip() for i in range(31))
                        smp_txt = re.sub(r"\s+", " ", smp_txt).strip()[:65]
                        print(f"POBRANO NOWY MODUL ({p}): \"{title}\" | Info: \"{smp_txt}\"", flush=True)
                        dg = open("src/demo_gfx.i").read()
                        sc = f"   *** TWILIGHT FIREFLIES 3D V2.0 *** MUSIC: {title.upper()} ({smp_txt.upper()}) VIA AMINET *** CODE & 3D ENGINE: MALEK69 & GEMINI AI (VIBE CODING) ***   "
                        dg = re.sub(r"scroll_text: dc\.b \"[^\"]+\"", f"scroll_text: dc.b \"{sc}\"", dg)
                        open("src/demo_gfx.i", "w").write(dg)
                        open("src/mod_credits.txt", "w").write(f"{title} ({p})")
                        saved = True
                        break
            if saved: break
        except Exception:
            pass
shutil.rmtree("/tmp/aminet_new", ignore_errors=True)
assert saved, "Nie udalo sie pobrac nowego modulu z Aminet"
