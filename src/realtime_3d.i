; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | Twilight Grayscale 3D Fly-Through & Illuminating Firefly Sphere
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0112,2(a1)            ; COLOR00 (twilight charcoal)
    move.w  #$0223,6(a1)            ; COLOR01 (BPL1 dark slate shadow)
    move.w  #$0789,10(a1)           ; COLOR02 (BPL2 silver-blue firefly illumination)
    move.w  #$0ffd,14(a1)           ; COLOR03 (BPL1+BPL2 bright warm-white firefly core)
    move.w  #$0112,18(a1)           ; COLOR04 (Blitter AA)

    ; 1. Wyznacz pozycje 3D Kuli Swietlikow lecacej przed kamera
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1                   ; orb_x = -64..+64
    move.w  d1,orb_x
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #3,d2                   ; orb_y = -32..+32
    subq.w  #8,d2
    move.w  d2,orb_y
    move.w  d7,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d3
    asr.w   #2,d3
    add.w   #220,d3                 ; orb_z = 156..284
    move.w  d3,orb_z

    ; 2. Przelot kamery przez kanion 16 skalnych monolitow 3D (posortowanych od najdalszego)
    move.w  d7,d6
    lsl.w   #2,d6                   ; cam_z += 4 per frame (50 FPS fly-through!)
    move.w  d7,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d5
    asr.w   #3,d5                   ; cam_sway_x (-32..+32)

    ; Znajdz najdalszy filar (start petli od tylu do przodu = algorytm malarza)
    moveq   #15,d4
.pil_lp:
    move.w  d4,d0
    lsl.w   #6,d0                   ; pillar base Z = i * 64
    sub.w   d6,d0
    and.w   #$03ff,d0               ; 0..1023
    add.w   #70,d0                  ; Z w kamerze: 70..1093
    move.w  d0,cur_pz

    ; Pozycja X filaru (lewa/prawa strona korytarza + zakret kanionu)
    move.w  #-115,d1
    btst    #0,d4
    beq.s   .side_ok
    move.w  #115,d1
.side_ok:
    sub.w   d5,d1                   ; ruch kamery na boki
    move.w  d1,cur_px

    ; Sprawdz odleglosc filaru od Kuli Swietlikow -> dynamiczne oswietlenie!
    sub.w   orb_x(pc),d1
    bpl.s   .dx_p
    neg.w   d1
.dx_p: move.w cur_pz(pc),d2
    sub.w   orb_z(pc),d2
    bpl.s   .dz_p
    neg.w   d2
.dz_p: add.w d2,d1
    move.l  draw_bpl1(pc),a3        ; domyslnie ciemny polmrok (BPL1)
    cmp.w   #175,d1
    bhi.s   .is_dark
    move.l  draw_bpl2(pc),a3        ; blisko kuli swietlikow -> rozswietlony srebrnym blaskiem (BPL2)!
.is_dark:
    bsr.w   draw_pillar_3d
    dbf     d4,.pil_lp

    ; 3. Rysuj Kule 64 Swietlikow 3D (swiecacy rdzen + wirujace swietliki rzucajace swiatlo)
    bsr.w   render_firefly_sphere
    bsr.w   update_twilight_copper
    movem.l (sp)+,d0-d7/a0-a5
    rts

draw_pillar_3d:
    ; Rzutuje frontowy prostokat monolitu 3D (szer. 34, wys. -110..+95) jako 2 bezbledne trojkaty
    move.w  cur_pz(pc),d2
    move.w  cur_px(pc),d0
    sub.w   #18,d0                  ; x_left 3D
    move.w  cur_px(pc),d1
    add.w   #18,d1                  ; x_right 3D
    muls.w  #260,d0
    ext.l   d2
    divs.l  d2,d0
    add.w   #160,d0                 ; sx1
    muls.w  #260,d1
    divs.l  d2,d1
    add.w   #160,d1                 ; sx2
    cmp.w   #318,d0
    bge.w   .p_skip
    cmp.w   #1,d1
    ble.w   .p_skip
    move.w  d0,p_sx1
    move.w  d1,p_sx2

    move.l  #-115*260,d0
    divs.l  d2,d0
    add.w   #122,d0                 ; sy_top
    move.l  #105*260,d1
    divs.l  d2,d1
    add.w   #122,d1                 ; sy_bot
    move.w  d0,p_sy1
    move.w  d1,p_sy2

    ; Trojkat 1: (sx1,sy1) - (sx2,sy1) - (sx2,sy2)
    move.w  p_sx1(pc),d0
    move.w  p_sy1(pc),d1
    move.w  p_sx2(pc),d2
    move.w  p_sy1(pc),d3
    move.w  p_sx2(pc),d4
    move.w  p_sy2(pc),d5
    bsr.w   fill_tri_clean

    ; Trojkat 2: (sx1,sy1) - (sx2,sy2) - (sx1,sy2)
    move.w  p_sx1(pc),d0
    move.w  p_sy1(pc),d1
    move.w  p_sx2(pc),d2
    move.w  p_sy2(pc),d3
    move.w  p_sx1(pc),d4
    move.w  p_sy2(pc),d5
    bsr.w   fill_tri_clean
