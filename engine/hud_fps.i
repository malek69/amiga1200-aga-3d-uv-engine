; ============================================================================
; AURA-3D AGA Engine v1.2 - Native 320x256 Bitplane FPS HUD (M68020+ / AGA)
; ============================================================================
; Renderuje ostry napis "FPS:XX" (48x9 px) w prawym gornym rogu ekranu
; bezposrednio na bitplanach po wykonaniu C2P (kolor 255 = bialy, 0 = obrys).
; Przelacznik widocznosci: klawisz H (hud_enabled).
; ============================================================================

hud_fps_init:
    move.b  #1,hud_enabled
    move.b  #1,info_visible
    move.w  #-2,hud_last_scene
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
    sub.l   hud_last_vbl,d1
    cmp.l   #50,d1                      ; 50 VBL = 1.0 s (PAL)
    blo.s   .tick_done

    move.l  d0,hud_last_vbl
    move.w  hud_frame_cnt,d0
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
    lea     hud_chars,a0
    move.b  #10,(a0)+                   ; F
    move.b  #11,(a0)+                   ; P
    move.b  #12,(a0)+                   ; S
    move.b  #13,(a0)+                   ; :

    moveq   #0,d0
    move.w  hud_fps_val,d0
    divu.w  #10,d0
    move.b  d0,(a0)+
    swap    d0
    move.b  d0,(a0)+

    lea     hud_bmp_fg,a1
    lea     hud_bmp_box,a2
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

    lea     hud_chars,a3
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
    tst.b   hud_enabled
    beq.w   .chk_km

    lea     draw_bpl1(pc),a0
    moveq   #7,d6                       ; 8 bitplanow (kolor 255 = bialy, 0 = czarne tlo ramki)
.bpl_lp:
    move.l  (a0),a1
    addq.l  #8,a0                       ; nastepny draw_bplX
    ifd FULL_RES
    lea     8*40+32(a1),a1              ; Y=8, X=256 (widoczne w DIWSTRT=$2c81)
    else
    lea     16*40+30(a1),a1             ; Y=16, X=240 (widoczne w DIWSTRT=$3891)
    endif

    lea     hud_bmp_fg,a2
    lea     hud_bmp_box,a3
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

    ; Rysuj "[H] HELP / [L] LANG" wylacznie podczas misji 3D (w Intro/Briefing tylko FPS!)
    bra.w   .hdo_done

    lea     draw_bpl1(pc),a0
    moveq   #7,d6
.hb_lp:
    move.l  (a0),a1
    addq.l  #8,a0
    ifd FULL_RES
    lea     19*40+32(a1),a1
    else
    lea     27*40+30(a1),a1
    endif
    lea     hud_k_badge(pc),a2
    moveq   #13,d7
.hb_y:
    move.l  (a2)+,d0
    or.l    d0,(a1)
    lea     40(a1),a1
    dbf     d7,.hb_y
    dbf     d6,.hb_lp

.chk_km:
    tst.b   keymap_visible
    beq.s   .hdo_done
    move.b  hud_lang,d0
    cmp.b   hud_last_km_lang,d0
    beq.s   .km_blit
    move.b  d0,hud_last_km_lang
    bsr.w   hud_bake_keymap
.km_blit:
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
    bsr.w   hud_draw_scene_info
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
    tst.b   hud_last_km_lang
    beq.s   .km_src_ok
    lea     keymap_lines_eng(pc),a0
.km_src_ok:
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
    dc.l $9025e870
    dc.l $90250848
    dc.l $f03dc870
    dc.l $90250840
    dc.l $9025ef40
    dc.l $00000000
    dc.l $00000000
    dc.l $8020c938
    dc.l $80212d40
    dc.l $8021ef58
    dc.l $80212b48
    dc.l $f03d2938
    dc.l $00000000
    dc.l $00000000

