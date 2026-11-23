    even
draw_3d_lens_flare:
    tst.b   flare_enabled(pc)
    beq.w   .lf_ret
    movem.l d0-d7/a0-a3,-(sp)

    move.w  light_vx,d0
    asr.w   #1,d0
    move.w  #-20,d1
    move.w  light_vz,d2
    asr.w   #1,d2

    sub.w   cam_ox,d0
    sub.w   cam_oy,d1
    sub.w   cam_oz,d2
    add.w   user_zoom,d2

    tst.b   cam_3d_active
    beq.s   .lf_cy

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
    move.w  d3,d0
    move.w  d4,d1
    bra.s   .lf_prj

.lf_cy:
    move.w  d0,d3
    muls.w  cam_cos,d3
    move.w  d2,d4
    muls.w  cam_sin,d4
    sub.l   d4,d3
    asr.l   #8,d3

    muls.w  cam_sin,d0
    muls.w  cam_cos,d2
    add.l   d0,d2
    asr.l   #8,d2
    move.w  d3,d0

.lf_prj:
    cmp.w   #28,d2
    blt.w   .lf_done

    ext.l   d0
    ext.l   d1
    ext.l   d2
    muls.l  #128,d0
    muls.l  #128,d1
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #80,d0
    add.w   #64,d1

    tst.w   d0
    bmi.w   .lf_done
    cmp.w   #159,d0
    bgt.w   .lf_done
    tst.w   d1
    bmi.w   .lf_done
    cmp.w   #127,d1
    bgt.w   .lf_done

    ; Test zasloniecia w 16-bitowym Z-Bufferze
    move.w  d1,d6
    mulu.w  #160,d6
    add.w   d0,d6
    lea     zbuf_3d,a1
    move.w  (a1,d6.l*2),d3
    subq.w  #8,d2
    cmp.w   d3,d2
    bgt.w   .lf_done

    move.w  d0,d4
    move.w  d1,d5
    lea     chunky_buf,a0

    ; Poziomy promien anamorficzny
    move.w  d4,d0
    sub.w   #22,d0
    move.w  d4,d1
    add.w   #22,d1
    move.w  d5,d2
    move.b  #124,d3
    bsr.w   .lf_hline

    move.w  d4,d0
    sub.w   #10,d0
    move.w  d4,d1
    add.w   #10,d1
    move.w  d5,d2
    move.b  #255,d3
    bsr.w   .lf_hline

    ; Pionowy promien krzyza swietlnego
    moveq   #-10,d6
.lf_vy:
    move.w  d5,d2
    add.w   d6,d2
    move.w  d4,d0
    move.w  d4,d1
    move.b  #125,d3
    bsr.w   .lf_hline
    addq.w  #1,d6
    cmp.w   #10,d6
    ble.s   .lf_vy

    ; 3 wtorne krazki dyfrakcyjne wzdluz osi (swiatlo -> srodek ekranu)
    move.w  #80,d6
    sub.w   d4,d6
    move.w  #64,d7
    sub.w   d5,d7

    move.w  d6,d0
    asr.w   #1,d0
    add.w   d4,d0
    move.w  d7,d1
    asr.w   #1,d1
    add.w   d5,d1
    moveq   #4,d2
    move.b  #206,d3
    bsr.s   .lf_disc

    move.w  d6,d0
    asr.w   #1,d0
    add.w   #80,d0
    move.w  d7,d1
    asr.w   #1,d1
    add.w   #64,d1
    moveq   #6,d2
    move.b  #122,d3
    bsr.s   .lf_disc

    move.w  #80,d0
    add.w   d6,d0
    move.w  #64,d1
    add.w   d7,d1
    moveq   #3,d2
    move.b  #28,d3
    bsr.s   .lf_disc

.lf_done:
    movem.l (sp)+,d0-d7/a0-a3
.lf_ret:
    rts

.lf_disc:
    movem.l d2/d4-d7,-(sp)
    move.w  d0,d4
    move.w  d1,d5
    move.w  d2,d6
    neg.w   d6
.ld_y:
    move.w  d5,d2
    add.w   d6,d2
    move.w  d6,d7
    bpl.s   .ld_a
    neg.w   d7
.ld_a:
    move.w  2(sp),d0                    ; d0 = promien r (3..6 px)
    lsr.w   #1,d7
    sub.w   d7,d0
    move.w  d4,d1
    add.w   d0,d1
    neg.w   d0
    add.w   d4,d0
    bsr.s   .lf_hline
    addq.w  #1,d6
    cmp.w   2(sp),d6
    ble.s   .ld_y
    movem.l (sp)+,d2/d4-d7
    rts

.lf_hline:
    tst.w   d2
    bmi.s   .lh_r
    cmp.w   #127,d2
    bgt.s   .lh_r
    tst.w   d0
    bpl.s   .lh_x0
    moveq   #0,d0
.lh_x0:
    cmp.w   #159,d1
    ble.s   .lh_x1
    move.w  #159,d1
.lh_x1:
    sub.w   d0,d1
    bmi.s   .lh_r
    movem.l d2/a1,-(sp)
    mulu.w  #160,d2
    add.w   d0,d2
    lea     (a0,d2.l),a1
.lh_lp:
    move.b  d3,(a1)+
    dbf     d1,.lh_lp
    movem.l (sp)+,d2/a1
.lh_r:
    rts

    even
flare_enabled: dc.b 1,0
