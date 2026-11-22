; ============================================================================
;  PLIK / FILE: realtime_3d.i
;  OPIS: Prawdziwe 3D z teksturowaniem UV 64x64, 16 kolorami AGA i C2P:
;        - Akt I: Przelot przez teksturowany tunel 3D za swiecacym swietlikiem.
;        - Akt II: Grota 3D z jeziorkiem, drzewem, rusalka, wodospadem i 2 swietlikami.
; ============================================================================
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    bsr.w   clear_chunky
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)
    move.w  #$0112,6(a1)
    move.w  #$0224,10(a1)
    move.w  #$0346,14(a1)
    move.w  #$0136,18(a1)
    move.w  #$0269,22(a1)
    move.w  #$04bc,26(a1)
    move.w  #$0ffd,30(a1)
    lea     $dff190,a1
    move.w  #$0641,(a1)+
    move.w  #$0962,(a1)+
    move.w  #$0c82,(a1)+
    move.w  #$0fb4,(a1)+
    move.w  #$0257,(a1)+
    move.w  #$038b,(a1)+
    move.w  #$06ef,(a1)+
    move.w  #$0fff,(a1)+
    move.l  vbl_tick(pc),d7
    cmp.l   #320,d7
    blo.w   act1_uv_tunnel
    bra.w   act2_360_cavern
proj_uv_160:
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
    sub.w   cam_oz(pc),d2
    move.w  d0,d3
    muls.w  cam_cos(pc),d3
    move.w  d2,d4
    muls.w  cam_sin(pc),d4
    sub.l   d4,d3
    asr.l   #8,d3
    muls.w  cam_sin(pc),d0
    muls.w  cam_cos(pc),d2
    add.l   d0,d2
    asr.l   #8,d2
    move.w  d3,d0
    cmp.w   #45,d2
    bge.s   .zo
    move.w  #45,d2
.zo: ext.l d0
    ext.l   d1
    ext.l   d2
    muls.l  #128,d0
    muls.l  #128,d1
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #80,d0
    add.w   #64,d1
    rts
act1_uv_tunnel:
    clr.w   cam_ox
    clr.w   cam_oy
    clr.w   cam_oz
    clr.w   cam_sin
    move.w  #256,cam_cos
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    move.w  d1,l1_x
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #14,d2
    move.w  d2,l1_y
    move.w  #170,l1_z
    move.w  d7,d6
    mulu.w  #6,d6
    moveq   #7,d4
.ts: move.w d4,d0
    mulu.w  #56,d0
    sub.w   d6,d0
    and.w   #$01ff,d0
    add.w   #80,d0
    move.w  d0,sz0
    add.w   #58,d0
    move.w  d0,sz1
    move.w  sz0(pc),d1
    lsr.w   #2,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   l1_x(pc),d2
    move.w  d2,sx0
    move.w  128(a2,d1.w*2),d2
    asr.w   #4,d2
    sub.w   l1_y(pc),d2
    move.w  d2,sy0
    move.w  sz1(pc),d1
    lsr.w   #2,d1
    add.w   d7,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   l1_x(pc),d2
    move.w  d2,sx1
    move.w  128(a2,d1.w*2),d2
    asr.w   #4,d2
    sub.w   l1_y(pc),d2
    move.w  d2,sy1
    move.w  sz0(pc),d0
    sub.w   l1_z(pc),d0
    bpl.s   .dz
    neg.w   d0
.dz: moveq #7,d1
    lsr.w   #5,d0
    sub.w   d0,d1
    cmp.w   #1,d1
    bge.s   .sl_ok
    moveq   #1,d1