keymap_lines:
    dc.b " AETHER FALCON: VANGUARD - STEROWANIE   "
    dc.b " STRZALKI / JOY2 : LOT I CELOWNIK LOCK  "
    dc.b " SPACJA / FIRE / ALT : DZIALKA+RAKIETY  "
    dc.b " PRZYTRZYMAJ FIRE : DOPALACZ TURBO      "
    dc.b " L : JEZYK (PL/EN)   H : ZAMKNIJ HELP   "
    dc.b " ESC / LMB : WYJSCIE DO AMIGAOS         "
hud_last_km_lang: dc.b 0,0
keymap_lines_eng:
    dc.b " AETHER FALCON: VANGUARD - CONTROLS     "
    dc.b " ARROWS / JOY2 : FLY & LOCK-ON RETICLE  "
    dc.b " SPACE / FIRE / ALT : CANNON & MISSILES "
    dc.b " HOLD FIRE : AFTERBURNER TURBO BOOST    "
    dc.b " L : LANG (PL/EN)   H : CLOSE HELP      "
    dc.b " ESC / LMB : EXIT TO AMIGAOS            "

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
    section hud_data_p,data_p

    even
hud_fps_val:    dc.w 50
hud_frame_cnt:  dc.w 0
hud_last_vbl:   dc.l 0
hud_chars:      ds.b 6
hud_enabled:    dc.b 1
keymap_visible: dc.b 0
hud_bmp_fg:     ds.l 18
hud_bmp_box:    ds.l 18

    section code,code

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

; ----------------------------------------------------------------------------
; hud_draw_scene_info - Pasek opisu sceny i efektow na dole ekranu (Y=246..254)
; ----------------------------------------------------------------------------
hud_draw_scene_info:
    rts
    movem.l d0-d7/a0-a4,-(sp)
    tst.b   info_visible
    beq.w   .si_exit

    ; Wyznacz numer aktualnej sceny (0 = F1 Splash, 1..7 = F2..F8)
    move.l  vbl_tick(pc),d7
    cmp.l   #150,d7
    bhs.s   .si_sc
    bra.w   .si_exit
.si_sc:
    sub.l   #150,d7
    lea     scene_timeline_table,a0
    moveq   #1,d2
.si_tl:
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    addq.l  #4,a0
    cmp.l   d1,d7
    blo.s   .si_chk
    addq.w  #1,d2
    cmp.w   #7,d2
    blo.s   .si_tl

.si_chk:
    lsl.w   #8,d2
    move.b  hud_lang,d2
    cmp.w   hud_last_scene,d2
    beq.s   .si_blit
    move.w  d2,hud_last_scene
    bsr.w   hud_bake_scene_info

.si_blit:
    lea     draw_bpl1(pc),a0
    moveq   #7,d6
.si_bpl:
    move.l  (a0),a1
    addq.l  #8,a0
    ifd FULL_RES
    lea     246*40(a1),a1
    else
    lea     216*40(a1),a1
    endif

    ; Gorny czarny margines 1 px (Y=246)
    moveq   #0,d0
    REPT 10
    move.l  d0,(a1)+
    ENDR

    ; 7 wierszy tekstu (Y=247..253)
    lea     scene_info_bmp,a2
    moveq   #6,d7
.si_y:
    REPT 10
    move.l  (a2)+,(a1)+
    ENDR
    dbf     d7,.si_y

    ; Dolny czarny margines 1 px (Y=254)
    REPT 10
    move.l  d0,(a1)+
    ENDR

    dbf     d6,.si_bpl

.si_exit:
    movem.l (sp)+,d0-d7/a0-a4
    rts

hud_bake_scene_info:
    movem.l d0-d7/a0-a3,-(sp)
    lea     scene_info_bmp,a1
    moveq   #69,d0
.sib_clr:
    clr.l   (a1)+
    dbf     d0,.sib_clr

    move.w  hud_last_scene,d0
    move.b  d0,d1
    lsr.w   #8,d0
    cmp.w   #7,d0
    bls.s   .sib_sc
    moveq   #7,d0
