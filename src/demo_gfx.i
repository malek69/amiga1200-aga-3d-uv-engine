; [EN/PL] MODULE: demo_gfx.i | AGA Top Logo Blitter Copy & 50FPS Sine-Scroller
draw_aga_overlays:
    movem.l d0-d6/a0-a3,-(sp)
    bsr.w   draw_starfield_3d
    ; 1. Kopiuj gorne logo AGA (320x44 = 440 longwords) na BPL1 i BPL2
    lea     logo_b1,a0
    move.l  draw_bpl1(pc),a1
    move.w  #439,d0
.lg1: move.l (a0)+,(a1)+
    dbf     d0,.lg1
    lea     logo_b2,a0
    move.l  draw_bpl2(pc),a1
    move.w  #439,d0
.lg2: move.l (a0)+,(a1)+
    dbf     d0,.lg2

    ; 2. Sine-Scroller na dole ekranu (Y = 216 + sin)
    move.l  vbl_tick(pc),d6
    add.l   d6,d6                   ; speed 2 px/frame
    move.w  d6,d4
    lsr.w   #4,d4                   ; char index
    and.w   #15,d6                  ; pixel shift 0..15
    lea     scroll_text(pc),a2
    lea     scroll_font,a3
    lea     sin_tab,a0
    moveq   #20,d5                  ; 21 znakow * 16 px = 336 px
    moveq   #0,d3                   ; ekranowy X
.sc_ch:
    move.w  d4,d0
    and.w   #127,d0
    moveq   #0,d1
    move.b  (a2,d0.w),d1
    sub.w   #32,d1
    bpl.s   .c_ok
    moveq   #0,d1
.c_ok: lsl.w #5,d1                  ; * 32 bajty na glif 16x16
    lea     (a3,d1.w),a1
    move.w  d3,d0
    sub.w   d6,d0                   ; x na ekranie
    move.l  vbl_tick(pc),d2
    add.w   d0,d2
    and.w   #$ff,d2
    move.w  (a0,d2.w*2),d2
    asr.w   #4,d2                   ; amplituda +-16 px
    add.w   #224,d2                 ; baza Y = 224
    mulu.w  #40,d2
    move.l  draw_bpl2(pc),a4
    add.l   d2,a4
    moveq   #15,d7
.sc_y:
    moveq   #0,d1
    move.w  (a1)+,d1
    tst.w   d0
    bmi.s   .sh_l
    cmp.w   #304,d0
    bgt.s   .next_y
    move.w  d0,d2
    lsr.w   #3,d2
    and.w   #$fffe,d2
    move.w  d0,d1
    and.w   #15,d1
    moveq   #0,d0
    move.w  -2(a1),d0
    swap    d0
    lsr.l   d1,d0
    or.l    d0,(a4,d2.w)
    move.w  d3,d0
    sub.w   d6,d0
    bra.s   .next_y
.sh_l: neg.w d0
    lsl.w   d0,d1
    or.w    d1,(a4)
    move.w  d3,d0
    sub.w   d6,d0
.next_y: lea 40(a4),a4
    dbf     d7,.sc_y
    add.w   #16,d3
    addq.w  #1,d4
    dbf     d5,.sc_ch
    movem.l (sp)+,d0-d6/a0-a3
    rts
scroll_text: dc.b "   *** AMIGA 1200 / THEA1200 OVERDRIVE V2.0 *** BARE-METAL M68020 REALTIME 3D + PROTRACKER MOD + 24-BIT COPPER *** VIBE CODING: MALEK69 & GEMINI AI (2026) ***   "
    even

draw_starfield_3d:
    movem.l d0-d4/a0-a1,-(sp)
    lea     star_pts(pc),a0
    move.l  draw_bpl1(pc),a1
    moveq   #63,d4
.st_lp:
    move.w  (a0),d0                 ; x
    move.w  2(a0),d1                ; y
    move.w  4(a0),d2                ; z
    subq.w  #4,d2
    cmp.w   #24,d2
    bgt.s   .z_ok
    move.w  #255,d2
.z_ok:
    move.w  d2,4(a0)
    addq.l  #6,a0
    asl.w   #7,d0
    ext.l   d0
    divs.w  d2,d0
    add.w   #160,d0
    bmi.s   .st_nx
    cmp.w   #319,d0
    bgt.s   .st_nx
    asl.w   #7,d1
    ext.l   d1
    divs.w  d2,d1
    add.w   #132,d1
    cmp.w   #46,d1
    blt.s   .st_nx
    cmp.w   #210,d1
    bgt.s   .st_nx
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a1,d1.l)
.st_nx:
    dbf     d4,.st_lp
    movem.l (sp)+,d0-d4/a0-a1
    rts
star_pts:
    dc.w 7,63,113
    dc.w -100,73,197
    dc.w -111,-45,217
    dc.w -21,-85,246
    dc.w 98,20,67
    dc.w -47,61,187
    dc.w -26,20,34
    dc.w -19,44,148
    dc.w 115,-44,32
    dc.w 92,68,81
    dc.w -119,16,201
    dc.w -62,-51,81
    dc.w 20,-33,227
    dc.w -44,1,40
    dc.w 96,-65,245
    dc.w 148,-86,204
    dc.w -86,6,212
    dc.w 95,-33,114
    dc.w -144,88,87
    dc.w 45,-85,138
    dc.w -24,2,100
    dc.w -122,76,181
    dc.w -5,-59,115
    dc.w 5,-17,128
    dc.w 140,12,233
    dc.w -31,53,174
    dc.w 20,-75,159
    dc.w -59,-27,43
    dc.w -49,-22,212
    dc.w 144,-71,113
    dc.w 139,-45,212
    dc.w 143,68,66
    dc.w 122,62,64
    dc.w -99,-32,44
    dc.w 66,-72,250
    dc.w 103,55,231
    dc.w -119,-86,228
    dc.w -71,-47,243
    dc.w 87,-55,51
    dc.w -141,-80,207
    dc.w -106,-86,129
    dc.w -131,-78,172
    dc.w 127,45,35
    dc.w -119,-24,161
    dc.w -70,-46,101
    dc.w 36,51,205
    dc.w 32,-90,142
    dc.w -114,-11,189
    dc.w 115,62,222
    dc.w 4,-10,147
    dc.w -104,67,242
    dc.w -19,23,122
    dc.w -27,-65,141
    dc.w -105,-10,191
    dc.w -104,49,243
    dc.w 60,-95,150
    dc.w 136,-61,95
    dc.w 145,85,38
    dc.w 106,39,250
    dc.w 58,-63,184
    dc.w 146,4,212
    dc.w 136,68,78
    dc.w 139,77,55
    dc.w 22,-88,59
