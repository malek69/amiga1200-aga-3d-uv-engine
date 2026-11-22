; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN/PL] MODULE: realtime_3d.i | Moonlit Two-Tier Waterfall, Swaying Leaves, Water Mist & 3D Fireflies
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0013,2(a1)            ; COLOR00 (midnight sky)
    move.w  #$0153,6(a1)            ; COLOR01 (top zone: deep emerald leaves)
    move.w  #$05ef,10(a1)           ; COLOR02 (glowing cyan waterfall, moon & mist)
    move.w  #$06e5,14(a1)           ; COLOR03 (top zone: sunlit green leaf tips)
    move.w  #$0146,18(a1)           ; COLOR04 (Blitter AA edge)

    ; 1. Ksiezic, gwiazdy oraz zwisajace na wietrze liscie w lewym gornym rogu
    bsr.w   draw_moon_and_leaves

    ; 2. Kinowa kamera: powolne kolysanie na boki (+-15 deg) i lekki pochyl
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d4
    asr.w   #5,d4
    add.w   #14,d4
    and.w   #$ff,d4
    move.w  d7,d0
    lsr.w   #1,d0
    add.w   #64,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d5
    asr.w   #4,d5
    and.w   #$ff,d5

    move.w  (a2,d4.w*2),s_x
    move.w  128(a2,d4.w*2),c_x
    move.w  (a2,d5.w*2),s_y
    move.w  128(a2,d5.w*2),c_y

    ; 3. Rzutowanie wierzcholkow kanionu, choinek, wodospadu, jeziora i glazow
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

    ; 4. Rysowanie wielokatow sceny (skaly, kaskady wody, jezioro, glazy)
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

    ; 5. Animowana woda, odbicia, unoszaca sie mgielka nad woda i 40 swietlikow 3D
    bsr.w   render_water_mist_fireflies
    bsr.w   update_aurora_and_mist_sky
    movem.l (sp)+,d0-d7/a0-a5
    rts

draw_moon_and_leaves:
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    ; A) Ksiezic (jasna tarcza na BPL2, zeby zachowal chlodny blask niezaleznie od zielonych lisci)
    lea     moon_spans(pc),a0
    move.w  #12*40,d2
    moveq   #29,d7
.mn_lp:
    move.l  (a0)+,d0
    move.l  (a0)+,d1
    or.l    d1,30(a3,d2.w)
    add.w   #40,d2
    dbf     d7,.mn_lp

    ; B) Zwisajace liscie w lewym gornym rogu (Y=0..54, X=0..155) kolyszace sie na wietrze
    lea     sin_tab,a1
    move.l  vbl_tick(pc),d6
    and.w   #$ff,d6
    move.w  (a1,d6.w*2),d6
    asr.w   #6,d6                   ; wychylenie wiatru -4..+4 px
    lea     leaf_clusters(pc),a0
    moveq   #35,d7                  ; 36 kepek lisci
.lf_lp:
    move.w  (a0)+,d0                ; baza X
    move.w  (a0)+,d1                ; baza Y
    move.w  (a0)+,d4                ; typ (0=ciemny lisc BPL1, 1=jasny lisc BPL1+BPL2)
    add.w   d6,d0
    bpl.s   .lx_ok
    moveq   #0,d0
.lx_ok:
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    ; Rysuj kepke lisci 3x2 px
    bset    d0,(a2,d1.l)
    bset    d0,40(a2,d1.l)
    tst.w   d4
    beq.s   .lf_s1
    bset    d0,(a3,d1.l)
.lf_s1:
    subq.w  #1,d0
    bpl.s   .lf_s2
    moveq   #7,d0
    addq.l  #1,d1
.lf_s2:
    bset    d0,(a2,d1.l)
    bset    d0,40(a2,d1.l)
    tst.w   d4
    beq.s   .lf_nx
    bset    d0,40(a3,d1.l)
.lf_nx:
    dbf     d7,.lf_lp

    ; C) Gwiazdy na nocnym niebie
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

    muls.w  #305,d0
    muls.w  #305,d1
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
    rts

render_water_mist_fireflies:
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    move.l  vbl_tick(pc),d7

    ; A) 56 gestych strug wody na gornej kaskadzie wodospadu
    lea     drop_seeds(pc),a4
    moveq   #55,d6
