; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | GROTA 3D: Tunnel Firefly -> Wet Grotto, Waterfall Mist, Island Tree, Rusalka & 2 Colorful Fireflies
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d7
    cmp.l   #400,d7
    blo.w   act1_tunnel
    bra.w   act2_grotto

act1_tunnel:
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0002,2(a1)            ; COLOR00 (gleboki mrok tunelu)
    move.w  #$0235,6(a1)            ; COLOR01 (BPL1 mokre, szaro-blekitne skaly tunelu)
    move.w  #$0795,10(a1)           ; COLOR02 (BPL2 poswiata na krawedziach od swietlika)
    move.w  #$0fe6,14(a1)           ; COLOR03 (BPL1+BPL2 jasny zloty rdzen swietlika)
    move.w  #$0124,18(a1)           ; COLOR04 (Blitter AA)
    bsr.w   update_tunnel_copper

    ; Pozycja 3D prowadzacego swietlika (kamera leci za nim i troche nad nim)
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1                   ; lead_x (-32..+32)
    move.w  d1,lead_x
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #20,d2                  ; lead_y (+4..+36 -> kamera lekko nad swietlikiem)
    move.w  d2,lead_y

    ; 12 skalistych zeber tunelu przelatujacych obok kamery (od najdalszego do najblizszego)
    move.w  d7,d6
    mulu.w  #6,d6
    moveq   #11,d4
.tun_lp:
    move.w  d4,d0
    lsl.w   #6,d0
    sub.w   d6,d0
    and.w   #$02ff,d0
    add.w   #85,d0                  ; Z = 85..852
    move.w  d0,cur_pz

    move.w  d0,d1
    lsr.w   #3,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #4,d2
    sub.w   lead_x(pc),d2
    move.w  d2,cur_px

    move.l  draw_bpl1(pc),a3
    bsr.w   draw_tunnel_arch
    dbf     d4,.tun_lp

    ; Prowadzacy swietlik + ogon iskier przed kamera
    move.w  lead_x(pc),d0
    move.w  lead_y(pc),d1
    move.w  #175,d2
    bsr.w   draw_glowing_firefly
    move.w  lead_x(pc),d0
    asr.w   #1,d0
    move.w  lead_y(pc),d1
    subq.w  #4,d1
    move.w  #150,d2
    bsr.w   draw_glowing_firefly
    movem.l (sp)+,d0-d7/a0-a5
    rts

draw_tunnel_arch:
    move.w  cur_pz(pc),d2
    ext.l   d2
    ; Lewa sciana tunelu: od X-135 do X-44
    move.w  cur_px(pc),d0
    sub.w   #135,d0
    muls.w  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx1
    move.w  cur_px(pc),d0
    sub.w   #44,d0
    muls.w  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx2
    move.l  #-85*250,d0
    divs.l  d2,d0
    add.w   #122,d0
    move.w  d0,p_sy1
    move.l  #95*250,d0
    divs.l  d2,d0
    add.w   #122,d0
    move.w  d0,p_sy2
    bsr.w   draw_quad_p
    ; Jasna krawedz oswietlona przez swietlika (BPL2)
    move.l  draw_bpl2(pc),a3
    move.w  p_sx2(pc),d0
    subq.w  #4,d0
    move.w  d0,p_sx1
    bsr.w   draw_quad_p

    ; Prawa sciana tunelu: od X+44 do X+135
    move.l  draw_bpl1(pc),a3
    move.w  cur_pz(pc),d2
    ext.l   d2
    move.w  cur_px(pc),d0
    add.w   #44,d0
    muls.w  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx1
    move.w  cur_px(pc),d0
    add.w   #135,d0
    muls.w  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx2
    bsr.w   draw_quad_p
    move.l  draw_bpl2(pc),a3
    move.w  p_sx1(pc),d0
    addq.w  #4,d0
    move.w  d0,p_sx2
    bsr.w   draw_quad_p
    rts

