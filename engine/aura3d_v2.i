; ============================================================================
;  PLIK / FILE: aura3d_v2.i
;  OPIS: Silnik 3D v2.0 (M68020+ / AGA 256 kolorow, natywny bufor 160x128 C2P):
;        - build_rot_matrix_3d / transform_verts_3d: pelny obrot 3D (Yaw/Pitch/Roll)
;        - clear_zbuffer_v2: czyszczenie 16-bitowego Z-Buffera 160x128 (40 KB Fast RAM)
;        - draw_uv_z_tri: rasteryzator trojkatow 3D z mapowaniem UV 64x64,
;          testem glebi Z-Buffer (16-bit) i 16-poziomowym cieniowaniem AGA.
;        - draw_mesh_v2: kompletny potok renderowania siatki 3D z rzutowaniem,
;          backface cullingiem i automatycznym cieniowaniem scian.
; ============================================================================

; ----------------------------------------------------------------------------
; build_rot_matrix_3d
; Input: d0.b = yaw (Y), d1.b = pitch (X), d2.b = roll (Z)
; ----------------------------------------------------------------------------
build_rot_matrix_3d:
    movem.l d0-d7/a0,-(sp)
    lea     sin_tab,a0

    and.w   #$ff,d0
    move.w  (a0,d0.w*2),d3          ; sy = sin(yaw)
    add.w   #64,d0
    and.w   #$ff,d0
    move.w  (a0,d0.w*2),d4          ; cy = cos(yaw)

    and.w   #$ff,d1
    move.w  (a0,d1.w*2),d5          ; sx = sin(pitch)
    add.w   #64,d1
    and.w   #$ff,d1
    move.w  (a0,d1.w*2),d6          ; cx = cos(pitch)

    and.w   #$ff,d2
    move.w  (a0,d2.w*2),d7          ; sz = sin(roll)
    add.w   #64,d2
    and.w   #$ff,d2
    move.w  (a0,d2.w*2),d2          ; cz = cos(roll)

    ; m00 = cy*cz + sy*sx*sz
    move.w  d4,d0
    muls.w  d2,d0
    asr.l   #8,d0
    move.w  d3,d1
    muls.w  d5,d1
    asr.l   #8,d1
    muls.w  d7,d1
    asr.l   #8,d1
    add.w   d1,d0
    move.w  d0,rot_m00

    ; m01 = -cy*sz + sy*sx*cz
    move.w  d4,d0
    neg.w   d0
    muls.w  d7,d0
    asr.l   #8,d0
    move.w  d3,d1
    muls.w  d5,d1
    asr.l   #8,d1
    muls.w  d2,d1
    asr.l   #8,d1
    add.w   d1,d0
    move.w  d0,rot_m01

    ; m02 = sy*cx
    move.w  d3,d0
    muls.w  d6,d0
    asr.l   #8,d0
    move.w  d0,rot_m02

    ; m10 = cx*sz
    move.w  d6,d0
    muls.w  d7,d0
    asr.l   #8,d0
    move.w  d0,rot_m10

    ; m11 = cx*cz
    move.w  d6,d0
    muls.w  d2,d0
    asr.l   #8,d0
    move.w  d0,rot_m11

    ; m12 = -sx
    move.w  d5,d0
    neg.w   d0
    move.w  d0,rot_m12

    ; m20 = -sy*cz + cy*sx*sz
    move.w  d3,d0
    neg.w   d0
    muls.w  d2,d0
    asr.l   #8,d0
    move.w  d4,d1
    muls.w  d5,d1
    asr.l   #8,d1
    muls.w  d7,d1
    asr.l   #8,d1
    add.w   d1,d0
    move.w  d0,rot_m20

    ; m21 = sy*sz + cy*sx*cz
    move.w  d3,d0
    muls.w  d7,d0
    asr.l   #8,d0
    move.w  d4,d1
    muls.w  d5,d1
    asr.l   #8,d1
    muls.w  d2,d1
    asr.l   #8,d1
    add.w   d1,d0
    move.w  d0,rot_m21

    ; m22 = cy*cx
    move.w  d4,d0
    muls.w  d6,d0
    asr.l   #8,d0
    move.w  d0,rot_m22

    movem.l (sp)+,d0-d7/a0
    rts

