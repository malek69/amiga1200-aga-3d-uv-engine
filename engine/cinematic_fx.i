        section code,code
cine_draw_letterbox:
        movem.l d0-d3/a0,-(sp)
        move.w  cine_bar_h(pc),d2
        ble.s   .lb_end
        cmp.w   #40,d2
        ble.s   .lb_ok
        moveq   #40,d2
.lb_ok: lea     chunky_buf,a0
        move.w  d2,d3
        subq.w  #1,d3
.lb_t:  moveq   #79,d0
.lb_tx: clr.l   (a0)+
        dbf     d0,.lb_tx
        dbf     d3,.lb_t
        lea     chunky_buf+256*320,a0
        move.w  d2,d0
        mulu.w  #320,d0
        suba.l  d0,a0
        move.w  d2,d3
        subq.w  #1,d3
.lb_b:  moveq   #79,d0
.lb_bx: clr.l   (a0)+
        dbf     d0,.lb_bx
        dbf     d3,.lb_b
.lb_end:movem.l (sp)+,d0-d3/a0
        rts
cine_move_camera_smooth:
        movem.l d0-d1,-(sp)
        move.l  cine_target_x(pc),d0
        sub.l   cam_x(pc),d0
        asr.l   #4,d0
        add.l   d0,cam_x
        move.l  cine_target_y(pc),d0
        sub.l   cam_y(pc),d0
        asr.l   #4,d0
        add.l   d0,cam_y
        move.w  cine_target_alt(pc),d0
        sub.w   cam_alt(pc),d0
        asr.w   #3,d0
        add.w   d0,cam_alt
        move.w  cine_target_pitch(pc),d0
        sub.w   cam_pitch(pc),d0
        asr.w   #3,d0
        add.w   d0,cam_pitch
        movem.l (sp)+,d0-d1
        rts
cine_draw_portrait_anim:
        movem.l d0-d7/a0-a1,-(sp)
        lea     chunky_buf+182*320+22,a0
        moveq   #57,d7
.pt_bg: moveq   #47,d6
.pt_bx: move.b  #134,(a0,d6.w)
        dbf     d6,.pt_bx
        adda.w  #320,a0
        dbf     d7,.pt_bg
        lea     chunky_buf+187*320+33,a0
        moveq   #10,d7
.hm_lp: move.w  #21,d6
.hm_x:  move.b  #122,d0
        cmp.w   #11,d6
        blt.s   .hm_c
        move.b  #116,d0
.hm_c:  move.b  d0,(a0,d6.w)
        dbf     d6,.hm_x
        adda.w  #320,a0
        dbf     d7,.hm_lp
        lea     chunky_buf+198*320+35,a0
        moveq   #24,d7
.fc_lp: move.w  d7,d5
        asr.w   #2,d5
        moveq   #17,d6
        sub.w   d5,d6
        move.w  d5,d4
        cmp.w   #9,d7
        blt.s   .ns_no
        cmp.w   #15,d7
        bgt.s   .ns_no
        addq.w  #2,d6
.ns_no: move.w  d5,d4
.fc_x:  move.b  #61,d0
        cmp.w   #11,d4
        blt.s   .fc_c2
        move.b  #56,d0
.fc_c2: move.b  d0,(a0,d4.w)
        addq.w  #1,d4
        dbf     d6,.fc_x
        adda.w  #320,a0
        dbf     d7,.fc_lp
        lea     chunky_buf+203*320+37,a0
        moveq   #2,d7
.vs_lp: moveq   #15,d6
.vs_x:  move.b  #158,(a0,d6.w)
        dbf     d6,.vs_x
        adda.w  #320,a0
        dbf     d7,.vs_lp
        lea     chunky_buf+216*320+40,a0
        move.w  cine_talking(pc),d0
        beq.s   .m_cls
        btst    #2,vbl_tick+3
        beq.s   .m_cls
        moveq   #7,d6
.mo_x:  move.b  #128,(a0,d6.w)
        move.b  #255,320(a0,d6.w)
        dbf     d6,.mo_x
        bra.s   .pt_end
.m_cls: moveq   #7,d6
.mc_x:  move.b  #48,(a0,d6.w)
        dbf     d6,.mc_x
.pt_end:lea     chunky_buf+224*320+27,a0
        moveq   #14,d7
.sh_lp: moveq   #37,d6
.sh_x:  move.b  #152,d0
        cmp.w   #18,d6
        blt.s   .sh_c
        move.b  #146,d0
.sh_c:  move.b  d0,(a0,d6.w)
        dbf     d6,.sh_x
        adda.w  #320,a0
        dbf     d7,.sh_lp
        movem.l (sp)+,d0-d7/a0-a1
        rts
