; ============================================================================
; AURA-3D AGA Engine v1.2 - Native 320x256 Bitplane FPS HUD (M68020+ / AGA)
; ============================================================================
; Renderuje ostry napis "FPS:XX" (48x9 px) w prawym gornym rogu ekranu
; bezposrednio na bitplanach po wykonaniu C2P (kolor 255 = bialy, 0 = obrys).
; Przelacznik widocznosci: klawisz H (hud_enabled).
; ============================================================================

hud_fps_init:
    move.b  #1,hud_enabled
    move.w  #50,hud_fps_val
    move.l  vbl_tick(pc),hud_last_vbl
    clr.w   hud_frame_cnt
    bsr.w   hud_bake_bitmap
    rts

hud_fps_tick:
    movem.l d0-d1,-(sp)
    addq.w  #1,hud_frame_cnt
    move.l  vbl_tick(pc),d0
    move.l  d0,d1
    sub.l   hud_last_vbl(pc),d1
    cmp.l   #50,d1                      ; 50 VBL = 1.0 s (PAL)
    blo.s   .tick_done

    move.l  d0,hud_last_vbl
    move.w  hud_frame_cnt(pc),d0
    cmp.w   #50,d0
    ble.s   .fps_ok
    moveq   #50,d0
.fps_ok:
    move.w  d0,hud_fps_val
    clr.w   hud_frame_cnt
    bsr.w   hud_bake_bitmap
.tick_done:
    movem.l (sp)+,d0-d1
    rts

; Sklada 9 wierszy maski tekstu (64 bity = 2 longwordy na wiersz) raz na sekunde
hud_bake_bitmap:
    movem.l d0-d7/a0-a3,-(sp)
    lea     hud_chars(pc),a0
    move.b  #10,(a0)+                   ; F
    move.b  #11,(a0)+                   ; P
    move.b  #12,(a0)+                   ; S
    move.b  #13,(a0)+                   ; :

    moveq   #0,d0
    move.w  hud_fps_val(pc),d0
    divu.w  #10,d0
    move.b  d0,(a0)+
    swap    d0
    move.b  d0,(a0)+

    lea     hud_bmp_fg(pc),a1
    lea     hud_bmp_box(pc),a2
    lea     hud_font_5x7(pc),a0

    moveq   #0,d7                       ; y = 0..8
.b_row:
    moveq   #0,d4                       ; gorne 32 bity (znaki 0..4)
    moveq   #0,d5                       ; dolne 32 bity (znak 5)

    tst.w   d7
    beq.w   .b_store
    cmp.w   #8,d7
    beq.w   .b_store

    move.w  d7,d6
    subq.w  #1,d6                       ; wiersz glifu 0..6

    lea     hud_chars(pc),a3
    ; Znak 0 (F) -> bit 26..30 w d4
    moveq   #0,d0
    move.b  (a3),d0
    lsl.w   #3,d0
    add.w   d6,d0
    moveq   #0,d1
    move.b  (a0,d0.w),d1
    lsl.l   #8,d1
    lsl.l   #8,d1
    lsl.l   #8,d1
    lsl.l   #2,d1
    or.l    d1,d4

    ; Znak 1 (P) -> bit 20..24 w d4
    moveq   #0,d0
    move.b  1(a3),d0
    lsl.w   #3,d0
    add.w   d6,d0
    moveq   #0,d1
    move.b  (a0,d0.w),d1
    lsl.l   #8,d1
    lsl.l   #8,d1
    lsl.l   #4,d1
    or.l    d1,d4

    ; Znak 2 (S) -> bit 14..18 w d4
    moveq   #0,d0
    move.b  2(a3),d0
    lsl.w   #3,d0
    add.w   d6,d0
    moveq   #0,d1
    move.b  (a0,d0.w),d1
    lsl.l   #8,d1
    lsl.l   #6,d1
    or.l    d1,d4

    ; Znak 3 (:) -> bit 8..12 w d4
    moveq   #0,d0
    move.b  3(a3),d0
    lsl.w   #3,d0
    add.w   d6,d0
    moveq   #0,d1
    move.b  (a0,d0.w),d1
    lsl.l   #8,d1
    or.l    d1,d4

    ; Znak 4 (dziesiatki) -> bit 2..6 w d4
    moveq   #0,d0
    move.b  4(a3),d0
    lsl.w   #3,d0
    add.w   d6,d0
    moveq   #0,d1
    move.b  (a0,d0.w),d1
    lsl.l   #2,d1
    or.l    d1,d4

    ; Znak 5 (jednosci) -> bit 27..31 w d5
    moveq   #0,d0
    move.b  5(a3),d0
    lsl.w   #3,d0
    add.w   d6,d0
    moveq   #0,d1
    move.b  (a0,d0.w),d1
    lsl.l   #8,d1
    lsl.l   #8,d1
    lsl.l   #8,d1
    lsl.l   #3,d1
    or.l    d1,d5

