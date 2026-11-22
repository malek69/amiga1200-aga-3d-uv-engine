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
    bra.w   act2_uv_grotto
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
    ; Rzutuje 4 wierzcholki z q_buf i rysuje 2 trojkaty z UV (0,0)-(63,0)-(63,63)-(0,63)
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
    and.w   #63,d5                  ; plynne przesuwanie tekstury UV wzdłuz tunelu!
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
act2_uv_grotto:
    lea     sin_tab,a2
    sub.l   #320,d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),cam_sin
    move.w  128(a2,d1.w*2),cam_cos
    move.w  cam_sin(pc),d2
    neg.w   d2
    asr.w   #1,d2
    move.w  d2,cam_ox
    move.w  #-10,cam_oy
    clr.w   cam_oz
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1
    move.w  d1,l1_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #2,d2
    add.w   #250,d2
    move.w  d2,l1_z
    move.w  d7,d1
    mulu.w  #3,d1
    and.w   #$ff,d1
    move.w  (a2,d1.w*2),d2
    asr.w   #3,d2
    sub.w   #12,d2
    move.w  d2,l1_y
    add.w   #128,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #2,d1
    move.w  d1,l2_x
    move.w  128(a2,d0.w*2),d2
    asr.w   #2,d2
    add.w   #250,d2
    move.w  d2,l2_z
    neg.w   d2
    add.w   #240,d2
    move.w  d2,l2_y
    lea     uv_grotto_mesh(pc),a4
    move.w  (a4)+,d4
.ug_lp: move.w (a4)+,d6            ; tex_id (0=skala, 1=woda, 2=liscie)
    move.w  (a4)+,d5                ; fixed_light (0=dynamiczne od 2 swietlikow)
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
    bsr.w   calc_dual_light
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
    dbf     d4,.ug_lp
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
draw_chunky_firefly:
    move.w  d7,ff_col
    bsr.w   proj_uv_160
    cmp.w   #6,d0
    blo.w   .fe
    cmp.w   #153,d0
    bhi.w   .fe
    cmp.w   #6,d1
    blo.w   .fe
    cmp.w   #121,d1
    bhi.w   .fe
    lea     chunky_buf,a0
    mulu.w  #160,d1
    add.w   d0,d1
    add.w   d1,a0
    move.b  ff_col+1(pc),d2
    move.b  d2,-320(a0)
    move.b  d2,-161(a0)
    move.b  d2,-160(a0)
    move.b  d2,-159(a0)
    move.b  d2,-2(a0)
    move.b  d2,-1(a0)
    move.b  #15,(a0)
    move.b  d2,1(a0)
    move.b  d2,2(a0)
    move.b  d2,159(a0)
    move.b  d2,160(a0)
    move.b  d2,161(a0)
    move.b  d2,320(a0)
.fe: rts
draw_chunky_rusalka:
    move.w  #-14,d0
    move.w  #26,d1
    move.w  #246,d2
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
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
uv_grotto_mesh:
    dc.w 16
    dc.w 0,0, -210,-130,275, -80,-130,275, -135,50,245
    dc.w 0,0, -210,-130,275, -135,50,245, -210,50,245
    dc.w 0,0, 95,-130,275, 210,-130,275, 135,50,245
    dc.w 0,0, 210,-130,275, 210,50,245, 135,50,245
    dc.w 0,0, -140,-130,275, 140,-130,275, 0,-95,280
    dc.w 0,0, -110,-125,265, -75,-125,265, -92,-62,258
    dc.w 0,0, 62,-125,265, 98,-125,265, 80,-58,258
    dc.w 1,3, -200,48,225, 200,48,225, 215,98,305
    dc.w 1,3, -200,48,225, 215,98,305, -215,98,305
    dc.w 1,6, 82,-64,274, 92,-64,274, 95,48,268
    dc.w 1,6, 82,-64,274, 95,48,268, 80,48,268
    dc.w 0,0, -64,48,252, 64,48,252, 46,35,242
    dc.w 0,0, -64,48,252, 46,35,242, -46,35,242
    dc.w 0,2, -6,36,248, 7,36,248, 4,-20,248
    dc.w 0,2, -6,36,248, 4,-20,248, -4,-20,248
    dc.w 2,0, -62,-8,248, 62,-8,248, 0,-48,242
    dc.w 2,0, -45,-28,250, 45,-28,250, 0,-72,245
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