.sib_sc:
    cmp.b   #1,d1
    bne.s   .sib_idx
    addq.w  #8,d0
.sib_idx:
    mulu.w  #52,d0
    lea     scene_info_strings(pc),a0
    adda.l  d0,a0
    lea     hud_ascii_5x7(pc),a2

    moveq   #0,d5                       ; znak 0..51
.sib_ch:
    moveq   #0,d0
    move.b  (a0)+,d0
    sub.w   #32,d0
    bpl.s   .sib_ok
    moveq   #0,d0
.sib_ok:
    lsl.w   #3,d0
    lea     (a2,d0.w),a3

    move.w  d5,d1
    mulu.w  #6,d1
    addq.w  #4,d1                       ; lewy margines 4 px
    move.w  d1,d2
    lsr.w   #3,d2                       ; bajt X (0..39)
    and.w   #7,d1                       ; przesuniecie bitowe

    lea     scene_info_bmp,a1
    moveq   #0,d4                       ; wiersz glifu 0..6
.sib_gy:
    moveq   #0,d0
    move.b  (a3,d4.w),d0
    lsl.w   #8,d0
    lsl.w   #3,d0
    lsr.w   d1,d0
    move.w  d4,d3
    mulu.w  #40,d3
    add.w   d2,d3
    or.b    d0,1(a1,d3.w)
    lsr.w   #8,d0
    or.b    d0,(a1,d3.w)
    addq.w  #1,d4
    cmp.w   #7,d4
    blo.s   .sib_gy

    addq.w  #1,d5
    cmp.w   #52,d5
    blo.s   .sib_ch

    movem.l (sp)+,d0-d7/a0-a3
    rts

    section fastram_bss,bss_p
scene_info_bmp: ds.b 7*40
    section code,code

    even
info_visible:   dc.b 1,0
hud_lang:       dc.b 0,0
hud_last_scene: dc.w -2
scene_info_strings:
    dc.b "F1: TYTUL AGA 256 KOLOROW / DEKOMPRESJA RLE 320X256 "
    dc.b "F2: MORPHING 3D (1008 TRIS) / WODA + CIENIE + Z-BUF "
    dc.b "F3: WAHADLOWIEC 3D / LENS FLARE + SMUGA + LUSTRO UV "
    dc.b "F4: SYSTEM PLANETARNY / CHROM ENV-MAP + ORBITA + UV "
    dc.b "F5: PRZELOT PRZEZ TORUS / KAMERA 6DOF + SPECULAR 3D "
    dc.b "F6: MODEL .OBJ 3D / SATYNOWY CHROM + ODBICIE WODNE  "
    dc.b "F7: TEREN 3D HEIGHTMAP / SWIATLO PUNKTOWE + Z-FOG   "
    dc.b "F8: FINAL 3D & ORBITA / GWIAZDY + AUDIO PAULA .MOD  "
    dc.b "F1: AGA TITLE 256 COLORS / RLE DECOMPRESSION 320X256"
    dc.b "F2: 3D MORPHING (1008 TRIS) / WATER + SHADOWS + ZBUF"
    dc.b "F3: 3D SHUTTLE / LENS FLARE + TRAIL + UV REFLECTION "
    dc.b "F4: PLANETARY SYSTEM / CHROME ENV-MAP + ORBIT + UV  "
    dc.b "F5: TORUS FLYTHROUGH / 6DOF CAMERA + 3D SPECULAR    "
    dc.b "F6: .OBJ 3D MODEL / SATIN CHROME + WATER REFLECTION "
    dc.b "F7: 3D HEIGHTMAP TERRAIN / POINT LIGHT + Z-FOG      "
    dc.b "F8: 3D FINALE & ORBIT / STARFIELD + PAULA .MOD AUDIO"
