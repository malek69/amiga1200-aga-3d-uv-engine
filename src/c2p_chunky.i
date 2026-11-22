; ============================================================================
;  PLIK / FILE: c2p_chunky.i
;  OPIS: Silnik Chunky 160x128 -> 4 Bitplany AGA (16 kolorow) + Rasteryzator
;        trojkatow 3D z prawdziwym mapowaniem tekstur UV 64x64 i cieniowaniem.
; ============================================================================
clear_chunky:
    lea     chunky_buf,a0
    move.w  #(160*128/16)-1,d0
    moveq   #0,d1
.cc: move.l d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    dbf     d0,.cc
    rts

c2p_160x128_to_aga:
    movem.l d0-d7/a0-a5,-(sp)
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    lea     c2p_exp(pc),a5
    moveq   #127,d6
.row_lp:
    moveq   #39,d7
.col_lp:
    moveq   #0,d0
    move.b  (a0)+,d0
    move.l  (a5,d0.w*4),d1
    lsl.l   #6,d1
    move.b  (a0)+,d0
    move.l  (a5,d0.w*4),d2
    lsl.l   #4,d2
    or.l    d2,d1
    move.b  (a0)+,d0
    move.l  (a5,d0.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1
    move.b  (a0)+,d0
    or.l    (a5,d0.w*4),d1
    move.b  d1,40(a4)
    move.b  d1,(a4)+
    lsr.l   #8,d1
    move.b  d1,40(a3)
    move.b  d1,(a3)+
    lsr.l   #8,d1
    move.b  d1,40(a2)
    move.b  d1,(a2)+
    lsr.l   #8,d1
    move.b  d1,40(a1)
    move.b  d1,(a1)+
    dbf     d7,.col_lp
    lea     40(a1),a1
    lea     40(a2),a2
    lea     40(a3),a3
    lea     40(a4),a4
    dbf     d6,.row_lp
    movem.l (sp)+,d0-d7/a0-a5
    rts
draw_uv_tri:
    ; Trojkat 3D z prawdziwa tekstura UV 64x64: a4 -> 3x(sx,sy,u,v), d6=tex_id (0..3), d7=light (0..7)
    movem.l d0-d7/a0-a5,-(sp)
    move.w  d6,uv_tex
    lsl.w   #4,d7
    and.w   #7,d7
    lsl.w   #4,d7
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
.c1: cmp.w #127,d7
    ble.s   .c2
    move.w  #127,d7
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
    mulu.w  #160,d0
    add.w   d0,a2
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
.xl_ok: cmp.w #159,d1
    ble.s   .xr_ok
    move.w  #159,d1
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
    and.w   #15,d0
    move.b  (a4,d0.w),(a0)+
    add.w   d2,d4
    add.w   d3,d5
    dbf     d1,.px_lp
.ry_nx: lea 12(a1),a1
    lea     160(a2),a2
    addq.w  #1,d6
    cmp.w   d7,d6
    ble.w   .ry_lp
.uv_ex: movem.l (sp)+,d0-d7/a0-a5
    rts
scan_uv_edge:
    move.w  2(a1),d1
    move.w  2(a2),d3
    cmp.w   d1,d3
    beq.w   .se_ex
    bgt.s   .se_ok
    exg     a1,a2
    exg     d1,d3
.se_ok: move.w d3,d6
    sub.w   d1,d6
    move.w  (a2),d0
    sub.w   (a1),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.w  4(a2),d2
    sub.w   4(a1),d2
    ext.l   d2
    lsl.l   #8,d2
    divs.l  d6,d2
    move.w  6(a2),d4
    sub.w   6(a1),d4
    ext.l   d4
    lsl.l   #8,d4
    divs.l  d6,d4
    move.w  (a1),d5
    swap    d5
    move.w  #$8000,d5
    move.w  4(a1),d7
    lsl.w   #8,d7
    move.w  6(a1),a3
    move.l  a3,d6
    lsl.w   #8,d6
    lea     uv_edges(pc),a0
    move.w  d1,a4
    mulu.w  #12,d1
    add.w   d1,a0
    move.w  a4,d1
.se_lp: tst.w d1
    bmi.s   .se_st
    cmp.w   #127,d1
    bgt.w   .se_ex
    move.l  d5,a4
    swap    d5
    cmp.w   (a0),d5
    bge.s   .se_r
    move.w  d5,(a0)
    move.w  d7,4(a0)
    move.w  d6,8(a0)
.se_r: cmp.w 2(a0),d5
    ble.s   .se_s2
    move.w  d5,2(a0)
    move.w  d7,6(a0)
    move.w  d6,10(a0)
.se_s2: move.l a4,d5
.se_st: add.l d0,d5
    add.w   d2,d7
    add.w   d4,d6
    lea     12(a0),a0
    addq.w  #1,d1
    cmp.w   d3,d1
    ble.s   .se_lp
.se_ex: rts
    even
uv_tex:   dc.w 0
uv_shade: dc.w 0
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
uv_edges: ds.b 128*12
c2p_exp:
    dc.l $00000000,$03000000,$00030000,$03030000
    dc.l $00000300,$03000300,$00030300,$03030300
    dc.l $00000003,$03000003,$00030003,$03030003
    dc.l $00000303,$03000303,$00030303,$03030303
shade_lut:
    dc.b 0,1,1,1,1,2,2,2, 0,4,4,4,4,5,5,5
    dc.b 0,1,1,2,2,2,3,3, 0,4,4,5,5,5,6,6
    dc.b 0,1,2,2,3,3,3,7, 0,4,5,5,6,6,6,7
    dc.b 0,2,2,3,3,7,7,7, 0,5,5,6,6,7,7,7
    dc.b 0,2,3,3,8,8,9,9, 0,5,6,6,8,8,9,9
    dc.b 0,3,3,8,8,9,9,10, 0,6,6,8,8,9,9,10
    dc.b 0,3,8,8,9,9,10,11, 0,6,8,8,9,9,10,11
    dc.b 0,12,12,13,13,14,14,14, 0,4,5,5,6,6,15,15
    even
