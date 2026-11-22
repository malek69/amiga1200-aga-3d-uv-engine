; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | Moonlit Two-Tier Waterfall, Lake Boulders & Illuminating 3D Fireflies
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0013,2(a1)            ; COLOR00 (deep midnight sky)
    move.w  #$0124,6(a1)            ; COLOR01 (BPL1 dark cliffs, pines & boulders)
    move.w  #$03cf,10(a1)           ; COLOR02 (BPL2 glowing cyan waterfall & halo)
    move.w  #$0fff,14(a1)           ; COLOR03 (BPL1+BPL2 white foam, moon & bright fireflies)
    move.w  #$0147,18(a1)           ; COLOR04 (Blitter AA twilight edge)

    ; 1. Ksiezic w prawym gornym rogu (poswiata BPL2 + jasna tarcza BPL1+BPL2)
    bsr.w   draw_moon_and_stars

    ; 2. Kinowa kamera: powolne kolysanie na boki (+-16 deg) i lekki pochyl z gory
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d4
    asr.w   #5,d4
    add.w   #14,d4
    and.w   #$ff,d4                 ; ax
    move.w  d7,d0
    lsr.w   #1,d0
    add.w   #64,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d5
    asr.w   #4,d5                   ; ay
    and.w   #$ff,d5

    move.w  (a2,d4.w*2),s_x
    move.w  128(a2,d4.w*2),c_x
    move.w  (a2,d5.w*2),s_y
    move.w  128(a2,d5.w*2),c_y

    ; 3. Rzutowanie wierzcholkow kanionu, choinek, 2-stopniowego wodospadu i jeziora
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

    ; 4. Rysowanie wielokatow sceny
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

    ; 5. Animowane kaskady wody, odbicia na jeziorze i 40 rozswietlajacych swietlikow 3D
    bsr.w   render_water_and_fireflies
    bsr.w   update_aurora_sky
    movem.l (sp)+,d0-d7/a0-a5
    rts

draw_moon_and_stars:
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    lea     moon_spans(pc),a0
    move.w  #14*40,d2               ; Y start = 14
    moveq   #29,d7                  ; 30 linii wysokosci ksiezyca
.mn_lp:
    move.l  (a0)+,d0                ; maska poswiaty BPL2
    move.l  (a0)+,d1                ; maska jasnej tarczy BPL1
    or.l    d0,30(a3,d2.w)          ; X = 240..271
    or.l    d1,30(a2,d2.w)
    add.w   #40,d2
    dbf     d7,.mn_lp
    ; Migoczace gwiazdy na nocnym niebie
    lea     sky_stars(pc),a0
    move.l  vbl_tick(pc),d6
    moveq   #19,d7
.gs_lp:
    move.w  (a0)+,d0
    move.w  (a0)+,d1
    move.w  d7,d2
    add.w   d6,d2
    and.w   #15,d2
    beq.s   .gs_nx
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)
.gs_nx: dbf d7,.gs_lp
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
    move.w  d2,last_z

    muls.w  #300,d0
    muls.w  #300,d1
    add.w   #375,d2
    cmp.w   #160,d2
    bge.s   .z_ok
    move.w  #160,d2
.z_ok:
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #122,d1
    cmp.w   #4,d0
    bge.s   .x_lo
    moveq   #4,d0
.x_lo: cmp.w #315,d0
    ble.s   .x_hi
    move.w  #315,d0
.x_hi: cmp.w #4,d1
    bge.s   .y_lo
    moveq   #4,d1
.y_lo: cmp.w #248,d1
    ble.s   .y_hi
    move.w  #248,d1
.y_hi: rts

render_water_and_fireflies:
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7
    ; A) 40 strug na gornej kaskadzie wodospadu (Y = -75..+5)
    lea     drop_seeds(pc),a4
    moveq   #39,d6
