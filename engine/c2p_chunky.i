    include "fast_clear.i"


    ifd FULL_RES
; ============================================================================
; c2p_160x128_to_aga (v1.14.5 - Superskalarny potok MC68060 pOEP/sOEP, 320x256)
; ============================================================================
c2p_160x128_to_aga:
    movem.l d0-d7/a0-a6,-(sp)
    lea     c2p_exp(pc),a5
    move.l  #$0f0f0f0f,a6               ; stala maska w rejestrze adresowym (zero hazardow)

    ; PRZEBIEG 1: Low nibbles (bity 0..3) -> BPL1..BPL4
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    move.w  #255,d7
    CNOP 0,16
    CNOP 0,16
.p1_row_060:
    moveq   #9,d6                       ; 10 blokow po 32 piksele = 320 px
.p1_col_060:
    moveq   #0,d2
    move.l  a6,d0

    ; --- Bajt 0 (px 0..7) -> d1 ---
    and.l   (a0)+,d0                    ; pOEP: fetch + maska 4 pikseli
    move.b  d0,d2                       ; sOEP: indeks px0
    move.l  (a5,d2.w*4),d1              ; px0 -> bity 0
    lsr.w   #8,d0                       ; px1 w dolnym bajcie
    lsl.l   #4,d1                       ; px0 -> bity 4
    move.l  (a5,d0.w*4),d2              ; px1
    swap    d0                          ; px2/px3 do dolnego slowa
    lsl.l   #5,d2                       ; px1 -> bity 5
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2                       ; px2
    lsr.w   #8,d0                       ; px3
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0                       ; przeladuj maske do nastepnych 4 px
    lsl.l   #7,d2
    or.l    d2,d1

    and.l   (a0)+,d0                    ; px 4..7
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d1              ; px4 -> bity 0
    move.l  (a5,d0.w*4),d2              ; px5
    swap    d0
    lsl.l   #1,d2                       ; px5 -> bity 1
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2                       ; px6
    lsr.w   #8,d0                       ; px7
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #3,d2
    or.l    d2,d1

    ; --- Bajt 1 (px 8..15) -> d3 ---
    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d3
    lsr.w   #8,d0
    lsl.l   #4,d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #7,d2
    or.l    d2,d3

    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #3,d2
    or.l    d2,d3

    ; --- Bajt 2 (px 16..23) -> d4 ---
    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d4
    lsr.w   #8,d0
    lsl.l   #4,d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #7,d2
    or.l    d2,d4

    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #3,d2
    or.l    d2,d4

    ; --- Bajt 3 (px 24..31) -> d5 ---
    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d5
    lsr.w   #8,d0
    lsl.l   #4,d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #7,d2
    or.l    d2,d5

    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d5

    ; Zapis 32-bitowy do BPL4..BPL1 z parowaniem ALU
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.p1_col_060
    dbf     d7,.p1_row_060

    ; PRZEBIEG 2: High nibbles (bity 4..7) -> BPL5..BPL8
    lea     chunky_buf,a0
    move.l  draw_bpl5(pc),a1
    move.l  draw_bpl6(pc),a2
    move.l  draw_bpl7(pc),a3
    move.l  draw_bpl8(pc),a4
    move.w  #255,d7
    CNOP 0,16
    CNOP 0,16
.p2_row_060:
    moveq   #9,d6
.p2_col_060:
    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d1
    lsr.w   #8,d0
    lsl.l   #4,d1
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d1
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d3
    lsr.w   #8,d0
    lsl.l   #4,d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d4
    lsr.w   #8,d0
    lsl.l   #4,d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d5
    lsr.w   #8,d0
    lsl.l   #4,d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d5

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d5

    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.p2_col_060
    dbf     d7,.p2_row_060

    movem.l (sp)+,d0-d7/a0-a6
    rts
    else
    ifd FULL_RES
; ============================================================================
; c2p_160x128_to_aga (FULL_RES 320x256 - 2px LUT c2p_exp256 + 32-bit Chip RAM)
; ============================================================================
c2p_160x128_to_aga:
    movem.l d0-d7/a0-a6,-(sp)
    lea     c2p_exp(pc),a5

    ; PRZEBIEG 1: Low nibbles -> BPL1..BPL4
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    move.w  #255,d7
    else
    move.w  #127,d7
    endif
    CNOP 0,4
    CNOP 0,4
