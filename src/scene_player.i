; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN] MODULE: scene_player.i | Dynamic 4-Color AGA Palette & Vector Frame Decoder (v2.0)
; [PL] MODUL: scene_player.i | Dekoder dynamicznej 4-kolorowej palety AGA i klatek (v2.0)

play_vector_frame:
    movem.l d0-d1/a0-a1,-(sp)
    moveq   #0,d0
    move.w  cur_frame(pc),d0
    lea     vec_frame_table,a0
    move.l  (a0,d0.l*4),a0

    move.l  cop_pal_ptr(pc),a1
    move.w  (a0)+,2(a1)             ; COLOR00 (dynamic background)
    move.w  (a0)+,6(a1)             ; COLOR01 (BPL1 silhouette)
    move.w  (a0)+,10(a1)            ; COLOR02 (BPL2 accent)
    move.w  (a0)+,18(a1)            ; COLOR04 (Blitter AA midpoint)

.poly_loop:
    move.w  (a0)+,d0                ; op: 0=BPL1 fill, 1=BPL1 cutout, 2=BPL2 accent, -1=end
    bmi.s   .frame_done
    move.l  a0,a1
    bsr.w   draw_polygon_mode
    move.w  (a0)+,d1
    lsl.w   #2,d1
    add.w   d1,a0
    bra.s   .poly_loop

.frame_done:
    movem.l (sp)+,d0-d1/a0-a1
    rts
