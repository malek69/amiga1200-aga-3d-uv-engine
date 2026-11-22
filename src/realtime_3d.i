; ============================================================================
;  PLIK / FILE: realtime_3d.i
;  OPIS: 3-aktowe demo 3D z teksturami UV 64x64 i 16 kolorami AGA:
;        - Akt I (0..260): Pelnoekranowy okragly tunel 3D ze swietlikiem.
;        - Akt II (260..380): Scena przejscia - wylot z tunelu do groty.
;        - Akt III (380+): Zamknieta grota 360 st. (sciany, sklepienie, woda,
;          wyspa, 3D drzewo, rusalka i 2 swietliki ze swietlistej tekstury).
; ============================================================================
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0001,2(a1)
    move.w  #$0113,6(a1)
    move.w  #$0225,10(a1)
    move.w  #$0347,14(a1)
    move.w  #$0136,18(a1)
    move.w  #$0269,22(a1)
    move.w  #$04bc,26(a1)
    move.w  #$0ffd,30(a1)
    lea     $dff190,a1
    move.w  #$0531,(a1)+
    move.w  #$0851,(a1)+
    move.w  #$0b72,(a1)+
    move.w  #$0fa4,(a1)+
    move.w  #$0257,(a1)+
    move.w  #$038b,(a1)+
    move.w  #$06ef,(a1)+
    move.w  #$0fff,(a1)+
    move.l  vbl_tick(pc),d7
    cmp.l   #260,d7
    blo.w   act1_round_tunnel
    cmp.l   #380,d7
    blo.w   act2_tunnel_exit_scene
    bra.w   act3_360_grotto
act1_round_tunnel:
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #3,d1
    add.w   #80,d1
    move.w  d1,ff_sx
    move.w  d7,d0
    mulu.w  #3,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d2
    asr.w   #4,d2
    add.w   #68,d2
    move.w  d2,ff_sy
    lea     tunnel_lut,a0
    lea     chunky_buf,a1
    lea     uv_tex_bank,a2
    move.w  d7,d5
    lsr.w   #1,d5
    move.w  d7,d6
    add.w   d6,d6
    moveq   #0,d3
.ty: move.w d3,d4
    sub.w   ff_sy(pc),d4
    muls.w  d4,d4
    move.l  d4,cur_dy2
    moveq   #0,d2
.tx: move.b (a0)+,d0
    add.b   d5,d0
    and.w   #63,d0
    move.b  (a0)+,d1
    beq.w   .is_hole
    move.b  d1,cur_v
    add.b   d6,d1
    and.w   #63,d1
    lsl.w   #6,d1
    or.w    d0,d1
    move.b  (a2,d1.w),d0           ; pelna tekstura skaly na calym ekranie 160x128!
    ; Przyciemnienie z glebia (im dalej w glab tunelu, tym ciemniej)
    cmp.b   #28,cur_v
    blo.s   .dep_ok
    lsr.b   #1,d0
    addq.b  #1,d0
.dep_ok:
    ; Okragle zlote swiatlo od odwłoka swietlika (dx^2 + dy^2)
    move.w  d2,d1
    sub.w   ff_sx(pc),d1
    muls.w  d1,d1
    add.l   cur_dy2(pc),d1
    cmp.l   #900,d1
    bhi.s   .wr_p
    addq.b  #6,d0
    cmp.b   #11,d0
    ble.s   .wr_p
    moveq   #11,d0
.wr_p: move.b d0,(a1)+
    addq.w  #1,d2
    cmp.w   #160,d2
    blo.w   .tx
    addq.w  #1,d3
    cmp.w   #128,d3
    blo.w   .ty
    bra.s   .dn_t
.is_hole: move.b #6,(a1)+
    addq.w  #1,d2
    cmp.w   #160,d2
    blo.w   .tx
    addq.w  #1,d3
    cmp.w   #128,d3
    blo.w   .ty
