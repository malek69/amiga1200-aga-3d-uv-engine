; ============================================================================
;  PLIK / FILE: realtime_3d.i
;  OPIS: Scenariusz fabularny "Grotto 3D":
;        - Akt I (act1_full_3d_tunnel): przelot za i nad 3D swietlikiem przez
;          zamkniety tunel 3D (sufit, podloga, sciany) rozswietlany jego odwłokiem.
;        - Akt II (act2_full_3d_grotto): obracajaca sie kamera w ciemnej grocie
;          z jeziorkiem, wysepka, 3D drzewem, rusalka, wodospadem z mgielka
;          oraz dwoma kolorowymi swietlikami (zlotym i turkusowym).
; ============================================================================
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0002,2(a1)
    move.w  #$0247,6(a1)
    move.w  #$0369,10(a1)
    move.w  #$059c,14(a1)
    move.w  #$0258,18(a1)
    move.w  #$04de,22(a1)
    move.w  #$0fb3,26(a1)
    move.w  #$0fff,30(a1)
    move.l  vbl_tick(pc),d7
    cmp.l   #300,d7
    blo.w   act1_full_3d_tunnel
    bra.w   act2_full_3d_grotto
act1_full_3d_tunnel:
    clr.w   cam_ox
    clr.w   cam_oy
    clr.w   cam_oz
    clr.w   cam_sin
    move.w  #256,cam_cos
    move.w  d7,tex_scroll
    bsr.w   set_dark_sky
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    move.w  d1,l1_x
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #22,d2
    move.w  d2,l1_y
    move.w  #195,l1_z
    move.w  #999,l2_z
    move.w  d7,d6
    mulu.w  #6,d6
    moveq   #5,d4
.t_seg: move.w d4,d0
    mulu.w  #76,d0
    sub.w   d6,d0
    and.w   #$01ff,d0
    add.w   #185,d0
    move.w  d0,sz0
    add.w   #26,d0
    move.w  d0,sz1
    move.w  sz0(pc),d1
    lsr.w   #2,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   l1_x(pc),d2
    move.w  d2,sx0
    move.w  128(a2,d1.w*2),d2
    asr.w   #4,d2
    sub.w   l1_y(pc),d2
    move.w  d2,sy0
    move.w  sz1(pc),d1
    lsr.w   #2,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   l1_x(pc),d2
    move.w  d2,sx1
    move.w  128(a2,d1.w*2),d2
    asr.w   #4,d2
    sub.w   l1_y(pc),d2
    move.w  d2,sy1
    move.w  sx0(pc),d0
    move.w  sy0(pc),d1
    move.w  sz0(pc),d2
    bsr.w   calc_dual_light
    move.w  d0,slit
    bsr.w   emit_full_tunnel_box
    dbf     d4,.t_seg
    move.w  l1_x(pc),d0
    move.w  l1_y(pc),d1
    move.w  l1_z(pc),d2
    moveq   #6,d7
    bsr.w   draw_firefly_3d
    movem.l (sp)+,d0-d7/a0-a5
    rts
emit_full_tunnel_box:
    movem.l d0-d7/a0-a4,-(sp)
    move.w  sx0(pc),d0
    move.w  sy0(pc),d1
    move.w  sz0(pc),d2
    move.w  sx1(pc),d3
    move.w  sy1(pc),d4
    move.w  sz1(pc),d5
    ; 1. Lewa sciana
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d0,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    bsr.w   draw_qbuf_tex0
    ; 2. Prawa sciana
    lea     q_buf(pc),a4
    move.w  d0,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d0,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    bsr.w   draw_qbuf_tex0
    ; 3. Sufit tunelu
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d0,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    bsr.w   draw_qbuf_tex0
    ; 4. Podloga tunelu
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d0,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #118,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #90,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    bsr.w   draw_qbuf_tex0
    movem.l (sp)+,d0-d7/a0-a4
    rts
draw_qbuf_tex0:
    movem.l d0-d5,-(sp)
    lea     tri_tmp(pc),a1
    lea     q_buf(pc),a0
    move.l  (a0),(a1)+
    move.w  4(a0),(a1)+
    move.l  6(a0),(a1)+
    move.w  10(a0),(a1)+
    move.l  12(a0),(a1)+
    move.w  16(a0),(a1)+
    lea     tri_tmp(pc),a4
    moveq   #0,d6
    move.w  slit(pc),d7
    bsr.w   draw_hires_tri
    lea     tri_tmp(pc),a1
    lea     q_buf(pc),a0
    move.l  (a0),(a1)+
    move.w  4(a0),(a1)+
    move.l  12(a0),(a1)+
    move.w  16(a0),(a1)+
    move.l  18(a0),(a1)+
    move.w  22(a0),(a1)+
    lea     tri_tmp(pc),a4
    moveq   #0,d6
    move.w  slit(pc),d7
    bsr.w   draw_hires_tri
    movem.l (sp)+,d0-d5
    rts
