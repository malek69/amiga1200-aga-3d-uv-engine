; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | 3D Waterfall Canyon, Lake & 3D Orbiting Fireflies
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d0
    move.w  d0,d1
    lsr.w   #8,d1
    lsr.w   #2,d1
    and.w   #3,d1
    lea     scene_palettes(pc),a0
    move.w  (a0,d1.w*8),d2
    move.l  cop_pal_ptr(pc),a1
    move.w  d2,2(a1)                ; COLOR00 (twilight sky)
    move.w  2(a0,d1.w*8),6(a1)      ; COLOR01 (BPL1 dark cliff & forest)
    move.w  4(a0,d1.w*8),10(a1)     ; COLOR02 (BPL2 waterfall & fireflies)
    move.w  #$0fff,14(a1)           ; COLOR03 (BPL1+BPL2 sparkling foam)
    move.w  6(a0,d1.w*8),18(a1)     ; COLOR04 (Blitter AA)
    bsr.w   update_copper_sky

    ; Delikatne kolysanie kamery 3D wokol wodospadu
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d4
    asr.w   #4,d4
    add.w   #26,d4
    and.w   #$ff,d4                 ; ax: lekki pochyl z gory
    move.w  d7,d5
    and.w   #$ff,d5                 ; ay: pelny obrot 360 stopni wokol wyspy
    moveq   #0,d6                   ; az: stabilny horyzont

    move.w  (a2,d4.w*2),s_x
    move.w  128(a2,d4.w*2),c_x
    move.w  (a2,d5.w*2),s_y
    move.w  128(a2,d5.w*2),c_y
    move.w  (a2,d6.w*2),s_z
    move.w  128(a2,d6.w*2),c_z

    ; 1. Rzutowanie wierzcholkow kanionu, wodospadu i jeziora
    lea     mesh_waterfall(pc),a4
    move.w  (a4)+,d7
    lea     proj_verts(pc),a3
.v_loop:
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   project_point_3d
    move.w  d0,(a3)+
    move.w  d1,(a3)+
    dbf     d7,.v_loop

    ; 2. Rysowanie widocznych scian (Backface Culling + BPL1 skala / BPL2 woda)
    move.w  (a4)+,d7
    lea     proj_verts(pc),a3
.f_loop:
    move.w  (a4)+,d0
    move.w  (a4)+,d6
    lea     poly_tmp(pc),a1
    move.w  d6,(a1)+
    move.w  d6,d5
    subq.w  #1,d5
.cp_v:
    move.w  (a4)+,d1
    move.l  (a3,d1.w*4),(a1)+
    dbf     d5,.cp_v

    lea     poly_tmp+2(pc),a1
    move.w  4(a1),d1
    sub.w   (a1),d1
    move.w  10(a1),d2
    sub.w   2(a1),d2
    muls.w  d2,d1
    move.w  6(a1),d3
    sub.w   2(a1),d3
    move.w  8(a1),d4
    sub.w   (a1),d4
    muls.w  d4,d3
    sub.l   d3,d1
    ble.s   .skip_f
    lea     poly_tmp(pc),a1
    bsr.w   draw_polygon_mode
.skip_f:
    dbf     d7,.f_loop

    ; 3. 48 Swietlikow 3D wirujacych wokol wodospadu i jeziora (BPL2)
    bsr.w   render_fireflies_3d
    movem.l (sp)+,d0-d7/a0-a5
    rts

project_point_3d:
    move.w  d1,d3
    muls.w  c_x(pc),d3
    move.w  d2,d4
    muls.w  s_x(pc),d4
    sub.l   d4,d3
    asr.l   #8,d3
    muls.w  s_x(pc),d1
    muls.w  c_x(pc),d2
    add.l   d2,d1
    asr.l   #8,d1
    move.w  d1,d2
    move.w  d3,d1

    move.w  d0,d3
    muls.w  c_y(pc),d3
    move.w  d2,d4
    muls.w  s_y(pc),d4
    add.l   d4,d3
    asr.l   #8,d3
    muls.w  s_y(pc),d0
    muls.w  c_y(pc),d2
    sub.l   d0,d2
    asr.l   #8,d2
    move.w  d3,d0

    muls.w  #295,d0
    muls.w  #295,d1
    add.w   #390,d2
    cmp.w   #160,d2
    bge.s   .z_ok
    move.w  #160,d2
.z_ok:
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #132,d1
    cmp.w   #4,d0
    bge.s   .x_lo
    moveq   #4,d0
.x_lo: cmp.w #315,d0
    ble.s   .x_hi
    move.w  #315,d0
.x_hi: cmp.w #46,d1
    bge.s   .y_lo
    moveq   #46,d1
.y_lo: cmp.w #208,d1
    ble.s   .y_hi
    move.w  #208,d1
.y_hi: rts

