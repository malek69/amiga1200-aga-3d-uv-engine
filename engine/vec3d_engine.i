; [EN/PL] MODULE: vec3d_engine.i | Fast-RAM XOR Scanline Polygon Rasterizer
init_fill_lut:
    movem.l d0-d6/a0,-(sp)
    move.l  af_fill_lut_ptr,a0
    moveq   #0,d5
.cl: moveq  #0,d4
.wl: move.w d5,d2
    moveq   #0,d3
    moveq   #15,d1
.bl: btst   d1,d4
    sne     d0
    and.w   #1,d0
    eor.w   d0,d2
    or.w    d2,d0
    beq.s   .ns
    bset    d1,d3
.ns: dbf    d1,.bl
    moveq   #0,d0
    tst.w   d2
    beq.s   .nc
    move.l  #$00010000,d0
.nc: move.w d3,d0
    move.l  d0,(a0)+
    addq.w  #1,d4
    bne.s   .wl
    addq.w  #1,d5
    cmp.w   #2,d5
    blo.s   .cl
    movem.l (sp)+,d0-d6/a0
    rts

draw_polygon_mode:
    movem.l d0-d7/a0/a2-a5,-(sp)
    move.w  d0,-(sp)
    move.w  (a1)+,d7
    cmp.w   #3,d7
    blo.w   .pa
    move.w  #319,bbox_x1
    move.w  #0,bbox_x2
    move.w  #255,bbox_y1
    move.w  #0,bbox_y2
    move.w  (a1)+,d0
    move.w  (a1)+,d1
    move.w  d0,d4
    move.w  d1,d5
    subq.w  #2,d7
.el: move.w (a1)+,d2
    move.w  (a1)+,d3
    bsr.w   .ed
    move.w  d2,d0
    move.w  d3,d1
    dbf     d7,.el
    move.w  d4,d2
    move.w  d3,d1
    move.w  d5,d3
    bsr.w   .ed
    move.w  bbox_y1(pc),d2
    move.w  bbox_y2(pc),d3
    cmp.w   d2,d3
    blo.w   .pa
    move.w  bbox_x1(pc),d0
    lsr.w   #4,d0
    move.w  bbox_x2(pc),d1
    lsr.w   #4,d1
    move.w  d1,d4
    sub.w   d0,d4
    move.w  d3,d5
    sub.w   d2,d5
    move.w  d2,d6
    mulu.w  #40,d6
    move.w  d0,d7
    add.w   d7,d7
    add.w   d7,d6
    lea     edge_buf,a0
    add.l   d6,a0
    move.w  (sp)+,d0
    move.l  draw_bpl8(pc),a2
    cmp.w   #2,d0
    bne.s   .to
    move.l  draw_bpl7(pc),a2
.to: add.l  d6,a2
    moveq   #40,d7
    sub.w   d4,d7
    sub.w   d4,d7
    subq.w  #2,d7
    move.l  af_fill_lut_ptr,a3
.yl: moveq  #0,d1
    move.w  d4,d6
.xl: moveq  #0,d2
    move.w  (a0),d2
    clr.w   (a0)+
    add.l   d1,d2
    move.l  (a3,d2.l*4),d3
    or.w    d3,(a2)+
    swap    d3
    and.l   #$00000001,d3
    swap    d3
    move.l  d3,d1
    dbf     d6,.xl
    add.w   d7,a0
    add.w   d7,a2
    dbf     d5,.yl
    movem.l (sp)+,d0-d7/a0-a1/a2-a5
    rts
.pa: addq.l #2,sp
    movem.l (sp)+,d0-d7/a0-a1/a2-a5
    rts
.ed: movem.l d0-d7/a0-a1,-(sp)
    tst.w   d1
    bpl.s   .y0a
    moveq   #0,d1
.y0a: cmp.w #255,d1
    ble.s   .y0b
    move.w  #255,d1
.y0b: tst.w d3
    bpl.s   .y1a
    moveq   #0,d3
.y1a: cmp.w #255,d3
    ble.s   .y1b
    move.w  #255,d3