.sl_ok: move.w d1,slit
    bsr.w   emit_uv_tunnel_box
    dbf     d4,.ts
    move.w  l1_x(pc),d0
    move.w  l1_y(pc),d1
    move.w  l1_z(pc),d2
    moveq   #11,d7
    bsr.w   draw_chunky_firefly
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
emit_uv_tunnel_box:
    movem.l d0-d7/a0-a4,-(sp)
    move.w  sx0(pc),d0
    move.w  sy0(pc),d1
    move.w  sz0(pc),d2
    move.w  sx1(pc),d3
    move.w  sy1(pc),d4
    move.w  sz1(pc),d5
    ; 1. Lewa sciana z UV (0,0 -> 63,0 -> 63,63 -> 0,63)
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    bsr.w   emit_uv_quad
    ; 2. Prawa sciana z UV
    lea     q_buf(pc),a4
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    bsr.w   emit_uv_quad
    ; 3. Sufit tunelu z UV
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    sub.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    bsr.w   emit_uv_quad
    ; 4. Podloga tunelu z UV
    lea     q_buf(pc),a4
    move.w  d0,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d0,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d1,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d2,(a4)+
    move.w  d3,d6
    add.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    move.w  d3,d6
    sub.w   #96,d6
    move.w  d6,(a4)+
    move.w  d4,d6
    add.w   #72,d6
    move.w  d6,(a4)+
    move.w  d5,(a4)+
    bsr.w   emit_uv_quad
    movem.l (sp)+,d0-d7/a0-a4
    rts
emit_uv_quad:
    movem.l d0-d7/a0-a4,-(sp)
    lea     q_buf(pc),a0
    lea     q_scr(pc),a1
    moveq   #3,d7
.pq: move.w (a0)+,d0
    move.w  (a0)+,d1
    move.w  (a0)+,d2
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    dbf     d7,.pq
    move.l  vbl_tick(pc),d5
    lsl.w   #2,d5
    and.w   #63,d5
    move.w  d5,d4
    add.w   #63,d4
    lea     q_scr(pc),a0
    lea     uv_tri(pc),a1
    move.l  (a0),(a1)+
    move.w  #0,(a1)+
    move.w  d5,(a1)+
    move.l  4(a0),(a1)+
    move.w  #63,(a1)+
    move.w  d5,(a1)+
    move.l  8(a0),(a1)+
    move.w  #63,(a1)+
    move.w  d4,(a1)+
    lea     uv_tri(pc),a4
    moveq   #0,d6
    move.w  slit(pc),d7
    bsr.w   draw_uv_tri
    lea     q_scr(pc),a0
    lea     uv_tri(pc),a1
    move.l  (a0),(a1)+
    move.w  #0,(a1)+
    move.w  d5,(a1)+
    move.l  8(a0),(a1)+
    move.w  #63,(a1)+
    move.w  d4,(a1)+
    move.l  12(a0),(a1)+
    move.w  #0,(a1)+
    move.w  d4,(a1)+
    lea     uv_tri(pc),a4
    moveq   #0,d6
    move.w  slit(pc),d7
    bsr.w   draw_uv_tri
    movem.l (sp)+,d0-d7/a0-a4
    rts
act2_360_cavern:
    lea     sin_tab,a2
    sub.l   #350,d7
    ; Pelny obrot kamery 360 stopni wokol wyspy i drzewa (centrum = 0,0,0, promien = 175)
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #-16,cam_oy
    clr.w   cam_oz
    move.w  #175,orbit_dist
    ; Swietlik #1 (zloty z tunelu) oraz Swietlik #2 (turkusowy z groty) kraza w 3D wokol drzewa
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #1,d1
    move.w  d1,l1_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #1,d2
    move.w  d2,l1_z
    move.w  d7,d1
    mulu.w  #3,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   #14,d2
    move.w  d2,l1_y
    add.w   #128,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #1,d1
    move.w  d1,l2_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #1,d2
    move.w  d2,l2_z
    neg.w   d2
    asr.w   #2,d2
    sub.w   #12,d2
    move.w  d2,l2_y
    ; Renderuj 360-stopniowa jaskinie (sciany, sklepienie, wode, wyspe, drzewo, wodospad)
    lea     cavern_360_mesh(pc),a4
    move.w  (a4)+,d4
.cv_lp: move.w (a4)+,d6            ; tex_id (0=skala, 1=woda, 2=liscie)
    move.w  (a4)+,d5                ; 0 = dynamiczne swiatlo od 2 swietlikow
    bne.s   .has_l
    move.w  (a4),d0
    add.w   6(a4),d0
    add.w   12(a4),d0
    divs.w  #3,d0
    move.w  2(a4),d1
    add.w   8(a4),d1
    add.w   14(a4),d1
    divs.w  #3,d1
    move.w  4(a4),d2
    add.w   10(a4),d2
    add.w   16(a4),d2
    divs.w  #3,d2
    bsr.w   calc_cavern_light
    move.w  d0,d5