.p_skip: rts

render_firefly_sphere:
    ; Rzutuj srodek Kuli Swietlikow
    move.w  orb_x(pc),d0
    move.w  orb_y(pc),d1
    move.w  orb_z(pc),d2
    muls.w  #260,d0
    muls.w  #260,d1
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #122,d1
    move.w  d0,orb_sx
    move.w  d1,orb_sy

    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7
    lea     sphere_seeds(pc),a4
    lea     sin_tab,a1
    moveq   #63,d6
.sp_lp:
    move.w  (a4)+,d3                ; kat theta
    add.w   d7,d3
    add.w   d7,d3
    and.w   #$ff,d3
    move.w  (a4)+,d4                ; promien warstwy (8..36)
    move.w  (a1,d3.w*2),d0
    muls.w  d4,d0
    asr.l   #8,d0
    add.w   orb_sx(pc),d0
    move.w  128(a1,d3.w*2),d1
    muls.w  d4,d1
    asr.l   #8,d1
    asr.w   #1,d1
    move.w  (a4)+,d5                ; pionowa oscylacja
    add.w   d7,d5
    and.w   #$ff,d5
    move.w  (a1,d5.w*2),d2
    muls.w  d4,d2
    asr.l   #8,d2
    add.w   d2,d1
    add.w   orb_sy(pc),d1

    cmp.w   #3,d0
    blo.w   .sp_nx
    cmp.w   #316,d0
    bhi.w   .sp_nx
    cmp.w   #3,d1
    blo.w   .sp_nx
    cmp.w   #250,d1
    bhi.w   .sp_nx

    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    ; Wewnetrzne swietliki kuli (r < 22) swieca bialo-zlotym rdzeniem (BPL1+BPL2), zewnetrzne poswiata (BPL2)
    bset    d0,(a3,d1.l)
    cmp.w   #22,d4
    bgt.s   .sp_nx
    bset    d0,(a2,d1.l)
    bset    d0,40(a3,d1.l)
.sp_nx: dbf d6,.sp_lp
    rts

fill_tri_clean:
    ; Bezbledny wypelniacz trojkatow (a3 = target bitplane, d0..d5 = x0,y0,x1,y1,x2,y2)
    movem.l d0-d7/a0-a2,-(sp)
    ; Wyznacz ymin i ymax
    move.w  d1,d6
    cmp.w   d3,d6
    ble.s   .ym1
    move.w  d3,d6
.ym1: cmp.w d5,d6
    ble.s   .ym2
    move.w  d5,d6
.ym2: move.w d1,d7
    cmp.w   d3,d7
    bge.s   .yx1
    move.w  d3,d7
.yx1: cmp.w d5,d7
    bge.s   .yx2
    move.w  d5,d7
.yx2: tst.w d6
    bpl.s   .yc1
    moveq   #0,d6
.yc1: cmp.w #255,d7
    ble.s   .yc2
    move.w  #255,d7
.yc2: cmp.w d6,d7
    ble.w   .tri_end
    move.w  d6,tri_ymin
    move.w  d7,tri_ymax

    ; Inicjuj span_left=+32000, span_right=-32000 dla ymin..ymax
    lea     edge_buf,a0
    lea     512(a0),a1
    move.w  d7,d2
    sub.w   d6,d2
    add.w   d6,d6
    add.w   d6,a0
    add.w   d6,a1
.in_sp: move.w #32000,(a0)+
    move.w  #-32000,(a1)+
    dbf     d2,.in_sp

    ; Rasteryzuj 3 krawedzie do tablic span_left / span_right
    movem.w d0-d5,-(sp)
    bsr.s   .tri_edge
    movem.w (sp),d0-d5
    move.w  d2,d0
    move.w  d3,d1
    move.w  d4,d2
    move.w  d5,d3
    bsr.s   .tri_edge
    movem.w (sp)+,d0-d5
    move.w  d4,d2
    move.w  d5,d3
    bsr.s   .tri_edge

    ; Wypelnij poziome odcinki na bitplanie a3
    move.w  tri_ymin(pc),d6
    move.w  tri_ymax(pc),d7
    lea     edge_buf,a0
    lea     512(a0),a1
    move.w  d6,d0
    add.w   d0,d0
    add.w   d0,a0
    add.w   d0,a1
    move.w  d6,d0
    mulu.w  #40,d0
    lea     (a3,d0.l),a2
.fl_y: move.w (a0)+,d0              ; xl
    move.w  (a1)+,d1                ; xr
    cmp.w   d0,d1
    blt.s   .fl_nx
    tst.w   d0
    bpl.s   .xl_ok
    moveq   #0,d0
