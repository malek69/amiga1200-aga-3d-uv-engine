; [EN/PL] AUTHORS: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | Demoscene 3D Tunnel + Firefly Light Source -> Wet Grotto
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d7
    cmp.l   #425,d7
    blo.w   act1_tunnel
    bra.w   act2_grotto
act1_tunnel:
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)
    move.w  #$0123,6(a1)
    move.w  #$0872,10(a1)
    move.w  #$0fe5,14(a1)
    move.w  #$0112,18(a1)
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    move.w  d1,lead_x
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #22,d2
    move.w  d2,lead_y
    ext.l   d2
    muls.l  #240,d2
    divs.l  #165,d2
    add.w   #124,d2
    move.w  d2,ff_scr_y
    bsr.w   update_tunnel_light_copper
    move.w  d7,d6
    mulu.w  #5,d6
    moveq   #15,d4
.ring_lp:
    move.w  d4,d0
    lsl.w   #5,d0
    sub.w   d6,d0
    and.w   #$01ff,d0
    add.w   #56,d0
    move.w  d0,cur_pz
    lsr.w   #2,d0
    add.w   d7,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #3,d2
    sub.w   lead_x(pc),d2
    move.w  d2,cur_cx
    move.w  128(a2,d0.w*2),d2
    asr.w   #4,d2
    sub.w   lead_y(pc),d2
    move.w  d2,cur_cy
    move.w  cur_pz(pc),d1
    sub.w   #165,d1
    bpl.s   .dz_ok
    neg.w   d1
.dz_ok: move.w d1,cur_ldist
    bsr.w   draw_demoscene_ring
    dbf     d4,.ring_lp
    move.w  lead_x(pc),d0
    move.w  lead_y(pc),d1
    move.w  #165,d2
    bsr.w   draw_3d_firefly_bulb
    movem.l (sp)+,d0-d7/a0-a5
    rts
draw_demoscene_ring:
    move.w  cur_pz(pc),d2
    ext.l   d2
    move.w  cur_cx(pc),d0
    ext.l   d0
    muls.l  #240,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,rc_x
    move.w  cur_cy(pc),d1
    ext.l   d1
    muls.l  #240,d1
    divs.l  d2,d1
    add.w   #124,d1
    move.w  d1,rc_y
    move.l  #92*240,d3
    divs.l  d2,d3
    cmp.w   #4,d3
    blt.w   .rg_end
    cmp.w   #260,d3
    bgt.w   .rg_end
    move.w  d3,rc_r
    mulu.w  #181,d3
    lsr.l   #8,d3
    move.w  d3,rc_rd
    move.l  draw_bpl1(pc),a3
    cmp.w   #95,cur_ldist
    bhi.s   .use_p
    move.l  draw_bpl2(pc),a3
.use_p: lea ring_pts(pc),a0
    move.w  rc_x(pc),d0
    move.w  rc_y(pc),d1
    move.w  rc_r(pc),d2
    move.w  rc_rd(pc),d3
    move.w  d0,(a0)+
    move.w  d1,d4
    sub.w   d2,d4
    move.w  d4,(a0)+
    move.w  d0,d4
    add.w   d3,d4
    move.w  d4,(a0)+
    move.w  d1,d4
    sub.w   d3,d4
    move.w  d4,(a0)+
    move.w  d0,d4
    add.w   d2,d4
    move.w  d4,(a0)+
    move.w  d1,(a0)+
    move.w  d0,d4
    add.w   d3,d4
    move.w  d4,(a0)+
    move.w  d1,d4
    add.w   d3,d4
    move.w  d4,(a0)+
    move.w  d0,(a0)+
    move.w  d1,d4
    add.w   d2,d4
    move.w  d4,(a0)+
    move.w  d0,d4
    sub.w   d3,d4
    move.w  d4,(a0)+
    move.w  d1,d4
    add.w   d3,d4
    move.w  d4,(a0)+
    move.w  d0,d4
    sub.w   d2,d4
    move.w  d4,(a0)+
    move.w  d1,(a0)+
    move.w  d0,d4
    sub.w   d3,d4
    move.w  d4,(a0)+
    move.w  d1,d4
    sub.w   d3,d4
    move.w  d4,(a0)+
    lea     ring_pts(pc),a0
    moveq   #6,d7