.has_l: lea uv_tri(pc),a1
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  #0,(a1)+
    move.w  #0,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  #63,(a1)+
    move.w  #0,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  #63,(a1)+
    move.w  #63,(a1)+
    move.l  a4,-(sp)
    lea     uv_tri(pc),a4
    move.w  d5,d7
    bsr.w   draw_uv_tri
    move.l  (sp)+,a4
    dbf     d4,.cv_lp
    bsr.w   draw_chunky_rusalka
    move.w  l1_x(pc),d0
    move.w  l1_y(pc),d1
    move.w  l1_z(pc),d2
    moveq   #11,d7
    bsr.w   draw_chunky_firefly
    move.w  l2_x(pc),d0
    move.w  l2_y(pc),d1
    move.w  l2_z(pc),d2
    moveq   #6,d7
    bsr.w   draw_chunky_firefly
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
calc_cavern_light:
    movem.l d1-d5,-(sp)
    move.w  d0,d3
    move.w  d1,d4
    move.w  d2,d5
    sub.w   l1_x(pc),d0
    bpl.s   .a1
    neg.w   d0
.a1: sub.w l1_y(pc),d1
    bpl.s   .a2
    neg.w   d1
.a2: sub.w l1_z(pc),d2
    bpl.s   .a3
    neg.w   d2
.a3: add.w d1,d0
    add.w   d2,d0
    sub.w   l2_x(pc),d3
    bpl.s   .b1
    neg.w   d3
.b1: sub.w l2_y(pc),d4
    bpl.s   .b2
    neg.w   d4
.b2: sub.w l2_z(pc),d5
    bpl.s   .b3
    neg.w   d5
.b3: add.w d4,d3
    add.w   d5,d3
    cmp.w   #175,d0
    bhi.s   .c2
    moveq   #7,d0
    movem.l (sp)+,d1-d5
    rts
.c2: cmp.w #175,d3
    bhi.s   .cm
    moveq   #5,d0
    movem.l (sp)+,d1-d5
    rts
.cm: cmp.w d3,d0
    ble.s   .md
    move.w  d3,d0
.md: cmp.w #260,d0
    bhi.s   .cd
    moveq   #3,d0
    movem.l (sp)+,d1-d5
    rts
.cd: moveq #1,d0
    movem.l (sp)+,d1-d5
    rts
draw_chunky_firefly:
    move.w  d7,ff_col
    bsr.w   proj_uv_160
    cmp.w   #8,d0
    blo.w   .fe
    cmp.w   #151,d0
    bhi.w   .fe
    cmp.w   #8,d1
    blo.w   .fe
    cmp.w   #119,d1
    bhi.w   .fe
    lea     chunky_buf,a0
    mulu.w  #160,d1
    add.w   d0,d1
    add.w   d1,a0
    move.b  ff_col+1(pc),d2
    ; Trzepoczace skrzydelka + poswiata swietlika
    move.b  d2,-324(a0)
    move.b  d2,-316(a0)
    move.b  d2,-163(a0)
    move.b  d2,-157(a0)
    move.b  d2,-320(a0)
    move.b  d2,-161(a0)
    move.b  d2,-160(a0)
    move.b  d2,-159(a0)
    move.b  d2,-3(a0)
    move.b  d2,-2(a0)
    move.b  d2,-1(a0)
    move.b  #15,(a0)
    move.b  d2,1(a0)
    move.b  d2,2(a0)
    move.b  d2,3(a0)
    move.b  d2,159(a0)
    move.b  d2,160(a0)
    move.b  d2,161(a0)
    move.b  d2,320(a0)
.fe: rts
draw_chunky_rusalka:
    move.w  #-14,d0
    move.w  #24,d1
    move.w  #0,d2
    bsr.w   proj_uv_160
    cmp.w   #140,d0
    bhi.s   .re
    cmp.w   #100,d1
    bhi.s   .re
    lea     chunky_buf,a0
    mulu.w  #160,d1
    add.w   d0,d1
    add.w   d1,a0
    lea     rusalka_bmp(pc),a1
    moveq   #21,d5
.ry: move.w (a1)+,d4
    moveq   #15,d6
.rx: btst d6,d4
    beq.s   .rn
    move.b  #15,(a0)
.rn: addq.l #1,a0
    dbf     d6,.rx
    lea     144(a0),a0
    dbf     d5,.ry
.re: rts
    even