.xl_ok: cmp.w #319,d1
    ble.s   .xr_ok
    move.w  #319,d1
.xr_ok: cmp.w d0,d1
    blt.s   .fl_nx
.px_lp: move.w d0,d2
    lsr.w   #3,d2
    move.w  d0,d3
    not.w   d3
    and.w   #7,d3
    bset    d3,(a2,d2.w)
    addq.w  #1,d0
    cmp.w   d1,d0
    ble.s   .px_lp
.fl_nx: lea 40(a2),a2
    addq.w  #1,d6
    cmp.w   d7,d6
    ble.s   .fl_y
.tri_end: movem.l (sp)+,d0-d7/a0-a2
    rts

.tri_edge:
    cmp.w   d1,d3
    beq.s   .te_ex
    bgt.s   .te_ok
    exg     d0,d2
    exg     d1,d3
.te_ok: move.w d3,d6
    sub.w   d1,d6
    ext.l   d6
    move.w  d2,d7
    sub.w   d0,d7
    ext.l   d7
    swap    d7
    divs.l  d6,d7
    swap    d0
    move.w  #$8000,d0
    lea     edge_buf,a0
    lea     512(a0),a1
.te_lp: tst.w d1
    bmi.s   .te_st
    cmp.w   #255,d1
    bgt.s   .te_ex
    move.l  d0,d4
    swap    d4
    move.w  d1,d5
    add.w   d5,d5
    cmp.w   (a0,d5.w),d4
    bge.s   .chk_r
    move.w  d4,(a0,d5.w)
.chk_r: cmp.w (a1,d5.w),d4
    ble.s   .te_st
    move.w  d4,(a1,d5.w)
.te_st: add.l d7,d0
    addq.w  #1,d1
    cmp.w   d3,d1
    ble.s   .te_lp
.te_ex: rts

update_twilight_copper:
    move.l  cop_sky_ptr(pc),a2
    lea     twilight_grad(pc),a0
    moveq   #31,d4
.tw_lp:
    move.w  (a0)+,d1
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     20(a2),a2
    dbf     d4,.tw_lp
    rts

    even
orb_x:    dc.w 0
orb_y:    dc.w 0
orb_z:    dc.w 200
orb_sx:   dc.w 160
orb_sy:   dc.w 122
cur_px:   dc.w 0
cur_pz:   dc.w 100
p_sx1:    dc.w 0
p_sx2:    dc.w 0
p_sy1:    dc.w 0
p_sy2:    dc.w 0
tri_ymin: dc.w 0
tri_ymax: dc.w 0
twilight_grad:
    dc.w $0001,$0001,$0112,$0112,$0113,$0223,$0224,$0234,$0335,$0345,$0446,$0456,$0557,$0567,$0456,$0345,$0334,$0223,$0223,$0112,$0112,$0112,$0112,$0011,$0011,$0001,$0001,$0001,$0001,$0000,$0000,$0000
sphere_seeds:
    dc.w 90,34,144
    dc.w 57,23,184
    dc.w 211,14,90
    dc.w 231,30,169
    dc.w 24,10,171
    dc.w 104,21,39
    dc.w 162,27,43
    dc.w 21,7,89
    dc.w 170,20,44
    dc.w 25,30,207
    dc.w 64,10,179
    dc.w 233,28,155
    dc.w 225,13,168
    dc.w 92,22,174
    dc.w 56,19,41
    dc.w 199,14,66
    dc.w 143,11,254
    dc.w 179,17,69
    dc.w 191,13,181
    dc.w 72,6,141
    dc.w 126,26,65
    dc.w 115,26,217
    dc.w 160,19,174
    dc.w 208,36,74
    dc.w 236,20,167
    dc.w 153,23,101
    dc.w 20,32,15
    dc.w 231,38,18
    dc.w 127,20,119
    dc.w 142,38,195
    dc.w 239,34,181
    dc.w 129,17,140
    dc.w 128,8,223
    dc.w 111,13,103
    dc.w 108,8,92
    dc.w 131,13,72
    dc.w 70,19,89
    dc.w 159,8,21
    dc.w 227,22,171
    dc.w 164,12,96
    dc.w 234,25,35
    dc.w 182,34,7
    dc.w 119,30,75
    dc.w 182,35,165
    dc.w 72,33,79
    dc.w 59,34,55
    dc.w 125,31,26
    dc.w 21,28,179
    dc.w 6,21,10
    dc.w 143,24,241
    dc.w 136,9,1
    dc.w 157,7,215
    dc.w 122,17,51
    dc.w 141,9,44
    dc.w 151,15,58
    dc.w 4,17,168
    dc.w 204,10,202
    dc.w 230,35,157
    dc.w 239,23,238
    dc.w 107,29,220
    dc.w 109,16,163
    dc.w 30,27,251
    dc.w 69,28,108
    dc.w 151,16,97
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