act2_grotto:
    lea     sin_tab,a2
    sub.l   #400,d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d5
    asr.w   #4,d5
    move.w  d5,cam_x

    ; Dwa kolorowe swietliki latajace w kolo drzewa i rusalki
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1
    move.w  d1,ff1_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #2,d2
    add.w   #250,d2
    move.w  d2,ff1_z
    move.w  d7,d1
    mulu.w  #3,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   #10,d2
    move.w  d2,ff1_y

    add.w   #128,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1
    move.w  d1,ff2_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #2,d2
    add.w   #250,d2
    move.w  d2,ff2_z
    neg.w   d2
    add.w   #245,d2
    move.w  d2,ff2_y

    ; Kolorowe oswietlenie groty przez 2 swietliki (zloty i turkusowo-szmaragdowy)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0002,2(a1)            ; COLOR00 (ciemna mokra grota)
    move.w  #$0234,6(a1)            ; COLOR01 (BPL1 wilgotne skaly, wysepka, pien drzewa)
    cmp.w   #250,ff1_z
    bge.s   .col_cyan
    move.w  #$0a72,10(a1)           ; COLOR02: cieple zlote swiatlo w grocie i na wodzie
    move.w  #$0fe6,14(a1)           ; COLOR03: jasny zloty blask + rusalka
    bra.s   .col_ok
.col_cyan:
    move.w  #$039a,10(a1)           ; COLOR02: szmaragdowo-turkusowy blask drugiego swietlika
    move.w  #$07fe,14(a1)           ; COLOR03: jasny turkusowy blask + rusalka
.col_ok:
    move.w  #$0124,18(a1)
    bsr.w   update_grotto_copper

    ; 1. Ciemne, mokre sciany groty i stalaktyty (BPL1)
    move.l  draw_bpl1(pc),a3
    lea     grotto_walls(pc),a4
    moveq   #5,d7
.gw_lp: bsr.w draw_mesh_poly
    dbf     d7,.gw_lp

    ; 2. Tafla jeziorka + cienki wodospad + szumiaca mgielka nad woda (BPL2)
    move.l  draw_bpl2(pc),a3
    lea     lake_poly(pc),a4
    bsr.w   draw_mesh_poly
    lea     thin_waterfall(pc),a4
    bsr.w   draw_mesh_poly
    bsr.w   render_waterfall_mist

    ; 3. Wysepka na srodku jeziorka + drzewo
    move.l  draw_bpl1(pc),a3
    lea     island_and_tree_b1(pc),a4
    moveq   #3,d7
.tr1_lp: bsr.w draw_mesh_poly
    dbf     d7,.tr1_lp
    move.l  draw_bpl2(pc),a3
    lea     tree_crown_glow(pc),a4
    moveq   #1,d7
.tr2_lp: bsr.w draw_mesh_poly
    dbf     d7,.tr2_lp

    ; 4. Ladna Rusalka przy drzewie + 2 kolorowe swietliki latajace w kolo drzewa
    bsr.w   draw_rusalka_sprite
    move.w  ff1_x(pc),d0
    move.w  ff1_y(pc),d1
    move.w  ff1_z(pc),d2
    bsr.w   draw_glowing_firefly
    move.w  ff2_x(pc),d0
    move.w  ff2_y(pc),d1
    move.w  ff2_z(pc),d2
    bsr.w   draw_glowing_firefly

    movem.l (sp)+,d0-d7/a0-a5
    rts

draw_mesh_poly:
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_grotto_pt
    move.w  d0,-(sp)
    move.w  d1,-(sp)
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_grotto_pt
    move.w  d0,-(sp)
    move.w  d1,-(sp)
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_grotto_pt
    move.w  d0,d4
    move.w  d1,d5
    move.w  (sp)+,d3
    move.w  (sp)+,d2
    move.w  (sp)+,d1
    move.w  (sp)+,d0
    bsr.w   fill_tri_clean
    rts

proj_grotto_pt:
    sub.w   cam_x(pc),d0
    muls.w  #260,d0
    muls.w  #260,d1
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #118,d1
    rts

draw_rusalka_sprite:
    move.w  #-14,d0
    move.w  #28,d1
    move.w  #242,d2
    bsr.s   proj_grotto_pt
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    lea     rusalka_bitmap(pc),a0
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    and.w   #$fffe,d3
    add.w   d3,d1
    add.l   d1,a2
    add.l   d1,a3
    and.w   #15,d0
    moveq   #21,d7