cine_draw_dialogue_panel:
        movem.l d0-d7/a0-a4,-(sp)
        lea     chunky_buf+178*320+16,a0
        moveq   #65,d7
.dp_y:  move.w  #287,d6
.dp_x:  move.b  #128,(a0,d6.w)
        dbf     d6,.dp_x
        adda.w  #320,a0
        dbf     d7,.dp_y
        lea     chunky_buf+178*320+16,a0
        move.w  #287,d6
.bd_x:  move.b  #156,(a0,d6.w)
        move.b  #156,65*320(a0,d6.w)
        dbf     d6,.bd_x
        bsr.w   cine_draw_portrait_anim
        clr.w   cine_talking
        move.w  cine_type_chars(pc),d7
        tst.l   cine_line1_ptr
        beq.s   .dp_no1
        move.l  cine_line1_ptr(pc),a2
        lea     chunky_buf+186*320+78,a3
        bsr.s   cine_print_n_5x7
.dp_no1:tst.l   cine_line2_ptr
        beq.s   .dp_no2
        move.l  cine_line2_ptr(pc),a2
        lea     chunky_buf+198*320+78,a3
        bsr.s   cine_print_n_5x7
.dp_no2:tst.w   d7
        bgt.s   .dp_no3
        tst.l   cine_line3_ptr
        beq.s   .dp_no3
        move.l  cine_line3_ptr(pc),a2
        lea     chunky_buf+216*320+78,a3
        move.w  #64,d7
        bsr.s   cine_print_n_5x7
.dp_no3:movem.l (sp)+,d0-d7/a0-a4
        rts
cine_print_n_5x7:
        tst.w   d7
        ble.s   .cp_end
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .cp_end
        subq.w  #1,d7
        bne.s   .ch_ok
        move.w  #1,cine_talking
.ch_ok: sub.w   #32,d0
        lsl.w   #3,d0
        lea     hud_ascii_5x7,a4
        add.l   d0,a4
        move.l  a3,a5
        moveq   #6,d3
.py_lp: move.b  (a4)+,d4
        btst    #4,d4
        beq.s   .b3
        move.b  #255,(a5)
.b3:    btst    #3,d4
        beq.s   .b2
        move.b  #255,1(a5)
.b2:    btst    #2,d4
        beq.s   .b1
        move.b  #255,2(a5)
.b1:    btst    #1,d4
        beq.s   .b0
        move.b  #255,3(a5)
.b0:    btst    #0,d4
        beq.s   .nx
        move.b  #255,4(a5)
.nx:    adda.w  #320,a5
        dbf     d3,.py_lp
        addq.l  #6,a3
        bra.s   cine_print_n_5x7
.cp_end:rts
cine_update_and_draw:
        cmp.b   #$14,kbd_held_raw
        bne.s   .ck_act
        move.b  #1,cine_active
        move.w  #1,cine_type_chars
.ck_act:tst.b   cine_active
        beq.s   .cu_end
        cmp.w   #16,cine_bar_h
        bge.s   .cb_ok
        addq.w  #1,cine_bar_h
.cb_ok: addq.w  #1,cine_type_chars
        bsr.w   cine_draw_dialogue_panel
        jsr     thea1200_draw_mouse_cursor
        cmp.w   #28,cine_type_chars
        blt.s   .cu_end
        bne.s   .ck_key
        clr.b   kbd_held_raw
        clr.b   mouse_lmb_click
.ck_key:
        move.b  kbd_held_raw,d0
        cmp.b   #$01,d0
        beq.s   .cu_cls
        cmp.b   #$02,d0
        beq.s   .cu_cls
        cmp.b   #$44,d0
        beq.s   .cu_cls
        tst.b   mouse_lmb_click
        beq.s   .cu_end
.cu_cls:clr.b   cine_active
.cu_end:rts
cine_bar_h:        dc.w 0
cine_talking:      dc.w 0
cine_type_chars:   dc.w 1
cine_active:       dc.b 1,0
cine_target_x:     dc.l 0
cine_target_y:     dc.l 0
cine_target_alt:   dc.w 115
cine_target_pitch: dc.w 110
cine_line1_ptr:    dc.l cine_demo_l1
cine_line2_ptr:    dc.l cine_demo_l2
cine_line3_ptr:    dc.l cine_demo_l3
cine_demo_l1:      dc.b "ORBITAL CMD: WELCOME TO SECTOR 01.",0
cine_demo_l2:      dc.b "DOMES IN SECTOR 01 AWAIT ORDERS.",0
cine_demo_l3:      dc.b "[1] ACKNOWLEDGE   [2] SCAN SECTOR",0
        even
