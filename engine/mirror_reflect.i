    even
project_mirror_verts_3d:
    tst.b   mirror_enabled(pc)
    beq.w   .pmv_ret
    movem.l d0-d7/a0-a3,-(sp)
    subq.w  #1,d7
    bmi.w   .pmv_done

    move.l  vbl_tick(pc),d0
    lsl.w   #2,d0
    move.w  d0,mir_wave_phase

    lea     rot_m00,a2
    lea     sin_tab,a3
.pmv_lp:
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
    move.w  d0,d2
    move.w  d3,d1
    move.w  (sp)+,d0

    ; Odbicie na tafli podlogi: wy_m = 42 + ((32 - wy) >> 2) -> rzutuje sie w sy = 88..120
    move.w  #32,d3
    sub.w   d1,d3
    bpl.s   .m_ab
    moveq   #0,d3
.m_ab:
    asr.w   #2,d3
    add.w   #42,d3
    move.w  d3,d1

    ; Falowanie wody w poziomie
    move.w  d1,d3
    muls.w  #3,d3
    add.w   mir_wave_phase(pc),d3
    and.w   #$ff,d3
    move.w  (a3,d3.w*2),d3
    asr.w   #5,d3
    add.w   d3,d0

    sub.w   cam_ox,d0
    sub.w   cam_oy,d1
    sub.w   cam_oz,d2
    add.w   user_zoom,d2

    tst.b   cam_3d_active
    beq.s   .mcam_y

    movem.l d4-d6/a2,-(sp)
    lea     cam_m00,a2
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
    bra.s   .mcam_ok

.mcam_y:
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

.mcam_ok:
    cmp.w   #24,d2
    bge.s   .mz_ok
    move.w  #24,d2
.mz_ok:
    move.w  d2,d0
    addq.w  #4,d0
    move.w  d0,-(sp)

    cmp.w   #2048,d2
    ble.s   .mrz_ok
    move.w  #2048,d2
.mrz_ok:
    move.l  a0,-(sp)
    lea     recip_table_32(pc),a0
    move.l  (a0,d2.w*4),d2          ; d2 = 1/Z w 16.16 (zero divs.l!)
    move.l  (sp)+,a0
    ext.l   d3
    ext.l   d1
    muls.l  d2,d3
    muls.l  d2,d1
    asr.l   #8,d3
    asr.l   #1,d3
    asr.l   #8,d1
    asr.l   #1,d1
    add.w   #80,d3
    add.w   #64,d1
    move.w  d3,(a1)+
    move.w  d1,(a1)+
    move.w  (sp)+,(a1)+

    dbf     d7,.pmv_lp
.pmv_done:
    movem.l (sp)+,d0-d7/a0-a3
.pmv_ret:
    rts

draw_mirror_env_mesh_v2:
    tst.b   mirror_enabled(pc)
    beq.w   .dmem_ret
    movem.l d0-d7/a0-a6,-(sp)
    move.w  (a0)+,d7
    subq.w  #1,d7
    bmi.w   .dmem_done

    move.b  shadow_col_idx,mir_saved_col

.dmem_lp:
    move.w  (a0)+,d4
    move.w  (a0)+,d5
    move.w  (a0)+,d6
    addq.l  #2,a0

    move.w  d4,d1
    mulu.w  #6,d1
    lea     (a1,d1.w),a4
    move.w  d5,d1
    mulu.w  #6,d1
    lea     (a1,d1.w),a5
    move.w  d6,d1
    mulu.w  #6,d1
    lea     (a1,d1.w),a6

    cmp.w   #66,2(a4)
    blt.w   .dmem_next
    cmp.w   #66,2(a5)
    blt.w   .dmem_next
    cmp.w   #66,2(a6)
    blt.w   .dmem_next

    cmp.w   #127,2(a4)
    bgt.w   .dmem_next
    cmp.w   #127,2(a5)
    bgt.w   .dmem_next
    cmp.w   #127,2(a6)
    bgt.w   .dmem_next

    cmp.w   #-40,(a4)
    blt.w   .dmem_next
    cmp.w   #200,(a4)
    bgt.w   .dmem_next
    cmp.w   #-40,(a5)
    blt.w   .dmem_next
    cmp.w   #200,(a5)
    bgt.w   .dmem_next
    cmp.w   #-40,(a6)
    blt.w   .dmem_next
    cmp.w   #200,(a6)
    bgt.w   .dmem_next

    move.w  (a5),d1
    sub.w   (a4),d1
    move.w  2(a6),d2
    sub.w   2(a4),d2
    muls.w  d2,d1
    move.w  2(a5),d2
    sub.w   2(a4),d2
    move.w  (a6),d3
    sub.w   (a4),d3
    muls.w  d3,d2
    sub.l   d2,d1
    bge.w   .dmem_next

    move.l  (a3,d4.w*4),d1
    lsr.w   #8,d1
    cmp.w   #10,d1
    bge.s   .mc_hi
    move.b  #204,shadow_col_idx
    bra.s   .mc_ok
.mc_hi:
    move.b  #26,shadow_col_idx
.mc_ok:

    movem.l d7/a0-a3,-(sp)
    lea     mir_tri_pkt(pc),a0
    move.w  (a4),(a0)+
    move.w  2(a4),(a0)+
    move.w  4(a4),(a0)+
    move.w  (a5),(a0)+
    move.w  2(a5),(a0)+
    move.w  4(a5),(a0)+
    move.w  (a6),(a0)+
    move.w  2(a6),(a0)+
    move.w  4(a6),(a0)+
    lea     mir_tri_pkt(pc),a4
    jsr     draw_shadow_z_tri
    movem.l (sp)+,d7/a0-a3

.dmem_next:
    dbf     d7,.dmem_lp

    move.b  mir_saved_col(pc),shadow_col_idx
.dmem_done:
    movem.l (sp)+,d0-d7/a0-a6
.dmem_ret:
    rts

    even
mir_wave_phase: dc.w 0
mir_saved_col:  dc.b 4
mirror_enabled: dc.b 1
mir_tri_pkt:    ds.w 9
