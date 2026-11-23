#!/usr/bin/env python3
import math

def main():
    # 64x64 (4096 bajtow) tablica mapy normalnych + rozblysku Phonga (0..15)
    lut = bytearray(64 * 64)
    lx, ly, lz = 0.45, -0.55, 0.704
    l_len = math.sqrt(lx*lx + ly*ly + lz*lz)
    lx, ly, lz = lx/l_len, ly/l_len, lz/l_len

    for y in range(64):
        ny_base = (y - 31.5) / 32.0
        for x in range(64):
            nx_base = (x - 31.5) / 32.0
            r2 = nx_base*nx_base + ny_base*ny_base
            nz = math.sqrt(max(0.0, 1.0 - min(1.0, r2)))
            # Perturbacja normalnych (mikro-fale normal mapy)
            bump_x = 0.18 * math.sin(x * 0.3927) * math.cos(y * 0.3927)
            bump_y = 0.18 * math.cos(x * 0.3927) * math.sin(y * 0.3927)
            nx = nx_base + bump_x
            ny = ny_base + bump_y
            n_len = math.sqrt(nx*nx + ny*ny + nz*nz) or 1.0
            nx, ny, nz = nx/n_len, ny/n_len, nz/n_len

            ndotl = max(0.0, nx*lx + ny*ly + nz*lz)
            # Wektor odbicia R = 2*(N.L)*N - L, V = (0, 0, 1) -> R.V = 2*(N.L)*nz - lz
            rv = max(0.0, 2.0 * ndotl * nz - lz)
            specular = pow(rv, 16)
            intensity = 0.15 + 0.55 * ndotl + 0.85 * specular
            shade = min(15, max(0, int(intensity * 15.99)))
            lut[y * 64 + x] = shade

    with open("engine/phong_norm_lut.bin", "wb") as f:
        f.write(lut)
    print(f"Wygenerowano engine/phong_norm_lut.bin ({len(lut)} bajtow)")

if __name__ == "__main__":
    main()
