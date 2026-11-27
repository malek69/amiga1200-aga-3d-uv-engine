; ============================================================================
; AURA-3D AGA Engine v1.1 - 24-bit Hardware Copper Sky & Horizon Gradient
; ============================================================================
; Generuje 228-liniowy gradient 24-bitowego COLOR00 ($DFF180) w Copperlist
; dokladnie dla okna DIWSTRT=$3881 .. DIWSTOP=$1cc1 (linie $38..$11b)
; za 0 cykli CPU podczas wyswietlania ramki.
; ============================================================================

    ifd FULL_RES
SKY_LINES       equ 256                 ; pelne 256 linii PAL od $2c (44) do $12b (299)
SKY_VSTART      equ $2c
    else
SKY_LINES       equ 256
SKY_VSTART      equ $2c
    endif

; ----------------------------------------------------------------------------
; copper_set_sky_theme
; Wejscie: d0.w = numer motywu (0=Cosmic Horizon, 1=Solaris, 2=Emerald, 3=Black)
; ----------------------------------------------------------------------------
copper_set_sky_theme:
    movem.l d0-d7/a0-a4,-(sp)
    move.l  cop_sky_ptr(pc),d1
    beq.w   .sky_done
    move.l  d1,a0

    and.w   #3,d0
    move.w  d0,sky_current_theme
    lea     sky_themes_table(pc),a1
    lsl.w   #4,d0                       ; 16 bajtow na motyw (4 kolory x 4B)
    adda.w  d0,a1                       ; a1 -> [C_TOP, C_HORIZ, C_GROUND, C_BOT]

    moveq   #0,d7                       ; indeks linii

.sky_line_lp:
    ifd FULL_RES
    ; Odcinki gradientu dla 256 linii:
    ;   0..167   (168 linii): C_TOP    -> C_HORIZ   (niebo az do linii horyzontu)
    ;   168..176 (9 linii):   C_HORIZ  -> C_GROUND  (ostre przejscie horyzontu)
    ;   177..255 (79 linii):  C_GROUND -> C_BOT     (powierzchnia / glebia pod horyzontem)
    cmp.w   #168,d7
    bge.s   .seg_horiz

    move.l  (a1),d0
    move.l  4(a1),d1
    move.w  d7,d2
    move.w  #168,d3
    bsr.w   .lerp_rgb24
    bra.s   .emit_cop_line

.seg_horiz:
    cmp.w   #177,d7
    bge.s   .seg_ground

    move.l  4(a1),d0
    move.l  8(a1),d1
    move.w  d7,d2
    sub.w   #168,d2
    moveq   #9,d3
    bsr.w   .lerp_rgb24
    bra.s   .emit_cop_line

.seg_ground:
    move.l  8(a1),d0
    move.l  12(a1),d1
    move.w  d7,d2
    sub.w   #177,d2
    move.w  #79,d3
    bsr.w   .lerp_rgb24
    else
    cmp.w   #168,d7
    bge.s   .seg_horiz2
    move.l  (a1),d0
    move.l  4(a1),d1
    move.w  d7,d2
    move.w  #168,d3
    bsr.w   .lerp_rgb24
    bra.s   .emit_cop_line
.seg_horiz2:
    cmp.w   #177,d7
    bge.s   .seg_ground2
    move.l  4(a1),d0
    move.l  8(a1),d1
    move.w  d7,d2
    sub.w   #168,d2
    moveq   #9,d3
    bsr.w   .lerp_rgb24
    bra.s   .emit_cop_line
.seg_ground2:
    move.l  8(a1),d0
    move.l  12(a1),d1
    move.w  d7,d2
    sub.w   #177,d2
    move.w  #79,d3
    bsr.w   .lerp_rgb24
    endif

.emit_cop_line:
    ; Pozycja Y wiazki PAL: y_beam = SKY_VSTART + d7
    move.w  #SKY_VSTART,d5
    add.w   d7,d5

    ; Jesli y_beam == $100 (256), wstaw Copper wraparound WAIT $ffdffffe
    cmp.w   #$0100,d5
    bne.s   .no_wrap
    move.l  #$ffdffffe,(a0)+