.y1b: cmp.w d1,d3
    beq.w   .ex
    bgt.s   .ys
    exg     d0,d2
    exg     d1,d3
.ys: cmp.w  bbox_y1(pc),d1
    bge.s   .ny1
    move.w  d1,bbox_y1
.ny1: move.w d3,d6
    subq.w  #1,d6
    cmp.w   bbox_y2(pc),d6
    ble.s   .ny2
    move.w  d6,bbox_y2
.ny2: move.w d0,d6
    move.w  d2,d7
    cmp.w   d6,d7
    bge.s   .xm
    exg     d6,d7
.xm: cmp.w  bbox_x1(pc),d6
    bge.s   .nx1
    move.w  d6,bbox_x1
.nx1: cmp.w bbox_x2(pc),d7
    ble.s   .nx2
    move.w  d7,bbox_x2
.nx2: move.w d3,d6
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
    move.w  d1,d4
    mulu.w  #40,d4
    add.l   d4,a0
    subq.w  #1,d6
.sy: move.l d0,d4
    swap    d4
    tst.w   d4
    bpl.s   .sx0
    moveq   #0,d4
.sx0: cmp.w #319,d4
    ble.s   .sx1
    move.w  #319,d4
.sx1: move.w d4,d5
    lsr.w   #3,d5
    not.w   d4
    and.w   #7,d4
    bchg    d4,(a0,d5.w)
    add.l   d7,d0
    lea     40(a0),a0
    dbf     d6,.sy
.ex: movem.l (sp)+,d0-d7/a0-a1
    rts
        section code,code
vec3d_draw_colony_structure:
        movem.l d0-d7/a0-a2,-(sp)
        lea     chunky_buf,a0
        cmp.w   #16,d4
        ble.s   .r_ok
        moveq   #16,d4
.r_ok:  moveq   #0,d7
.dm_lp: move.w  d3,d0
        sub.w   d7,d0
        cmp.w   #16,d0
        blt.w   .dm_nx
        cmp.w   #250,d0
        bgt.w   .dm_nx
        mulu.w  #320,d0
        lea     (a0,d0.l),a1
        move.w  d7,d5
        mulu.w  d5,d5
        move.w  d4,d0
        addq.w  #1,d0
        divu.w  d0,d5
        move.w  d4,d0
        sub.w   d5,d0
        bge.s   .w_ok
        moveq   #0,d0
.w_ok:  move.w  d1,d2
        sub.w   d0,d2
        move.w  d0,d5
        add.w   d5,d5
.dx_lp: cmp.w   #4,d2
        blt.s   .dx_nx
        cmp.w   #315,d2
        bgt.s   .dx_nx
        move.b  d6,d0
        cmp.w   d1,d2
        bgt.s   .sh_r
        addq.b  #2,d0
        bra.s   .px_w
.sh_r:  subq.b  #2,d0
.px_w:  move.b  d0,(a1,d2.w)
.dx_nx: addq.w  #1,d2
        dbf     d5,.dx_lp
.dm_nx: addq.w  #1,d7
        cmp.w   d4,d7
        ble.w   .dm_lp
        move.w  d3,d0
        sub.w   d4,d0
        subq.w  #5,d0
        moveq   #4,d7
.sp_lp: cmp.w   #12,d0
        blt.s   .sp_nx
        cmp.w   #250,d0
        bgt.s   .sp_nx
        move.w  d0,d2
        mulu.w  #320,d2
        lea     (a0,d2.l),a1
        move.b  #255,(a1,d1.w)
.sp_nx: addq.w  #1,d0
        dbf     d7,.sp_lp
        movem.l (sp)+,d0-d7/a0-a1-a2
        rts

vec3d_draw_drone_3d:
        movem.l d0-d7/a0-a2,-(sp)
        lea     chunky_buf,a0
        cmp.w   #12,d4
        ble.s   .dr_ok
        moveq   #12,d4
.dr_ok: move.w  d4,d7
        neg.w   d7
