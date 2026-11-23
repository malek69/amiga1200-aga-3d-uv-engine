; ============================================================================
; AURA-3D AGA Engine v1.2 - Native 320x256 Bitplane FPS HUD (M68020+ / AGA)
; ============================================================================
; Renderuje ostry napis "FPS:XX" (48x9 px) w prawym gornym rogu ekranu
; bezposrednio na bitplanach po wykonaniu C2P (kolor 255 = bialy, 0 = obrys).
; Przelacznik widocznosci: klawisz H (hud_enabled).
; ============================================================================

hud_fps_init:
    move.b  #1,hud_enabled
    clr.b   keymap_visible
    bsr.w   hud_bake_keymap
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
    movem.l d0-d7/a0-a4,-(sp)
    tst.b   hud_enabled(pc)
    beq.w   .chk_km

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

    ; Rysuj widoczna etykiete "[K] KLAWISZE" zaraz pod licznikiem FPS (Y=17, X=256)
    lea     draw_bpl1(pc),a0
    moveq   #7,d6
.hb_lp:
    move.l  (a0),a1
    addq.l  #8,a0
    lea     17*40+32(a1),a1
    lea     hud_k_badge(pc),a2
    moveq   #6,d7
.hb_y:
    move.l  (a2)+,d0
    or.l    d0,(a1)
    lea     40(a1),a1
    dbf     d7,.hb_y
    dbf     d6,.hb_lp

.chk_km:
    tst.b   keymap_visible(pc)
    beq.s   .hdo_done
    lea     draw_bpl1(pc),a0
    moveq   #7,d6
.km_bpl:
    move.l  (a0),a1
    addq.l  #8,a0
    lea     56*40+4(a1),a1
    lea     keymap_bmp,a2
    moveq   #53,d7
.km_y:
    move.l  (a2)+,(a1)
    move.l  (a2)+,4(a1)
    move.l  (a2)+,8(a1)
    move.l  (a2)+,12(a1)
    move.l  (a2)+,16(a1)
    move.l  (a2)+,20(a1)
    move.l  (a2)+,24(a1)
    move.l  (a2)+,28(a1)
    lea     40(a1),a1
    dbf     d7,.km_y
    dbf     d6,.km_bpl
.hdo_done:
    movem.l (sp)+,d0-d7/a0-a4
.hdo_ret:
    rts

hud_bake_keymap:
    movem.l d0-d7/a0-a4,-(sp)
    lea     keymap_bmp,a1
    move.w  #(8*54)-1,d0
.km_clr:
    clr.l   (a1)+
    dbf     d0,.km_clr
    lea     keymap_lines(pc),a0
    lea     hud_ascii_5x7(pc),a2
    moveq   #0,d7
.km_ln:
    move.w  d7,d6
    mulu.w  #9*32,d6
    lea     keymap_bmp,a1
    adda.l  d6,a1
    adda.l  #32,a1
    moveq   #0,d5
.km_ch:
    moveq   #0,d0
    move.b  (a0)+,d0
    sub.w   #32,d0
    bpl.s   .km_ok
    moveq   #0,d0
.km_ok:
    lsl.w   #3,d0
    lea     (a2,d0.w),a3
    move.w  d5,d1
    mulu.w  #6,d1
    addq.w  #8,d1
    move.w  d1,d2
    lsr.w   #3,d2
    and.w   #7,d1
    moveq   #0,d4
.km_gy:
    moveq   #0,d0
    move.b  (a3,d4.w),d0
    lsl.w   #8,d0
    lsl.w   #3,d0
    lsr.w   d1,d0
    move.w  d4,d3
    lsl.w   #5,d3
    add.w   d2,d3
    or.b    d0,1(a1,d3.w)
    lsr.w   #8,d0
    or.b    d0,(a1,d3.w)
    addq.w  #1,d4
    cmp.w   #7,d4
    blo.s   .km_gy
    addq.w  #1,d5
    cmp.w   #40,d5
    blo.s   .km_ch
    addq.w  #1,d7
    cmp.w   #6,d7
    blo.s   .km_ln
    movem.l (sp)+,d0-d7/a0-a4
    rts

hud_k_badge:
    dc.l $90979070
    dc.l $a0941048
    dc.l $c0f71070
    dc.l $a0941040
    dc.l $90979e40
    dc.l $00000000
    dc.l $00000000

keymap_lines:
    dc.b "  AURA-3D AGA ENGINE V1.14 - KLAWISZE   "
    dc.b " F1-F8: SCENY   TAB: NASTEPNA SCENA     "
    dc.b " STRZALKI / JOY2: OBROT   W/S: ZOOM     "
    dc.b " 1-4: NIEBO COPPER   M: LUSTRO  G: PODL "
    dc.b " C: CIENIE  F: MGLA  L: FLARA  H: FPS    "
    dc.b " SPACJA/R: RESET   K: ZAMKNIJ PANEL     "

