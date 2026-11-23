render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    tst.b   pal_loaded
    bne.s   .pal_ok
    move.b  #1,pal_loaded
    lea     aga_pal256,a0
    bsr.w   load_aga_256_palette
.pal_ok:
    move.l  vbl_tick(pc),d7
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
    jsr     hud_draw_overlay
    movem.l (sp)+,d0-d7/a0-a5
    rts
pal_loaded: dc.b 0,0