; ----------------------------------------------------------------------------
; transform_and_project_verts
; Obraca wierzcholki obiektu macierza rot_m00..m22, przesuwa o (tx, ty, tz),
; stosuje kamere (cam_ox/oy/oz, cam_sin/cos) i rzutuje na ekran 160x128!
; Input: a0 = zrodlowe wierzcholki [x.w, y.w, z.w]
;        a1 = bufor zrzutowanych wierzcholkow [sx.w, sy.w, sz.w]
;        d7.w = liczba wierzcholkow (> 0)
;        d4.w = tx, d5.w = ty, d6.w = tz
; ----------------------------------------------------------------------------
transform_and_project_verts:
    movem.l d0-d7/a0-a2,-(sp)
    subq.w  #1,d7
    bmi.w   .tp_done
    lea     rot_m00(pc),a2
.tp_lp:
    move.w  (a0)+,d0                ; vx
    move.w  (a0)+,d1                ; vy
    move.w  (a0)+,d2                ; vz

    ; wx = (vx*m00 + vy*m01 + vz*m02) >> 8 + tx
    move.w  d0,d3
    muls.w  (a2),d3
    move.w  d1,-(sp)
    muls.w  2(a2),d1
    add.l   d1,d3
    move.w  d2,d1
    muls.w  4(a2),d1
    add.l   d1,d3
    asr.l   #8,d3
    add.w   d4,d3                   ; d3 = wx
    move.w  (sp)+,d1

    ; wy = (vx*m10 + vy*m11 + vz*m12) >> 8 + ty
    move.w  d3,-(sp)                ; zachowaj wx
    move.w  d0,d3
    muls.w  6(a2),d3
    move.w  d1,-(sp)
    muls.w  8(a2),d1
    add.l   d1,d3
    move.w  d2,d1
    muls.w  10(a2),d1
    add.l   d1,d3
    asr.l   #8,d3
    add.w   d5,d3                   ; d3 = wy
    move.w  (sp)+,d1

    ; wz = (vx*m20 + vy*m21 + vz*m22) >> 8 + tz
    muls.w  12(a2),d0
    muls.w  14(a2),d1
    add.l   d1,d0
    muls.w  16(a2),d2
    add.l   d2,d0
    asr.l   #8,d0
    add.w   d6,d0                   ; d0 = wz
    move.w  d0,d2                   ; d2 = wz
    move.w  d3,d1                   ; d1 = wy
    move.w  (sp)+,d0                ; d0 = wx

    ; Transformacja kamery (cam_ox, cam_oy, cam_oz, cam_sin, cam_cos)
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
    sub.w   cam_oz(pc),d2

    move.w  d0,d3
    muls.w  cam_cos(pc),d3
    move.l  d4,-(sp)
    move.w  d2,d4
    muls.w  cam_sin(pc),d4
    sub.l   d4,d3
    asr.l   #8,d3                   ; rx

    muls.w  cam_sin(pc),d0
    muls.w  cam_cos(pc),d2
    add.l   d0,d2
    asr.l   #8,d2                   ; rz
    move.l  (sp)+,d4

    cmp.w   #24,d2
    bge.s   .z_clip_ok
    move.w  #24,d2
.z_clip_ok:
    move.w  d2,-(sp)                ; zapisz sz (glebokosc Z do Z-Buffera)
    ext.l   d3
    ext.l   d1
    ext.l   d2
    muls.l  #128,d3
    muls.l  #128,d1
    divs.l  d2,d3
    divs.l  d2,d1
    add.w   #80,d3                  ; srodek X = 80 (ekran 160x128)
    add.w   #64,d1                  ; srodek Y = 64
    move.w  d3,(a1)+                ; sx
    move.w  d1,(a1)+                ; sy
    move.w  (sp)+,(a1)+             ; sz

    dbf     d7,.tp_lp