.dr1_lp:
    move.w  (a4)+,d0                ; x (-38..+38)
    move.w  (a4)+,d1                ; start y
    add.w   d7,d1
    add.w   d7,d1
    and.w   #$3f,d1                 ; 0..63
    sub.w   #62,d1                  ; -62..+1
    moveq   #18,d2
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
    bset    d0,80(a3,d1.l)
    dbf     d6,.dr1_lp

    ; B) 24 strugi na dolnej kaskadzie + piana na progu i odbicia na jeziorze
    lea     drop_seeds(pc),a4
    moveq   #23,d6
.dr2_lp:
    move.w  (a4)+,d0
    asl.w   #1,d0                   ; szersza dolna kaskada
    move.w  (a4)+,d1
    add.w   d7,d1
    add.w   d7,d1
    add.w   d7,d1
    and.w   #$1f,d1                 ; 0..31
    addq.w  #6,d1                   ; +6..+37
    moveq   #34,d2
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
    dbf     d6,.dr2_lp

    ; C) 40 swietlikow 3D: gdy przelatuja blisko (Z < 15), rozswietlaja okolice krzyzem i podbijaja zorze!
    clr.w   ff_glow
    lea     firefly_seeds(pc),a4
    lea     sin_tab,a1
    moveq   #39,d6
.ff_lp:
    move.w  (a4)+,d3
    add.w   d7,d3
    and.w   #$ff,d3
    move.w  (a1,d3.w*2),d0
    asr.w   #1,d0                   ; X: -128..+128
    move.w  (a4)+,d3
    move.w  d7,d4
    add.w   d4,d4
    add.w   d4,d3
    and.w   #$ff,d3
    move.w  (a1,d3.w*2),d1
    asr.w   #2,d1                   ; Y: -64..+64
    move.w  (a4)+,d3
    add.w   d7,d3
    add.w   #64,d3
    and.w   #$ff,d3
    move.w  (a1,d3.w*2),d2
    asr.w   #1,d2                   ; Z: -128..+128
    bsr.w   project_point_3d
    move.w  last_z(pc),d4
    cmp.w   #10,d4
    bgt.s   .ff_far
    ; Swietlik blisko kamery -> rozswietlajacy rozblysk 3x3 (bialy rdzen + turkusowa poswiata)!
    addq.w  #1,ff_glow
    move.w  d1,d4
    mulu.w  #40,d4
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d4
    move.w  d0,d5
    not.w   d5
    and.w   #7,d5
    bset    d5,(a2,d4.l)            ; bialy rdzen (BPL1+BPL2)
    bset    d5,(a3,d4.l)
    bset    d5,-40(a3,d4.l)         ; gorna poswiata (BPL2)
    bset    d5,40(a3,d4.l)          ; dolna poswiata (BPL2)
    ; lewy/prawy piksel poswiaty
    subq.w  #1,d0
    move.w  d1,d4
    mulu.w  #40,d4
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d4
    move.w  d0,d5
    not.w   d5
    and.w   #7,d5
    bset    d5,(a3,d4.l)
    addq.w  #2,d0
    move.w  d1,d4
    mulu.w  #40,d4
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d4
    move.w  d0,d5
    not.w   d5
    and.w   #7,d5
    bset    d5,(a3,d4.l)
    bra.s   .ff_nx
.ff_far:
    ; Swietlik w oddali -> delikatne migotanie
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
.ff_nx:
    dbf     d6,.ff_lp
    rts

update_aurora_sky:
    move.l  cop_sky_ptr(pc),a2
    lea     aurora_grad(pc),a0
    move.w  ff_glow(pc),d3
    lsr.w   #3,d3
    cmp.w   #3,d3
    ble.s   .gl_ok
    moveq   #3,d3
.gl_ok: moveq #31,d4
.au_lp:
    move.w  (a0)+,d1
    add.w   d3,d1                   ; rozswietlenie zorzy gdy swietliki przelatuja blisko!
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     20(a2),a2
    dbf     d4,.au_lp
    rts
