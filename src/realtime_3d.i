; ============================================================================
;  PLIK / FILE: realtime_3d.i
;  OPIS: Akt I: Okragly tunel 3D z teksturami UV + oswietlenie od swietlika
;        (swietlik rysowany z osobnej swietlistej tekstury).
;        Akt II: Zamknieta jaskinia 360 st. wokol wyspy, drzewa i rusalki
;        z sortowaniem trojkatow Z i dwoma swietlikami ze swietlistej tekstury.
; ============================================================================
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)            ; 0: gleboki mrok
    move.w  #$0112,6(a1)            ; 1: cien kamienia
    move.w  #$0224,10(a1)           ; 2: ciemna skala
    move.w  #$0346,14(a1)           ; 3: oswietlona skala / mech
    move.w  #$0136,18(a1)           ; 4: gleboka woda
    move.w  #$0269,22(a1)           ; 5: falujaca woda
    move.w  #$04bc,26(a1)           ; 6: turkusowy blask / wodospad
    move.w  #$0ffd,30(a1)           ; 7: jasny blask / rusalka
    lea     $dff190,a1
    move.w  #$0531,(a1)+            ; 8: cieply braz / zloto w cieniu
    move.w  #$0851,(a1)+            ; 9: bursztynowe swiatlo swietlika
    move.w  #$0b72,(a1)+            ; 10: jasne zlote swiatlo
    move.w  #$0fa4,(a1)+            ; 11: zloty blask swietlika
    move.w  #$0257,(a1)+            ; 12: woda w polcieniu
    move.w  #$038b,(a1)+            ; 13: jasna fala
    move.w  #$06ef,(a1)+            ; 14: piana wodospadu
    move.w  #$0fff,(a1)+            ; 15: bialy rdzen swiatla
    move.l  vbl_tick(pc),d7
    cmp.l   #320,d7
    blo.w   act1_round_tunnel
    bra.w   act2_360_cavern
act1_round_tunnel:
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1                   ; ff_sx = -32..+32 -> +80 = 48..112
    add.w   #80,d1
    move.w  d1,ff_sx
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #70,d2                  ; ff_sy = 54..86
    move.w  d2,ff_sy
    ; Renderuj 160x128 okragly tunel 3D z oswietleniem wokol swietlika (ff_sx, ff_sy)
    lea     tunnel_lut,a0
    lea     chunky_buf,a1
    lea     uv_tex_bank,a2
    move.w  d7,d5
    lsr.w   #1,d5                   ; obrot kamery w tunelu
    move.w  d7,d6
    add.w   d6,d6                   ; predkosc lotu w glab tunelu
    moveq   #0,d3                   ; Y = 0..127
.ty: move.w d3,d4
    sub.w   ff_sy(pc),d4
    bpl.s   .ay
    neg.w   d4
.ay: move.w d4,cur_ay
    moveq   #0,d2                   ; X = 0..159
.tx: move.b (a0)+,d0               ; U (kat)
    add.b   d5,d0
    and.w   #63,d0
    move.b  (a0)+,d1               ; V (glebia 1/Z)
    beq.s   .is_hole
    add.b   d6,d1
    and.w   #63,d1
    lsl.w   #6,d1
    or.w    d0,d1
    move.b  (a2,d1.w),d0           ; teksel skaly (1..7)
    ; Oswietlenie punktowe od swiecacego swietlika na scianach okraglego tunelu!
    move.w  d2,d1
    sub.w   ff_sx(pc),d1
    bpl.s   .ax
    neg.w   d1
.ax: add.w cur_ay(pc),d1
    cmp.w   #34,d1
    bhi.s   .chk_m
    addq.b  #6,d0                   ; blisko swietlika -> cieple zlote swiatlo (8..11)!
    cmp.b   #11,d0
    ble.s   .wr_p
    moveq   #11,d0
    bra.s   .wr_p
.chk_m: lsr.b #1,d0
    addq.b  #1,d0
