; [EN/PL] MODULE: realtime_3d.i | Grotto 3D (2026 Edition: Continuous 3D Tunnel + High-Poly Shaded Grotto)
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)            ; COLOR00: gleboki mrok
    move.w  #$0113,6(a1)            ; COLOR01: gleboki cien kamienia / wody
    move.w  #$0225,10(a1)           ; COLOR02: mokra skala w polcieniu
    move.w  #$0347,14(a1)           ; COLOR03: oswietlona skala / mech
    move.w  #$0136,18(a1)           ; COLOR04: gleboka woda jeziora
    move.w  #$04bc,22(a1)           ; COLOR05: turkusowy blask / wodospad
    move.w  #$0b72,26(a1)           ; COLOR06: cieple bursztynowe swiatlo swietlika
    move.w  #$0ffd,30(a1)           ; COLOR07: jasny blask swietlika / rusalka
    move.l  vbl_tick(pc),d7
    cmp.l   #320,d7
    blo.w   act1_full_3d_tunnel
    bra.w   act2_full_3d_grotto
act1_full_3d_tunnel:
    clr.w   cam_ox
    clr.w   cam_oy
    clr.w   cam_oz
    clr.w   cam_sin
    move.w  #256,cam_cos
    move.w  d7,tex_scroll
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
    add.w   #20,d2
    move.w  d2,l1_y
    move.w  #165,l1_z
    move.w  #999,l2_z
    ; 10 ciaglych segmentow 3D tunelu (krok 48, glebokosc 50 -> brak dziur, 80 trojkatow/klatke!)
    move.w  d7,d6
    mulu.w  #7,d6
    moveq   #9,d4
.t_seg: move.w d4,d0
    mulu.w  #48,d0
    sub.w   d6,d0
    and.w   #$01ff,d0
    add.w   #75,d0
    move.w  d0,sz0
    add.w   #54,d0
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
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    bsr.w   draw_qbuf_tex0
    lea     q_buf(pc),a4
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    bsr.w   draw_qbuf_tex0
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    bsr.w   draw_qbuf_tex0
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
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
    sub.l   #320,d7
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
    move.w  #-10,cam_oy
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
    cmp.w   #16,d0
    blo.w   .ff_ex
    cmp.w   #303,d0
    bhi.w   .ff_ex
    cmp.w   #16,d1
    blo.w   .ff_ex
    cmp.w   #238,d1
    bhi.w   .ff_ex
    move.w  d0,ff_px
    move.w  d1,ff_py
    ; Trzepoczace skrzydelka + promienie swiatla
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d6
    lsl.w   #4,d6
    and.w   #$ff,d6
    move.w  (a2,d6.w*2),d5
    asr.w   #5,d5
    move.w  ff_px(pc),d0
    sub.w   #10,d0
    move.w  ff_py(pc),d1
    add.w   d5,d1
    subq.w  #4,d1
    move.w  ff_col(pc),d7
    bsr.s   plot_aga_px
    addq.w  #1,d0
    bsr.s   plot_aga_px
    move.w  ff_px(pc),d0
    add.w   #10,d0
    bsr.s   plot_aga_px
    subq.w  #1,d0
    bsr.s   plot_aga_px
    ; Duza poswiata 13x13 + krzyz promieni wokol swietlika
    move.w  ff_py(pc),d1
    subq.w  #6,d1
    moveq   #12,d5
.fy: move.w ff_px(pc),d0
    subq.w  #6,d0
    moveq   #12,d4
.fx: move.w ff_col(pc),d7
    bsr.s   plot_aga_px
    addq.w  #1,d0
    dbf     d4,.fx
    addq.w  #1,d1
    dbf     d5,.fy
    ; Jasny bialy rdzen 3x3 (COLOR07)
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
    moveq   #0,d2
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
    moveq   #7,d7
    bsr.w   plot_aga_px
.mn: dbf d5,.ms
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
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
grotto_scene_mesh:
    dc.w 30
    dc.w 0,0,-210,-130,275,-80,-130,275,-135,50,245
    dc.w 0,0,-210,-130,275,-135,50,245,-210,50,245
    dc.w 0,0,95,-130,275,210,-130,275,135,50,245
    dc.w 0,0,210,-130,275,210,50,245,135,50,245
    dc.w 0,0,-140,-130,275,140,-130,275,0,-95,280
    dc.w 0,0,-110,-125,265,-75,-125,265,-92,-62,258
    dc.w 0,0,-55,-125,270,-25,-125,270,-40,-75,264
    dc.w 0,0,20,-125,270,52,-125,270,36,-72,264
    dc.w 0,0,62,-125,265,98,-125,265,80,-58,258
    dc.w 1,4,-200,48,225,200,48,225,215,98,305
    dc.w 1,4,-200,48,225,215,98,305,-215,98,305
    dc.w 1,5,62,50,252,114,50,252,122,74,275
    dc.w 1,5,62,50,252,122,74,275,58,74,275
    dc.w 1,6,-32,52,255,32,52,255,42,76,280
    dc.w 3,1,-68,50,246,68,50,246,54,62,262
    dc.w 3,1,-68,50,246,54,62,262,-54,62,262
    dc.w 1,5,82,-64,274,92,-64,274,95,48,268
    dc.w 1,5,82,-64,274,95,48,268,80,48,268
    dc.w 0,0,-64,48,252,64,48,252,46,35,242
    dc.w 0,0,-64,48,252,46,35,242,-46,35,242
    dc.w 0,2,-46,35,242,46,35,242,0,30,238
    dc.w 0,2,-6,36,248,7,36,248,4,-20,248
    dc.w 0,2,-6,36,248,4,-20,248,-4,-20,248
    dc.w 0,2,-3,-10,248,-28,-28,246,-22,-32,246
    dc.w 0,2,3,-12,248,30,-28,246,24,-32,246
    dc.w 2,0,-62,-8,248,62,-8,248,0,-48,242
    dc.w 2,0,-52,-22,250,52,-22,250,0,-64,244
    dc.w 2,0,-38,-38,252,38,-38,252,0,-78,246
    dc.w 2,0,-24,-54,254,24,-54,254,0,-90,248
    dc.w 0,0,-185,50,242,-110,50,242,-148,32,236
    dc.w 0,0,115,50,242,185,50,242,150,34,236
mist_pts: dc.w 74,0,78,7,82,14,86,21,90,3,94,10,98,18,76,25,80,12,84,19,88,27,92,4,96,11,75,20,83,28,91,6
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