.tp_done:
    movem.l (sp)+,d0-d7/a0-a2
    rts

; ----------------------------------------------------------------------------
; clear_zbuffer_v2
; Czysci 16-bitowy Z-Buffer (160*128*2 = 40960 bajtow) wartoscia $7fff
; ----------------------------------------------------------------------------
clear_zbuffer_v2:
    movem.l d0-d7/a0-a1,-(sp)
    lea     zbuf_3d+40960,a0
    move.l  #$7fff7fff,d0
    move.l  d0,d1
    move.l  d0,d2
    move.l  d0,d3
    move.l  d0,d4
    move.l  d0,d5
    move.l  d0,d6
    move.l  d0,d7
    move.w  #1280-1,a1              ; 1280 * 32 bajty = 40960 B
.cz_lp:
    movem.l d0-d7,-(a0)
    subq.w  #1,a1
    cmp.w   #-1,a1
    bne.s   .cz_lp
    movem.l (sp)+,d0-d7/a0-a1
    rts

; ----------------------------------------------------------------------------
; draw_mesh_v2
; Renderuje kompletny obiekt 3D z zrzutowanych wierzcholkow (backface culling,
; automatyczne cieniowanie z normalnej 2D, tekstura UV 64x64, 16-bit Z-Buffer).
; Input: a0 = wskaznik na definicje siatki:
;             [num_tris.w]
;             dla kazdego trojkata (16 bajtow):
;             [i0.w, i1.w, i2.w, u0.b, v0.b, u1.b, v1.b, u2.b, v2.b, tex_id.w, base_shade.w]
;        a1 = bufor zrzutowanych wierzcholkow [sx.w, sy.w, sz.w]
;        a2 = bank tekstur 64x64 (kazda tekstura = 4096 bajtow)
; ----------------------------------------------------------------------------
draw_mesh_v2:
    movem.l d0-d7/a0-a6,-(sp)
    move.w  (a0)+,d7                ; liczba trojkatow
    subq.w  #1,d7
    bmi.w   .dm_done

.dm_tri_lp:
    move.w  (a0)+,d0                ; i0
    move.w  (a0)+,d1                ; i1
    move.w  (a0)+,d2                ; i2
    mulu.w  #6,d0
    mulu.w  #6,d1
    mulu.w  #6,d2
    lea     (a1,d0.w),a3            ; v0 (sx, sy, sz)
    lea     (a1,d1.w),a4            ; v1
    lea     (a1,d2.w),a5            ; v2

    ; Backface culling + pole 2D: cross = (x1-x0)*(y2-y0) - (y1-y0)*(x2-x0)
    move.w  (a4),d0
    sub.w   (a3),d0                 ; x1 - x0
    move.w  2(a5),d1
    sub.w   2(a3),d1                ; y2 - y0
    muls.w  d1,d0

    move.w  2(a4),d2
    sub.w   2(a3),d2                ; y1 - y0
    move.w  (a5),d3
    sub.w   (a3),d3                 ; x2 - x0
    muls.w  d3,d2
    sub.l   d2,d0                   ; cross <= 0 -> tylna sciana, pomin!
    ble.w   .dm_skip_tri

    ; Zbuduj pakiet 3 wierzcholkow dla draw_uv_z_tri w v2_tri_pkt
    lea     v2_tri_pkt(pc),a6
    move.w  (a3),(a6)+              ; sx0
    move.w  2(a3),(a6)+             ; sy0
    move.w  4(a3),(a6)+             ; sz0
    moveq   #0,d1
    move.b  (a0)+,d1                ; u0
    move.w  d1,(a6)+
    move.b  (a0)+,d1                ; v0
    move.w  d1,(a6)+

    move.w  (a4),(a6)+              ; sx1
    move.w  2(a4),(a6)+             ; sy1
    move.w  4(a4),(a6)+             ; sz1
    move.b  (a0)+,d1                ; u1
    move.w  d1,(a6)+
    move.b  (a0)+,d1                ; v1
    move.w  d1,(a6)+

    move.w  (a5),(a6)+              ; sx2
    move.w  2(a5),(a6)+             ; sy2
    move.w  4(a5),(a6)+             ; sz2
    move.b  (a0)+,d1                ; u2
    move.w  d1,(a6)+
    move.b  (a0)+,d1                ; v2
    move.w  d1,(a6)+

    ; Wybierz teksture (tex_id * 4096) i poziom jasnosci (4..15 wg pola widocznej sciany)
    move.w  (a0)+,d1                ; tex_id
    lsl.w   #8,d1
    lsl.w   #4,d1                   ; * 4096
    lea     (a2,d1.w),a5            ; a5 = wskaznik na teksture 64x64

    move.w  (a0)+,d2                ; base_shade
    asr.l   #6,d0                   ; skaluj pole cross na przyrost jasnosci 0..11
    cmp.l   #11,d0
    ble.s   .sh_cap
    moveq   #11,d0