.dr1_lp:
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    add.w   d7,d1
    add.w   d7,d1
    and.w   #$3f,d1
    sub.w   #62,d1
    moveq   #18,d2
    bsr.w   project_point_3d
    cmp.w   #2,d0
    blo.w   .dr_sk
    cmp.w   #317,d0
    bhi.w   .dr_sk
    cmp.w   #2,d1
    blo.w   .dr_sk
    cmp.w   #250,d1
    bhi.w   .dr_sk
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
.dr_sk: dbf d6,.dr1_lp

    ; B) 36 strug wody na dolnej kaskadzie + fale na jeziorze
    lea     drop_seeds(pc),a4
    moveq   #35,d6
.dr2_lp:
    move.w  (a4)+,d0
    asl.w   #1,d0
    move.w  (a4)+,d1
    add.w   d7,d1
    add.w   d7,d1
    add.w   d7,d1
    and.w   #$1f,d1
    addq.w  #6,d1
    moveq   #34,d2
    bsr.w   project_point_3d
    cmp.w   #2,d0
    blo.w   .dr_sk
    cmp.w   #317,d0
    bhi.w   .dr_sk
    cmp.w   #2,d1
    blo.w   .dr_sk
    cmp.w   #250,d1
    bhi.w   .dr_sk
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
.dr2_sk: dbf d6,.dr2_lp

    ; C) 48 czasteczek mgielki unoszacej sie znad wody u podnoza obu wodospadow
    lea     mist_seeds(pc),a4
    moveq   #47,d6
.ms_lp:
    move.w  (a4)+,d0                ; x (-85..+85)
    move.w  (a4)+,d1                ; faza unoszenia
    move.w  (a4)+,d2                ; z (30..75)
    add.w   d7,d1
    and.w   #$1f,d1                 ; 0..31
    neg.w   d1
    add.w   #42,d1                  ; unosi sie z Y=+42 do Y=+11
    bsr.w   project_point_3d
    cmp.w   #2,d0
    blo.w   .dr_sk
    cmp.w   #317,d0
    bhi.w   .dr_sk
    cmp.w   #2,d1
    blo.w   .dr_sk
    cmp.w   #250,d1
    bhi.w   .dr_sk
    mulu.w  #40,d1
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d1
    not.w   d0
    and.w   #7,d0
    bset    d0,(a3,d1.l)            ; miekka para wodna (BPL2)
    eor.w   #2,d0
    bset    d0,40(a3,d1.l)
.ms_sk: dbf d6,.ms_lp

    ; D) 40 swietlikow 3D rozswietlajacych okolice gdy przelatuja blisko
    clr.w   ff_glow
    lea     firefly_seeds(pc),a4
    lea     sin_tab,a1
    moveq   #39,d6
.ff_lp:
    move.w  (a4)+,d3
    add.w   d7,d3
    and.w   #$ff,d3
    move.w  (a1,d3.w*2),d0
    asr.w   #1,d0
    move.w  (a4)+,d3
    move.w  d7,d4
    add.w   d4,d4
    add.w   d4,d3
    and.w   #$ff,d3
    move.w  (a1,d3.w*2),d1
    asr.w   #2,d1
    move.w  (a4)+,d3
    add.w   d7,d3
    add.w   #64,d3
    and.w   #$ff,d3
    move.w  (a1,d3.w*2),d2
    asr.w   #1,d2
    bsr.w   project_point_3d
    move.w  last_z(pc),d4
    cmp.w   #12,d4
    bgt.w   .ff_far
    addq.w  #1,ff_glow
    move.w  d1,d4
    mulu.w  #40,d4
    move.w  d0,d3
    lsr.w   #3,d3
    add.w   d3,d4
    move.w  d0,d5
    not.w   d5
    and.w   #7,d5
    bset    d5,(a2,d4.l)
    bset    d5,(a3,d4.l)
    bset    d5,-40(a3,d4.l)
    bset    d5,40(a3,d4.l)
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

update_aurora_and_mist_sky:
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
    add.w   d3,d1
    move.w  d1,6(a2)
    move.w  d1,14(a2)
    lea     20(a2),a2
    dbf     d4,.au_lp
    ; Przelacz palete ponizej zwisajacych lisci (pas 7 = Y 56) na ciemne skaly i biala piane!
    move.l  cop_sky_ptr(pc),a2
    lea     7*20(a2),a2
    move.w  #$0182,4(a2)
    move.w  #$0124,6(a2)
    move.w  #$0186,12(a2)
    move.w  #$0fff,14(a2)
    rts
    even