.b_store:
    move.l  d4,(a1)+
    move.l  d5,(a1)+
    ; Maska tła ramki HUD (42 px szerokosci w prawym gornym rogu)
    move.l  #$7ffffffc,(a2)+
    move.l  #$fc000000,(a2)+

    addq.w  #1,d7
    cmp.w   #9,d7
    blo.w   .b_row

    movem.l (sp)+,d0-d7/a0-a3
    rts

; ----------------------------------------------------------------------------
; hud_draw_overlay - Wypisuje HUD na draw_bpl1..8 zaraz po C2P (X=256, Y=6)
; ----------------------------------------------------------------------------
hud_draw_overlay:
    tst.b   hud_enabled(pc)
    beq.s   .hdo_ret
    movem.l d0-d7/a0-a3,-(sp)

    ; Offset ekranowy: Y=6 * 40 bajtow + X=256/8 (32 bajty) = 272
    lea     draw_bpl1(pc),a0
    moveq   #7,d6                       ; 8 bitplanow (kolor 255 = bialy, 0 = czarne tlo ramki)
.bpl_lp:
    move.l  (a0),a1
    addq.l  #8,a0                       ; nastepny draw_bplX
    lea     272(a1),a1

    lea     hud_bmp_fg(pc),a2
    lea     hud_bmp_box(pc),a3
    moveq   #8,d7                       ; 9 wierszy
.y_lp:
    move.l  (a3)+,d0
    not.l   d0
    and.l   d0,(a1)                     ; wyczysc tlo ramki na kolor 0
    move.l  (a2)+,d1
    or.l    d1,(a1)                     ; ustaw piksele tekstu na kolor 255

    move.l  (a3)+,d0
    not.l   d0
    and.l   d0,4(a1)
    move.l  (a2)+,d1
    or.l    d1,4(a1)

    lea     40(a1),a1
    dbf     d7,.y_lp
    dbf     d6,.bpl_lp

    movem.l (sp)+,d0-d7/a0-a3
.hdo_ret:
    rts

    even
hud_fps_val:    dc.w 50
hud_frame_cnt:  dc.w 0
hud_last_vbl:   dc.l 0
hud_chars:      ds.b 6
hud_enabled:    dc.b 1,0
hud_bmp_fg:     ds.l 18
hud_bmp_box:    ds.l 18

hud_font_5x7:
    dc.b $0e,$11,$13,$15,$19,$11,$0e,0  ; 0
    dc.b $04,$0c,$04,$04,$04,$04,$0e,0  ; 1
    dc.b $0e,$11,$01,$02,$04,$08,$1f,0  ; 2
    dc.b $1f,$02,$04,$02,$01,$11,$0e,0  ; 3
    dc.b $02,$06,$0a,$12,$1f,$02,$02,0  ; 4
    dc.b $1f,$10,$1e,$01,$01,$11,$0e,0  ; 5
    dc.b $06,$08,$10,$1e,$11,$11,$0e,0  ; 6
    dc.b $1f,$01,$02,$04,$08,$08,$08,0  ; 7
    dc.b $0e,$11,$11,$0e,$11,$11,$0e,0  ; 8
    dc.b $0e,$11,$11,$0f,$01,$02,$0c,0  ; 9
    dc.b $1f,$10,$10,$1e,$10,$10,$10,0  ; 10: F
    dc.b $1e,$11,$11,$1e,$10,$10,$10,0  ; 11: P
    dc.b $0f,$10,$10,$0e,$01,$01,$1e,0  ; 12: S
    dc.b $00,$04,$04,$00,$04,$04,$00,0  ; 13: :