hud_ascii_5x7:
    dc.b $00,$00,$00,$00,$00,$00,$00,0, $04,$04,$04,$04,$00,$00,$04,0
    dc.b $0a,$0a,$00,$00,$00,$00,$00,0, $0a,$1f,$0a,$0a,$1f,$0a,$00,0
    dc.b $04,$0f,$14,$0e,$05,$1e,$04,0, $19,$19,$02,$04,$08,$13,$13,0
    dc.b $0c,$12,$14,$08,$15,$12,$0d,0, $04,$04,$00,$00,$00,$00,$00,0
    dc.b $02,$04,$08,$08,$08,$04,$02,0, $08,$04,$02,$02,$02,$04,$08,0
    dc.b $00,$04,$15,$0e,$15,$04,$00,0, $00,$04,$04,$1f,$04,$04,$00,0
    dc.b $00,$00,$00,$00,$04,$04,$08,0, $00,$00,$00,$1f,$00,$00,$00,0
    dc.b $00,$00,$00,$00,$00,$0c,$0c,0, $01,$01,$02,$04,$08,$10,$10,0
    dc.b $0e,$11,$13,$15,$19,$11,$0e,0, $04,$0c,$04,$04,$04,$04,$0e,0
    dc.b $0e,$11,$01,$02,$04,$08,$1f,0, $1f,$02,$04,$02,$01,$11,$0e,0
    dc.b $02,$06,$0a,$12,$1f,$02,$02,0, $1f,$10,$1e,$01,$01,$11,$0e,0
    dc.b $06,$08,$10,$1e,$11,$11,$0e,0, $1f,$01,$02,$04,$08,$08,$08,0
    dc.b $0e,$11,$11,$0e,$11,$11,$0e,0, $0e,$11,$11,$0f,$01,$02,$0c,0
    dc.b $00,$0c,$0c,$00,$0c,$0c,$00,0, $00,$04,$04,$00,$04,$04,$08,0
    dc.b $02,$04,$08,$10,$08,$04,$02,0, $00,$00,$1f,$00,$1f,$00,$00,0
    dc.b $08,$04,$02,$01,$02,$04,$08,0, $0e,$11,$01,$02,$04,$00,$04,0
    dc.b $0e,$11,$17,$15,$17,$10,$0e,0, $0e,$11,$11,$1f,$11,$11,$11,0
    dc.b $1e,$11,$11,$1e,$11,$11,$1e,0, $0e,$11,$10,$10,$10,$11,$0e,0
    dc.b $1c,$12,$11,$11,$11,$12,$1c,0, $1f,$10,$10,$1e,$10,$10,$1f,0
    dc.b $1f,$10,$10,$1e,$10,$10,$10,0, $0e,$11,$10,$17,$11,$11,$0f,0
    dc.b $11,$11,$11,$1f,$11,$11,$11,0, $0e,$04,$04,$04,$04,$04,$0e,0
    dc.b $07,$02,$02,$02,$02,$12,$0c,0, $11,$12,$14,$18,$14,$12,$11,0
    dc.b $10,$10,$10,$10,$10,$10,$1f,0, $11,$1b,$15,$15,$11,$11,$11,0
    dc.b $11,$19,$15,$13,$11,$11,$11,0, $0e,$11,$11,$11,$11,$11,$0e,0
    dc.b $1e,$11,$11,$1e,$10,$10,$10,0, $0e,$11,$11,$11,$15,$12,$0d,0
    dc.b $1e,$11,$11,$1e,$14,$12,$11,0, $0f,$10,$10,$0e,$01,$01,$1e,0
    dc.b $1f,$04,$04,$04,$04,$04,$04,0, $11,$11,$11,$11,$11,$11,$0e,0
    dc.b $11,$11,$11,$11,$11,$0a,$04,0, $11,$11,$11,$15,$15,$1b,$11,0
    dc.b $11,$11,$0a,$04,$0a,$11,$11,0, $11,$11,$0a,$04,$04,$04,$04,0
    dc.b $1f,$01,$02,$04,$08,$10,$1f,0, $0e,$08,$08,$08,$08,$08,$0e,0
    dc.b $10,$10,$08,$04,$02,$01,$01,0, $0e,$02,$02,$02,$02,$02,$0e,0
    dc.b $04,$0a,$11,$00,$00,$00,$00,0, $00,$00,$00,$00,$00,$00,$1f,0

    section fastram_bss,bss_p
keymap_bmp:     ds.b 54*32
    section code,code

    even
hud_fps_val:    dc.w 50
hud_frame_cnt:  dc.w 0
hud_last_vbl:   dc.l 0
hud_chars:      ds.b 6
hud_enabled:    dc.b 1
keymap_visible: dc.b 0
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
