#!/usr/bin/env python3
import struct

def main():
    max_val = 512
    # Tablica 1/x w formacie 16.16 (32-bit unsigned) dla x = 0..512
    # x = 0 ustawione na 0, aby uniknac dzielenia przez zero
    table_32 = [0]
    for x in range(1, max_val + 1):
        val = int((1 << 16) / x)
        table_32.append(val)

    with open("engine/recip_table_32.bin", "wb") as f:
        for val in table_32:
            f.write(struct.pack(">I", val))

    print(f"Wygenerowano engine/recip_table_32.bin ({len(table_32) * 4} bajtow)")

if __name__ == "__main__":
    main()