.wr_p: move.b d0,(a1)+
    addq.w  #1,d2
    cmp.w   #160,d2
    blo.s   .tx
    addq.w  #1,d3
    cmp.w   #128,d3
    blo.s   .ty
    bra.s   .dn_tun
.is_hole: clr.b (a1)+
    addq.w  #1,d2
    cmp.w   #160,d2
    blo.s   .tx
    addq.w  #1,d3
    cmp.w   #128,d3
    blo.s   .ty
.dn_tun:
    ; Rysuj swietlika z osobnej swietlistej tekstury (zloto-bialy rdzen + skrzydelka)
    move.w  ff_sx(pc),d0
    move.w  ff_sy(pc),d1
    moveq   #11,d7
    bsr.w   draw_textured_firefly_2d
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
proj_uv_160:
    ; Kamera krazy po orbicie o promieniu cam_oz (=-185) wokol srodka jaskini (0,0,0)
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
    move.w  d0,d3
    muls.w  cam_cos(pc),d3
    move.w  d2,d4
    muls.w  cam_sin(pc),d4
    sub.l   d4,d3
    asr.l   #8,d3                   ; rx
    muls.w  cam_sin(pc),d0
    muls.w  cam_cos(pc),d2
    add.l   d0,d2
    asr.l   #8,d2                   ; rz
    sub.w   cam_oz(pc),d2           ; odsun kamera o 185 jednostek od srodka wyspy!
    move.w  d3,d0
    cmp.w   #25,d2
    bge.s   .zo
    move.w  #-999,d0
    move.w  #-999,d1
    rts
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
act2_360_cavern:
    bsr.w   clear_chunky
    lea     sin_tab,a2
    sub.l   #320,d7
    ; Obrot kamery 360 stopni dookola drzewa i wyspy (cam_oz = -185)
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #-14,cam_oy
    move.w  #-185,cam_oz
    ; Swietlik #1 (zloty z tunelu) i Swietlik #2 (turkusowy) kraza wokol drzewa
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
    ; Najpierw rysuj sciany, sklepienie i tafla wody calej jaskini (otoczenie 360 st.)
    lea     cavern_env_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    ; Nastepnie rysuj wyspe, drzewo, wodospad i rusalke na pierwszym planie
    lea     cavern_fg_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    bsr.w   draw_chunky_rusalka
    ; Dwa swietliki rysowane z osobnej swietlistej tekstury (tex 3)!
    move.w  l1_x(pc),d0
    move.w  l1_y(pc),d1
    move.w  l1_z(pc),d2
    bsr.w   proj_uv_160
    moveq   #11,d7
    bsr.w   draw_textured_firefly_2d
    move.w  l2_x(pc),d0
    move.w  l2_y(pc),d1
    move.w  l2_z(pc),d2
    bsr.w   proj_uv_160
    moveq   #6,d7
    bsr.w   draw_textured_firefly_2d
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
render_uv_mesh_list:
    move.w  (a4)+,d4
.um_lp: move.w (a4)+,d6
    move.w  (a4)+,d5
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
    bsr.s   calc_cavern_light
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
    cmp.w   #-500,uv_tri
    blt.s   .skip_t
    cmp.w   #-500,uv_tri+8
    blt.s   .skip_t
    cmp.w   #-500,uv_tri+16
    blt.s   .skip_t
    move.w  d5,d7
    bsr.w   draw_uv_tri
.skip_t:
    move.l  (sp)+,a4
    dbf     d4,.um_lp
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
.md: cmp.w #265,d0
    bhi.s   .cd
    moveq   #3,d0
    movem.l (sp)+,d1-d5
    rts
.cd: moveq #2,d0
    movem.l (sp)+,d1-d5
    rts
draw_textured_firefly_2d:
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
    lea     uv_tex_bank+12288,a1
    move.l  vbl_tick(pc),d3
    and.w   #63,d3
    lsl.w   #6,d3
    add.w   d3,a1
    move.b  (a1),d2
    and.b   d7,d2
    bne.s   .c_ok
    move.b  d7,d2