.sh_cap:
    add.w   d2,d0
    cmp.w   #15,d0
    ble.s   .sh_ok
    moveq   #15,d0
.sh_ok:
    move.w  d7,-(sp)
    move.w  d0,d7                   ; poziom jasnosci 0..15
    lea     v2_tri_pkt(pc),a4
    bsr.w   draw_uv_z_tri
    move.w  (sp)+,d7

    dbf     d7,.dm_tri_lp
    bra.s   .dm_done

.dm_skip_tri:
    lea     10(a0),a0               ; pomin 6B UV + 2B tex_id + 2B base_shade
    dbf     d7,.dm_tri_lp

.dm_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

; ----------------------------------------------------------------------------
; draw_uv_z_tri (natywny bufor 160x128)
; Input: a4 -> 3 wierzcholki po 5 slow: [sx.w, sy.w, sz.w, u.w (0..63), v.w (0..63)]
;        a5 -> tekstura 64x64 chunky (4096 bajtow)
;        d7.w -> poziom oswietlenia (0..15)
; ----------------------------------------------------------------------------
draw_uv_z_tri:
    movem.l d0-d7/a0-a6,-(sp)
    move.l  a5,v2_tex_ptr
    and.w   #$0f,d7
    lsl.w   #8,d7
    lea     shade_lut_v2,a0
    add.w   d7,a0
    move.l  a0,v2_shade_ptr

    lea     v2_verts(pc),a0
    move.w  #14,d0
.cp_v:
    move.w  (a4)+,(a0)+
    dbf     d0,.cp_v

    lea     v2_verts(pc),a0
    move.w  2(a0),d6
    move.w  d6,d7
    move.w  12(a0),d0
    cmp.w   d0,d6
    ble.s   .y1a
    move.w  d0,d6
.y1a:
    cmp.w   d0,d7
    bge.s   .y1b
    move.w  d0,d7
.y1b:
    move.w  22(a0),d0
    cmp.w   d0,d6
    ble.s   .y2a
    move.w  d0,d6
.y2a:
    cmp.w   d0,d7
    bge.s   .y2b
    move.w  d0,d7
.y2b:
    tst.w   d6
    bpl.s   .yc1
    moveq   #0,d6
.yc1:
    cmp.w   #127,d7
    ble.s   .yc2
    move.w  #127,d7
.yc2:
    cmp.w   d6,d7
    ble.w   .uvz_done
    move.w  d6,v2_ymin
    move.w  d6,v2_cur_y
    move.w  d7,v2_ymax

    lea     v2_edge_buf,a1
    move.w  d6,d0
    lsl.w   #5,d0
    add.w   d0,a1
    move.w  d7,d1
    sub.w   d6,d1
    move.l  #$7fff0000,d2
    move.l  #$80010000,d3