.p1_row:
    moveq   #9,d6                   ; 10 blokow po 32 piksele = 320 px
.p1_col:
    ; Bajt 0 (piksele 0..7) -> d1
    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d1
    lsl.l   #4,d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d3
    lsl.l   #4,d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d4
    lsl.l   #4,d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d5
    lsl.l   #4,d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5

    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.fr1_col
    dbf     d7,.fr1_row

    ; PRZEBIEG 2: High nibbles -> BPL5..BPL8
    lea     chunky_buf,a0
    move.l  draw_bpl5(pc),a1
    move.l  draw_bpl6(pc),a2
    move.l  draw_bpl7(pc),a3
    move.l  draw_bpl8(pc),a4
    move.w  #255,d7
    else
    move.w  #127,d7
    endif
    CNOP 0,4
    CNOP 0,4
.p2_row:
    moveq   #9,d6
.fr2_col:
    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d1
    lsl.l   #4,d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d3
    lsl.l   #4,d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d4
    lsl.l   #4,d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d5
    lsl.l   #4,d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5

    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.fr2_col
    dbf     d7,.fr2_row

    movem.l (sp)+,d0-d7/a0-a6
    rts
    else
; ============================================================================
; c2p_160x128_to_aga (Single-Pass 2x1 Pixel-Doubled 8-Bitplane 256-Color C2P)
; ============================================================================
c2p_160x128_to_aga:
    movem.l d0-d7/a0-a6,-(sp)
    lea     c2p_2px_8bpl_lut(pc),a5
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    move.l  draw_bpl5(pc),d4
    move.l  draw_bpl6(pc),d5
    move.l  draw_bpl7(pc),d6
    move.l  draw_bpl8(pc),a6

    endif
draw_uv_tri:
    ; Trojkat 3D z prawdziwa tekstura UV 64x64: a4 -> 3x(sx,sy,u,v), d6=tex_id (0..3), d7=light (0..7)
    movem.l d0-d7/a0-a6,-(sp)
    move.w  d6,uv_tex
    move.w  d7,uv_shade
    move.w  (a4)+,uv_x0
    move.w  (a4)+,uv_y0
    move.w  (a4)+,uv_u0
    move.w  (a4)+,uv_v0
    move.w  (a4)+,uv_x1
    move.w  (a4)+,uv_y1
    move.w  (a4)+,uv_u1
    move.w  (a4)+,uv_v1
    move.w  (a4)+,uv_x2
    move.w  (a4)+,uv_y2
    move.w  (a4)+,uv_u2
    move.w  (a4)+,uv_v2
    ; Wyznacz ymin..ymax w 0..127
    move.w  uv_y0(pc),d6
    move.w  uv_y1(pc),d1
    move.w  uv_y2(pc),d2
    cmp.w   d1,d6
    ble.s   .y1
    move.w  d1,d6
.y1: cmp.w d2,d6
    ble.s   .y2
    move.w  d2,d6
.y2: move.w uv_y0(pc),d7
    cmp.w   d1,d7
    bge.s   .y3
    move.w  d1,d7
.y3: cmp.w d2,d7
    bge.s   .y4
    move.w  d2,d7
.y4: tst.w d6
    bpl.s   .c1
    moveq   #0,d6
    ifd FULL_RES
.c1: cmp.w #255,d7
    ble.s   .c2
    move.w  #255,d7
    else
.c1: cmp.w #127,d7
    ble.s   .c2
    move.w  #127,d7
    endif
.c2: cmp.w d6,d7
    ble.w   .uv_ex
    move.w  d6,uv_ymin
    move.w  d7,uv_ymax
    lea     uv_edges(pc),a0
    move.w  d6,d0
    mulu.w  #12,d0
    add.w   d0,a0
    move.w  d7,d1
    sub.w   d6,d1