s_x: dc.w 0
c_x: dc.w 0
s_y: dc.w 0
c_y: dc.w 0
last_z: dc.w 0
ff_glow: dc.w 0
proj_verts: ds.l 48
poly_tmp: ds.w 20
moon_spans:
    dc.l $00000000,$00000000
    dc.l $000ff000,$00000000
    dc.l $003ffc00,$00000000
    dc.l $00ffff00,$00000000
    dc.l $01ffff80,$00000000
    dc.l $03ffffc0,$000fc000
    dc.l $07ffffe0,$003fc000
    dc.l $0ffffff0,$007fc000
    dc.l $0ffffff0,$00ffc000
    dc.l $1ffffff8,$01ffe000
    dc.l $1ffffff8,$01fff800
    dc.l $3ffffffc,$03fff800
    dc.l $3ffffffc,$03fffc00
    dc.l $3ffffffc,$03fffc00
    dc.l $3ffffffc,$03ffffc0
    dc.l $3ffffffc,$03ffffc0
    dc.l $3ffffffc,$03ffffc0
    dc.l $3ffffffc,$03ffffc0
    dc.l $3ffffffc,$03ffffc0
    dc.l $1ffffff8,$01ffff80
    dc.l $1ffffff8,$01ffff80
    dc.l $0ffffff0,$00ffff00
    dc.l $0ffffff0,$007ffe00
    dc.l $07ffffe0,$003ffc00
    dc.l $03ffffc0,$000ff000
    dc.l $01ffff80,$00000000
    dc.l $00ffff00,$00000000
    dc.l $003ffc00,$00000000
    dc.l $000ff000,$00000000
    dc.l $00000000,$00000000
aurora_grad:
    dc.w $0013,$0014,$0015,$0026,$0027,$0038,$0149,$015a,$016a,$0159,$0148,$0147,$0036,$0036,$0148,$0159,$0147,$0036,$0025,$0147,$0159,$026a,$0159,$0147,$0036,$0025,$0024,$0014,$0013,$0013,$0012,$0012
leaf_clusters:
    dc.w 81,26,0
    dc.w 72,28,1
    dc.w 59,15,1
    dc.w 30,30,1
    dc.w 57,8,0
    dc.w 28,33,0
    dc.w 56,9,0
    dc.w 117,7,1
    dc.w 13,22,0
    dc.w 62,23,0
    dc.w 30,9,0
    dc.w 105,10,0
    dc.w 28,40,1
    dc.w 52,16,1
    dc.w 94,7,0
    dc.w 61,28,0
    dc.w 17,9,1
    dc.w 108,16,1
    dc.w 67,11,1
    dc.w 77,15,1
    dc.w 141,14,0
    dc.w 103,18,0
    dc.w 81,19,1
    dc.w 49,12,0
    dc.w 41,26,0
    dc.w 29,5,1
    dc.w 63,16,0
    dc.w 116,10,1
    dc.w 83,27,1
    dc.w 19,7,1
    dc.w 44,25,0
    dc.w 50,28,1
    dc.w 6,5,0
    dc.w 93,10,0
    dc.w 131,5,1
    dc.w 18,27,0
sky_stars:
    dc.w 198,26
    dc.w 265,26
    dc.w 290,11
    dc.w 171,58
    dc.w 199,16
    dc.w 169,10
    dc.w 247,41
    dc.w 194,58
    dc.w 279,60
    dc.w 280,16
    dc.w 194,28
    dc.w 217,61
    dc.w 223,48
    dc.w 280,52
    dc.w 267,48
    dc.w 232,66
    dc.w 266,8
    dc.w 303,67
    dc.w 193,56
    dc.w 178,16
mesh_nature:
    dc.w 37
    dc.w -145,-75,10, -40,-62,15, -45,5,25, -145,15,25
    dc.w 40,-62,15, 145,-80,10, 145,15,25, 45,5,25
    dc.w -38,-62,18, 38,-62,18, 46,5,26, -46,5,26
    dc.w -145,5,25, -52,5,28, -58,42,38, -145,42,38
    dc.w 52,5,28, 145,5,25, 145,42,38, 58,42,38
    dc.w -50,5,30, 50,5,30, 62,42,40, -62,42,40
    dc.w -155,42,38, 155,42,38, 145,52,145, -145,52,145
    dc.w -105,-72,12, -80,-70,12, -92,-115,12, 92,-118,12
    dc.w -125,48,110, -55,48,115, -90,34,112
    dc.w 60,48,120, 130,48,115, 95,36,118
    dc.w 13
    dc.w 0,4, 0,1,2,3
    dc.w 0,4, 4,5,6,7
    dc.w 0,4, 12,13,14,15
    dc.w 0,4, 16,17,18,19
    dc.w 0,3, 28,29,30
    dc.w 0,3, 4,5,31
    dc.w 2,4, 8,9,10,11
    dc.w 2,4, 9,8,11,10
    dc.w 2,4, 20,21,22,23
    dc.w 2,4, 21,20,23,22
    dc.w 2,4, 24,25,26,27
    dc.w 2,4, 25,24,27,26
    dc.w 0,3, 32,33,34
    dc.w 0,3, 35,36,37
