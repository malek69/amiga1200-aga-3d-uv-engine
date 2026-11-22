; [EN/PL] MODULE: realtime_3d.i | 3D Textured Tunnel Flight Behind Firefly -> Wet Grotto with Rusalka
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d7
    cmp.l   #450,d7
    blo.w   act1_tunnel
    bra.w   act2_grotto
act1_tunnel:
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)
    move.w  #$0124,6(a1)            ; COLOR01: ciemna mokra skala
    move.w  #$0a72,10(a1)           ; COLOR02: cieple zlote swiatlo od tylka swietlika
    move.w  #$0fe6,14(a1)           ; COLOR03: jasny rdzen swietlika
    move.w  #$0113,18(a1)
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    move.w  d1,light_x
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #24,d2
    move.w  d2,light_y
    move.w  #160,light_z
    bsr.w   update_tunnel_copper
    ; 10 oteksturowanych segmentow tunelu 3D (lewa i prawa sciana skalna oswietlana przez swietlika)
    move.w  d7,d6
    mulu.w  #5,d6
    moveq   #9,d4
.seg_lp:
    move.w  d4,d0
    mulu.w  #48,d0
    sub.w   d6,d0
    and.w   #$01ff,d0
    add.w   #55,d0                  ; Z_front = 55..566
    move.w  d0,seg_z0
    add.w   #46,d0
    move.w  d0,seg_z1
    ; Zakret tunelu
    move.w  seg_z0(pc),d1
    lsr.w   #2,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   light_x(pc),d2
    move.w  d2,seg_x0
    move.w  seg_z1(pc),d1
    lsr.w   #2,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   light_x(pc),d2
    move.w  d2,seg_x1
    ; Oblicz oswietlenie 3D z odwłoka swietlika dla tego segmentu
    move.w  seg_x0(pc),d0
    moveq   #0,d1
    move.w  seg_z0(pc),d2
    bsr.w   calc_3d_light
    move.w  d0,seg_lit
    bsr.w   draw_textured_tunnel_seg
    dbf     d4,.seg_lp
    bsr.w   draw_3d_firefly
    movem.l (sp)+,d0-d7/a0-a5
    rts
draw_textured_tunnel_seg:
    movem.l d4/d6-d7,-(sp)
    ; Lewa sciana tunelu (2 oteksturowane trojkaty z tekstura mokrej skaly tex_id=0)
    lea     tmp_tri(pc),a4
    move.w  seg_x0(pc),d0
    sub.w   #62,d0
    move.w  d0,(a4)+
    move.w  #-75,(a4)+
    move.w  seg_z0(pc),(a4)+
    move.w  seg_x1(pc),d0
    sub.w   #62,d0
    move.w  d0,(a4)+
    move.w  #-75,(a4)+
    move.w  seg_z1(pc),(a4)+
    move.w  seg_x1(pc),d0
    sub.w   #62,d0
    move.w  d0,(a4)+
    move.w  #85,(a4)+
    move.w  seg_z1(pc),(a4)+
    lea     tmp_tri(pc),a4
    moveq   #0,d6
    move.w  seg_lit(pc),d7
    bsr.w   draw_tex_tri
    ; Prawa sciana tunelu
    lea     tmp_tri(pc),a4
    move.w  seg_x0(pc),d0
    add.w   #62,d0
    move.w  d0,(a4)+
    move.w  #-75,(a4)+
    move.w  seg_z0(pc),(a4)+
    move.w  seg_x1(pc),d0
    add.w   #62,d0
    move.w  d0,(a4)+
    move.w  #85,(a4)+
    move.w  seg_z1(pc),(a4)+
    move.w  seg_x1(pc),d0
    add.w   #62,d0
    move.w  d0,(a4)+
    move.w  #-75,(a4)+
    move.w  seg_z1(pc),(a4)+
    lea     tmp_tri(pc),a4
    moveq   #0,d6
    move.w  seg_lit(pc),d7
    bsr.w   draw_tex_tri
    movem.l (sp)+,d4/d6-d7
    rts