.c_ok: move.b d2,-324(a0)
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
ff_sx: dc.w 80
ff_sy: dc.w 64
cur_ay: dc.w 0
uv_tri: ds.w 12
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
cavern_env_mesh:
    dc.w 33
    dc.w 0,0,0,260,-115,0,260,183,183,-115,183,183,183,183,48,183,183
    dc.w 0,0,0,260,-115,0,260,183,183,48,183,183,0,260,48,0,260
    dc.w 0,0,0,260,-115,0,260,183,183,-115,183,183,0,-145,0
    dc.w 1,0,0,48,0,0,260,48,0,260,183,183,48,183,183
    dc.w 0,0,183,183,-115,183,183,260,0,-115,260,0,260,0,48,260,0
    dc.w 0,0,183,183,-115,183,183,260,0,48,260,0,183,183,48,183,183
    dc.w 0,0,183,183,-115,183,183,260,0,-115,260,0,0,-145,0
    dc.w 1,0,0,48,0,183,183,48,183,183,260,0,48,260,0
    dc.w 0,0,260,0,-115,260,0,183,-183,-115,183,-183,183,-183,48,183,-183
    dc.w 0,0,260,0,-115,260,0,183,-183,48,183,-183,260,0,48,260,0
    dc.w 0,0,260,0,-115,260,0,183,-183,-115,183,-183,0,-145,0
    dc.w 1,0,0,48,0,260,0,48,260,0,183,-183,48,183,-183
    dc.w 0,0,183,-183,-115,183,-183,0,-260,-115,0,-260,0,-260,48,0,-260
    dc.w 0,0,183,-183,-115,183,-183,0,-260,48,0,-260,183,-183,48,183,-183
    dc.w 0,0,183,-183,-115,183,-183,0,-260,-115,0,-260,0,-145,0
    dc.w 1,0,0,48,0,183,-183,48,183,-183,0,-260,48,0,-260
    dc.w 0,0,0,-260,-115,0,-260,-183,-183,-115,-183,-183,-183,-183,48,-183,-183
    dc.w 0,0,0,-260,-115,0,-260,-183,-183,48,-183,-183,0,-260,48,0,-260
    dc.w 0,0,0,-260,-115,0,-260,-183,-183,-115,-183,-183,0,-145,0
    dc.w 1,0,0,48,0,0,-260,48,0,-260,-183,-183,48,-183,-183
    dc.w 0,0,-183,-183,-115,-183,-183,-260,0,-115,-260,0,-260,0,48,-260,0
    dc.w 0,0,-183,-183,-115,-183,-183,-260,0,48,-260,0,-183,-183,48,-183,-183
    dc.w 0,0,-183,-183,-115,-183,-183,-260,0,-115,-260,0,0,-145,0
    dc.w 1,0,0,48,0,-183,-183,48,-183,-183,-260,0,48,-260,0
    dc.w 0,0,-260,0,-115,-260,0,-183,183,-115,-183,183,-183,183,48,-183,183
    dc.w 0,0,-260,0,-115,-260,0,-183,183,48,-183,183,-260,0,48,-260,0
    dc.w 0,0,-260,0,-115,-260,0,-183,183,-115,-183,183,0,-145,0
    dc.w 1,0,0,48,0,-260,0,48,-260,0,-183,183,48,-183,183
    dc.w 0,0,-183,183,-115,-183,183,0,260,-115,0,260,0,260,48,0,260
    dc.w 0,0,-183,183,-115,-183,183,0,260,48,0,260,-183,183,48,-183,183
    dc.w 0,0,-183,183,-115,-183,183,0,260,-115,0,260,0,-145,0
    dc.w 1,0,0,48,0,-183,183,48,-183,183,0,260,48,0,260
    dc.w 1,6,175,-65,185,190,-65,170,190,48,170
    dc.w 1,6,175,-65,185,190,48,170,175,48,185
cavern_fg_mesh:
    dc.w 10
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
