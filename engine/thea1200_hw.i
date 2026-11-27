        section code,code
thea1200_init_hw:
        move.w  #$c000,$dff034
        move.w  #160,mouse_x
        move.w  #128,mouse_y
        move.w  $dff00a,mouse_prev_xy
        move.w  #256,aga_fade_lvl
        rts
thea1200_read_peripherals:
        movem.l d0-d3,-(sp)
        move.w  $dff00a,d0
        move.w  mouse_prev_xy(pc),d1
        move.w  d0,mouse_prev_xy
        move.b  d0,d2
        sub.b   d1,d2
        ext.w   d2
        move.w  d2,mouse_dx
        beq.s   .nmx
        move.b  #120,mouse_active
        add.w   d2,mouse_x
.nmx:   lsr.w   #8,d0
        lsr.w   #8,d1
        sub.b   d1,d0
        ext.w   d0
        move.w  d0,mouse_dy
        beq.s   .nmy
        move.b  #120,mouse_active
        add.w   d0,mouse_y
.nmy:
        cmp.w   #4,mouse_x
        bge.s   .mx1
        move.w  #4,mouse_x
.mx1:   cmp.w   #315,mouse_x
        ble.s   .mx2
        move.w  #315,mouse_x
.mx2:   cmp.w   #4,mouse_y
        bge.s   .my1
        move.w  #4,mouse_y
.my1:   cmp.w   #251,mouse_y
        ble.s   .my2
        move.w  #251,mouse_y
.my2:   clr.b   pad_btn2_held
        btst    #6,$dff016
        bne.s   .nb2
        move.b  #1,pad_btn2_held
.nb2:   clr.b   rmb_held
        btst    #2,$dff016
        bne.s   .nrm
        move.b  #1,rmb_held
.nrm:   clr.b   mouse_lmb_click
        btst    #6,$bfe001
        bne.s   .lmb_up
        tst.b   mouse_lmb_prev
        bne.s   .rd_end
        move.b  #1,mouse_lmb_prev
        move.b  #1,mouse_lmb_click
        move.b  #120,mouse_active
        bra.s   .rd_end
.lmb_up:clr.b   mouse_lmb_prev
.rd_end:movem.l (sp)+,d0-d3
        rts
thea1200_draw_mouse_cursor:
        tst.b   mouse_active
        beq.s   .mc_end
        subq.b  #1,mouse_active
        movem.l d0-d3/a0,-(sp)
        move.w  mouse_x(pc),d0
        move.w  mouse_y(pc),d1
        lea     chunky_buf,a0
        mulu.w  #320,d1
        add.l   d1,a0
        add.w   d0,a0
        moveq   #5,d2
.mc_lp: move.b  #255,(a0)
        move.b  #255,1(a0)
        adda.w  #320,a0
        dbf     d2,.mc_lp
        movem.l (sp)+,d0-d3/a0
.mc_end:rts
mouse_active:    dc.b 0
mouse_lmb_prev:  dc.b 0
mouse_lmb_click: dc.b 0,0

aga_apply_24bit_fade:
        movem.l d0-d7/a0-a2,-(sp)
        lea     $dff000,a1
        move.w  aga_fade_lvl(pc),d6
        moveq   #0,d7
.bk_lp: move.w  d7,d5
        ror.w   #3,d5
        move.w  d5,$106(a1)
        lea     $180(a1),a2
        moveq   #31,d4
.hi_lp: move.l  (a0)+,d0
        move.l  d0,d1
        swap    d1
        and.w   #$ff,d1
        mulu.w  d6,d1
        lsr.w   #8,d1
        move.w  d0,d2
        lsr.w   #8,d2
        and.w   #$ff,d2
        mulu.w  d6,d2
        lsr.w   #8,d2
        move.w  d0,d3
        and.w   #$ff,d3
        mulu.w  d6,d3
        lsr.w   #8,d3
        move.w  d1,d0
        and.w   #$f0,d0
        lsl.w   #4,d0
        and.w   #$f0,d2
        or.w    d2,d0
        lsr.w   #4,d3
        or.w    d3,d0
        move.w  d0,(a2)+
        dbf     d4,.hi_lp
        lea     -128(a0),a0
        or.w    #$0200,d5
        move.w  d5,$106(a1)
        lea     $180(a1),a2
        moveq   #31,d4