.in_e: move.w #32000,(a0)
    move.w  #-32000,2(a0)
    lea     12(a0),a0
    dbf     d1,.in_e
    lea     uv_x0(pc),a1
    lea     uv_x1(pc),a2
    bsr.w   scan_uv_edge
    lea     uv_x1(pc),a1
    lea     uv_x2(pc),a2
    bsr.w   scan_uv_edge
    lea     uv_x2(pc),a1
    lea     uv_x0(pc),a2
    bsr.w   scan_uv_edge
    ; Rasteryzacja poziomych linii z interpolacja (U, V) i tablica cieniowania!
    lea     uv_tex_bank,a3
    move.w  uv_tex(pc),d0
    lsl.w   #8,d0
    lsl.w   #4,d0                   ; 4096 bajtow na teksture 64x64
    add.w   d0,a3
    lea     shade_lut(pc),a4
    add.w   uv_shade(pc),a4
    move.w  uv_ymin(pc),d6
    move.w  uv_ymax(pc),d7
    lea     uv_edges(pc),a1
    move.w  d6,d0
    mulu.w  #12,d0
    add.w   d0,a1
    lea     chunky_buf,a2
    move.w  d6,d0
    mulu.w  #320,d0
    add.l   d0,a2
.ry_lp: move.w (a1),d0             ; xl
    move.w  2(a1),d1                ; xr
    cmp.w   d0,d1
    ble.w   .ry_nx
    move.w  d1,d4
    sub.w   d0,d4                   ; span_w = xr - xl
    ext.l   d4
    move.w  6(a1),d2
    sub.w   4(a1),d2
    ext.l   d2
    divs.l  d4,d2                   ; 32-bit du (zero overflow!)
    move.w  10(a1),d3
    sub.w   8(a1),d3
    ext.l   d3
    divs.l  d4,d3                   ; 32-bit dv (zero overflow!)
    move.w  4(a1),d4                ; cur_u (8.8)
    move.w  8(a1),d5                ; cur_v (8.8)
    tst.w   d0
    bpl.s   .xl_ok
.cl_l: add.w d2,d4
    add.w   d3,d5
    addq.w  #1,d0
    bmi.s   .cl_l
.xl_ok: cmp.w #319,d1
    ble.s   .xr_ok
    move.w  #319,d1
.xr_ok: sub.w d0,d1
    bmi.s   .ry_nx
    lea     (a2,d0.w),a0
.px_lp: move.w d5,d0
    lsr.w   #2,d0
    and.w   #$0fc0,d0               ; (V >> 8) * 64 (bity 6..11)
    move.w  d4,d3
    lsr.w   #8,d3
    and.w   #$003f,d3               ; (U >> 8) & 63 (bity 0..5 - zero kolizji!)
    or.w    d3,d0
    move.b  (a3,d0.w),d0
    add.b   uv_shade+1(pc),d0
    move.b  d0,(a0)+
    add.w   d2,d4
    add.w   d3,d5
    dbf     d1,.px_lp
.ry_nx: lea 12(a1),a1
    lea     320(a2),a2
    addq.w  #1,d6
    cmp.w   d7,d6
    ble.w   .ry_lp
.uv_ex: movem.l (sp)+,d0-d7/a0-a6
    rts
    endif
    endif