.eg_lp: move.w (a0),d0
    move.w  2(a0),d1
    move.w  4(a0),d2
    move.w  6(a0),d3
    bsr.w   draw_line_clipped
    addq.l  #4,a0
    dbf     d7,.eg_lp
    move.w  (a0),d0
    move.w  2(a0),d1
    lea     ring_pts(pc),a0
    move.w  (a0),d2
    move.w  2(a0),d3
    bsr.w   draw_line_clipped
.rg_end: rts
draw_3d_firefly_bulb:
    ext.l   d0
    ext.l   d1
    muls.l  #240,d0
    muls.l  #240,d1
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #124,d1
    cmp.w   #12,d0
    blo.w   .fb_ex
    cmp.w   #307,d0
    bhi.w   .fb_ex
    cmp.w   #12,d1
    blo.w   .fb_ex
    cmp.w   #242,d1
    bhi.w   .fb_ex
    move.w  d0,fb_x
    move.w  d1,fb_y
    move.l  draw_bpl2(pc),a3
    subq.w  #1,d1
    moveq   #4,d5
.hl_y: move.w fb_x(pc),d0
    subq.w  #2,d0
    moveq   #4,d4
.hl_x: bsr.s set_px_a3
    addq.w  #1,d0
    dbf     d4,.hl_x
    addq.w  #1,d1
    dbf     d5,.hl_y
    move.l  vbl_tick(pc),d6
    and.w   #7,d6
    addq.w  #4,d6
    move.w  fb_x(pc),d0
    sub.w   d6,d0
    move.w  fb_y(pc),d1
    addq.w  #1,d1
    move.w  fb_x(pc),d2
    add.w   d6,d2
    move.w  d1,d3
    bsr.w   draw_line_clipped
    move.w  fb_x(pc),d0
    move.w  fb_y(pc),d1
    addq.w  #1,d1
    sub.w   d6,d1
    move.w  d0,d2
    move.w  fb_y(pc),d3
    addq.w  #1,d3
    add.w   d6,d3
    bsr.w   draw_line_clipped
    move.l  draw_bpl1(pc),a3
    move.w  fb_x(pc),d0
    move.w  fb_y(pc),d1
    addq.w  #1,d1
    bsr.s   set_px_a3
    addq.w  #1,d0
    bsr.s   set_px_a3
    addq.w  #1,d1
    bsr.s   set_px_a3
    subq.w  #1,d0
    bsr.s   set_px_a3
.fb_ex: rts
set_px_a3:
    cmp.w   #2,d0
    blo.s   .sp_no
    cmp.w   #317,d0
    bhi.s   .sp_no
    cmp.w   #2,d1
    blo.s   .sp_no
    cmp.w   #252,d1
    bhi.s   .sp_no
    move.w  d1,d2
    mulu.w  #40,d2
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d2
    move.w  d0,d3
    not.w   d3
    and.w   #7,d3
    bset    d3,(a3,d2.l)
.sp_no: rts
draw_line_clipped:
    movem.l d0-d7/a0,-(sp)
    sub.w   d0,d2
    sub.w   d1,d3
    moveq   #1,d4
    tst.w   d2
    bpl.s   .dxp
    neg.w   d2
    moveq   #-1,d4
.dxp: moveq #1,d5
    tst.w   d3
    bpl.s   .dyp
    neg.w   d3
    moveq   #-1,d5
.dyp: cmp.w d3,d2
    blt.s   .steep
    move.w  d2,d6
    lsr.w   #1,d6
    move.w  d2,d7
.lx_lp: bsr.s .plot
    add.w   d4,d0
    sub.w   d3,d6
    bge.s   .lx_nx
    add.w   d5,d1
    add.w   d2,d6
.lx_nx: dbf d7,.lx_lp
    bra.s   .ln_ex
.steep: move.w d3,d6
    lsr.w   #1,d6
    move.w  d3,d7
.ly_lp: bsr.s .plot
    add.w   d5,d1
    sub.w   d2,d6
    bge.s   .ly_nx
    add.w   d4,d0
    add.w   d3,d6
.ly_nx: dbf d7,.ly_lp
.ln_ex: movem.l (sp)+,d0-d7/a0
    rts