.lo_lp: move.l  (a0)+,d0
        move.l  d0,d1
        swap    d1
        and.w   #$ff,d1
        mulu.w  d6,d1
        lsr.w   #8,d1
        move.w  d0,d2
        lsr.w   #8,d2
        and.w   #$ff,d2
        mulu.w  d6,d2
        lsr.w   #8,d2
        move.w  d0,d3
        and.w   #$ff,d3
        mulu.w  d6,d3
        lsr.w   #8,d3
        and.w   #$0f,d1
        lsl.w   #8,d1
        and.w   #$0f,d2
        lsl.w   #4,d2
        or.w    d2,d1
        and.w   #$0f,d3
        or.w    d3,d1
        move.w  d1,(a2)+
        dbf     d4,.lo_lp
        addq.w  #1,d7
        cmp.w   #8,d7
        blt.w   .bk_lp
        clr.w   $106(a1)
        movem.l (sp)+,d0-d7/a0-a2
        rts

aga_apply_24bit_tint:
        movem.l d0-d7/a0-a2,-(sp)
        lea     $dff000,a1
        moveq   #0,d7
.tb_lp: move.w  d7,d5
        ror.w   #3,d5
        move.w  d5,$106(a1)
        lea     $180(a1),a2
        moveq   #31,d4
.th_lp: move.l  (a0)+,d0
        move.l  d0,d1
        swap    d1
        and.w   #$ff,d1
        mulu.w  aga_tint_r(pc),d1
        lsr.w   #8,d1
        cmp.w   #255,d1
        ble.s   .r1
        move.w  #255,d1
.r1:    move.w  d0,d2
        lsr.w   #8,d2
        and.w   #$ff,d2
        mulu.w  aga_tint_g(pc),d2
        lsr.w   #8,d2
        cmp.w   #255,d2
        ble.s   .g1
        move.w  #255,d2
.g1:    move.w  d0,d3
        and.w   #$ff,d3
        mulu.w  aga_tint_b(pc),d3
        lsr.w   #8,d3
        cmp.w   #255,d3
        ble.s   .b1
        move.w  #255,d3
.b1:    move.w  d1,d0
        and.w   #$f0,d0
        lsl.w   #4,d0
        and.w   #$f0,d2
        or.w    d2,d0
        lsr.w   #4,d3
        or.w    d3,d0
        move.w  d0,(a2)+
        dbf     d4,.th_lp
        lea     -128(a0),a0
        or.w    #$0200,d5
        move.w  d5,$106(a1)
        lea     $180(a1),a2
        moveq   #31,d4
.tl_lp: move.l  (a0)+,d0
        move.l  d0,d1
        swap    d1
        and.w   #$ff,d1
        mulu.w  aga_tint_r(pc),d1
        lsr.w   #8,d1
        cmp.w   #255,d1
        ble.s   .r2
        move.w  #255,d1
.r2:    move.w  d0,d2
        lsr.w   #8,d2
        and.w   #$ff,d2
        mulu.w  aga_tint_g(pc),d2
        lsr.w   #8,d2
        cmp.w   #255,d2
        ble.s   .g2
        move.w  #255,d2
.g2:    move.w  d0,d3
        and.w   #$ff,d3
        mulu.w  aga_tint_b(pc),d3
        lsr.w   #8,d3
        cmp.w   #255,d3
        ble.s   .b2
        move.w  #255,d3
.b2:    and.w   #$0f,d1
        lsl.w   #8,d1
        and.w   #$0f,d2
        lsl.w   #4,d2
        or.w    d2,d1
        and.w   #$0f,d3
        or.w    d3,d1
        move.w  d1,(a2)+
        dbf     d4,.tl_lp
        addq.w  #1,d7
        cmp.w   #8,d7
        blt.w   .tb_lp
        clr.w   $106(a1)
        movem.l (sp)+,d0-d7/a0-a2
        rts
aga_tint_r: dc.w 256
aga_tint_g: dc.w 256
aga_tint_b: dc.w 256
aga_mood:   dc.b 0,0
mouse_dx:      dc.w 0
mouse_dy:      dc.w 0
mouse_x:       dc.w 160
mouse_y:       dc.w 128
mouse_prev_xy: dc.w 0
aga_fade_lvl:  dc.w 256
pad_btn2_held: dc.b 0
rmb_held:      dc.b 0
