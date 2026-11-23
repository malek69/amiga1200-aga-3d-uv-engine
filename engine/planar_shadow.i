; ============================================================================
; AURA-3D AGA Engine v1.2 - Real-Time 3D Planar Shadows (M68020+ / Z-Buffer)
; ============================================================================

project_planar_shadows_3d:
    movem.l d0-d7/a0-a3,-(sp)
    tst.b   shadows_enabled(pc)
    beq.w   .pps_done

    subq.w  #1,d7
    bmi.w   .pps_done

    move.w  light_vy,d0
    neg.w   d0
    cmp.w   #16,d0
    bge.s   .ly_ok
    moveq   #16,d0
.ly_ok:
    move.l  #256,d1
    divs.w  d0,d1
    move.w  d1,shd_inv_ly

    lea     rot_m00(pc),a2
.pps_lp:
    move.w  (a0)+,d0
    move.w  (a0)+,d1
    move.w  (a0)+,d2

    move.w  d0,d3
    muls.w  (a2),d3
    move.w  d1,-(sp)
    muls.w  2(a2),d1
    add.l   d1,d3
    move.w  d2,d1
    muls.w  4(a2),d1
    add.l   d1,d3
    asr.l   #8,d3
    add.w   d4,d3
    move.w  (sp)+,d1

    move.w  d3,-(sp)
    move.w  d0,d3
    muls.w  6(a2),d3
    move.w  d1,-(sp)
    muls.w  8(a2),d1
    add.l   d1,d3
    move.w  d2,d1
    muls.w  10(a2),d1
    add.l   d1,d3
    asr.l   #8,d3
    add.w   d5,d3
    move.w  (sp)+,d1

    muls.w  12(a2),d0
    muls.w  14(a2),d1
    add.l   d1,d0
    muls.w  16(a2),d2
    add.l   d2,d0
    asr.l   #8,d0
    add.w   d6,d0
    move.w  d0,d2
    move.w  d3,d1
    move.w  (sp)+,d0

    move.w  shadow_ground_y(pc),d3
    sub.w   d1,d3
    bpl.s   .above_gnd
    moveq   #0,d3
.above_gnd:
    muls.w  shd_inv_ly(pc),d3
    asr.l   #8,d3
    cmp.l   #384,d3
    ble.s   .t_ok
    move.l  #384,d3
.t_ok:

    move.w  light_vx,d1
    muls.w  d3,d1
    asr.l   #8,d1
    sub.w   d1,d0

    move.w  light_vz,d1
    muls.w  d3,d1
    asr.l   #8,d1
    sub.w   d1,d2

    move.w  shadow_ground_y(pc),d1

    sub.w   cam_ox,d0
    sub.w   cam_oy,d1
    sub.w   cam_oz,d2
    add.w   user_zoom,d2

    tst.b   cam_3d_active
    beq.s   .scam_y

    movem.l d4-d6/a2,-(sp)
    lea     cam_m00(pc),a2
    move.w  d0,d3
    muls.w  (a2),d3
    move.w  d1,d4
    muls.w  2(a2),d4
    add.l   d4,d3
    move.w  d2,d4
    muls.w  4(a2),d4
    add.l   d4,d3
    asr.l   #8,d3

    move.w  d0,d4
    muls.w  6(a2),d4
    move.w  d1,d5
    muls.w  8(a2),d5
    add.l   d5,d4
    move.w  d2,d5
    muls.w  10(a2),d5
    add.l   d5,d4
    asr.l   #8,d4

    muls.w  12(a2),d0
    muls.w  14(a2),d1
    add.l   d1,d0
    muls.w  16(a2),d2
    add.l   d2,d0
    asr.l   #8,d0
    move.w  d0,d2
    move.w  d4,d1
    movem.l (sp)+,d4-d6/a2
    bra.s   .scam_ok

.scam_y:
    move.w  d0,d3
    muls.w  cam_cos,d3
    move.l  d4,-(sp)
    move.w  d2,d4
    muls.w  cam_sin,d4
    sub.l   d4,d3
    asr.l   #8,d3

    muls.w  cam_sin,d0
    muls.w  cam_cos,d2
    add.l   d0,d2
    asr.l   #8,d2
    move.l  (sp)+,d4
.scam_ok:
    cmp.w   #24,d2
    bge.s   .sz_ok
    move.w  #24,d2