.rs_lp: moveq #0,d2
    move.w  (a0)+,d2
    swap    d2
    lsr.l   d0,d2
    or.l    d2,(a2)
    or.l    d2,(a3)
    lea     40(a2),a2
    lea     40(a3),a3
    dbf     d7,.rs_lp
    rts

render_waterfall_mist:
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7
    lea     mist_seeds(pc),a4
    moveq   #23,d6
.wf_dr: move.w (a4)+,d0
    and.w   #7,d0
    add.w   #78,d0
    move.w  (a4)+,d1
    add.w   d7,d1
    add.w   d7,d1
    and.w   #$3f,d1
    sub.w   #45,d1
    move.w  #272,d2
    bsr.w   proj_grotto_pt
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a2,d1.l)
    bset    d0,(a3,d1.l)
    bset    d0,40(a3,d1.l)
    dbf     d6,.wf_dr

    moveq   #35,d6
.ms_lp: move.w (a4)+,d0
    asr.w   #1,d0
    add.w   #72,d0
    move.w  (a4)+,d1
    add.w   d7,d1
    and.w   #$1f,d1
    neg.w   d1
    add.w   #46,d1
    move.w  #268,d2
    bsr.w   proj_grotto_pt
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)
    dbf     d6,.ms_lp
    rts

draw_glowing_firefly:
    bsr.w   proj_grotto_pt
    cmp.w   #4,d0
    blo.s   .gf_ex
    cmp.w   #315,d0
    bhi.s   .gf_ex
    cmp.w   #4,d1
    blo.s   .gf_ex
    cmp.w   #248,d1
    bhi.s   .gf_ex
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    move.w  d0,d4
    not.w   d4
    and.w   #7,d4
    bset    d4,(a2,d1.l)
    bset    d4,(a3,d1.l)
    bset    d4,-40(a3,d1.l)
    bset    d4,40(a3,d1.l)
    subq.w  #1,d0
    move.w  d0,d3
    lsr.w   #3,d3
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)
.gf_ex: rts

draw_quad_p:
    move.w  p_sx1(pc),d0
    move.w  p_sy1(pc),d1
    move.w  p_sx2(pc),d2
    move.w  p_sy1(pc),d3
    move.w  p_sx2(pc),d4
    move.w  p_sy2(pc),d5
    bsr.s   fill_tri_clean
    move.w  p_sx1(pc),d0
    move.w  p_sy1(pc),d1
    move.w  p_sx2(pc),d2
    move.w  p_sy2(pc),d3
    move.w  p_sx1(pc),d4
    move.w  p_sy2(pc),d5
    bsr.s   fill_tri_clean
    rts

fill_tri_clean:
    movem.l d0-d7/a0-a2,-(sp)
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

    movem.w d0-d5,-(sp)
    bsr.w   .tri_edge
    movem.w (sp),d0-d5
    move.w  d2,d0
    move.w  d3,d1
    move.w  d4,d2
    move.w  d5,d3
    bsr.w   .tri_edge
    movem.w (sp)+,d0-d5
    move.w  d4,d2
    move.w  d5,d3
    bsr.w   .tri_edge

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
.fl_y: move.w (a0)+,d0
    move.w  (a1)+,d1
    cmp.w   d0,d1
    blt.s   .fl_nx
    tst.w   d0
    bpl.s   .xl_ok
    moveq   #0,d0
.xl_ok: cmp.w #319,d1
    ble.s   .xr_ok
    move.w  #319,d1
.xr_ok: sub.w d0,d1
    bmi.s   .fl_nx
    addq.w  #1,d1
    ext.l   d0
.bf_lp: cmp.w #32,d1
    ble.s   .bf_last
    bfset   (a2){d0:0}
    add.l   #32,d0
    sub.w   #32,d1
    bra.s   .bf_lp
.bf_last: bfset (a2){d0:d1}
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

update_tunnel_copper:
    move.l  cop_sky_ptr(pc),a2
    moveq   #31,d4
