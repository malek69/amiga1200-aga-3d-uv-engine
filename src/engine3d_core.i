; [EN/PL] MODULE: engine3d_core.i | M68020 3D Geometry, Point-Light Shading & Procedural 16x16 Texturing
proj_3d:
    ; Input: d0=X, d1=Y, d2=Z (kamera w 0,0,0) -> Output: d0=sx, d1=sy
    cmp.w   #45,d2
    bge.s   .z_ok
    move.w  #45,d2
.z_ok: ext.l d0
    ext.l   d1
    ext.l   d2
    muls.l  #256,d0
    muls.l  #256,d1
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #124,d1
    rts

calc_3d_light:
    ; Input: d0=px, d1=py, d2=pz (srodek sciany 3D) vs (light_x, light_y, light_z)
    ; Output: d0 = poziom swiatla (0=cien BPL1, 1=polcien tekstura, 2=jasne swiatlo BPL2)
    sub.w   light_x(pc),d0
    bpl.s   .lx_p
    neg.w   d0
.lx_p: sub.w light_y(pc),d1
    bpl.s   .ly_p
    neg.w   d1
.ly_p: sub.w light_z(pc),d2
    bpl.s   .lz_p
    neg.w   d2
.lz_p: add.w d1,d0
    add.w   d2,d0                   ; odleglosc 3D od swiecacego odwloka swietlika
    cmp.w   #95,d0
    bhi.s   .l_mid
    moveq   #2,d0                   ; blisko swietlika -> jasne swiatlo (BPL2)
    rts
.l_mid: cmp.w #175,d0
    bhi.s   .l_drk
    moveq   #1,d0                   ; strefa przejsciowa -> tekstura mieszana
    rts
.l_drk: moveq #0,d0                   ; daleko -> mrok (BPL1)
    rts

draw_tex_tri:
    ; Rysuje oteksturowany trojkat 3D: a4 -> 3 wierzcholki (x,y,z), d6=tex_id (0..3), d7=light (0..2)
    movem.l d0-d7/a0-a5,-(sp)
    move.w  d6,cur_tex
    move.w  d7,cur_lit
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.s   proj_3d
    move.w  d0,tv_x0
    move.w  d1,tv_y0
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_3d
    move.w  d0,tv_x1
    move.w  d1,tv_y1
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_3d
    move.w  d0,tv_x2
    move.w  d1,tv_y2
    ; Wyznacz ymin..ymax
    move.w  tv_y0(pc),d6
    move.w  tv_y1(pc),d1
    move.w  tv_y2(pc),d2
    cmp.w   d1,d6
    ble.s   .y1
    move.w  d1,d6
.y1: cmp.w d2,d6
    ble.s   .y2
    move.w  d2,d6
.y2: move.w tv_y0(pc),d7
    cmp.w   d1,d7
    bge.s   .y3
    move.w  d1,d7
.y3: cmp.w d2,d7
    bge.s   .y4
    move.w  d2,d7
.y4: tst.w d6
    bpl.s   .yc1
    moveq   #0,d6
.yc1: cmp.w #254,d7
    ble.s   .yc2
    move.w  #254,d7
.yc2: cmp.w d6,d7
    ble.w   .t_done
    move.w  d6,tri_y0
    move.w  d7,tri_y1
    lea     edge_buf,a0
    lea     512(a0),a1
    move.w  d7,d2
    sub.w   d6,d2
    add.w   d6,d6
    add.w   d6,a0
    add.w   d6,a1
.isp: move.w #32000,(a0)+
    move.w  #-32000,(a1)+
    dbf     d2,.isp
    move.w  tv_x0(pc),d0
    move.w  tv_y0(pc),d1
    move.w  tv_x1(pc),d2
    move.w  tv_y1(pc),d3
    bsr.w   .scan_e
    move.w  tv_x1(pc),d0
    move.w  tv_y1(pc),d1
    move.w  tv_x2(pc),d2
    move.w  tv_y2(pc),d3
    bsr.w   .scan_e
    move.w  tv_x2(pc),d0
    move.w  tv_y2(pc),d1
    move.w  tv_x0(pc),d2
    move.w  tv_y0(pc),d3
    bsr.w   .scan_e
    ; Wypelnij poziome pasy z tekstura 16x16 (a4 = baza tekstury 32B)
    lea     tex_bank(pc),a4
    move.w  cur_tex(pc),d0
    lsl.w   #5,d0
    add.w   d0,a4
    move.w  tri_y0(pc),d6
    move.w  tri_y1(pc),d7
    lea     edge_buf,a0
    lea     512(a0),a1
    move.w  d6,d0
    add.w   d0,d0
    add.w   d0,a0
    add.w   d0,a1
    move.l  draw_bpl1(pc),a2
    move.l  draw_bpl2(pc),a3
    move.w  d6,d0
    mulu.w  #40,d0
    add.l   d0,a2
    add.l   d0,a3