render_fireflies_3d:
    lea     firefly_seeds(pc),a4
    lea     sin_tab,a2
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7
    moveq   #47,d6
.ff_lp:
    move.w  (a4)+,d3                ; phase X
    add.w   d7,d3
    and.w   #$ff,d3
    move.w  (a2,d3.w*2),d0
    asr.w   #1,d0                   ; -128..+128
    move.w  (a4)+,d3                ; phase Y
    move.w  d7,d4
    add.w   d4,d4
    add.w   d4,d3
    and.w   #$ff,d3
    move.w  (a2,d3.w*2),d1
    asr.w   #2,d1                   ; -64..+64
    sub.w   #10,d1
    move.w  (a4)+,d3                ; phase Z
    add.w   d7,d3
    add.w   #64,d3
    and.w   #$ff,d3
    move.w  (a2,d3.w*2),d2
    asr.w   #1,d2                   ; -128..+128
    bsr.w   project_point_3d
    ; Rysuj swietlik jako jasny punkt 2x2 px na BPL2 (plus migotanie)
    move.w  d6,d3
    add.w   d7,d3
    and.w   #7,d3
    beq.s   .ff_nx
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)
    bset    d0,40(a3,d1.l)
.ff_nx:
    dbf     d6,.ff_lp
    rts
    even
s_x: dc.w 0
c_x: dc.w 0
s_y: dc.w 0
c_y: dc.w 0
s_z: dc.w 0
c_z: dc.w 0
proj_verts: ds.l 32
poly_tmp:   ds.w 20
scene_palettes:
    dc.w $0124,$0132,$06ef,$0378
    dc.w $0214,$0223,$08ff,$0479
    dc.w $0134,$0142,$09fd,$0488
    dc.w $0125,$0224,$07df,$0379
mesh_waterfall:
    dc.w 19
    ; 0..3: gorny prog skalny (klif)
    dc.w -110,-95,-35, 110,-95,-35, 110,-95,20, -110,-95,20
    ; 4..7: lewy filar skalny wodospadu
    dc.w -110,-95,20, -34,-95,20, -34,35,35, -110,35,35
    ; 8..11: prawy filar skalny wodospadu
    dc.w 34,-95,20, 110,-95,20, 110,35,35, 34,35,35
    ; 12..15: kaskada wodospadu (strumien wody miedzy skalami, BPL2)
    dc.w -32,-92,23, 32,-92,23, 36,36,42, -36,36,42
    ; 16..19: dolne jezioro / rozlewisko u podnoza wodospadu (BPL2)
    dc.w -125,36,35, 125,36,35, 105,42,135, -105,42,135
    dc.w 10
    ; Gorny plaskowyz i tylna sciana klifu (BPL1 = ciemna skala)
    dc.w 0,4, 0,1,2,3
    dc.w 0,4, 1,0,7,10
    ; Lewy i prawy filar skalny (BPL1)
    dc.w 0,4, 4,5,6,7
    dc.w 0,4, 8,9,10,11
    dc.w 0,4, 0,4,7,3
    dc.w 0,4, 9,1,2,10
    ; Kaskada wodospadu - przod i tyl (BPL2 = jasna woda)
    dc.w 2,4, 12,13,14,15
    dc.w 2,4, 13,12,15,14
    ; Tafla jeziora i piana u podnoza (BPL2)
    dc.w 2,4, 16,17,18,19
    dc.w 2,4, 17,16,19,18
    dc.w 0,4, 19,18,17,16
firefly_seeds:
    dc.w 60,163,52
    dc.w 114,215,251
    dc.w 225,122,1
    dc.w 41,56,147
    dc.w 50,230,5
    dc.w 251,160,107
    dc.w 203,128,178
    dc.w 182,192,39
    dc.w 174,45,149
    dc.w 147,234,72
    dc.w 158,12,188
    dc.w 186,236,216
    dc.w 46,204,255
    dc.w 59,217,251
    dc.w 203,132,215
    dc.w 245,12,114
    dc.w 66,25,52
    dc.w 219,240,72
    dc.w 246,117,62
    dc.w 233,240,128
    dc.w 205,157,245
    dc.w 205,221,103
    dc.w 150,137,4
    dc.w 16,76,234
    dc.w 250,184,102
    dc.w 133,248,238
    dc.w 254,222,17
    dc.w 148,162,234
    dc.w 50,224,132
    dc.w 231,93,217
    dc.w 245,32,136
    dc.w 255,189,49
    dc.w 99,210,74
    dc.w 230,7,47
    dc.w 0,231,42
    dc.w 101,126,61
    dc.w 22,137,182
    dc.w 79,2,160
    dc.w 251,69,114
    dc.w 242,67,148
    dc.w 43,213,81
    dc.w 69,156,210
    dc.w 199,76,100
    dc.w 192,7,54
    dc.w 199,37,26
    dc.w 177,180,13
    dc.w 13,243,167
    dc.w 155,230,166
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