.sz_ok:
    move.w  d2,-(sp)
    ext.l   d3
    ext.l   d1
    ext.l   d2
    muls.l  #128,d3
    muls.l  #128,d1
    divs.l  d2,d3
    divs.l  d2,d1
    add.w   #80,d3
    add.w   #64,d1
    move.w  d3,(a1)+
    move.w  d1,(a1)+
    move.w  (sp)+,(a1)+

    dbf     d7,.pps_lp
.pps_done:
    movem.l (sp)+,d0-d7/a0-a3
    rts

draw_shadow_mesh_v2:
    movem.l d0-d7/a0-a6,-(sp)
    tst.b   shadows_enabled(pc)
    beq.w   .dsm_done

    move.w  (a0)+,d7
    subq.w  #1,d7
    bmi.w   .dsm_done

.dsm_lp:
    move.w  (a0)+,d4
    move.w  (a0)+,d5
    move.w  (a0)+,d6
    addq.l  #2,a0

    move.w  d4,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a4
    move.w  d5,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a5
    move.w  d6,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a6

    ; Near-plane + Ground-bounds guard: cienie tylko ponizej horyzontu (sy >= 66) i w polu widzenia
    cmp.w   #56,4(a4)
    blt.w   .dsm_next
    cmp.w   #56,4(a5)
    blt.w   .dsm_next
    cmp.w   #56,4(a6)
    blt.w   .dsm_next

    cmp.w   #66,2(a4)
    blt.w   .dsm_next
    cmp.w   #66,2(a5)
    blt.w   .dsm_next
    cmp.w   #66,2(a6)
    blt.w   .dsm_next

    cmp.w   #-40,(a4)
    blt.w   .dsm_next
    cmp.w   #200,(a4)
    bgt.w   .dsm_next
    cmp.w   #-40,(a5)
    blt.w   .dsm_next
    cmp.w   #200,(a5)
    bgt.w   .dsm_next
    cmp.w   #-40,(a6)
    blt.w   .dsm_next
    cmp.w   #200,(a6)
    bgt.w   .dsm_next

    move.w  (a5),d0
    sub.w   (a4),d0
    move.w  2(a6),d1
    sub.w   2(a4),d1
    muls.w  d1,d0
    move.w  2(a5),d2
    sub.w   2(a4),d2
    move.w  (a6),d3
    sub.w   (a4),d3
    muls.w  d3,d2
    sub.l   d2,d0
    ble.w   .dsm_next

    lea     shd_tri_pkt(pc),a2
    move.w  (a4),(a2)+
    move.w  2(a4),(a2)+
    move.w  4(a4),(a2)+
    move.w  (a5),(a2)+
    move.w  2(a5),(a2)+
    move.w  4(a5),(a2)+
    move.w  (a6),(a2)+
    move.w  2(a6),(a2)+
    move.w  4(a6),(a2)+

    movem.l d7/a0-a1,-(sp)
    lea     shd_tri_pkt(pc),a4
    bsr.s   draw_shadow_z_tri
    movem.l (sp)+,d7/a0-a1

.dsm_next:
    dbf     d7,.dsm_lp
.dsm_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

draw_shadow_z_tri:
    movem.l d0-d7/a0-a6,-(sp)
    move.w  2(a4),d6
    move.w  d6,d7
    move.w  8(a4),d0
    cmp.w   d0,d6
    ble.s   .sy1a
    move.w  d0,d6
.sy1a:
    cmp.w   d0,d7
    bge.s   .sy1b
    move.w  d0,d7
.sy1b:
    move.w  14(a4),d0
    cmp.w   d0,d6
    ble.s   .sy2a
    move.w  d0,d6
.sy2a:
    cmp.w   d0,d7
    bge.s   .sy2b
    move.w  d0,d7
.sy2b:
    tst.w   d6
    bpl.s   .syc1
    moveq   #0,d6
.syc1:
    cmp.w   #127,d7
    ble.s   .syc2
    move.w  #127,d7
.syc2:
    cmp.w   d6,d7
    ble.w   .szt_done
    move.w  d6,shd_ymin
    move.w  d6,shd_cur_y
    move.w  d7,shd_ymax

    lea     v2_edge_buf,a1
    move.w  d6,d0
    lsl.w   #4,d0
    adda.w  d0,a1
    move.w  d7,d1
    sub.w   d6,d1
    move.l  #$7fff0000,d2
    move.l  #$80010000,d3