.ty_lp: move.w (a0)+,d0
    move.w  (a1)+,d1
    cmp.w   d0,d1
    blt.w   .ty_nx
    tst.w   d0
    bpl.s   .xl_ok
    moveq   #0,d0
.xl_ok: cmp.w #319,d1
    ble.s   .xr_ok
    move.w  #319,d1
.xr_ok: cmp.w d0,d1
    blt.w   .ty_nx
    move.w  d6,d2
    and.w   #15,d2
    move.w  (a4,d2.w*2),d3          ; 16-bitowy wzor tekstury dla wiersza Y
    move.w  d0,d4
    lsr.w   #4,d4                   ; word start
    move.w  d1,d5
    lsr.w   #4,d5                   ; word end
    sub.w   d4,d5
    add.w   d4,d4                   ; byte offset
    cmp.w   #2,cur_lit
    beq.s   .lit_hi
    cmp.w   #1,cur_lit
    beq.s   .lit_md
.lit_lo: or.w d3,(a2,d4.w)          ; cien: tekstura tylko na BPL1
    addq.w  #2,d4
    dbf     d5,.lit_lo
    bra.s   .ty_nx
.lit_md: or.w d3,(a2,d4.w)          ; polcien: tekstura na BPL1 + odwrotny wzor na BPL2
    not.w   d3
    or.w    d3,(a3,d4.w)
    not.w   d3
    addq.w  #2,d4
    dbf     d5,.lit_md
    bra.s   .ty_nx
.lit_hi: or.w d3,(a3,d4.w)          ; jasne swiatlo: tekstura na BPL2
    addq.w  #2,d4
    dbf     d5,.lit_hi
.ty_nx: lea 40(a2),a2
    lea     40(a3),a3
    addq.w  #1,d6
    cmp.w   d7,d6
    ble.w   .ty_lp
.t_done: movem.l (sp)+,d0-d7/a0-a5
    rts
.scan_e: cmp.w d1,d3
    beq.s   .se_ex
    bgt.s   .se_ok
    exg     d0,d2
    exg     d1,d3
.se_ok: move.w d3,d6
    sub.w   d1,d6
    ext.l   d6
    move.w  d2,d7
    sub.w   d0,d7
    ext.l   d7
    swap    d7
    divs.l  d6,d7
    swap    d0
    move.w  #$8000,d0
    lea     edge_buf,a0
    lea     512(a0),a1
.se_lp: tst.w d1
    bmi.s   .se_st
    cmp.w   #254,d1
    bgt.s   .se_ex
    move.l  d0,d4
    swap    d4
    move.w  d1,d5
    add.w   d5,d5
    cmp.w   (a0,d5.w),d4
    bge.s   .se_r
    move.w  d4,(a0,d5.w)
.se_r: cmp.w (a1,d5.w),d4
    ble.s   .se_st
    move.w  d4,(a1,d5.w)
.se_st: add.l d7,d0
    addq.w  #1,d1
    cmp.w   d3,d1
    ble.s   .se_lp
.se_ex: rts
light_x: dc.w 0
light_y: dc.w 0
light_z: dc.w 160
cur_tex: dc.w 0
cur_lit: dc.w 0
tv_x0:   dc.w 0
tv_y0:   dc.w 0
tv_x1:   dc.w 0
tv_y1:   dc.w 0
tv_x2:   dc.w 0
tv_y2:   dc.w 0
tri_y0:  dc.w 0
tri_y1:  dc.w 0
tex_bank:
    ; Tex 0: Mokra skala (chropowata tekstura kamienia z refleksami)
    dc.w $eedb,$b7f6,$dfbe,$7edf,$fb7d,$eedb,$77bd,$dbef,$eedb,$b7f6,$dfbe,$7edf,$fb7d,$eedb,$77bd,$dbef
    ; Tex 1: Falujaca woda i kaskada wodospadu
    dc.w $f0f0,$7878,$3c3c,$1e1e,$0f0f,$8787,$c3c3,$e1e1,$f0f0,$7878,$3c3c,$1e1e,$0f0f,$8787,$c3c3,$e1e1
    ; Tex 2: Liscie i mech na drzewie / wysepce
    dc.w $aa55,$55aa,$ee77,$77ee,$aa55,$55aa,$ddbb,$bbdd,$aa55,$55aa,$ee77,$77ee,$aa55,$55aa,$ddbb,$bbdd
    ; Tex 3: Gładki rdzen / biala piana
    dc.w $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