.ie_lp:
    move.l  d2,(a1)
    move.l  d3,16(a1)
    lea     32(a1),a1
    dbf     d1,.ie_lp

    lea     v2_verts(pc),a0
    lea     10(a0),a1
    bsr.w   scan_uvz_edge
    lea     v2_verts+10(pc),a0
    lea     10(a0),a1
    bsr.w   scan_uvz_edge
    lea     v2_verts+20(pc),a0
    lea     v2_verts(pc),a1
    bsr.w   scan_uvz_edge

    move.w  v2_ymin(pc),d6
    move.w  v2_ymax(pc),d7
    lea     v2_edge_buf,a0
    move.w  d6,d0
    lsl.w   #5,d0
    add.w   d0,a0

    lea     chunky_buf,a1
    lea     zbuf_3d,a2
    move.w  d6,d0
    mulu.w  #160,d0
    add.l   d0,a1
    add.l   d0,d0
    add.l   d0,a2

    move.l  v2_tex_ptr(pc),a4
    move.l  v2_shade_ptr(pc),a5

.span_y:
    move.w  (a0),d0                 ; xl
    move.w  16(a0),d1               ; xr
    cmp.w   d0,d1
    ble.w   .next_y

    move.w  d1,d2
    sub.w   d0,d2                   ; dx > 0
    ext.l   d2

    move.l  4(a0),d3                ; zl
    move.l  20(a0),d4               ; zr
    sub.l   d3,d4
    divs.l  d2,d4
    move.l  d4,v2_dz

    move.l  8(a0),d4                ; ul
    move.l  24(a0),d5               ; ur
    sub.l   d4,d5
    divs.l  d2,d5
    move.l  d5,v2_du

    move.l  12(a0),d5               ; vl
    move.l  28(a0),a6               ; vr
    sub.l   d5,a6
    move.l  a6,d2
    move.w  d1,a6
    sub.w   d0,a6
    move.l  a6,d4
    divs.l  d4,d2                   ; dv_dx -> d2

    tst.w   d0
    bpl.s   .xl_clip_ok
    neg.w   d0
    ext.l   d0
    move.l  v2_dz(pc),d4
    muls.l  d0,d4
    add.l   d4,d3
    move.l  v2_du(pc),d4
    muls.l  d0,d4
    add.l   8(a0),d4
    move.l  d2,d6
    muls.l  d0,d6
    add.l   d6,d5
    moveq   #0,d0
    bra.s   .xr_clip
.xl_clip_ok:
    move.l  8(a0),d4
.xr_clip:
    cmp.w   #159,d1
    ble.s   .xr_clip_ok
    move.w  #159,d1
.xr_clip_ok:
    sub.w   d0,d1
    bmi.w   .next_y

    lea     (a1,d0.w),a3
    lea     (a2,d0.w*2),a6
    move.l  v2_du(pc),d7

.px_lp:
    move.l  d3,d0
    swap    d0
    cmp.w   (a6),d0
    bge.s   .px_skip
    move.w  d0,(a6)

    move.l  d5,d0
    swap    d0
    and.w   #63,d0
    lsl.w   #6,d0
    move.l  d4,d6
    swap    d6
    and.w   #63,d6
    or.w    d6,d0

    moveq   #0,d6
    move.b  (a4,d0.w),d6
    move.b  (a5,d6.w),(a3)
.px_skip:
    addq.l  #1,a3
    addq.l  #2,a6
    add.l   v2_dz(pc),d3
    add.l   d7,d4
    add.l   d2,d5
    dbf     d1,.px_lp

    move.w  v2_ymax(pc),d7
    move.w  v2_cur_y(pc),d6
.next_y:
    addq.w  #1,d6
    move.w  d6,v2_cur_y
    lea     32(a0),a0
    lea     160(a1),a1
    lea     320(a2),a2
    cmp.w   d7,d6
    ble.w   .span_y