.dn_t:
    move.w  ff_sx(pc),d0
    move.w  ff_sy(pc),d1
    moveq   #11,d7
    bsr.w   draw_textured_firefly_2d
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
act2_tunnel_exit_scene:
    ; Scena przejscia (vbl_tick 260..380): wylot z skalnego luku tunelu do mrocznej groty!
    bsr.w   clear_chunky
    sub.l   #260,d7                 ; t = 0..119
    clr.w   cam_ox
    move.w  #-8,cam_oy
    move.w  d7,d0
    lsl.w   #1,d0
    sub.w   #310,d0                 ; kamera leci od Z=-310 do Z=-70 przez skalny luk!
    move.w  d0,cam_oz
    clr.w   cam_sin
    move.w  #256,cam_cos
    ; Zloty swietlik wlatuje do groty (l1) a turkusowy nadlatuje znad wody (l2)
    move.w  d7,d0
    asr.w   #1,d0
    sub.w   #30,d0
    move.w  d0,l1_x
    move.w  #-6,l1_y
    move.w  #140,l1_z
    move.w  #35,l2_x
    sub.w   d0,l2_x
    move.w  #4,l2_y
    move.w  #180,l2_z
    ; Najpierw rysuj wnetrze groty przed wylotem + skalny luk tunelu wokol kamery!
    lea     cavern_env_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    lea     cavern_fg_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    lea     tunnel_arch_mesh(pc),a4
    bsr.w   render_uv_mesh_list
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
proj_uv_160:
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
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
    sub.w   cam_oz(pc),d2
    move.w  d3,d0
    cmp.w   #28,d2
    bge.s   .zo
    move.w  #28,d2
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
act3_360_grotto:
    bsr.w   clear_chunky
    lea     sin_tab,a2
    sub.l   #380,d7
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #-14,cam_oy
    move.w  #-150,cam_oz
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
    lea     cavern_env_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    lea     cavern_fg_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    bsr.w   draw_chunky_rusalka
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
    move.w  d5,d7
    bsr.w   draw_uv_tri
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
    cmp.w   #210,d0
    bhi.s   .c2
    moveq   #7,d0
    movem.l (sp)+,d1-d5
    rts
.c2: cmp.w #210,d3
    bhi.s   .cm
    moveq   #5,d0
    movem.l (sp)+,d1-d5
    rts
.cm: cmp.w d3,d0
    ble.s   .md
    move.w  d3,d0
.md: cmp.w #310,d0
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
cur_v: dc.w 0
cur_dy2: dc.l 0
ff_sx: dc.w 80
ff_sy: dc.w 64
uv_tri: ds.w 12
rusalka_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$1ef0,$1c70,$07c0,$0380,$0fe0,$1ff0,$1bb0,$07c0,$07c0,$0fe0,$0fe0,$1ff0,$1ff0,$3ff8,$3ff8,$1ef0,$0c60,$0c60
cavern_env_mesh:
    dc.w 33
    dc.w 0,0,0,-125,310,219,-125,219,219,48,219
    dc.w 0,0,0,-125,310,219,48,219,0,48,310
    dc.w 0,0,0,-125,310,219,-125,219,0,-155,0
    dc.w 1,0,0,48,0,0,48,310,219,48,219
    dc.w 0,0,219,-125,219,310,-125,0,310,48,0
    dc.w 0,0,219,-125,219,310,48,0,219,48,219
    dc.w 0,0,219,-125,219,310,-125,0,0,-155,0
    dc.w 1,0,0,48,0,219,48,219,310,48,0
    dc.w 0,0,310,-125,0,219,-125,-219,219,48,-219
    dc.w 0,0,310,-125,0,219,48,-219,310,48,0
    dc.w 0,0,310,-125,0,219,-125,-219,0,-155,0
    dc.w 1,0,0,48,0,310,48,0,219,48,-219
    dc.w 0,0,219,-125,-219,0,-125,-310,0,48,-310
    dc.w 0,0,219,-125,-219,0,48,-310,219,48,-219
    dc.w 0,0,219,-125,-219,0,-125,-310,0,-155,0
    dc.w 1,0,0,48,0,219,48,-219,0,48,-310
    dc.w 0,0,0,-125,-310,-219,-125,-219,-219,48,-219
    dc.w 0,0,0,-125,-310,-219,48,-219,0,48,-310
    dc.w 0,0,0,-125,-310,-219,-125,-219,0,-155,0
    dc.w 1,0,0,48,0,0,48,-310,-219,48,-219
    dc.w 0,0,-219,-125,-219,-310,-125,0,-310,48,0
    dc.w 0,0,-219,-125,-219,-310,48,0,-219,48,-219
    dc.w 0,0,-219,-125,-219,-310,-125,0,0,-155,0
    dc.w 1,0,0,48,0,-219,48,-219,-310,48,0
    dc.w 0,0,-310,-125,0,-219,-125,219,-219,48,219
    dc.w 0,0,-310,-125,0,-219,48,219,-310,48,0
    dc.w 0,0,-310,-125,0,-219,-125,219,0,-155,0
    dc.w 1,0,0,48,0,-310,48,0,-219,48,219
    dc.w 0,0,-219,-125,219,0,-125,310,0,48,310
    dc.w 0,0,-219,-125,219,0,48,310,-219,48,219
    dc.w 0,0,-219,-125,219,0,-125,310,0,-155,0
    dc.w 1,0,0,48,0,-219,48,219,0,48,310
    dc.w 1,6,200,-70,210,220,-70,190,220,48,190
    dc.w 1,6,200,-70,210,220,48,190,200,48,210
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
tunnel_arch_mesh:
    dc.w 2
    dc.w 0,3,-150,-110,-160,-55,-110,-160,-85,55,-160
    dc.w 0,3,55,-110,-160,150,-110,-160,85,55,-160
    dc.w 0,3,-85,-110,-160,85,-110,-160,0,-52,-160
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
