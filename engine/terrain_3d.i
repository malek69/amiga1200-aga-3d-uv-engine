; ============================================================================
; AURA-3D AGA Engine v1.14 - Teren 3D z mapy wysokosci i cieniowaniem stokow
; ============================================================================

TER_COLS    equ 16
TER_ROWS    equ 13

terrain_3d_init:
    movem.l d0-d5/a0-a1,-(sp)
    lea     terrain_hmap,a0
    lea     sin_tab,a1
    moveq   #0,d5
.ti_z:
    moveq   #0,d4
.ti_x:
    move.w  d4,d0
    muls.w  #5,d0
    and.w   #$ff,d0
    move.w  (a1,d0.w*2),d1

    move.w  d5,d0
    muls.w  #4,d0
    add.w   #64,d0
    and.w   #$ff,d0
    add.w   (a1,d0.w*2),d1

    move.w  d4,d0
    sub.w   d5,d0
    lsl.w   #2,d0
    and.w   #$ff,d0
    move.w  (a1,d0.w*2),d2
    asr.w   #1,d2
    add.w   d2,d1

    asr.w   #4,d1
    move.b  d1,(a0)+

    addq.w  #1,d4
    cmp.w   #64,d4
    blo.s   .ti_x
    addq.w  #1,d5
    cmp.w   #64,d5
    blo.s   .ti_z
    movem.l (sp)+,d0-d5/a0-a1
    rts

render_3d_terrain_flyover:
    movem.l d0-d7/a0-a6,-(sp)
    tst.b   ter_inited(pc)
    bne.s   .ter_ready
    move.b  #1,ter_inited
    bsr.w   terrain_3d_init
.ter_ready:
    ; Oblicz pozycje dynamicznego swiatla punktowego nad terenem (X, Z)
    lea     sin_tab,a1
    move.l  vbl_tick(pc),d0
    lsl.w   #1,d0
    and.w   #$ff,d0
    move.w  (a1,d0.w*2),d1
    asr.w   #1,d1                   ; light_x w zakresie -64..+64
    move.w  d1,ter_light_x

    add.w   #64,d0
    and.w   #$ff,d0
    move.w  (a1,d0.w*2),d1
    asr.w   #2,d1
    add.w   #120,d1                 ; light_z w zakresie 88..152
    move.w  d1,ter_light_z

    move.l  vbl_tick(pc),d0
    move.l  d0,d1
    lsr.l   #2,d1
    move.w  d1,ter_scroll_z
    and.w   #3,d0
    lsl.w   #2,d0
    move.w  d0,ter_sub_z

    lea     terrain_hmap,a0
    lea     ter_proj_buf,a1

    moveq   #0,d7
.tr_z_lp:
    move.w  d7,d5
    lsl.w   #4,d5
    add.w   #76,d5
    sub.w   ter_sub_z(pc),d5

    move.w  d7,d3
    add.w   ter_scroll_z(pc),d3
    and.w   #63,d3
    lsl.w   #6,d3

    moveq   #0,d6
.tr_x_lp:
    move.w  d6,d4
    subq.w  #7,d4
    muls.w  #20,d4

    move.w  d6,d0
    and.w   #63,d0
    add.w   d3,d0
    move.b  (a0,d0.w),d1
    ext.w   d1

    move.w  d6,d0
    addq.w  #1,d0
    and.w   #63,d0
    add.w   d3,d0
    move.b  (a0,d0.w),d2
    ext.w   d2
    sub.w   d1,d2
    move.w  d2,ter_slope_dh

    move.w  #68,d2
    sub.w   d1,d2

    move.w  d5,d0
    add.w   user_zoom,d0
    cmp.w   #42,d0
    bge.s   .tz_ok
    move.w  #42,d0
.tz_ok:

    movem.l d3/d5-d6,-(sp)
    move.w  d0,d6
    cmp.w   #2048,d6
    ble.s   .trz_ok
    move.w  #2048,d6
.trz_ok:
    move.l  a0,-(sp)
    lea     recip_table_32(pc),a0
    move.l  (a0,d6.w*4),d6          ; d6 = 1/Z w 16.16 (zero divs.l!)
    move.l  (sp)+,a0
    move.w  d4,d3
    ext.l   d3
    ext.l   d2
    muls.l  d6,d3
    muls.l  d6,d2
    asr.l   #8,d3
    asr.l   #8,d2
    asr.l   #1,d2
    add.w   #160,d3
    add.w   #64,d2
    move.w  d3,(a1)+
    move.w  d2,(a1)+
    move.w  d0,(a1)+

    cmp.w   #12,d1
    bge.s   .tc_mid
    move.w  #212,d3
    bra.s   .tc_slope
.tc_mid:
    cmp.w   #20,d1
    bge.s   .tc_top
    move.w  #116,d3
    bra.s   .tc_slope
.tc_top:
    move.w  #28,d3
