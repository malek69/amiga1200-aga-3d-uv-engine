; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | GROTTO 3D: Tunnel Firefly -> Wet Grotto, Waterfall Mist, Island Tree, Rusalka & 2 Colorful Fireflies
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d7
    cmp.l   #400,d7
    blo.w   act1_tunnel
    bra.w   act2_grotto

act1_tunnel:
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0002,2(a1)
    move.w  #$0235,6(a1)
    move.w  #$0795,10(a1)
    move.w  #$0fe6,14(a1)
    move.w  #$0124,18(a1)
    bsr.w   update_tunnel_copper

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
    add.w   #20,d2
    move.w  d2,lead_y

    move.w  d7,d6
    mulu.w  #6,d6
    moveq   #11,d4
.tun_lp:
    move.w  d4,d0
    lsl.w   #6,d0
    sub.w   d6,d0
    and.w   #$02ff,d0
    add.w   #95,d0
    move.w  d0,cur_pz

    move.w  d0,d1
    lsr.w   #3,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #4,d2
    sub.w   lead_x(pc),d2
    move.w  d2,cur_px

    bsr.w   draw_tunnel_arch
    dbf     d4,.tun_lp

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
    move.w  cur_px(pc),d0
    sub.w   #130,d0
    ext.l   d0
    muls.l  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx1
    move.w  cur_px(pc),d0
    sub.w   #46,d0
    ext.l   d0
    muls.l  #250,d0
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
    moveq   #0,d0
    bsr.w   draw_rect_lut
    move.w  p_sx2(pc),d0
    subq.w  #4,d0
    move.w  d0,p_sx1
    moveq   #2,d0
    bsr.w   draw_rect_lut

    move.w  cur_pz(pc),d2
    ext.l   d2
    move.w  cur_px(pc),d0
    add.w   #46,d0
    ext.l   d0
    muls.l  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx1
    move.w  cur_px(pc),d0
    add.w   #130,d0
    ext.l   d0
    muls.l  #250,d0
    divs.l  d2,d0
    add.w   #160,d0
    move.w  d0,p_sx2
    moveq   #0,d0
    bsr.w   draw_rect_lut
    move.w  p_sx1(pc),d0
    addq.w  #4,d0
    move.w  d0,p_sx2
    moveq   #2,d0
    bsr.w   draw_rect_lut
    rts

draw_rect_lut:
    move.w  p_sx1(pc),d1
    move.w  p_sx2(pc),d2
    cmp.w   #318,d1
    bge.s   .dr_no
    cmp.w   #1,d2
    ble.s   .dr_no
    tst.w   d1
    bpl.s   .c1
    moveq   #0,d1
.c1: cmp.w #318,d2
    ble.s   .c2
    move.w  #318,d2
.c2: cmp.w d1,d2
    ble.s   .dr_no
    lea     poly_tmp(pc),a1
    move.w  #4,(a1)+
    move.w  d1,(a1)+
    move.w  p_sy1(pc),(a1)+
    move.w  d2,(a1)+
    move.w  p_sy1(pc),(a1)+
    move.w  d2,(a1)+
    move.w  p_sy2(pc),(a1)+
    move.w  d1,(a1)+
    move.w  p_sy2(pc),(a1)+
    lea     poly_tmp(pc),a1
    bsr.w   draw_polygon_mode
.dr_no: rts

act2_grotto:
    lea     sin_tab,a2
    sub.l   #400,d7
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

    move.l  cop_pal_ptr(pc),a1
    move.w  #$0002,2(a1)
    move.w  #$0234,6(a1)
    cmp.w   #250,ff1_z
    bge.s   .col_cyan
    move.w  #$0a72,10(a1)
    move.w  #$0fe6,14(a1)
    bra.s   .col_ok
.col_cyan:
    move.w  #$039a,10(a1)
    move.w  #$07fe,14(a1)
.col_ok:
    move.w  #$0124,18(a1)
    bsr.w   update_grotto_copper

    lea     grotto_walls(pc),a4
    moveq   #5,d7
.gw_lp: moveq #0,d0
    bsr.w   draw_mesh_tri_lut
    dbf     d7,.gw_lp

    lea     lake_poly(pc),a4
    moveq   #1,d7
.lk_lp: moveq #2,d0
    bsr.w   draw_mesh_tri_lut
    dbf     d7,.lk_lp

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
    bsr.w   draw_glowing_firefly
    move.w  ff2_x(pc),d0
    move.w  ff2_y(pc),d1
    move.w  ff2_z(pc),d2
    bsr.w   draw_glowing_firefly

    movem.l (sp)+,d0-d7/a0-a5
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