c2p_2px_8bpl_lut:
    dc.l $00000000,$00000000
    dc.l $00000000,$000000c0
    dc.l $00000000,$0000c000
    dc.l $00000000,$0000c0c0
    dc.l $00000000,$00c00000
    dc.l $00000000,$00c000c0
    dc.l $00000000,$00c0c000
    dc.l $00000000,$00c0c0c0
    dc.l $00000000,$c0000000
    dc.l $00000000,$c00000c0
    dc.l $00000000,$c000c000
    dc.l $00000000,$c000c0c0
    dc.l $00000000,$c0c00000
    dc.l $00000000,$c0c000c0
    dc.l $00000000,$c0c0c000
    dc.l $00000000,$c0c0c0c0
    dc.l $000000c0,$00000000
    dc.l $000000c0,$000000c0
    dc.l $000000c0,$0000c000
    dc.l $000000c0,$0000c0c0
    dc.l $000000c0,$00c00000
    dc.l $000000c0,$00c000c0
    dc.l $000000c0,$00c0c000
    dc.l $000000c0,$00c0c0c0
    dc.l $000000c0,$c0000000
    dc.l $000000c0,$c00000c0
    dc.l $000000c0,$c000c000
    dc.l $000000c0,$c000c0c0
    dc.l $000000c0,$c0c00000
    dc.l $000000c0,$c0c000c0
    dc.l $000000c0,$c0c0c000
    dc.l $000000c0,$c0c0c0c0
    dc.l $0000c000,$00000000
    dc.l $0000c000,$000000c0
    dc.l $0000c000,$0000c000
    dc.l $0000c000,$0000c0c0
    dc.l $0000c000,$00c00000
    dc.l $0000c000,$00c000c0
    dc.l $0000c000,$00c0c000
    dc.l $0000c000,$00c0c0c0
    dc.l $0000c000,$c0000000
    dc.l $0000c000,$c00000c0
    dc.l $0000c000,$c000c000
    dc.l $0000c000,$c000c0c0
    dc.l $0000c000,$c0c00000
    dc.l $0000c000,$c0c000c0
    dc.l $0000c000,$c0c0c000
    dc.l $0000c000,$c0c0c0c0
    dc.l $0000c0c0,$00000000
    dc.l $0000c0c0,$000000c0
    dc.l $0000c0c0,$0000c000
    dc.l $0000c0c0,$0000c0c0
    dc.l $0000c0c0,$00c00000
    dc.l $0000c0c0,$00c000c0
    dc.l $0000c0c0,$00c0c000
    dc.l $0000c0c0,$00c0c0c0
    dc.l $0000c0c0,$c0000000
    dc.l $0000c0c0,$c00000c0
    dc.l $0000c0c0,$c000c000
    dc.l $0000c0c0,$c000c0c0
    dc.l $0000c0c0,$c0c00000
    dc.l $0000c0c0,$c0c000c0
    dc.l $0000c0c0,$c0c0c000
    dc.l $0000c0c0,$c0c0c0c0
    dc.l $00c00000,$00000000
    dc.l $00c00000,$000000c0
    dc.l $00c00000,$0000c000
    dc.l $00c00000,$0000c0c0
    dc.l $00c00000,$00c00000
    dc.l $00c00000,$00c000c0
    dc.l $00c00000,$00c0c000
    dc.l $00c00000,$00c0c0c0
    dc.l $00c00000,$c0000000
    dc.l $00c00000,$c00000c0
    dc.l $00c00000,$c000c000
    dc.l $00c00000,$c000c0c0
    dc.l $00c00000,$c0c00000
    dc.l $00c00000,$c0c000c0
    dc.l $00c00000,$c0c0c000
    dc.l $00c00000,$c0c0c0c0
    dc.l $00c000c0,$00000000
    dc.l $00c000c0,$000000c0
    dc.l $00c000c0,$0000c000
    dc.l $00c000c0,$0000c0c0
    dc.l $00c000c0,$00c00000
    dc.l $00c000c0,$00c000c0
    dc.l $00c000c0,$00c0c000
    dc.l $00c000c0,$00c0c0c0
    dc.l $00c000c0,$c0000000
    dc.l $00c000c0,$c00000c0
    dc.l $00c000c0,$c000c000
    dc.l $00c000c0,$c000c0c0
    dc.l $00c000c0,$c0c00000
    dc.l $00c000c0,$c0c000c0
    dc.l $00c000c0,$c0c0c000
    dc.l $00c000c0,$c0c0c0c0
    dc.l $00c0c000,$00000000
    dc.l $00c0c000,$000000c0
    dc.l $00c0c000,$0000c000
    dc.l $00c0c000,$0000c0c0
    dc.l $00c0c000,$00c00000
    dc.l $00c0c000,$00c000c0
    dc.l $00c0c000,$00c0c000
    dc.l $00c0c000,$00c0c0c0
    dc.l $00c0c000,$c0000000
    dc.l $00c0c000,$c00000c0
    dc.l $00c0c000,$c000c000
    dc.l $00c0c000,$c000c0c0
    dc.l $00c0c000,$c0c00000
    dc.l $00c0c000,$c0c000c0
    dc.l $00c0c000,$c0c0c000
    dc.l $00c0c000,$c0c0c0c0
    dc.l $00c0c0c0,$00000000
    dc.l $00c0c0c0,$000000c0
    dc.l $00c0c0c0,$0000c000
    dc.l $00c0c0c0,$0000c0c0
    dc.l $00c0c0c0,$00c00000
    dc.l $00c0c0c0,$00c000c0
    dc.l $00c0c0c0,$00c0c000
    dc.l $00c0c0c0,$00c0c0c0
    dc.l $00c0c0c0,$c0000000
    dc.l $00c0c0c0,$c00000c0
    dc.l $00c0c0c0,$c000c000
    dc.l $00c0c0c0,$c000c0c0
    dc.l $00c0c0c0,$c0c00000
    dc.l $00c0c0c0,$c0c000c0
    dc.l $00c0c0c0,$c0c0c000
    dc.l $00c0c0c0,$c0c0c0c0
    dc.l $c0000000,$00000000
    dc.l $c0000000,$000000c0
    dc.l $c0000000,$0000c000
    dc.l $c0000000,$0000c0c0
    dc.l $c0000000,$00c00000
    dc.l $c0000000,$00c000c0
    dc.l $c0000000,$00c0c000
    dc.l $c0000000,$00c0c0c0
    dc.l $c0000000,$c0000000
    dc.l $c0000000,$c00000c0
    dc.l $c0000000,$c000c000
    dc.l $c0000000,$c000c0c0
    dc.l $c0000000,$c0c00000
    dc.l $c0000000,$c0c000c0
    dc.l $c0000000,$c0c0c000
    dc.l $c0000000,$c0c0c0c0
    dc.l $c00000c0,$00000000
    dc.l $c00000c0,$000000c0
    dc.l $c00000c0,$0000c000
    dc.l $c00000c0,$0000c0c0
    dc.l $c00000c0,$00c00000
    dc.l $c00000c0,$00c000c0
    dc.l $c00000c0,$00c0c000
    dc.l $c00000c0,$00c0c0c0
    dc.l $c00000c0,$c0000000
    dc.l $c00000c0,$c00000c0
    dc.l $c00000c0,$c000c000
    dc.l $c00000c0,$c000c0c0
    dc.l $c00000c0,$c0c00000
    dc.l $c00000c0,$c0c000c0
    dc.l $c00000c0,$c0c0c000
    dc.l $c00000c0,$c0c0c0c0
    dc.l $c000c000,$00000000
    dc.l $c000c000,$000000c0
    dc.l $c000c000,$0000c000
    dc.l $c000c000,$0000c0c0
    dc.l $c000c000,$00c00000
    dc.l $c000c000,$00c000c0
    dc.l $c000c000,$00c0c000
    dc.l $c000c000,$00c0c0c0
    dc.l $c000c000,$c0000000
    dc.l $c000c000,$c00000c0
    dc.l $c000c000,$c000c000
    dc.l $c000c000,$c000c0c0
    dc.l $c000c000,$c0c00000
    dc.l $c000c000,$c0c000c0
    dc.l $c000c000,$c0c0c000
    dc.l $c000c000,$c0c0c0c0
    dc.l $c000c0c0,$00000000
    dc.l $c000c0c0,$000000c0
    dc.l $c000c0c0,$0000c000
    dc.l $c000c0c0,$0000c0c0
    dc.l $c000c0c0,$00c00000
    dc.l $c000c0c0,$00c000c0
    dc.l $c000c0c0,$00c0c000
    dc.l $c000c0c0,$00c0c0c0
    dc.l $c000c0c0,$c0000000
    dc.l $c000c0c0,$c00000c0
    dc.l $c000c0c0,$c000c000
    dc.l $c000c0c0,$c000c0c0
    dc.l $c000c0c0,$c0c00000
    dc.l $c000c0c0,$c0c000c0
    dc.l $c000c0c0,$c0c0c000
    dc.l $c000c0c0,$c0c0c0c0
    dc.l $c0c00000,$00000000
    dc.l $c0c00000,$000000c0
    dc.l $c0c00000,$0000c000
    dc.l $c0c00000,$0000c0c0
    dc.l $c0c00000,$00c00000
    dc.l $c0c00000,$00c000c0
    dc.l $c0c00000,$00c0c000
    dc.l $c0c00000,$00c0c0c0
    dc.l $c0c00000,$c0000000
    dc.l $c0c00000,$c00000c0
    dc.l $c0c00000,$c000c000
    dc.l $c0c00000,$c000c0c0
    dc.l $c0c00000,$c0c00000
    dc.l $c0c00000,$c0c000c0
    dc.l $c0c00000,$c0c0c000
    dc.l $c0c00000,$c0c0c0c0
    dc.l $c0c000c0,$00000000
    dc.l $c0c000c0,$000000c0
    dc.l $c0c000c0,$0000c000
    dc.l $c0c000c0,$0000c0c0
    dc.l $c0c000c0,$00c00000
    dc.l $c0c000c0,$00c000c0
    dc.l $c0c000c0,$00c0c000
    dc.l $c0c000c0,$00c0c0c0
    dc.l $c0c000c0,$c0000000
    dc.l $c0c000c0,$c00000c0
    dc.l $c0c000c0,$c000c000
    dc.l $c0c000c0,$c000c0c0
    dc.l $c0c000c0,$c0c00000
    dc.l $c0c000c0,$c0c000c0
    dc.l $c0c000c0,$c0c0c000
    dc.l $c0c000c0,$c0c0c0c0
    dc.l $c0c0c000,$00000000
    dc.l $c0c0c000,$000000c0
    dc.l $c0c0c000,$0000c000
    dc.l $c0c0c000,$0000c0c0
    dc.l $c0c0c000,$00c00000
    dc.l $c0c0c000,$00c000c0
    dc.l $c0c0c000,$00c0c000
    dc.l $c0c0c000,$00c0c0c0
    dc.l $c0c0c000,$c0000000
    dc.l $c0c0c000,$c00000c0
    dc.l $c0c0c000,$c000c000
    dc.l $c0c0c000,$c000c0c0
    dc.l $c0c0c000,$c0c00000
    dc.l $c0c0c000,$c0c000c0
    dc.l $c0c0c000,$c0c0c000
    dc.l $c0c0c000,$c0c0c0c0
    dc.l $c0c0c0c0,$00000000
    dc.l $c0c0c0c0,$000000c0
    dc.l $c0c0c0c0,$0000c000
    dc.l $c0c0c0c0,$0000c0c0
    dc.l $c0c0c0c0,$00c00000
    dc.l $c0c0c0c0,$00c000c0
    dc.l $c0c0c0c0,$00c0c000
    dc.l $c0c0c0c0,$00c0c0c0
    dc.l $c0c0c0c0,$c0000000
    dc.l $c0c0c0c0,$c00000c0
    dc.l $c0c0c0c0,$c000c000
    dc.l $c0c0c0c0,$c000c0c0
    dc.l $c0c0c0c0,$c0c00000
    dc.l $c0c0c0c0,$c0c000c0
    dc.l $c0c0c0c0,$c0c0c000
    dc.l $c0c0c0c0,$c0c0c0c0