.tc_slope:
    move.w  ter_slope_dh(pc),d2
    asr.w   #2,d2
    add.w   d2,d3

    ; Dodaj jasnosc od dynamicznego swiatla punktowego (promien ~72 jednostki)
    move.w  d4,d2
    sub.w   ter_light_x(pc),d2
    muls.w  d2,d2                   ; dx^2
    move.w  d0,d6
    sub.w   ter_light_z(pc),d6
    muls.w  d6,d6                   ; dz^2
    add.l   d6,d2                   ; dist^2
    cmp.l   #5184,d2                ; 72^2
    bge.s   .no_pt_light
    lsr.l   #8,d2
    lsr.l   #1,d2                   ; 0..10
    moveq   #10,d6
    sub.w   d2,d6                   ; bonus jasnosci 1..10
    add.w   d6,d3
.no_pt_light:
    cmp.w   #192,d3
    bge.s   .tc_f
    cmp.w   #104,d3
    bge.s   .tc_f
    cmp.w   #16,d3
    bge.s   .tc_f
    move.w  #108,d3
.tc_f:
    cmp.w   #320,d0
    ble.s   .tc_st
    subq.w  #4,d3
.tc_st:
    move.w  d3,(a1)+
    movem.l (sp)+,d3/d5-d6

    addq.w  #1,d6
    cmp.w   #TER_COLS,d6
    blo.w   .tr_x_lp

    addq.w  #1,d7
    cmp.w   #TER_ROWS,d7
    blo.w   .tr_z_lp

    lea     ter_proj_buf,a1
    moveq   #1,d7
.tm_r_lp:
    moveq   #0,d6
.tm_c_lp:
    move.w  d7,d0
    mulu.w  #TER_COLS*8,d0
    move.w  d6,d1
    lsl.w   #3,d1
    add.w   d1,d0
    lea     (a1,d0.l),a2
    lea     8(a2),a3
    lea     TER_COLS*8(a2),a5
    lea     8(a5),a4

    movem.l d6-d7/a1-a5,-(sp)
    bsr.s   .draw_ter_tri_a
    movem.l (sp)+,d6-d7/a1-a5

    movem.l d6-d7/a1-a5,-(sp)
    bsr.s   .draw_ter_tri_b
    movem.l (sp)+,d6-d7/a1-a5

    addq.w  #1,d6
    cmp.w   #TER_COLS-1,d6
    blo.s   .tm_c_lp

    addq.w  #1,d7
    cmp.w   #TER_ROWS-1,d7
    blo.s   .tm_r_lp

    movem.l (sp)+,d0-d7/a0-a6
    rts

.draw_ter_tri_a:
    cmp.w   #132,2(a2)
    bgt.s   .dta_skip
    cmp.w   #132,2(a5)
    bgt.s   .dta_skip
    cmp.w   #132,2(a4)
    ble.s   .dta_ok
.dta_skip:
    rts
.dta_ok:
    lea     ter_tri_pkt(pc),a0
    move.w  (a2),(a0)+
    move.w  2(a2),(a0)+
    move.w  4(a2),(a0)+
    move.w  (a5),(a0)+
    move.w  2(a5),(a0)+
    move.w  4(a5),(a0)+
    move.w  (a4),(a0)+
    move.w  2(a4),(a0)+
    move.w  4(a4),(a0)+
    move.b  7(a4),d0
    move.b  d0,shadow_col_idx
    lea     ter_tri_pkt(pc),a4
    jsr     draw_shadow_z_tri
    rts

.draw_ter_tri_b:
    cmp.w   #132,2(a2)
    bgt.s   .dtb_skip
    cmp.w   #132,2(a4)
    bgt.s   .dtb_skip
    cmp.w   #132,2(a3)
    ble.s   .dtb_ok
.dtb_skip:
    rts
.dtb_ok:
    lea     ter_tri_pkt(pc),a0
    move.w  (a2),(a0)+
    move.w  2(a2),(a0)+
    move.w  4(a2),(a0)+
    move.w  (a4),(a0)+
    move.w  2(a4),(a0)+
    move.w  4(a4),(a0)+
    move.w  (a3),(a0)+
    move.w  2(a3),(a0)+
    move.w  4(a3),(a0)+
    move.b  7(a3),d0
    subq.b  #3,d0
    move.b  d0,shadow_col_idx
    lea     ter_tri_pkt(pc),a4
    jsr     draw_shadow_z_tri
    rts

    even
ter_light_x:    dc.w 0
ter_light_z:    dc.w 120
ter_inited:     dc.b 0,0
ter_scroll_z:   dc.w 0
ter_sub_z:      dc.w 0
ter_slope_dh:   dc.w 0
ter_tri_pkt:    ds.w 9

    section fastram_bss,bss_p
terrain_hmap:   ds.b 64*64
ter_proj_buf:   ds.w TER_COLS*TER_ROWS*4
    section code,code