orbit_dist: dc.w 0
sz0: dc.w 80
sz1: dc.w 130
sx0: dc.w 0
sy0: dc.w 0
sx1: dc.w 0
sy1: dc.w 0
slit: dc.w 4
ff_col: dc.w 11
q_buf: ds.w 12
q_scr: ds.w 8
uv_tri: ds.w 12
oct_offsets:
    dc.w -40,-85,  40,-85
    dc.w  40,-85,  95,-35
    dc.w  95,-35,  95, 35
    dc.w  95, 35,  40, 85
    dc.w  40, 85, -40, 85
    dc.w -40, 85, -95, 35
    dc.w -95, 35, -95,-35
    dc.w -95,-35, -40,-85
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
cavern_360_mesh:
    dc.w 44
    dc.w 0,0,0,-120,250,176,-120,176,176,48,176
    dc.w 0,0,0,-120,250,176,48,176,0,48,250
    dc.w 0,0,0,-120,250,176,-120,176,0,-150,0
    dc.w 1,0,0,48,0,0,48,250,176,48,176
    dc.w 0,0,176,-120,176,250,-120,0,250,48,0
    dc.w 0,0,176,-120,176,250,48,0,176,48,176
    dc.w 0,0,176,-120,176,250,-120,0,0,-150,0
    dc.w 1,0,0,48,0,176,48,176,250,48,0
    dc.w 0,0,250,-120,0,176,-120,-176,176,48,-176
    dc.w 0,0,250,-120,0,176,48,-176,250,48,0
    dc.w 0,0,250,-120,0,176,-120,-176,0,-150,0
    dc.w 1,0,0,48,0,250,48,0,176,48,-176
    dc.w 0,0,176,-120,-176,0,-120,-250,0,48,-250
    dc.w 0,0,176,-120,-176,0,48,-250,176,48,-176
    dc.w 0,0,176,-120,-176,0,-120,-250,0,-150,0
    dc.w 1,0,0,48,0,176,48,-176,0,48,-250
    dc.w 0,0,0,-120,-250,-176,-120,-176,-176,48,-176
    dc.w 0,0,0,-120,-250,-176,48,-176,0,48,-250
    dc.w 0,0,0,-120,-250,-176,-120,-176,0,-150,0
    dc.w 1,0,0,48,0,0,48,-250,-176,48,-176
    dc.w 0,0,-176,-120,-176,-250,-120,0,-250,48,0
    dc.w 0,0,-176,-120,-176,-250,48,0,-176,48,-176
    dc.w 0,0,-176,-120,-176,-250,-120,0,0,-150,0
    dc.w 1,0,0,48,0,-176,48,-176,-250,48,0
    dc.w 0,0,-250,-120,0,-176,-120,176,-176,48,176
    dc.w 0,0,-250,-120,0,-176,48,176,-250,48,0
    dc.w 0,0,-250,-120,0,-176,-120,176,0,-150,0
    dc.w 1,0,0,48,0,-250,48,0,-176,48,176
    dc.w 0,0,-176,-120,176,0,-120,250,0,48,250
    dc.w 0,0,-176,-120,176,0,48,250,-176,48,176
    dc.w 0,0,-176,-120,176,0,-120,250,0,-150,0
    dc.w 1,0,0,48,0,-176,48,176,0,48,250
    dc.w 1,5,165,-70,175,180,-70,160,180,48,160
    dc.w 1,5,165,-70,175,180,48,160,165,48,175
    dc.w 0,0,-56,48,30,56,48,30,0,34,0
    dc.w 0,0,56,48,30,0,48,-56,0,34,0
    dc.w 0,0,0,48,-56,-56,48,30,0,34,0
    dc.w 0,2,-6,36,0,6,36,0,0,-22,0
    dc.w 0,2,0,36,-6,0,36,6,0,-22,0
    dc.w 2,0,-54,-10,28,54,-10,28,0,-55,0
    dc.w 2,0,54,-10,28,0,-10,-54,0,-55,0
    dc.w 2,0,0,-10,-54,-54,-10,28,0,-55,0
    dc.w 2,0,-38,-32,20,38,-32,20,0,-75,0
    dc.w 2,0,38,-32,20,0,-32,-38,0,-75,0
    dc.w 2,0,0,-32,-38,-38,-32,20,0,-75,0
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