draw_3d_firefly:
    move.w  light_x(pc),d0
    move.w  light_y(pc),d1
    move.w  light_z(pc),d2
    bsr.w   proj_3d
    move.w  d0,fb_x
    move.w  d1,fb_y
    ; Trzepoczace skrzydelka 3D (BPL2)
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    lsl.w   #4,d7
    and.w   #$ff,d7
    move.w  (a2,d7.w*2),d5
    asr.w   #5,d5
    move.l  draw_bpl2(pc),a3
    move.w  fb_x(pc),d0
    sub.w   #11,d0
    move.w  fb_y(pc),d1
    add.w   d5,d1
    subq.w  #4,d1
    bsr.s   plot_safe
    move.w  fb_x(pc),d0
    add.w   #11,d0
    bsr.s   plot_safe
    ; Swiecacy odwlok swietlika (poswiata 5x5 na BPL2 + jasny rdzen 3x3 BPL1+BPL2)
    move.w  fb_y(pc),d1
    subq.w  #1,d1
    moveq   #4,d5
.gy: move.w fb_x(pc),d0
    subq.w  #2,d0
    moveq   #4,d4
.gx: bsr.s plot_safe
    addq.w  #1,d0
    dbf     d4,.gx
    addq.w  #1,d1
    dbf     d5,.gy
    move.l  draw_bpl1(pc),a3
    move.w  fb_y(pc),d1
    moveq   #2,d5
.cy: move.w fb_x(pc),d0
    subq.w  #1,d0
    moveq   #2,d4
.cx: bsr.s plot_safe
    addq.w  #1,d0
    dbf     d4,.cx
    addq.w  #1,d1
    dbf     d5,.cy
    rts
plot_safe:
    cmp.w   #319,d0
    bhi.s   .ps_no
    cmp.w   #254,d1
    bhi.s   .ps_no
    move.w  d1,d2
    mulu.w  #40,d2
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d2
    move.w  d0,d3
    not.w   d3
    and.w   #7,d3
    bset    d3,(a3,d2.l)
.ps_no: rts
act2_grotto:
    lea     sin_tab,a2
    sub.l   #450,d7
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
    sub.w   #8,d2
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
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)
    move.w  #$0123,6(a1)
    cmp.w   #250,ff1_z
    bge.s   .col_c
    move.w  #$0962,10(a1)
    move.w  #$0fe5,14(a1)
    bra.s   .col_o
.col_c: move.w #$0289,10(a1)
    move.w  #$06fe,14(a1)
.col_o: move.w #$0112,18(a1)
    bsr.w   update_grotto_copper
    ; 1. Oteksturowane sciany groty (tex 0 = mokra skala)
    lea     grotto_tris(pc),a4
    moveq   #5,d4
.gt_lp: moveq #0,d6
    moveq   #1,d7
    bsr.w   draw_tex_tri
    lea     18(a4),a4
    dbf     d4,.gt_lp
    ; 2. Oteksturowana tafla jeziorka (tex 1 = falujaca woda) + cienki wodospad z mgielka
    lea     lake_tris(pc),a4
    moveq   #1,d4
.lk_lp: moveq #1,d6
    moveq   #2,d7
    bsr.w   draw_tex_tri
    lea     18(a4),a4
    dbf     d4,.lk_lp
    lea     wf_tris(pc),a4
    moveq   #1,d4
.wf_lp: moveq #1,d6
    moveq   #2,d7
    bsr.w   draw_tex_tri
    lea     18(a4),a4
    dbf     d4,.wf_lp
    bsr.w   render_mist_particles
    ; 3. Wysepka i drzewo (tex 2 = liscie i mech) + Rusalka + 2 kolorowe swietliki
    lea     tree_tris(pc),a4
    moveq   #3,d4
.tr_lp: moveq #2,d6
    moveq   #1,d7
    bsr.w   draw_tex_tri
    lea     18(a4),a4
    dbf     d4,.tr_lp
    bsr.w   draw_rusalka
    move.w  ff1_x(pc),light_x
    move.w  ff1_y(pc),light_y
    move.w  ff1_z(pc),light_z
    bsr.w   draw_3d_firefly
    move.w  ff2_x(pc),light_x
    move.w  ff2_y(pc),light_y
    move.w  ff2_z(pc),light_z
    bsr.w   draw_3d_firefly
    movem.l (sp)+,d0-d7/a0-a5
    rts
draw_rusalka:
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    lea     rusalka_bmp(pc),a0
    add.l   #144*40+17,a2
    add.l   #144*40+17,a3
    moveq   #21,d7
.rs_l: move.w (a0)+,d0
    or.w    d0,(a2)
    or.w    d0,(a3)
    lea     40(a2),a2
    lea     40(a3),a3
    dbf     d7,.rs_l
    rts
render_mist_particles:
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7
    lea     mist_pts(pc),a4
    moveq   #31,d6
.ms_l: move.w (a4)+,d0
    move.w  (a4)+,d1
    add.w   d7,d1
    and.w   #$1f,d1
    neg.w   d1
    add.w   #172,d1
    bsr.w   plot_safe
    dbf     d6,.ms_l
    rts