act2_full_3d_grotto:
    lea     sin_tab,a2
    sub.l   #300,d7
    move.w  d7,tex_scroll
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),cam_sin
    move.w  128(a2,d1.w*2),cam_cos
    move.w  cam_sin(pc),d2
    neg.w   d2
    asr.w   #1,d2
    move.w  d2,cam_ox
    move.w  #-12,cam_oy
    clr.w   cam_oz
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1
    move.w  d1,l1_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #2,d2
    add.w   #250,d2
    move.w  d2,l1_z
    move.w  d7,d1
    mulu.w  #3,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   #12,d2
    move.w  d2,l1_y
    add.w   #128,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1
    move.w  d1,l2_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #2,d2
    add.w   #250,d2
    move.w  d2,l2_z
    neg.w   d2
    add.w   #240,d2
    move.w  d2,l2_y
    bsr.w   set_grotto_sky
    lea     grotto_scene_mesh(pc),a4
    move.w  (a4)+,d4
.gm_lp: move.w (a4)+,d6
    move.w  (a4)+,d5
    bne.s   .has_lit
    move.w  (a4),d0
    add.w   6(a4),d0
    add.w   12(a4),d0
    divs.w  #3,d0
    move.w  2(a4),d1
    add.w   8(a4),d1
    add.w   14(a4),d1
    divs.w  #3,d1
    move.w  4(a4),d2
    add.w   10(a4),d2
    add.w   16(a4),d2
    divs.w  #3,d2
    bsr.w   calc_dual_light
    move.w  d0,d5
.has_lit: move.w d5,d7
    bsr.w   draw_hires_tri
    lea     18(a4),a4
    dbf     d4,.gm_lp
    bsr.w   draw_rusalka_3d
    bsr.w   draw_mist_3d
    move.w  l1_x(pc),d0
    move.w  l1_y(pc),d1
    move.w  l1_z(pc),d2
    moveq   #6,d7
    bsr.w   draw_firefly_3d
    move.w  l2_x(pc),d0
    move.w  l2_y(pc),d1
    move.w  l2_z(pc),d2
    moveq   #5,d7
    bsr.w   draw_firefly_3d
    movem.l (sp)+,d0-d7/a0-a5
    rts
draw_firefly_3d:
    move.w  d7,ff_col
    bsr.w   proj_3d_cam
    cmp.w   #8,d0
    blo.w   .ff_ex
    cmp.w   #311,d0
    bhi.w   .ff_ex
    cmp.w   #8,d1
    blo.w   .ff_ex
    cmp.w   #246,d1
    bhi.w   .ff_ex
    move.w  d0,ff_px
    move.w  d1,ff_py
    subq.w  #2,d1
    moveq   #4,d5
.fy: move.w ff_px(pc),d0
    subq.w  #2,d0
    moveq   #4,d4
.fx: move.w ff_col(pc),d7
    bsr.s   plot_aga_px
    addq.w  #1,d0
    dbf     d4,.fx
    addq.w  #1,d1
    dbf     d5,.fy
    move.w  ff_py(pc),d1
    subq.w  #1,d1
    moveq   #2,d5
.cy: move.w ff_px(pc),d0
    subq.w  #1,d0
    moveq   #2,d4
.cx: moveq #7,d7
    bsr.s   plot_aga_px
    addq.w  #1,d0
    dbf     d4,.cx
    addq.w  #1,d1
    dbf     d5,.cy
.ff_ex: rts
plot_aga_px:
    move.w  d1,d2
    mulu.w  #40,d2
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d2
    move.w  d0,d3
    not.w   d3
    and.w   #7,d3
    btst    #0,d7
    beq.s   .p1
    move.l  draw_bpl1(pc),a3
    bset    d3,(a3,d2.l)
.p1: btst #1,d7
    beq.s   .p2
    move.l  draw_bpl2(pc),a3
    bset    d3,(a3,d2.l)
