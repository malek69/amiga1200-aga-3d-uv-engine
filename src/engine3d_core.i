; ============================================================================
;  PLIK / FILE: engine3d_core.i
;  OPIS: Silnik 3D M68020:
;        - proj_3d_cam: obrot kamery 3D (sin/cos) i rzutowanie perspektywiczne.
;        - calc_dual_light: dynamiczne oswietlenie punktowe z 2 swietlikow (8 odcieni).
;        - draw_hires_tri / span_blit_32: pikselowo gladki rasteryzator trojkatow 3D
;          z teksturami wysokiej rozdzielczosci 32x32 px.
; ============================================================================
proj_3d_cam:
    ; Input: d0=X, d1=Y, d2=Z -> stosuje obrot kamery Y (cam_sin, cam_cos) i rzutuje na 320x256
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
    sub.w   cam_oz(pc),d2
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
    move.w  d3,d0
    cmp.w   #42,d2
    bge.s   .z_ok
    move.w  #42,d2
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

calc_dual_light:
    movem.l d1-d5,-(sp)
    ; Input: d0=px, d1=py, d2=pz -> Output: d0 = kolor 1..7 wg odleglosci od zlotego (light1) i turkusowego (light2) swietlika
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
    add.w   d2,d0                   ; dist1 (zloty swietlik)
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
    add.w   d5,d3                   ; dist2 (turkusowy swietlik)
    cmp.w   #165,d0
    bhi.s   .chk_l2
    moveq   #6,d0                   ; blisko zlotego swietlika -> cieple zlote swiatlo (COLOR06)
    movem.l (sp)+,d1-d5
    rts
.chk_l2: cmp.w #95,d3
    bhi.s   .chk_md
    moveq   #5,d0                   ; blisko turkusowego swietlika -> jasny turkus (COLOR05)
    movem.l (sp)+,d1-d5
    rts
.chk_md: cmp.w d3,d0
    ble.s   .min_d
    move.w  d3,d0
.min_d: cmp.w #155,d0
    bhi.s   .chk_dk
    moveq   #3,d0                   ; sredni dystans -> oswietlona skala/mech (COLOR03)
    movem.l (sp)+,d1-d5
    rts
.chk_dk: cmp.w #225,d0
    bhi.s   .is_dk
    moveq   #2,d0                   ; polcien (COLOR02)
    movem.l (sp)+,d1-d5
    rts
.is_dk: moveq #2,d0                  ; gleboki cien groty/tunelu (COLOR01)
    movem.l (sp)+,d1-d5
    rts

draw_hires_tri:
    ; Pikselowo gladki trojkat 3D z tekstura 32x32: a4 -> 3 wierzcholki (x,y,z), d6=tex_id (0..3), d7=shade (1..7)
    movem.l d0-d7/a0-a5,-(sp)
    move.w  d6,cur_tex
    move.w  d7,cur_lit
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_3d_cam
    move.w  d0,tv_x0
    move.w  d1,tv_y0
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_3d_cam
    move.w  d0,tv_x1
    move.w  d1,tv_y1
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    bsr.w   proj_3d_cam
    move.w  d0,tv_x2
    move.w  d1,tv_y2
    lea     tv_y0(pc),a0
    moveq   #2,d0
.cly: cmp.w #-16,(a0)
    bge.s   .cy_a
    move.w  #-16,(a0)
.cy_a: cmp.w #270,(a0)
    ble.s   .cy_b
    move.w  #270,(a0)
.cy_b: addq.l #4,a0
    dbf     d0,.cly
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
    lea     local_edge_buf(pc),a0
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
    bsr.w   scan_tri_edge
    move.w  tv_x1(pc),d0
    move.w  tv_y1(pc),d1
    move.w  tv_x2(pc),d2
    move.w  tv_y2(pc),d3
    bsr.w   scan_tri_edge
    move.w  tv_x2(pc),d0
    move.w  tv_y2(pc),d1
    move.w  tv_x0(pc),d2
    move.w  tv_y0(pc),d3
    bsr.w   scan_tri_edge
    lea     tex_bank(pc),a4
    move.w  cur_tex(pc),d0
    lsl.w   #7,d0                   ; 128 bajtow na teksture 32x32
    add.w   d0,a4
    move.w  tri_y0(pc),d6
    move.w  tri_y1(pc),d7
    lea     local_edge_buf(pc),a0
    lea     512(a0),a1
    move.w  d6,d0
    add.w   d0,d0
    add.w   d0,a0
    add.w   d0,a1
    move.w  d6,d0
    mulu.w  #40,d0
    move.l  d0,row_off