.plot: cmp.w #319,d0
    bhi.s   .pl_no
    cmp.w   #254,d1
    bhi.s   .pl_no
    move.w  d1,a0
    mulu.w  #40,d1
    move.w  d0,-(sp)
    lsr.w   #3,d0
    add.w   d0,d1
    move.w  (sp),d0
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)
    move.w  (sp)+,d0
    move.w  a0,d1
.pl_no: rts
act2_grotto:
    lea     sin_tab,a2
    sub.l   #425,d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d5
    asr.w   #4,d5
    move.w  d5,cam_x
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
    bge.s   .col_cyan
    move.w  #$0962,10(a1)
    move.w  #$0fe5,14(a1)
    bra.s   .col_ok
.col_cyan: move.w #$0289,10(a1)
    move.w  #$06fe,14(a1)
.col_ok: move.w #$0112,18(a1)
    bsr.w   update_grotto_copper
    lea     grotto_walls(pc),a4
    moveq   #5,d7
.gw_lp: moveq #0,d0
    bsr.w   draw_mesh_tri_lut
    dbf     d7,.gw_lp
    bsr.w   render_lake_ripples
    lea     thin_waterfall(pc),a4
    moveq   #1,d7
.wf_lp: moveq #2,d0
    bsr.w   draw_mesh_tri_lut
    dbf     d7,.wf_lp
    bsr.w   render_waterfall_mist
    lea     island_and_tree_b1(pc),a4
    moveq   #3,d7
.tr1_lp: moveq #0,d0
    bsr.w   draw_mesh_tri_lut
    dbf     d7,.tr1_lp
    lea     tree_crown_glow(pc),a4
    moveq   #1,d7
.tr2_lp: moveq #2,d0
    bsr.w   draw_mesh_tri_lut
    dbf     d7,.tr2_lp
    bsr.w   draw_rusalka_sprite
    move.w  ff1_x(pc),d0
    move.w  ff1_y(pc),d1
    move.w  ff1_z(pc),d2
    bsr.w   draw_3d_firefly_bulb
    move.w  ff2_x(pc),d0
    move.w  ff2_y(pc),d1
    move.w  ff2_z(pc),d2
    bsr.w   draw_3d_firefly_bulb
    movem.l (sp)+,d0-d7/a0-a5
    rts
render_lake_ripples:
    move.l  draw_bpl2(pc),a3
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    moveq   #13,d6
    move.w  #172,d5
.lk_lp: move.w d5,d0
    lsl.w   #2,d0
    add.w   d7,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d4
    asr.w   #4,d4
    move.w  #26,d0
    add.w   d4,d0
    move.w  d5,d1
    move.w  #294,d2
    sub.w   d4,d2
    move.w  d5,d3
    bsr.w   draw_line_clipped
    addq.w  #5,d5
    dbf     d6,.lk_lp
    rts
draw_mesh_tri_lut:
    move.w  d0,-(sp)
    lea     poly_tmp(pc),a1
    move.w  #3,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_grotto_pt
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_grotto_pt
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_grotto_pt
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  (sp)+,d0
    lea     poly_tmp(pc),a1
    bsr.w   draw_polygon_mode
    rts
proj_grotto_pt:
    sub.w   cam_x(pc),d0
    ext.l   d0
    ext.l   d1
    muls.l  #260,d0
    muls.l  #260,d1
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
update_tunnel_light_copper:
    move.l  cop_sky_ptr(pc),a2
    move.w  ff_scr_y(pc),d5
    moveq   #0,d6
    moveq   #31,d4
.tl_lp: move.w d6,d1
    sub.w   d5,d1
    bpl.s   .ay_ok
    neg.w   d1
.ay_ok: move.w #$0001,d0
    cmp.w   #22,d1
    bhi.s   .t_c2
    move.w  #$0221,d0
    bra.s   .t_wr
.t_c2: cmp.w #48,d1
    bhi.s   .t_wr
    move.w  #$0111,d0
.t_wr: move.w d0,6(a2)
    move.w  d0,14(a2)
    addq.w  #8,d6
    lea     20(a2),a2
    dbf     d4,.tl_lp
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
poly_tmp: ds.w 20
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