.no_wrap:
    ; WAIT (y_beam & $ff) << 24 | $07fe
    move.w  d5,d6
    and.w   #$00ff,d6
    lsl.w   #8,d6
    or.w    #$0007,d6
    swap    d6
    move.w  #$fffe,d6
    move.l  d6,(a0)+

    ; Rozbij d4 ($00RRGGBB) na hi_rgb (R7..4 G7..4 B7..4) i lo_rgb (R3..0 G3..0 B3..0)
    move.l  d4,d0
    lsr.l   #4,d0
    and.w   #$000f,d0                   ; B hi
    move.l  d4,d1
    lsr.l   #8,d1
    and.w   #$00f0,d1                   ; G hi
    or.w    d1,d0
    move.l  d4,d1
    swap    d1
    and.w   #$00f0,d1
    lsl.w   #4,d1                       ; R hi
    or.w    d1,d0                       ; d0.w = hi_rgb

    move.l  d4,d1
    and.w   #$000f,d1                   ; B lo
    move.l  d4,d2
    lsr.w   #4,d2
    and.w   #$00f0,d2                   ; G lo
    or.w    d2,d1
    move.l  d4,d2
    swap    d2
    lsl.w   #8,d2
    and.w   #$0f00,d2                   ; R lo
    or.w    d2,d1                       ; d1.w = lo_rgb

    ; Zapis AGA 24-bit COLOR00:
    move.l  #(BPLCON3<<16)|$0c00,(a0)+
    move.w  #COLOR00,(a0)+
    move.w  d0,(a0)+

    move.l  #(BPLCON3<<16)|$0e00,(a0)+
    move.w  #COLOR00,(a0)+
    move.w  d1,(a0)+

    ifnd FULL_RES
    btst    #0,d7
    bne.s   .odd_ln
    move.l  #(BPL1MOD<<16)|$ffd8,(a0)+
    move.l  #(BPL2MOD<<16)|$ffd8,(a0)+
    bra.s   .mod_ok
.odd_ln:
    move.l  #(BPL1MOD<<16)|$0000,(a0)+
    move.l  #(BPL2MOD<<16)|$0000,(a0)+
.mod_ok:
    endif

    addq.w  #1,d7
    cmp.w   #SKY_LINES,d7
    blo.w   .sky_line_lp

    ; Przywroc domyslny bank BPLCON3 ($0c00) i czarny kolor dolnej ramki
    move.l  #(BPLCON3<<16)|$0c00,(a0)+
    move.l  #(COLOR00<<16)|$0000,(a0)+
    move.l  #$fffffffe,(a0)+

.sky_done:
    movem.l (sp)+,d0-d7/a0-a4
    rts

; ----------------------------------------------------------------------------
; .lerp_rgb24: interpoluje liniowo c0 (d0.l) -> c1 (d1.l) dla kroku t=d2/d3
; Zwraca wynik $00RRGGBB w d4.l
; ----------------------------------------------------------------------------
.lerp_rgb24:
    ; Kanal R
    move.l  d0,d4
    swap    d4
    and.w   #$00ff,d4                   ; r0
    move.l  d1,d5
    swap    d5
    and.w   #$00ff,d5                   ; r1
    sub.w   d4,d5
    muls.w  d2,d5
    divs.w  d3,d5
    add.w   d5,d4                       ; r
    swap    d4
    clr.w   d4                          ; d4 = r << 16

    ; Kanal G
    move.w  d0,d5
    lsr.w   #8,d5                       ; g0
    move.w  d1,d6
    lsr.w   #8,d6                       ; g1
    sub.w   d5,d6
    muls.w  d2,d6
    divs.w  d3,d6
    add.w   d6,d5                       ; g
    lsl.w   #8,d5
    or.w    d5,d4

    ; Kanal B
    moveq   #0,d5
    move.b  d0,d5                       ; b0
    moveq   #0,d6
    move.b  d1,d6                       ; b1
    sub.w   d5,d6
    muls.w  d2,d6
    divs.w  d3,d6
    add.w   d6,d5                       ; b
    or.w    d5,d4
    rts

    even
sky_themes_table:
    ; Motyw 0: Cosmic Horizon (gleboki granat -> blekit horyzontu -> ciemny grunt)
    dc.l    $00020514, $00163e72, $00081428, $0002040a
    ; Motyw 1: Solaris Dusk (kosmiczny fiolet -> zloty horyzont -> ciemna purpura)
    dc.l    $000e041a, $00582418, $001c0a16, $00070208
    ; Motyw 2: Emerald Nebula (ciemny szmaragd -> jasny turkus -> glebia)
    dc.l    $00021010, $00104842, $00051c1a, $00010808
    ; Motyw 3: Pure Black
    dc.l    $00000000, $00000000, $00000000, $00000000

    even
sky_current_theme: dc.w 0