.sie_lp:
    move.l  d2,(a1)
    move.l  d3,8(a1)
    lea     16(a1),a1
    dbf     d1,.sie_lp

    move.l  a4,a0
    lea     6(a4),a1
    bsr.w   .scan_shd_edge
    lea     6(a4),a0
    lea     12(a4),a1
    bsr.w   .scan_shd_edge
    lea     12(a4),a0
    move.l  a4,a1
    bsr.w   .scan_shd_edge

    move.w  shd_ymin(pc),d6
    move.w  shd_ymax(pc),d7
    lea     v2_edge_buf,a0
    move.w  d6,d0
    lsl.w   #4,d0
    adda.w  d0,a0

    lea     chunky_buf,a1
    lea     zbuf_3d,a2
    move.w  d6,d0
    mulu.w  #160,d0
    add.l   d0,a1
    add.l   d0,d0
    add.l   d0,a2
    move.b  shadow_col_idx(pc),d5

.sspan_y:
    move.w  (a0),d0
    move.w  8(a0),d1
    cmp.w   d0,d1
    ble.s   .snext_y

    move.w  d1,d2
    sub.w   d0,d2
    ext.l   d2

    move.l  4(a0),d3
    move.l  12(a0),d4
    sub.l   d3,d4
    divs.l  d2,d4

    tst.w   d0
    bpl.s   .sxl_ok
    neg.w   d0
    ext.l   d0
    muls.l  d4,d0
    add.l   d0,d3
    moveq   #0,d0
.sxl_ok:
    cmp.w   #159,d1
    ble.s   .sxr_ok
    move.w  #159,d1
.sxr_ok:
    sub.w   d0,d1
    bmi.s   .snext_y

    lea     (a1,d0.w),a3
    lea     (a2,d0.w*2),a6
.spx_lp:
    move.l  d3,d0
    swap    d0
    cmp.w   (a6),d0
    bge.s   .spx_skip
    move.w  d0,(a6)
    move.b  d5,(a3)
.spx_skip:
    addq.l  #1,a3
    addq.l  #2,a6
    add.l   d4,d3
    dbf     d1,.spx_lp

.snext_y:
    move.w  shd_ymax(pc),d7
    move.w  shd_cur_y(pc),d6
    addq.w  #1,d6
    move.w  d6,shd_cur_y
    lea     16(a0),a0
    lea     160(a1),a1
    lea     320(a2),a2
    cmp.w   d7,d6
    ble.w   .sspan_y

.szt_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

.scan_shd_edge:
    movem.l d0-d6/a0-a3,-(sp)
    move.w  2(a0),d1
    move.w  2(a1),d3
    cmp.w   d1,d3
    beq.w   .sse_done
    bgt.s   .sse_ord
    exg     a0,a1
    exg     d1,d3
.sse_ord:
    move.w  d3,d6
    sub.w   d1,d6
    ext.l   d6

    move.w  (a1),d0
    sub.w   (a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,a2

    move.w  4(a1),d0
    sub.w   4(a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,a3

    move.w  (a0),d4
    swap    d4
    move.w  #$8000,d4
    move.w  4(a0),d5
    swap    d5
    clr.w   d5

    lea     v2_edge_buf,a0
.sse_lp:
    cmp.w   #127,d3
    ble.s   .sse_ylim
    move.w  #127,d3
.sse_ylim:
    tst.w   d1
    bmi.s   .sse_adv
    cmp.w   d3,d1
    bgt.s   .sse_done

    move.w  d1,d2
    lsl.w   #4,d2
    lea     (a0,d2.w),a1

    move.l  d4,d2
    swap    d2
    cmp.w   (a1),d2
    bge.s   .schk_r
    move.l  d4,(a1)
    move.l  d5,4(a1)
.schk_r:
    cmp.w   8(a1),d2
    ble.s   .sse_adv
    move.l  d4,8(a1)
    move.l  d5,12(a1)
.sse_adv:
    add.l   a2,d4
    add.l   a3,d5
    addq.w  #1,d1
    cmp.w   d3,d1
    ble.s   .sse_lp
.sse_done:
    movem.l (sp)+,d0-d6/a0-a3
    rts

    even
shd_tri_pkt:     ds.w 9
shd_ymin:        dc.w 0
shd_ymax:        dc.w 0
shd_cur_y:       dc.w 0
shd_inv_ly:      dc.w 256
shadow_ground_y: dc.w 62
shadow_col_idx:  dc.b 1
shadows_enabled: dc.b 1,0