.dy_lp: move.w  d3,d0
        add.w   d7,d0
        cmp.w   #16,d0
        blt.w   .dy_nx
        cmp.w   #248,d0
        bgt.w   .dy_nx
        mulu.w  #320,d0
        lea     (a0,d0.l),a1
        move.w  d7,d5
        bpl.s   .ab_ok
        neg.w   d5
.ab_ok: cmp.w   #1,d5
        bgt.s   .body
        move.w  d4,d6
        add.w   d6,d6
        bra.s   .dr_w
.body:  move.w  d4,d6
        sub.w   d5,d6
        asr.w   #1,d6
        addq.w  #1,d6
.dr_w:  move.w  d1,d2
        sub.w   d6,d2
        move.w  d6,d5
        add.w   d5,d5
.dx2:   cmp.w   #4,d2
        blt.s   .dx2n
        cmp.w   #315,d2
        bgt.s   .dx2n
        move.b  #122,d0
        cmp.w   d1,d2
        bne.s   .px2
        move.b  #190,d0
.px2:   move.b  d0,(a1,d2.w)
.dx2n:  addq.w  #1,d2
        dbf     d5,.dx2
.dy_nx: addq.w  #1,d7
        cmp.w   d4,d7
        ble.w   .dy_lp
        movem.l (sp)+,d0-d7/a0-a1-a2
        rts

vec3d_draw_laser_3d:
        movem.l d0/a0-a1,-(sp)
        lea     chunky_buf+185*320+118,a0
        lea     chunky_buf+185*320+202,a1
        moveq   #58,d0
.lz_lp: move.b  d6,(a0)
        move.b  d6,1(a0)
        move.b  d6,(a1)
        move.b  d6,-1(a1)
        suba.w  #319,a0
        suba.w  #321,a1
        dbf     d0,.lz_lp
        movem.l (sp)+,d0/a0-a1
        rts
        section code,code
vec3d_clear_zbuf_fast:
        movem.l d0-d7/a0-a1,-(sp)
        lea     zbuf_3d,a0
        move.l  #$7fff7fff,d0
        move.l  d0,d1
        move.l  d0,d2
        move.l  d0,d3
        move.l  d0,d4
        move.l  d0,d5
        move.l  d0,d6
        move.l  d0,a1
        move.w  #5119,d7
.cz_f:  movem.l d0-d6/a1,(a0)
        lea     32(a0),a0
        dbf     d7,.cz_f
        movem.l (sp)+,d0-d7/a0-a1
        rts
vec3d_draw_sun_halo:
        movem.l d0-d7/a0-a1,-(sp)
        move.w  cam_yaw(pc),d1
        and.w   #255,d1
        ext.w   d1
        sub.w   #128,d1
        asl.w   #2,d1
        add.w   #160,d1
        cmp.w   #-24,d1
        blt.w   .sn_no
        cmp.w   #344,d1
        bgt.w   .sn_no
        lea     chunky_buf,a0
        moveq   #-16,d7
.sy_lp: move.w  #36,d0
        add.w   d7,d0
        mulu.w  #320,d0
        lea     (a0,d0.l),a1
        move.w  d7,d5
        muls.w  d5,d5
        moveq   #-16,d6
.sx_lp: move.w  d1,d2
        add.w   d6,d2
        cmp.w   #2,d2
        blt.s   .sx_nx
        cmp.w   #317,d2
        bgt.s   .sx_nx
        move.w  d6,d3
        muls.w  d3,d3
        add.w   d5,d3
        cmp.w   #256,d3
        bgt.s   .sx_nx
        move.b  #154,d0
        cmp.w   #100,d3
        bgt.s   .sn_px
        move.b  #158,d0
        cmp.w   #36,d3
        bgt.s   .sn_px
        move.b  #255,d0
.sn_px: move.b  d0,(a1,d2.w)
.sx_nx: addq.w  #1,d6
        cmp.w   #16,d6
        ble.s   .sx_lp
        addq.w  #1,d7
        cmp.w   #16,d7
        ble.s   .sy_lp