draw_uv_tri:
    rts
uv_ymin:  dc.w 0
uv_ymax:  dc.w 0
uv_tmp:   dc.w 0
uv_x0:    dc.w 0
uv_y0:    dc.w 0
uv_u0:    dc.w 0
uv_v0:    dc.w 0
uv_x1:    dc.w 0
uv_y1:    dc.w 0
uv_u1:    dc.w 0
uv_v1:    dc.w 0
uv_x2:    dc.w 0
uv_y2:    dc.w 0
uv_u2:    dc.w 0
uv_v2:    dc.w 0
    ifd FULL_RES
uv_edges: ds.b 256*12
    else
uv_edges: ds.b 128*12
    endif
    CNOP 0,16
c2p_exp:
    dc.l $00000000,$01000000,$00010000,$01010000
    dc.l $00000100,$01000100,$00010100,$01010100
    dc.l $00000001,$01000001,$00010001,$01010001
    dc.l $00000101,$01000101,$00010101,$01010101
shade_lut:
    dc.b 1,1,1,2,2,2,3,3, 4,4,4,4,5,5,5,6
    dc.b 1,1,2,2,2,3,3,3, 4,4,5,5,5,6,6,6
    dc.b 1,2,2,3,3,3,10,11, 4,5,5,6,6,6,15,15
    dc.b 8,8,8,9,9,9,9,9, 4,5,5,6,6,15,15,15
    dc.b 2,3,3,10,10,11,11,11, 5,5,6,6,15,15,15,15
    dc.b 10,10,10,11,11,11,11,11, 5,6,6,15,15,15,15,15
    dc.b 4,4,5,5,6,6,15,15, 5,6,6,15,15,15,15,15
    dc.b 12,12,12,13,13,13,14,14, 6,6,15,15,15,15,15,15

