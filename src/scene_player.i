; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN] MODULE: scene_player.i | 16-Bit Packed Stream + 24-Bit AGA Copper Sky & Beat Sync
; [PL] MODUL: scene_player.i | Strumien 16-bit + 24-bit niebo Coppera AGA i Beat Sync
play_vector_frame:
    movem.l d0-d5/a0-a2,-(sp)
    moveq   #0,d0
    move.w  cur_frame(pc),d0
    lea     vec_frame_table,a0
    move.l  (a0,d0.l*4),a0
    move.w  (a0)+,d2                ; base RGB12 sky color
    move.l  cop_pal_ptr(pc),a1
    move.w  d2,2(a1)
    move.w  (a0)+,6(a1)             ; COLOR01
    move.w  (a0)+,10(a1)            ; COLOR02
    move.w  (a0)+,18(a1)            ; COLOR04 (Blitter AA)
    bsr.w   update_copper_sky
.poly_loop:
    move.w  (a0)+,d0
    bmi.s   .frame_done
    move.l  a0,a1
    bsr.w   draw_polygon_mode
    move.w  (a0)+,d1                ; N vertices (2 bytes each!)
    add.w   d1,d1
    add.w   d1,a0
    bra.s   .poly_loop
.frame_done:
    movem.l (sp)+,d0-d5/a0-a2
    rts
update_copper_sky:
    move.l  cop_sky_ptr(pc),a2
    moveq   #0,d3
    move.b  beat_boost(pc),d3
    moveq   #31,d4
    moveq   #0,d5
.sky_lp:
    move.w  d5,d0
    lsr.w   #2,d0
    add.w   d3,d0
    subq.w  #3,d0
    move.w  d2,d1
    lsr.w   #8,d1
    and.w   #$000f,d1
    add.w   d0,d1
    bpl.s   .r_ok1
    moveq   #0,d1
.r_ok1: cmp.w #15,d1
    ble.s   .r_ok2
    moveq   #15,d1
.r_ok2: lsl.w #8,d1
    move.w  d2,d0
    lsr.w   #4,d0
    and.w   #$000f,d0
    move.w  d5,a1
    add.w   d3,d0
    subq.w  #2,d0
    bpl.s   .g_ok1
    moveq   #0,d0
.g_ok1: cmp.w #15,d0
    ble.s   .g_ok2
    moveq   #15,d0
.g_ok2: lsl.w #4,d0
    or.w    d0,d1
    move.w  d2,d0
    and.w   #$000f,d0
    add.w   d3,d0
    cmp.w   #15,d0
    ble.s   .b_ok
    moveq   #15,d0
.b_ok:  or.w    d0,d1
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     16(a2),a2
    addq.w  #1,d5
    dbf     d4,.sky_lp
    rts