.ty_lp: move.w (a0)+,d0             ; dokladny piksel xl
    move.w  (a1)+,d1                ; dokladny piksel xr
    cmp.w   d0,d1
    blt.w   .ty_nx
    tst.w   d0
    bpl.s   .xl_ok
    moveq   #0,d0
.xl_ok: cmp.w #319,d1
    ble.s   .xr_ok
    move.w  #319,d1
.xr_ok: cmp.w #319,d0
    bgt.w   .ty_nx
    tst.w   d1
    bmi.w   .ty_nx
    cmp.w   d0,d1
    blt.w   .ty_nx
    ; Pobierz 32-bitowy wzor tekstury hi-res dla wiersza Y & 31 + przesuniecie parallax
    move.w  d6,d2
    add.w   tv_x0(pc),d2
    add.w   tex_scroll(pc),d2
    and.w   #31,d2
    move.l  (a4,d2.w*4),d3          ; 32-bitowy wzor tekstury
    move.w  tv_x0(pc),d4
    and.w   #31,d4
    rol.l   d4,d3                   ; dopasowanie fazy tekstury do obiektu 3D!
    move.l  d3,row_tex
    move.w  cur_lit(pc),d5
    btst    #0,d5
    beq.s   .no_b1
    move.l  draw_bpl1(pc),a2
    add.l   row_off(pc),a2
    bsr.s   span_blit_32
.no_b1: btst #1,d5
    beq.s   .no_b2
    move.l  draw_bpl2(pc),a2
    add.l   row_off(pc),a2
    bsr.s   span_blit_32
.no_b2: btst #2,d5
    beq.s   .ty_nx
    move.l  draw_bpl3(pc),a2
    add.l   row_off(pc),a2
    bsr.s   span_blit_32
.ty_nx: add.l #40,row_off
    addq.w  #1,d6
    cmp.w   d7,d6
    ble.w   .ty_lp
.t_done: movem.l (sp)+,d0-d7/a0-a5
    rts
span_blit_32:
    movem.l d0-d4,-(sp)
    move.l  row_tex(pc),d3
    moveq   #0,d2
    move.w  d0,d2
    lsr.w   #5,d2
    add.w   d2,d2
    add.w   d2,d2
    moveq   #0,d4
    move.w  d1,d4
    lsr.w   #5,d4
    add.w   d4,d4
    add.w   d4,d4
    and.w   #31,d0
    and.w   #31,d1
    cmp.w   d2,d4
    bne.s   .sp_multi
    moveq   #-1,d4
    lsr.l   d0,d4
    moveq   #-1,d0
    eor.w   #31,d1
    lsl.l   d1,d0
    and.l   d0,d4
    and.l   d3,d4
    or.l    d4,(a2,d2.w)
    movem.l (sp)+,d0-d4
    rts
.sp_multi:
    move.w  d2,-(sp)
    moveq   #-1,d2
    lsr.l   d0,d2
    and.l   d3,d2
    move.w  (sp)+,d0
    or.l    d2,(a2,d0.w)
    addq.w  #4,d0
.sp_mid: cmp.w d4,d0
    bge.s   .sp_rt
    or.l    d3,(a2,d0.w)
    addq.w  #4,d0
    bra.s   .sp_mid
.sp_rt: moveq #-1,d2
    eor.w   #31,d1
    lsl.l   d1,d2
    and.l   d3,d2
    or.l    d2,(a2,d4.w)
    movem.l (sp)+,d0-d4
    rts
scan_tri_edge: cmp.w d1,d3
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
    lea     local_edge_buf(pc),a0
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
    even