update_tunnel_copper:
    move.l  cop_sky_ptr(pc),a2
    moveq   #31,d4
.tc_l: move.w #$0001,6(a2)
    move.w  #$0001,14(a2)
    lea     20(a2),a2
    dbf     d4,.tc_l
    rts
update_grotto_copper:
    move.l  cop_sky_ptr(pc),a2
    lea     grotto_grad(pc),a0
    moveq   #31,d4
.gc_l: move.w (a0)+,d1
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     20(a2),a2
    dbf     d4,.gc_l
    rts
    even
seg_z0: dc.w 60
seg_z1: dc.w 100
seg_x0: dc.w 0
seg_x1: dc.w 0
seg_lit: dc.w 0
fb_x: dc.w 160
fb_y: dc.w 140
ff1_x: dc.w 0
ff1_y: dc.w 0
ff1_z: dc.w 220
ff2_x: dc.w 0
ff2_y: dc.w 0
ff2_z: dc.w 280
tmp_tri: ds.w 9
grotto_grad: dc.w $0001,$0001,$0011,$0012,$0112,$0123,$0123,$0124,$0124,$0123,$0123,$0112,$0012,$0011,$0001,$0001,$0011,$0123,$0134,$0145,$0256,$0267,$0256,$0145,$0134,$0023,$0012,$0011,$0001,$0001,$0000,$0000
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
grotto_tris:
    dc.w -170,-115,260, -85,-115,260, -110,50,260, -170,-115,260, -110,50,260, -170,50,260
    dc.w 95,-115,260, 170,-115,260, 115,50,260, 170,-115,260, 170,50,260, 115,50,260
    dc.w -95,-115,260, -55,-115,260, -75,-65,260, 45,-115,260, 88,-115,260, 66,-70,260
lake_tris:
    dc.w -155,48,220, 155,48,220, 165,86,330, -155,48,220, 165,86,330, -165,86,330
wf_tris:
    dc.w 78,-55,275, 86,-55,275, 88,48,275, 78,-55,275, 88,48,275, 76,48,275
tree_tris:
    dc.w -52,48,250, 52,48,250, 38,38,250, -52,48,250, 38,38,250, -38,38,250
    dc.w -48,-12,250, 48,-12,250, 0,-56,250, -36,-28,250, 36,-28,250, 0,-68,250
mist_pts: dc.w 220,0,224,7,228,14,232,21,236,3,240,10,244,18,248,25,222,12,226,19,230,27,234,4,238,11,242,20,246,28,250,6,221,15,225,22,229,29,233,8,237,16,241,24,245,2,249,9,223,17,227,26,231,5,235,13,239,23,243,30,247,1,251,14
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0

    even
lead_x: dc.w 0
lead_y: dc.w 16
ff_scr_y: dc.w 140
cam_x: dc.w 0
ff1_x: dc.w 0
ff1_y: dc.w 0
ff1_z: dc.w 220
ff2_x: dc.w 0
ff2_y: dc.w 0
ff2_z: dc.w 280
cur_px: dc.w 0
cur_pz: dc.w 100
cur_cx: dc.w 0
cur_cy: dc.w 0
cur_ldist: dc.w 0
rc_x: dc.w 160
rc_y: dc.w 124
rc_r: dc.w 40
rc_rd: dc.w 28
fb_x: dc.w 160
fb_y: dc.w 140
ring_pts: ds.l 8
poly_tmp: ds.w 20
grotto_grad:
    dc.w $0001,$0001,$0011,$0012,$0112,$0123,$0123,$0124,$0124,$0123,$0123,$0112,$0012,$0011,$0001,$0001,$0011,$0123,$0134,$0145,$0256,$0267,$0256,$0145,$0134,$0023,$0012,$0011,$0001,$0001,$0000,$0000
rusalka_bitmap:
    dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
grotto_walls:
    dc.w -170,-115,260, -85,-115,260, -110,50,260
    dc.w -170,-115,260, -110,50,260, -170,50,260
    dc.w 95,-115,260, 170,-115,260, 115,50,260
    dc.w 170,-115,260, 170,50,260, 115,50,260
    dc.w -95,-115,260, -55,-115,260, -75,-65,260
    dc.w 45,-115,260, 88,-115,260, 66,-70,260
thin_waterfall:
    dc.w 78,-55,275, 85,-55,275, 87,48,275
    dc.w 78,-55,275, 87,48,275, 76,48,275
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