.p2: btst #2,d7
    beq.s   .p3
    move.l  draw_bpl3(pc),a3
    bset    d3,(a3,d2.l)
.p3: rts
draw_rusalka_3d:
    move.w  #-14,d0
    move.w  #26,d1
    move.w  #246,d2
    bsr.w   proj_3d_cam
    move.w  d0,rs_x
    move.w  d1,rs_y
    lea     rusalka_bmp(pc),a0
    moveq   #21,d5
.ry: move.w (a0)+,d4
    move.w  rs_x(pc),d0
    moveq   #15,d6
.rx: btst d6,d4
    beq.s   .rn
    move.w  rs_y(pc),d1
    moveq   #7,d7
    bsr.s   plot_aga_px
.rn: addq.w #1,d0
    dbf     d6,.rx
    addq.w  #1,rs_y
    dbf     d5,.ry
    rts
draw_mist_3d:
    move.l  vbl_tick(pc),d6
    lea     mist_pts(pc),a4
    moveq   #15,d5
.ms: move.w (a4)+,d0
    move.w  (a4)+,d1
    add.w   d6,d1
    and.w   #$1f,d1
    neg.w   d1
    add.w   #46,d1
    move.w  #268,d2
    bsr.w   proj_3d_cam
    cmp.w   #318,d0
    bhi.s   .mn
    cmp.w   #252,d1
    bhi.s   .mn
    moveq   #5,d7
    bsr.w   plot_aga_px
.mn: dbf d5,.ms
    rts
set_dark_sky:
    move.l  cop_sky_ptr(pc),a2
    moveq   #31,d4
.sd: move.w #$0001,6(a2)
    move.w  #$0001,14(a2)
    lea     20(a2),a2
    dbf     d4,.sd
    rts
set_grotto_sky:
    move.l  cop_sky_ptr(pc),a2
    lea     grotto_grad(pc),a0
    moveq   #31,d4
.sg: move.w (a0)+,d1
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     20(a2),a2
    dbf     d4,.sg
    rts
    even
sz0: dc.w 60
sz1: dc.w 110
sx0: dc.w 0
sy0: dc.w 0
sx1: dc.w 0
sy1: dc.w 0
slit: dc.w 1
ff_col: dc.w 6
ff_px: dc.w 160
ff_py: dc.w 124
rs_x: dc.w 150
rs_y: dc.w 140
q_buf: ds.w 12
tri_tmp: ds.w 9
grotto_grad: dc.w $0001,$0001,$0012,$0013,$0113,$0124,$0124,$0135,$0135,$0124,$0124,$0113,$0013,$0012,$0002,$0002,$0012,$0124,$0135,$0146,$0146,$0135,$0124,$0023,$0012,$0012,$0001,$0001,$0001,$0000,$0000,$0000
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
grotto_scene_mesh:
    dc.w 17
    dc.w 0,0, -190,-125,270, -80,-125,270, -120,50,250
    dc.w 0,0, -190,-125,270, -120,50,250, -190,50,250
    dc.w 0,0, 90,-125,270, 190,-125,270, 125,50,250
    dc.w 0,0, 190,-125,270, 190,50,250, 125,50,250
    dc.w 0,0, -100,-125,270, -50,-125,270, -75,-60,260
    dc.w 0,0, 45,-125,270, 95,-125,270, 70,-65,260
    dc.w 1,4, -175,48,200, 175,48,200, 195,92,340
    dc.w 1,4, -175,48,200, 195,92,340, -195,92,340
    dc.w 1,5, 82,-62,275, 91,-62,275, 94,48,270
    dc.w 1,5, 82,-62,275, 94,48,270, 80,48,270
    dc.w 0,0, -58,48,255, 58,48,255, 42,36,245
    dc.w 0,0, -58,48,255, 42,36,245, -42,36,245
    dc.w 0,2, -5,38,250, 6,38,250, 4,-18,250
    dc.w 0,2, -5,38,250, 4,-18,250, -4,-18,250
    dc.w 2,0, -54,-10,250, 54,-10,250, 0,-54,245
    dc.w 2,0, -42,-28,252, 42,-28,252, 0,-68,248
    dc.w 2,0, -28,-44,254, 28,-44,254, 0,-82,250
    dc.w 0,1, -180,50,245, -120,50,245, -150,36,240
mist_pts: dc.w 74,0,78,7,82,14,86,21,90,3,94,10,98,18,76,25,80,12,84,19,88,27,92,4,96,11,75,20,83,28,91,6
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