.sn_no: movem.l (sp)+,d0-d7/a0-a1
        rts
vec3d_draw_beacon_ring:
        movem.l d0-d6/a0-a1,-(sp)
        lea     chunky_buf,a0
        move.w  d4,d5
        addq.w  #4,d5
        move.w  d3,d0
        sub.w   d5,d0
        cmp.w   #14,d0
        blt.s   .br_no
        cmp.w   #248,d0
        bgt.s   .br_no
        mulu.w  #320,d0
        lea     (a0,d0.l),a1
        move.w  d1,d2
        sub.w   d5,d2
        move.w  d5,d0
        add.w   d0,d0
.br_x:  cmp.w   #4,d2
        blt.s   .br_xn
        cmp.w   #315,d2
        bgt.s   .br_xn
        move.b  #255,(a1,d2.w)
.br_xn: addq.w  #1,d2
        dbf     d0,.br_x
.br_no: movem.l (sp)+,d0-d6/a0-a1
        rts
vec3d_draw_line_2d:
        movem.l d0-d7/a0-a1,-(sp)
        lea     chunky_buf,a0
        move.w  d2,d4
        sub.w   d0,d4
        moveq   #1,d6
        tst.w   d4
        bpl.s   .dxp
        neg.w   d4
        moveq   #-1,d6
.dxp:   move.w  d3,d5
        sub.w   d1,d5
        move.w  #320,d7
        tst.w   d5
        bpl.s   .dyp
        neg.w   d5
        move.w  #-320,d7
.dyp:   mulu.w  #320,d1
        add.l   d1,a0
        add.w   d0,a0
        move.w  a2,d1
        cmp.w   d5,d4
        blt.s   .steep
        move.w  d4,d2
        move.w  d4,d3
        asr.w   #1,d3
.lp_x:  move.b  d1,(a0)
        adda.w  d6,a0
        sub.w   d5,d3
        bge.s   .nx_x
        add.w   d4,d3
        adda.w  d7,a0
.nx_x:  dbf     d2,.lp_x
        bra.s   .ln_ok
.steep: move.w  d5,d2
        move.w  d5,d3
        asr.w   #1,d3
.lp_y:  move.b  d1,(a0)
        adda.w  d7,a0
        sub.w   d4,d3
        bge.s   .nx_y
        add.w   d5,d3
        adda.w  d6,a0
.nx_y:  dbf     d2,.lp_y
.ln_ok: movem.l (sp)+,d0-d7/a0-a1
        rts
        section code,code
vec3d_draw_clouds_360:
        movem.l d0-d7/a0-a2,-(sp)
        lea     chunky_buf,a0
        lea     cloud_pos(pc),a2
        moveq   #5,d7
.cl_lp: move.w  (a2)+,d1
        sub.w   cam_yaw(pc),d1
        and.w   #255,d1
        ext.w   d1
        sub.w   #128,d1
        asl.w   #2,d1
        add.w   #160,d1
        move.w  (a2)+,d3
        cmp.w   #-20,d1
        blt.s   .cl_nx
        cmp.w   #340,d1
        bgt.s   .cl_nx
        mulu.w  #320,d3
        lea     (a0,d3.l),a1
        moveq   #-14,d6
.cx_lp: move.w  d1,d2
        add.w   d6,d2
        cmp.w   #2,d2
        blt.s   .cx_nx
        cmp.w   #317,d2
        bgt.s   .cx_nx
        move.b  #154,(a1,d2.w)
        cmp.w   #-8,d6
        blt.s   .cx_nx
        cmp.w   #8,d6
        bgt.s   .cx_nx
        move.b  #156,-320(a1,d2.w)
        move.b  #156,320(a1,d2.w)
.cx_nx: addq.w  #1,d6
        cmp.w   #14,d6
        ble.s   .cx_lp
.cl_nx: dbf     d7,.cl_lp
        movem.l (sp)+,d0-d7/a0-a1-a2
        rts