.uvz_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

; ----------------------------------------------------------------------------
; scan_uvz_edge
; ----------------------------------------------------------------------------
scan_uvz_edge:
    movem.l d0-d7/a0-a3,-(sp)
    move.w  2(a0),d1
    move.w  2(a1),d3
    cmp.w   d1,d3
    beq.w   .se_done
    bgt.s   .se_ord
    exg     a0,a1
    exg     d1,d3
.se_ord:
    move.w  d3,d6
    sub.w   d1,d6
    ext.l   d6

    move.w  (a1),d7
    sub.w   (a0),d7
    ext.l   d7
    swap    d7
    divs.l  d6,d7

    move.w  4(a1),d5
    sub.w   4(a0),d5
    ext.l   d5
    swap    d5
    divs.l  d6,d5

    move.w  6(a1),d4
    sub.w   6(a0),d4
    ext.l   d4
    swap    d4
    divs.l  d6,d4

    move.w  8(a1),d2
    sub.w   8(a0),d2
    ext.l   d2
    swap    d2
    divs.l  d6,d2

    move.w  (a0),d0
    swap    d0
    move.w  #$8000,d0
    move.w  4(a0),d6
    swap    d6
    clr.w   d6
    move.w  6(a0),a2
    move.l  a2,d1
    swap    d1
    clr.w   d1
    move.l  d1,a3
    move.w  8(a0),a2
    move.w  2(a0),-(sp)             ; zachowaj y0 na stosie
    move.l  a2,d1
    swap    d1
    clr.w   d1
    move.l  d1,a0                   ; a0 = cur_v (16.16)
    move.w  (sp)+,d1                ; d1 = y0
    lea     v2_edge_buf,a2

.se_step:
    cmp.w   #127,d3
    ble.s   .se_ylim_ok
    move.w  #127,d3
.se_ylim_ok:
    tst.w   d1
    bmi.s   .se_adv
    cmp.w   d3,d1
    bgt.s   .se_done
    move.w  d1,-(sp)
    lsl.w   #5,d1
    lea     (a2,d1.w),a1

    move.l  d0,d1
    swap    d1
    cmp.w   (a1),d1
    bge.s   .chk_r
    move.l  d0,(a1)
    move.l  d6,4(a1)
    move.l  a3,8(a1)
    move.l  a0,12(a1)
.chk_r:
    cmp.w   16(a1),d1
    ble.s   .se_pop1
    move.l  d0,16(a1)
    move.l  d6,20(a1)
    move.l  a3,24(a1)
    move.l  a0,28(a1)
.se_pop1:
    move.w  (sp)+,d1

.se_adv:
    add.l   d7,d0
    add.l   d5,d6
    add.l   d4,a3
    add.l   d2,a0
    addq.w  #1,d1
    cmp.w   d3,d1
    ble.s   .se_step

.se_done:
    movem.l (sp)+,d0-d7/a0-a3
    rts

    even
rot_m00: dc.w 256
rot_m01: dc.w 0
rot_m02: dc.w 0
rot_m10: dc.w 0
rot_m11: dc.w 256
rot_m12: dc.w 0
rot_m20: dc.w 0
rot_m21: dc.w 0
rot_m22: dc.w 256

v2_tex_ptr:   dc.l 0
v2_shade_ptr: dc.l 0
v2_dz:        dc.l 0
v2_du:        dc.l 0
v2_ymin:      dc.w 0
v2_ymax:      dc.w 0
v2_cur_y:     dc.w 0
v2_verts:     ds.w 15
v2_tri_pkt:   ds.w 15

shade_lut_v2:
    incbin  "shade_lut_v2.bin"

    section fastram_bss,bss_p
zbuf_3d:      ds.w 160*128
v2_edge_buf:  ds.b 128*32
v2_proj_buf:  ds.w 512*3

    section code,code