drop_seeds:
    dc.w 0,40
    dc.w 38,3
    dc.w -30,17
    dc.w 17,40
    dc.w 32,17
    dc.w -20,61
    dc.w -22,21
    dc.w -25,0
    dc.w 7,51
    dc.w 26,6
    dc.w 29,22
    dc.w -30,27
    dc.w -25,15
    dc.w 8,19
    dc.w -37,42
    dc.w -21,50
    dc.w 7,9
    dc.w 29,33
    dc.w 30,38
    dc.w -23,52
    dc.w -37,8
    dc.w -32,8
    dc.w -37,4
    dc.w 14,6
    dc.w 5,52
    dc.w -6,51
    dc.w -8,31
    dc.w 2,37
    dc.w -30,52
    dc.w -25,32
    dc.w -10,49
    dc.w -38,17
    dc.w 11,26
    dc.w 29,40
    dc.w -30,13
    dc.w 1,32
    dc.w 34,15
    dc.w 8,54
    dc.w 3,55
    dc.w -21,57
    dc.w -9,32
    dc.w -16,56
    dc.w 27,4
    dc.w 9,27
    dc.w -31,30
    dc.w -30,14
    dc.w 14,4
    dc.w 24,17
    dc.w 20,58
    dc.w 5,1
    dc.w -12,44
    dc.w -3,12
    dc.w -21,27
    dc.w 21,28
    dc.w 36,33
    dc.w 23,8
mist_seeds:
    dc.w -49,0,70
    dc.w -67,5,58
    dc.w -80,3,42
    dc.w 75,6,46
    dc.w 22,3,59
    dc.w 83,4,36
    dc.w -57,4,30
    dc.w -19,2,62
    dc.w 8,7,53
    dc.w 25,6,48
    dc.w -60,4,30
    dc.w 20,27,35
    dc.w 72,17,44
    dc.w -27,13,64
    dc.w 78,11,67
    dc.w -72,20,53
    dc.w -73,5,51
    dc.w 0,30,53
    dc.w 2,20,30
    dc.w -2,6,75
    dc.w -22,20,42
    dc.w 22,6,50
    dc.w -68,8,64
    dc.w 45,20,63
    dc.w -25,4,64
    dc.w 61,5,70
    dc.w 15,18,71
    dc.w -84,19,67
    dc.w 85,17,37
    dc.w 77,14,58
    dc.w -2,30,42
    dc.w -32,21,59
    dc.w 67,7,56
    dc.w 32,30,54
    dc.w 26,1,32
    dc.w -85,20,69
    dc.w 64,11,30
    dc.w 38,3,48
    dc.w 31,18,73
    dc.w -42,29,50
    dc.w 59,0,50
    dc.w 61,26,59
    dc.w 6,22,43
    dc.w -36,7,46
    dc.w -66,29,75
    dc.w 5,10,61
    dc.w -73,10,33
    dc.w -27,19,72
firefly_seeds:
    dc.w 150,42,144
    dc.w 104,83,99
    dc.w 202,250,95
    dc.w 147,210,53
    dc.w 158,149,59
    dc.w 154,49,144
    dc.w 189,39,168
    dc.w 207,12,145
    dc.w 111,250,215
    dc.w 75,242,56
    dc.w 22,113,0
    dc.w 16,4,175
    dc.w 221,250,197
    dc.w 57,61,112
    dc.w 218,196,190
    dc.w 213,129,186
    dc.w 170,45,29
    dc.w 152,18,221
    dc.w 188,149,247
    dc.w 23,217,42
    dc.w 113,118,198
    dc.w 71,130,167
    dc.w 188,134,194
    dc.w 3,147,132
    dc.w 96,153,143
    dc.w 43,230,163
    dc.w 11,16,94
    dc.w 55,163,187
    dc.w 45,254,27
    dc.w 48,70,147
    dc.w 99,147,66
    dc.w 151,251,178
    dc.w 149,60,20
    dc.w 84,125,173
    dc.w 58,204,59
    dc.w 157,23,229
    dc.w 56,168,38
    dc.w 76,26,147
    dc.w 30,130,135
    dc.w 154,216,87
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