vec3d_spawn_particles:
        movem.l d0-d4/a0,-(sp)
        lea     pt_pool,a0
        moveq   #15,d4
.sp_lp: tst.b   6(a0)
        bne.s   .sp_nx
        move.w  d0,(a0)
        move.w  d1,2(a0)
        move.w  d4,d2
        subq.w  #8,d2
        move.b  d2,4(a0)
        move.w  d4,d3
        and.w   #7,d3
        subq.w  #4,d3
        move.b  d3,5(a0)
        move.b  #18,6(a0)
        move.b  d6,7(a0)
.sp_nx: addq.l  #8,a0
        dbf     d4,.sp_lp
        movem.l (sp)+,d0-d4/a0
        rts
vec3d_update_particles:
        movem.l d0-d4/a0-a1,-(sp)
        lea     pt_pool,a0
        lea     chunky_buf,a1
        moveq   #31,d4
.up_lp: tst.b   6(a0)
        beq.s   .up_nx
        subq.b  #1,6(a0)
        move.b  4(a0),d0
        ext.w   d0
        add.w   d0,(a0)
        move.b  5(a0),d1
        ext.w   d1
        add.w   d1,2(a0)
        move.w  (a0),d0
        move.w  2(a0),d1
        cmp.w   #4,d0
        blt.s   .up_nx
        cmp.w   #315,d0
        bgt.s   .up_nx
        cmp.w   #14,d1
        blt.s   .up_nx
        cmp.w   #248,d1
        bgt.s   .up_nx
        mulu.w  #320,d1
        add.w   d0,d1
        move.b  7(a0),(a1,d1.l)
.up_nx: addq.l  #8,a0
        dbf     d4,.up_lp
        movem.l (sp)+,d0-d4/a0-a1
        rts
cloud_pos: dc.w 20,44, 65,52, 115,40, 165,50, 210,42, 245,54

vec3d_draw_mesh_3d:
        movem.l d0-d7/a0-a4,-(sp)
        movem.l d4-d6/a0/a2-a3,-(sp)
        jsr     build_rot_matrix_3d
        movem.l (sp)+,d4-d6/a0/a2-a3
        move.w  (a0)+,d7
        movem.l d7/a2-a3,-(sp)
        lea     v2_proj_buf,a1
        jsr     transform_and_project_verts
        movem.l (sp)+,d7/a0/a3
        lea     v2_env_buf,a1
        jsr     transform_normals_envmap
        move.b  #1,phong_enabled
        clr.b   zfog_enabled
        move.l  a3,a0
        lea     v2_proj_buf,a1
        lea     exo_tex_solid(pc),a2
        lea     v2_env_buf,a3
        jsr     draw_gouraud_env_mesh_v2
        movem.l (sp)+,d0-d7/a0-a1-a4
        rts


vec3d_draw_ground_shadow:
        movem.l d0-d5/a0-a1,-(sp)
        cmp.w   #8,d1
        blt.s   .sh_end
        cmp.w   #311,d1
        bgt.s   .sh_end
        lea     vx_ybuf,a0
        move.w  d1,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d3
        cmp.w   #20,d3
        blt.s   .sh_end
        cmp.w   #252,d3
        bgt.s   .sh_end
        lea     chunky_buf,a1
        mulu.w  #320,d3
        add.l   d3,a1
        cmp.w   #10,d4
        ble.s   .sr_ok
        moveq   #10,d4
.sr_ok: move.w  d1,d2
        sub.w   d4,d2
        move.w  d4,d5
        add.w   d5,d5
.sh_lp: cmp.w   #4,d2
        blt.s   .sh_nx
        cmp.w   #315,d2
        bgt.s   .sh_nx
        clr.b   (a1,d2.w)
        clr.b   320(a1,d2.w)
        clr.b   640(a1,d2.w)
.sh_nx: addq.w  #1,d2
        dbf     d5,.sh_lp
.sh_end:movem.l (sp)+,d0-d5/a0-a1
        rts

        section fastram_bss,bss
pt_pool: ds.b 32*8
        section code,code
