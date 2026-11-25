render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d7
    cmp.l   #150,d7
    bhs.s   .after_splash
    cmp.b   #2,pal_loaded
    beq.s   .sp_cached
    move.b  #2,pal_loaded
    lea     splash_pal_data,a0
    bsr.w   load_aga_256_palette
    bsr.w   decode_splash_to_draw_bpl
    bsr.w   copy_draw_to_disp_bpl
.sp_cached:
    movem.l (sp)+,d0-d7/a0-a5
    rts

.after_splash:
    sub.l   #150,d7
    lea     scene_timeline_table(pc),a0
.tl_lp:
    move.l  (a0)+,d0                ; start_tick
    move.l  (a0)+,d1                ; end_tick ($ffffffff = koniec)
    move.l  (a0)+,a1                ; wskaznik procedury sceny w demo_scenes.i
    cmp.l   d1,d7
    blo.s   .run_sc
    bra.s   .tl_lp
.run_sc:
    sub.l   d0,d7                   ; lokalny czas sceny (t = 0..N)
    jsr     (a1)
    bsr.w   c2p_160x128_to_aga
    jsr     ground_fill_screen_margins
    jsr     hud_draw_overlay
    cmp.b   #1,pal_loaded
    beq.s   .pal_done
    move.b  #1,pal_loaded
    bsr.w   wait_vbl
    lea     aga_pal256,a0
    bsr.w   load_aga_256_palette
    moveq   #0,d0
    jsr     copper_set_sky_theme
.pal_done:
    movem.l (sp)+,d0-d7/a0-a5
    rts
pal_loaded: dc.b 0,0

decode_splash_to_draw_bpl:
    movem.l d0-d1/d5/d7/a0-a2,-(sp)
    lea     splash_bpl_rle,a0
    lea     draw_bpl1(pc),a1
    moveq   #7,d7
.ds_bpl:
    move.l  (a1),a2
    addq.l  #8,a1
    move.w  #10240,d5
.ds_dec:
    tst.w   d5
    ble.s   .ds_next
    moveq   #0,d0
    move.b  (a0)+,d0
    bmi.s   .ds_run
    sub.w   d0,d5
    subq.w  #1,d5
.ds_lit:
    move.b  (a0)+,(a2)+
    dbf     d0,.ds_lit
    bra.s   .ds_dec
.ds_run:
    and.w   #$7f,d0
    sub.w   d0,d5
    subq.w  #1,d5
    move.b  (a0)+,d1
.ds_rlp:
    move.b  d1,(a2)+
    dbf     d0,.ds_rlp
    bra.s   .ds_dec
.ds_next:
    dbf     d7,.ds_bpl
    movem.l (sp)+,d0-d1/d5/d7/a0-a2
    rts

copy_draw_to_disp_bpl:
    movem.l d0-d1/a0-a3,-(sp)
    lea     draw_bpl1(pc),a2
    lea     disp_bpl1(pc),a3
    moveq   #7,d1
.cb_p:
    move.l  (a2),a0
    move.l  (a3),a1
    addq.l  #8,a2
    addq.l  #8,a3
    move.w  #2560-1,d0
.cb_l:
    move.l  (a0)+,(a1)+
    dbf     d0,.cb_l
    dbf     d1,.cb_p
    movem.l (sp)+,d0-d1/a0-a3
    rts
