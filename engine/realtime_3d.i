render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d7
    cmp.l   #150,d7
    bhs.s   .after_splash
    lea     splash_pal_data,a0
    bsr.w   load_aga_256_palette
    bsr.w   decode_splash_to_draw_bpl
    clr.b   pal_loaded
    movem.l (sp)+,d0-d7/a0-a5
    rts

.after_splash:
    sub.l   #150,d7
    tst.b   pal_loaded
    bne.s   .pal_ok
    move.b  #1,pal_loaded
    lea     aga_pal256,a0
    bsr.w   load_aga_256_palette
.pal_ok:
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