cam_ox:  dc.w 0
cam_oy:  dc.w 0
cam_oz:  dc.w 0
cam_sin: dc.w 0
cam_cos: dc.w 256
l1_x:    dc.w 0
l1_y:    dc.w 0
l1_z:    dc.w 160
l2_x:    dc.w 0
l2_y:    dc.w 0
l2_z:    dc.w 260
cur_tex: dc.w 0
cur_lit: dc.w 1
tex_scroll: dc.w 0
row_off: dc.l 0
row_tex: dc.l 0
tv_x0:   dc.w 0
tv_y0:   dc.w 0
tv_x1:   dc.w 0
tv_y1:   dc.w 0
tv_x2:   dc.w 0
tv_y2:   dc.w 0
tri_y0:  dc.w 0
tri_y1:  dc.w 0
local_edge_buf: ds.w 512
tex_bank:
    dc.l $efdffff7
    dc.l $dff7effd
    dc.l $e7f47dff
    dc.l $ffbfff9f
    dc.l $e7fdddf7
    dc.l $f7ff7dbf
    dc.l $ffffffff
    dc.l $dfdffdf3
    dc.l $f7efbfbf
    dc.l $bfffbff7
    dc.l $fff0ffff
    dc.l $bfffffff
    dc.l $df7fffff
    dc.l $ffffd7fd
    dc.l $b7eee7ff
    dc.l $dd9defff
    dc.l $7ffbfdf7
    dc.l $ff5daefd
    dc.l $b7fffbbf
    dc.l $effff5ff
    dc.l $f73d9bff
    dc.l $df7ffff7
    dc.l $f6ba6ffe
    dc.l $ef5ffddf
    dc.l $bbbfffff
    dc.l $bffebdbe
    dc.l $bafffed9
    dc.l $feff77ff
    dc.l $fffcffff
    dc.l $f7fb7f7f
    dc.l $bfffffbf
    dc.l $fffdbf0f
    dc.l $77dd77dd
    dc.l $ffdfffdf
    dc.l $fbfffbff
    dc.l $bbeebbee
    dc.l $ffefffef
    dc.l $fdfffdff
    dc.l $5df75df7
    dc.l $fff7fff7
    dc.l $fefffeff
    dc.l $aefbaefb
    dc.l $fffbfffb
    dc.l $ff7fff7f
    dc.l $d77dd77d
    dc.l $fffdfffd
    dc.l $ffbfffbf
    dc.l $ebbeebbe
    dc.l $fffefffe
    dc.l $ffdfffdf
    dc.l $75df75df
    dc.l $7fff7fff
    dc.l $ffefffef
    dc.l $baefbaef
    dc.l $bfffbfff
    dc.l $fff7fff7
    dc.l $dd77dd77
    dc.l $dfffdfff
    dc.l $fffbfffb
    dc.l $eebbeebb
    dc.l $efffefff
    dc.l $fffdfffd
    dc.l $f75df75d
    dc.l $f7fff7ff
    dc.l $e79227ff
    dc.l $aebfcf70
    dc.l $eb8bebbb
    dc.l $eb93ed8c
    dc.l $6724fcef
    dc.l $cfbd26ad
    dc.l $edbfee79
    dc.l $bf63d60f
    dc.l $0d976786
    dc.l $cbcbeb9d
    dc.l $e7bb4516
    dc.l $fb9c64f9
    dc.l $696eef9c
    dc.l $efbeee95
    dc.l $eff5e637
    dc.l $eebf8bbf
    dc.l $ef97c3bd
    dc.l $593df3ff
    dc.l $c7bbcf9f
    dc.l $cf7e6eb7
    dc.l $6b24ef9f
    dc.l $5e2a4a95
    dc.l $b71f6f3c
    dc.l $f6aaee9f
    dc.l $eb3e2bbd
    dc.l $7cbcfa9f
    dc.l $fd3d7faf
    dc.l $ef8ccbad
    dc.l $e6adc5bf
    dc.l $a7b7273d
    dc.l $e6f7ed3e
    dc.l $a98b6faf
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
    dc.l $ffffffff
