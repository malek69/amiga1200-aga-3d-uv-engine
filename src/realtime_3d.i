; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | Scenic 3D Nature Diorama: Dual Waterfall, Pines & Fireflies
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.w  #$0124,d2
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0124,2(a1)            ; COLOR00 (twilight sky)
    move.w  #$0143,6(a1)            ; COLOR01 (BPL1 forest & rocks)
    move.w  #$04df,10(a1)           ; COLOR02 (BPL2 turquoise water)
    move.w  #$0fff,14(a1)           ; COLOR03 (BPL1+BPL2 white foam & fireflies)
    move.w  #$0268,18(a1)           ; COLOR04 (Blitter AA)
    bsr.w   update_copper_sky

    ; Kinowa praca kamery: powolne kolysanie na boki (+-20 deg) i lekki pochyl z gory
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d4
    asr.w   #5,d4
    add.w   #18,d4
    and.w   #$ff,d4                 ; ax: delikatny widok z gory
    move.w  d7,d0
    lsr.w   #1,d0
    add.w   #64,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d5
    asr.w   #4,d5                   ; ay: spokojne kolysanie +-16 jednostek
    and.w   #$ff,d5

    move.w  (a2,d4.w*2),s_x
    move.w  128(a2,d4.w*2),c_x
    move.w  (a2,d5.w*2),s_y
    move.w  128(a2,d5.w*2),c_y

    ; 1. Rzutowanie wierzcholkow dioramy natury 3D
    lea     mesh_nature(pc),a4
    move.w  (a4)+,d7
    lea     proj_verts(pc),a3
.v_loop:
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   project_point_3d
    move.w  d0,(a3)+
    move.w  d1,(a3)+
    dbf     d7,.v_loop

    ; 2. Rysowanie bryly dioramy (skaly, drzewa, kaskady wody, jezioro)
    move.w  (a4)+,d7
    lea     proj_verts(pc),a3
.f_loop:
    move.w  (a4)+,d0
    move.w  (a4)+,d6
    lea     poly_tmp(pc),a1
    move.w  d6,(a1)+
    move.w  d6,d5
    subq.w  #1,d5
.cp_v:
    move.w  (a4)+,d1
    move.l  (a3,d1.w*4),(a1)+
    dbf     d5,.cp_v

    lea     poly_tmp+2(pc),a1
    move.w  4(a1),d1
    sub.w   (a1),d1
    move.w  10(a1),d2
    sub.w   2(a1),d2
    muls.w  d2,d1
    move.w  6(a1),d3
    sub.w   2(a1),d3
    move.w  8(a1),d4
    sub.w   (a1),d4
    muls.w  d4,d3
    sub.l   d3,d1
    ble.s   .skip_f
    lea     poly_tmp(pc),a1
    bsr.w   draw_polygon_mode
.skip_f:
    dbf     d7,.f_loop

    ; 3. Animowane strugi wodospadu + 48 swietlikow 3D
    bsr.w   render_water_and_fireflies
    movem.l (sp)+,d0-d7/a0-a5
    rts

project_point_3d:
    move.w  d1,d3
    muls.w  c_x(pc),d3
    move.w  d2,d4
    muls.w  s_x(pc),d4
    sub.l   d4,d3
    asr.l   #8,d3
    muls.w  s_x(pc),d1
    muls.w  c_x(pc),d2
    add.l   d2,d1
    asr.l   #8,d1
    move.w  d1,d2
    move.w  d3,d1

    move.w  d0,d3
    muls.w  c_y(pc),d3
    move.w  d2,d4
    muls.w  s_y(pc),d4
    add.l   d4,d3
    asr.l   #8,d3
    muls.w  s_y(pc),d0
    muls.w  c_y(pc),d2
    sub.l   d0,d2
    asr.l   #8,d2
    move.w  d3,d0

    muls.w  #310,d0
    muls.w  #310,d1
    add.w   #380,d2
    cmp.w   #160,d2
    bge.s   .z_ok
    move.w  #160,d2
.z_ok:
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #130,d1
    cmp.w   #4,d0
    bge.s   .x_lo
    moveq   #4,d0
.x_lo: cmp.w #315,d0
    ble.s   .x_hi
    move.w  #315,d0
.x_hi: cmp.w #46,d1
    bge.s   .y_lo
    moveq   #46,d1
.y_lo: cmp.w #208,d1
    ble.s   .y_hi
    move.w  #208,d1
.y_hi: rts

render_water_and_fireflies:
    ; A) 32 jasne krople/smugi splywajace po wodospadzie (BPL1+BPL2 = biala piana COLOR03)
    lea     drop_seeds(pc),a4
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7
    moveq   #31,d6
.dr_lp:
    move.w  (a4)+,d0                ; x (-28..+28)
    move.w  (a4)+,d1                ; start y
    add.w   d7,d1
    add.w   d7,d1                   ; predkosc splywania wody
    and.w   #$7f,d1
    sub.w   #82,d1                  ; -82..+45
    moveq   #22,d2                  ; z kaskady
    bsr.w   project_point_3d
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a2,d1.l)
    bset    d0,(a3,d1.l)
    bset    d0,40(a2,d1.l)
    bset    d0,40(a3,d1.l)
    dbf     d6,.dr_lp

    ; B) 48 swietlikow 3D unoszacych sie nad woda i drzewami
    lea     firefly_seeds(pc),a4
    lea     sin_tab,a2
    moveq   #47,d6
.ff_lp:
    move.w  (a4)+,d3
    add.w   d7,d3
    and.w   #$ff,d3
    move.w  (a2,d3.w*2),d0
    asr.w   #1,d0
    move.w  (a4)+,d3
    move.w  d7,d4
    add.w   d4,d4
    add.w   d4,d3
    and.w   #$ff,d3
    move.w  (a2,d3.w*2),d1
    asr.w   #2,d1
    sub.w   #15,d1
    move.w  (a4)+,d3
    add.w   d7,d3
    add.w   #64,d3
    and.w   #$ff,d3
    move.w  (a2,d3.w*2),d2
    asr.w   #2,d2
    add.w   #45,d2
    bsr.w   project_point_3d
    move.w  d6,d3
    add.w   d7,d3
    and.w   #7,d3
    beq.s   .ff_nx
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)
    bset    d0,40(a3,d1.l)
.ff_nx:
    dbf     d6,.ff_lp
    rts