.tc_lp: move.w #$0002,6(a2)
    move.w  #$0002,14(a2)
    lea     20(a2),a2
    dbf     d4,.tc_lp
    rts

update_grotto_copper:
    move.l  cop_sky_ptr(pc),a2
    lea     grotto_grad(pc),a0
    moveq   #31,d4
.gc_lp: move.w (a0)+,d1
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     20(a2),a2
    dbf     d4,.gc_lp
    rts
    even
lead_x: dc.w 0
lead_y: dc.w 16
cam_x:  dc.w 0
ff1_x:  dc.w 0
ff1_y:  dc.w 0
ff1_z:  dc.w 220
ff2_x:  dc.w 0
ff2_y:  dc.w 0
ff2_z:  dc.w 280
cur_px: dc.w 0
cur_pz: dc.w 100
p_sx1:  dc.w 0
p_sx2:  dc.w 0
p_sy1:  dc.w 0
p_sy2:  dc.w 0
tri_ymin: dc.w 0
tri_ymax: dc.w 0
grotto_grad:
    dc.w $0002,$0002,$0012,$0013,$0113,$0124,$0124,$0135,$0135,$0124,$0124,$0113,$0013,$0012,$0002,$0002,$0012,$0124,$0135,$0146,$0257,$0268,$0257,$0146,$0134,$0023,$0012,$0012,$0002,$0002,$0001,$0001
rusalka_bitmap:
    dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
grotto_walls:
    dc.w -180,-120,260, -85,-120,260, -115,52,260
    dc.w -180,-120,260, -115,52,260, -180,52,260
    dc.w 95,-120,260, 180,-120,260, 120,52,260
    dc.w 180,-120,260, 180,52,260, 120,52,260
    dc.w -95,-120,260, -55,-120,260, -75,-65,260
    dc.w 45,-120,260, 88,-120,260, 66,-70,260
lake_poly:
    dc.w -155,48,220, 155,48,220, 165,86,330
    dc.w -155,48,220, 165,86,330, -165,86,330
thin_waterfall:
    dc.w 78,-55,275, 86,-55,275, 88,48,275
    dc.w 78,-55,275, 88,48,275, 76,48,275
island_and_tree_b1:
    dc.w -52,48,250, 52,48,250, 38,38,250
    dc.w -52,48,250, 38,38,250, -38,38,250
    dc.w -4,40,250, 5,40,250, 3,-18,250
    dc.w -4,40,250, 3,-18,250, -3,-18,250
tree_crown_glow:
    dc.w -48,-12,250, 48,-12,250, 0,-56,250
    dc.w -36,-28,250, 36,-28,250, 0,-68,250
mist_seeds:
    dc.w -38,54
    dc.w 99,4
    dc.w -61,59
    dc.w -18,31
    dc.w 119,16
    dc.w -112,40
    dc.w -66,31
    dc.w 102,59
    dc.w 85,34
    dc.w -35,21
    dc.w -58,48
    dc.w 5,6
    dc.w 50,29
    dc.w -76,0
    dc.w -55,56
    dc.w 41,34
    dc.w 32,23
    dc.w 72,20
    dc.w -118,48
    dc.w -93,37
    dc.w -51,34
    dc.w -29,59
    dc.w 83,15
    dc.w -37,1
    dc.w 16,6
    dc.w -33,26
    dc.w 104,25
    dc.w -114,26
    dc.w -93,54
    dc.w 74,16
    dc.w -7,53
    dc.w 9,41
    dc.w 76,1
    dc.w 60,36
    dc.w -10,31
    dc.w -68,7
    dc.w 41,8
    dc.w 50,10
    dc.w -112,33
    dc.w -25,29
    dc.w -10,56
    dc.w -80,6
    dc.w -71,47
    dc.w 56,5
    dc.w -53,0
    dc.w -79,5
    dc.w 100,46
    dc.w -73,48
    dc.w -14,18
    dc.w 61,58
    dc.w -61,11
    dc.w -70,26
    dc.w -106,0
    dc.w -63,8
    dc.w 25,11
    dc.w -96,56
    dc.w -33,55
    dc.w -108,48
    dc.w 35,49
    dc.w -16,18
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
