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
    add.w   user_yaw(pc),d0
    add.w   user_pitch(pc),d1
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

    ; Transformacja kamery (pelna 3D cam_m00..22 lub szybka Y cam_sin/cos)
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
    sub.w   cam_oz(pc),d2
    add.w   user_zoom(pc),d2

    tst.b   cam_3d_active
    beq.s   .cam_y_only

    movem.l d4-d6/a2,-(sp)
    lea     cam_m00(pc),a2
    ; rx = (dx*cm00 + dy*cm01 + dz*cm02) >> 8
    move.w  d0,d3
    muls.w  (a2),d3
    move.w  d1,d4
    muls.w  2(a2),d4
    add.l   d4,d3
    move.w  d2,d4
    muls.w  4(a2),d4
    add.l   d4,d3
    asr.l   #8,d3                   ; d3 = rx

    ; ry = (dx*cm10 + dy*cm11 + dz*cm12) >> 8
    move.w  d0,d4
    muls.w  6(a2),d4
    move.w  d1,d5
    muls.w  8(a2),d5
    add.l   d5,d4
    move.w  d2,d5
    muls.w  10(a2),d5
    add.l   d5,d4
    asr.l   #8,d4                   ; d4 = ry

    ; rz = (dx*cm20 + dy*cm21 + dz*cm22) >> 8
    muls.w  12(a2),d0
    muls.w  14(a2),d1
    add.l   d1,d0
    muls.w  16(a2),d2
    add.l   d2,d0
    asr.l   #8,d0
    move.w  d0,d2                   ; d2 = rz
    move.w  d4,d1                   ; d1 = ry
    movem.l (sp)+,d4-d6/a2
    bra.s   .cam_done

.cam_y_only:
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
.cam_done:

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
; clear_zbuffer_v2 -> fast_clear.i (14-reg movem.l)

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
    move.l  vbl_tick(pc),d0
    lsr.l   #2,d0
    and.w   #63,d0
    add.w   d0,8(a4)
    add.w   d0,18(a4)
    add.w   d0,28(a4)
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
    cmp.w   #2048,d2
    ble.s   .dx_ok
    move.w  #2048,d2
.dx_ok:
    lea     recip_table_32(pc),a6
    move.l  (a6,d2.w*4),d2          ; d2 = 1/dx w formacie 16.16 (zero divs.l!)

    move.l  4(a0),d3                ; zl
    move.l  20(a0),d4               ; zr
    sub.l   d3,d4
    muls.l  d2,d6:d4
    move.w  d6,d4
    swap    d4
    move.l  d4,v2_dz

    move.l  8(a0),d4                ; ul
    move.l  24(a0),d5               ; ur
    sub.l   d4,d5
    muls.l  d2,d6:d5
    move.w  d6,d5
    swap    d5
    move.l  d5,v2_du

    move.l  12(a0),d5               ; vl
    move.l  28(a0),a6               ; vr
    sub.l   d5,a6
    move.l  a6,d4
    muls.l  d2,d6:d4
    move.w  d6,d4
    swap    d4
    move.l  d4,d2                   ; dv_dx -> d2

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

    movem.l a0-a1,-(sp)
    lea     (a1,d0.w),a3
    lea     (a2,d0.w*2),a6
    move.l  v2_du(pc),d7
    move.l  v2_dz(pc),a0
    move.l  d2,a1

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
    add.l   a0,d3
    add.l   d7,d4
    add.l   a1,d5
    dbf     d1,.px_lp
    movem.l (sp)+,a0-a1

.next_y:
    move.w  v2_ymax(pc),d7
    move.w  v2_cur_y(pc),d6
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
    cmp.w   #2048,d6
    ble.s   .edy_ok
    move.w  #2048,d6
.edy_ok:
    lea     recip_table_32(pc),a2
    move.l  (a2,d6.w*4),d6          ; d6 = 1/dy w 16.16 (zero divs.l!)

    move.w  (a1),d7
    sub.w   (a0),d7
    ext.l   d7
    muls.l  d6,d7                   ; dx * (1/dy) -> wynik juz w 16.16!

    move.w  4(a1),d5
    sub.w   4(a0),d5
    ext.l   d5
    muls.l  d6,d5                   ; dz * (1/dy) -> wynik juz w 16.16!

    move.w  6(a1),d4
    sub.w   6(a0),d4
    ext.l   d4
    muls.l  d6,d4                   ; du * (1/dy) -> wynik juz w 16.16!

    move.w  8(a1),d2
    sub.w   8(a0),d2
    ext.l   d2
    muls.l  d6,d2                   ; dv * (1/dy) -> wynik juz w 16.16!

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

; ----------------------------------------------------------------------------
; transform_normals_envmap
; Input: a0 = zrodlowe normalne wierzcholkow [nx.w, ny.w, nz.w] (skala 256)
;        a1 = bufor wynikowy v2_env_buf [u.b, v.b, shade.b, pad.b]
;        d7.w = liczba wierzcholkow (> 0)
; ----------------------------------------------------------------------------
transform_normals_envmap:
    movem.l d0-d7/a0-a2,-(sp)
    subq.w  #1,d7
    bmi.w   .tne_done
    lea     rot_m00(pc),a2
.tne_lp:
    move.w  (a0)+,d0                ; nx
    move.w  (a0)+,d1                ; ny
    move.w  (a0)+,d2                ; nz

    ; rx = (nx*m00 + ny*m01 + nz*m02) >> 8
    move.w  d0,d3
    muls.w  (a2),d3
    move.w  d1,-(sp)
    muls.w  2(a2),d1
    add.l   d1,d3
    move.w  d2,d1
    muls.w  4(a2),d1
    add.l   d1,d3
    asr.l   #8,d3                   ; d3 = rx
    move.w  (sp)+,d1

    ; ry = (nx*m10 + ny*m11 + nz*m12) >> 8
    move.w  d3,-(sp)                ; zachowaj rx
    move.w  d0,d3
    muls.w  6(a2),d3
    move.w  d1,-(sp)
    muls.w  8(a2),d1
    add.l   d1,d3
    move.w  d2,d1
    muls.w  10(a2),d1
    add.l   d1,d3
    asr.l   #8,d3                   ; d3 = ry
    move.w  (sp)+,d1

    ; rz = (nx*m20 + ny*m21 + nz*m22) >> 8
    muls.w  12(a2),d0
    muls.w  14(a2),d1
    add.l   d1,d0
    muls.w  16(a2),d2
    add.l   d2,d0
    asr.l   #8,d0
    move.w  d0,d2                   ; d2 = rz
    move.w  d3,d1                   ; d1 = ry
    move.w  (sp)+,d0                ; d0 = rx

    ; EnvMap U = clamp((rx >> 3) + 32, 0, 63)
    move.w  d0,d3
    asr.w   #3,d3
    add.w   #32,d3
    bpl.s   .eu_min
    moveq   #0,d3
.eu_min:
    cmp.w   #63,d3
    ble.s   .eu_max
    moveq   #63,d3
.eu_max:
    move.b  d3,(a1)+                ; u.b

    ; EnvMap V = clamp((ry >> 3) + 32, 0, 63)
    move.w  d1,d3
    asr.w   #3,d3
    add.w   #32,d3
    bpl.s   .ev_min
    moveq   #0,d3
.ev_min:
    cmp.w   #63,d3
    ble.s   .ev_max
    moveq   #63,d3
.ev_max:
    move.b  d3,(a1)+                ; v.b

    ; Oswietlenie kierunkowe N . L = (rx*lx + ry*ly + rz*lz) >> 12 + ambient(6)
    muls.w  light_vx(pc),d0
    muls.w  light_vy(pc),d1
    add.l   d1,d0
    muls.w  light_vz(pc),d2
    add.l   d2,d0
    asr.l   #8,d0
    asr.l   #4,d0
    addq.w  #6,d0
    cmp.w   #11,d0
    ble.s   .no_spec
    move.w  d0,d3
    sub.w   #11,d3
    add.w   d3,d3
    add.w   d3,d0
.no_spec:
    cmp.w   #1,d0
    bge.s   .nl_min
    moveq   #1,d0
.nl_min:
    cmp.w   #15,d0
    ble.s   .nl_max
    moveq   #15,d0
.nl_max:
    move.b  d0,(a1)+                ; shade.b
    clr.b   (a1)+                   ; pad.b

    dbf     d7,.tne_lp
.tne_done:
    movem.l (sp)+,d0-d7/a0-a2
    rts

; ----------------------------------------------------------------------------
; draw_env_mesh_v2
; Renderuje siatke 3D z Environment Mappingiem i oswietleniem N . L
; Input: a0 = siatka: [num_tris.w] + [i0.w, i1.w, i2.w, tex_id.w] (8B na trojkat)
;        a1 = v2_proj_buf [sx.w, sy.w, sz.w]
;        a2 = bank tekstur 64x64 (4096B na teksture)
;        a3 = v2_env_buf [u.b, v.b, shade.b, pad.b]
; ----------------------------------------------------------------------------
draw_env_mesh_v2:
    movem.l d0-d7/a0-a6,-(sp)
    move.w  (a0)+,d7
    subq.w  #1,d7
    bmi.w   .dem_done

.dem_lp:
    move.w  (a0)+,d4                ; i0
    move.w  (a0)+,d5                ; i1
    move.w  (a0)+,d6                ; i2

    move.w  d4,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a4            ; proj v0
    move.w  d5,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a5            ; proj v1
    move.w  d6,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a6            ; proj v2

    ; Backface culling
    move.w  (a5),d0
    sub.w   (a4),d0
    move.w  2(a6),d1
    sub.w   2(a4),d1
    muls.w  d1,d0
    move.w  2(a5),d2
    sub.w   2(a4),d2
    move.w  (a6),d3
    sub.w   (a4),d3
    muls.w  d3,d2
    sub.l   d2,d0
    ble.w   .dem_skip

    ; Wypelnij v2_tri_pkt pozycjami (sx, sy, sz)
    move.w  (a4),v2_tri_pkt
    move.w  2(a4),v2_tri_pkt+2
    move.w  4(a4),v2_tri_pkt+4
    move.w  (a5),v2_tri_pkt+10
    move.w  2(a5),v2_tri_pkt+12
    move.w  4(a5),v2_tri_pkt+14
    move.w  (a6),v2_tri_pkt+20
    move.w  2(a6),v2_tri_pkt+22
    move.w  4(a6),v2_tri_pkt+24

    ; Pobierz EnvMap (u, v) oraz srednia jasnosc N . L z 3 wierzcholkow
    moveq   #0,d3                   ; suma jasnosci
    moveq   #0,d0
    move.b  (a3,d4.w*4),d0
    move.w  d0,v2_tri_pkt+6
    move.b  1(a3,d4.w*4),d0
    move.w  d0,v2_tri_pkt+8
    move.b  2(a3,d4.w*4),d0
    add.w   d0,d3

    move.b  (a3,d5.w*4),d0
    move.w  d0,v2_tri_pkt+16
    move.b  1(a3,d5.w*4),d0
    move.w  d0,v2_tri_pkt+18
    move.b  2(a3,d5.w*4),d0
    add.w   d0,d3

    move.b  (a3,d6.w*4),d0
    move.w  d0,v2_tri_pkt+26
    move.b  1(a3,d6.w*4),d0
    move.w  d0,v2_tri_pkt+28
    move.b  2(a3,d6.w*4),d0
    add.w   d0,d3

    divs.w  #3,d3                   ; sredni poziom swiatla 0..15
    move.w  (a0)+,d1                ; tex_id
    lsl.w   #8,d1
    lsl.w   #4,d1

    movem.l d7/a0/a5,-(sp)
    lea     (a2,d1.w),a5
    lea     v2_tri_pkt,a4
    move.w  d3,d7
    bsr.w   draw_uv_z_tri
    movem.l (sp)+,d7/a0/a5

    dbf     d7,.dem_lp
    bra.s   .dem_done

.dem_skip:
    addq.l  #2,a0
    dbf     d7,.dem_lp

.dem_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

light_vx:     dc.w 110
light_vy:     dc.w -140
light_vz:     dc.w -180


v2_uv_anim_u:   dc.w 0
v2_uv_anim_v:   dc.w 0
phong_norm_lut:
    incbin  "phong_norm_lut.bin"

recip_table_32:
    incbin  "recip_table_32.bin"

shade_lut_v2:
    incbin  "shade_lut_v2.bin"

    section fastram_bss,bss_p
zbuf_3d:      ds.w 160*128
v2_edge_buf:  ds.b 128*32
v2_proj_buf:  ds.w 2048*3
v2_env_buf:   ds.l 2048

    section code,code

; ============================================================================
;  MODUL GOURAUD SHADING + ENVIRONMENT MAPPING (Krok 3)
; ============================================================================

; ----------------------------------------------------------------------------
; draw_gouraud_env_mesh_v2
; Renderuje siatke 3D z gladkim cieniowaniem Gourauda po wierzcholkach,
; Environment Mappingiem 64x64 oraz 16-bitowym Z-Bufferem.
; Input: a0 = siatka: [num_tris.w] + [i0.w, i1.w, i2.w, tex_id.w]
;        a1 = v2_proj_buf [sx.w, sy.w, sz.w]
;        a2 = bank tekstur 64x64 (4096B na teksture)
;        a3 = v2_env_buf [u.b, v.b, shade.b, pad.b]
; ----------------------------------------------------------------------------
draw_gouraud_env_mesh_v2:
    movem.l d0-d7/a0-a6,-(sp)
    move.w  (a0)+,d7
    subq.w  #1,d7
    bmi.w   .dgem_done

.dgem_lp:
    move.w  (a0)+,d4                ; i0
    move.w  (a0)+,d5                ; i1
    move.w  (a0)+,d6                ; i2

    move.w  d4,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a4            ; proj v0
    move.w  d5,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a5            ; proj v1
    move.w  d6,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a6            ; proj v2

    ; Backface culling
    move.w  (a5),d0
    sub.w   (a4),d0
    move.w  2(a6),d1
    sub.w   2(a4),d1
    muls.w  d1,d0
    move.w  2(a5),d2
    sub.w   2(a4),d2
    move.w  (a6),d3
    sub.w   (a4),d3
    muls.w  d3,d2
    sub.l   d2,d0
    ble.w   .dgem_skip

    ; Zbuduj pakiet 3 wierzcholkow po 6 slow: [sx, sy, sz, u, v, shade] + Z-Fog
    lea     v2_g_pkt,a5
    move.w  (a4),(a5)+
    move.w  2(a4),(a5)+
    move.w  4(a4),d1                ; sz0
    move.w  d1,(a5)+
    moveq   #0,d0
    move.b  (a3,d4.w*4),d0
    move.w  d0,(a5)+
    move.b  1(a3,d4.w*4),d0
    move.w  d0,(a5)+
    move.b  2(a3,d4.w*4),d0
    bsr.s   .apply_zfog
    move.w  d0,(a5)+

    move.w  d5,d0
    mulu.w  #6,d0
    lea     (a1,d0.w),a4
    move.w  (a4),(a5)+
    move.w  2(a4),(a5)+
    move.w  4(a4),d1                ; sz1
    move.w  d1,(a5)+
    moveq   #0,d0
    move.b  (a3,d5.w*4),d0
    move.w  d0,(a5)+
    move.b  1(a3,d5.w*4),d0
    move.w  d0,(a5)+
    move.b  2(a3,d5.w*4),d0
    bsr.s   .apply_zfog
    move.w  d0,(a5)+

    move.w  (a6),(a5)+
    move.w  2(a6),(a5)+
    move.w  4(a6),d1                ; sz2
    move.w  d1,(a5)+
    moveq   #0,d0
    move.b  (a3,d6.w*4),d0
    move.w  d0,(a5)+
    move.b  1(a3,d6.w*4),d0
    move.w  d0,(a5)+
    move.b  2(a3,d6.w*4),d0
    bsr.s   .apply_zfog
    move.w  d0,(a5)+

    move.w  (a0)+,d1                ; tex_id
    lsl.w   #8,d1
    lsl.w   #4,d1

    movem.l d7/a0,-(sp)
    lea     (a2,d1.w),a5
    lea     v2_g_pkt,a4
    bsr.w   draw_uv_gouraud_z_tri
    movem.l (sp)+,d7/a0

    dbf     d7,.dgem_lp
    bra.s   .dgem_done

.dgem_skip:
    addq.l  #2,a0
    dbf     d7,.dgem_lp

.dgem_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

; Z-Fog (Depth Cueing): d0.w = shade (0..15), d1.w = sz
.apply_zfog:
    tst.b   zfog_enabled(pc)
    beq.s   .zf_ret
    sub.w   zfog_start(pc),d1
    ble.s   .zf_ret
    move.w  zfog_shift(pc),d2
    asr.w   d2,d1
    sub.w   d1,d0
    cmp.w   #5,d0
    bge.s   .zf_ret
    moveq   #5,d0                   ; zachowaj nasycenie kolorow w glebi
.zf_ret:
    rts

zfog_start:   dc.w 152
zfog_shift:   dc.w 3
zfog_enabled: dc.b 1,0

; ----------------------------------------------------------------------------
; draw_uv_gouraud_z_tri (natywny bufor 160x128)
; Input: a4 -> 3 wierzcholki po 6 slow: [sx, sy, sz, u, v, shade]
;        a5 -> tekstura 64x64 chunky (4096B)
; ----------------------------------------------------------------------------
draw_uv_gouraud_z_tri:
    movem.l d0-d7/a0-a6,-(sp)
    move.l  a5,g_tex_ptr

    lea     g_verts,a0
    move.w  #17,d0
.gcp_v:
    move.w  (a4)+,(a0)+
    dbf     d0,.gcp_v

    lea     g_verts,a0
    move.w  2(a0),d6
    move.w  d6,d7
    move.w  14(a0),d0
    cmp.w   d0,d6
    ble.s   .gy1a
    move.w  d0,d6
.gy1a:
    cmp.w   d0,d7
    bge.s   .gy1b
    move.w  d0,d7
.gy1b:
    move.w  26(a0),d0
    cmp.w   d0,d6
    ble.s   .gy2a
    move.w  d0,d6
.gy2a:
    cmp.w   d0,d7
    bge.s   .gy2b
    move.w  d0,d7
.gy2b:
    tst.w   d6
    bpl.s   .gyc1
    moveq   #0,d6
.gyc1:
    cmp.w   #127,d7
    ble.s   .gyc2
    move.w  #127,d7
.gyc2:
    cmp.w   d6,d7
    ble.w   .guvz_done
    move.w  d6,g_ymin
    move.w  d6,g_cur_y
    move.w  d7,g_ymax

    ; Wyzeruj granice w v2_g_edge_buf (40 bajtow na wiersz)
    lea     v2_g_edge_buf,a1
    move.w  d6,d0
    mulu.w  #40,d0
    add.l   d0,a1
    move.w  d7,d1
    sub.w   d6,d1
    move.l  #$7fff0000,d2
    move.l  #$80010000,d3
.gie_lp:
    move.l  d2,(a1)
    move.l  d3,20(a1)
    lea     40(a1),a1
    dbf     d1,.gie_lp

    lea     g_verts,a0
    lea     12(a0),a1
    bsr.w   scan_gouraud_edge
    lea     g_verts+12,a0
    lea     12(a0),a1
    bsr.w   scan_gouraud_edge
    lea     g_verts+24,a0
    lea     g_verts,a1
    bsr.w   scan_gouraud_edge

    move.w  g_ymin(pc),d6
    move.w  g_ymax(pc),d7
    lea     v2_g_edge_buf,a0
    move.w  d6,d0
    mulu.w  #40,d0
    add.l   d0,a0

    lea     chunky_buf,a1
    lea     zbuf_3d,a2
    move.w  d6,d0
    mulu.w  #160,d0
    add.l   d0,a1
    add.l   d0,d0
    add.l   d0,a2

    move.l  g_tex_ptr(pc),a4
    lea     shade_lut_v2,a5

.gspan_y:
    move.w  (a0),d0                 ; xl
    move.w  20(a0),d1               ; xr
    cmp.w   d0,d1
    ble.w   .gnext_y

    move.w  d1,d2
    sub.w   d0,d2                   ; dx > 0
    ext.l   d2

    move.l  4(a0),d3                ; zl
    move.l  24(a0),d4               ; zr
    sub.l   d3,d4
    divs.l  d2,d4
    move.l  d4,g_dz

    move.l  8(a0),d4                ; ul
    move.l  28(a0),d5               ; ur
    sub.l   d4,d5
    divs.l  d2,d5
    move.l  d5,g_du

    move.l  12(a0),d5               ; vl
    move.l  32(a0),d6               ; vr
    sub.l   d5,d6
    divs.l  d2,d6
    move.l  d6,g_dv

    move.l  16(a0),d6               ; sl
    move.l  36(a0),d7               ; sr
    sub.l   d6,d7
    divs.l  d2,d7
    move.l  d7,g_ds

    move.l  16(a0),d2               ; cur_s (16.16)

    tst.w   d0
    bpl.s   .gxl_ok
    neg.w   d0
    ext.l   d0
    move.l  g_dz(pc),d6
    muls.l  d0,d6
    add.l   d6,d3
    move.l  g_du(pc),d6
    muls.l  d0,d6
    add.l   d6,d4
    move.l  g_dv(pc),d6
    muls.l  d0,d6
    add.l   d6,d5
    move.l  g_ds(pc),d6
    muls.l  d0,d6
    add.l   d6,d2
    moveq   #0,d0
.gxl_ok:
    cmp.w   #159,d1
    ble.s   .gxr_ok
    move.w  #159,d1
.gxr_ok:
    sub.w   d0,d1
    bmi.w   .gnext_y

    movem.l a0-a2,-(sp)
    lea     (a1,d0.w),a3
    lea     (a2,d0.w*2),a6
    move.l  g_dz(pc),d7
    move.l  g_du(pc),a0
    move.l  g_dv(pc),a1
    move.l  g_ds(pc),a2

.gpx_lp:
    move.l  d3,d0
    swap    d0
    cmp.w   (a6),d0
    bge.s   .gpx_skip
    move.w  d0,(a6)

    move.l  d5,d0
    swap    d0
    and.w   #63,d0
    lsl.w   #6,d0
    move.l  d4,d6
    swap    d6
    and.w   #63,d6
    or.w    d6,d0

    move.l  d2,d6
    swap    d6
    and.w   #$0f,d6
    lsl.w   #8,d6
    move.b  (a4,d0.w),d6
    move.b  (a5,d6.w),(a3)
.gpx_skip:
    addq.l  #1,a3
    addq.l  #2,a6
    add.l   d7,d3
    add.l   a0,d4
    add.l   a1,d5
    add.l   a2,d2
    dbf     d1,.gpx_lp
    movem.l (sp)+,a0-a2

.gnext_y:
    move.w  g_ymax(pc),d7
    move.w  g_cur_y(pc),d6
    addq.w  #1,d6
    move.w  d6,g_cur_y
    lea     40(a0),a0
    lea     160(a1),a1
    lea     320(a2),a2
    cmp.w   d7,d6
    ble.w   .gspan_y

.guvz_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts

; ----------------------------------------------------------------------------
; scan_gouraud_edge: interpoluje X, Z, U, V, S wzdluz krawedzi a0 -> a1
; ----------------------------------------------------------------------------
scan_gouraud_edge:
    movem.l d0-d7/a0-a3,-(sp)
    move.w  2(a0),d1
    move.w  2(a1),d3
    cmp.w   d1,d3
    beq.w   .gse_done
    bgt.s   .gse_ord
    exg     a0,a1
    exg     d1,d3
.gse_ord:
    move.w  d3,d6
    sub.w   d1,d6                   ; dy > 0
    ext.l   d6

    move.w  (a1),d0
    sub.w   (a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,ge_dx

    move.w  4(a1),d0
    sub.w   4(a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,ge_dz

    move.w  6(a1),d0
    sub.w   6(a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,ge_du

    move.w  8(a1),d0
    sub.w   8(a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,ge_dv

    move.w  10(a1),d0
    sub.w   10(a0),d0
    ext.l   d0
    swap    d0
    divs.l  d6,d0
    move.l  d0,ge_ds

    move.w  (a0),d4
    swap    d4
    move.w  #$8000,d4               ; cur_x
    move.w  4(a0),d5
    swap    d5
    clr.w   d5                      ; cur_z
    move.w  6(a0),d6
    swap    d6
    clr.w   d6                      ; cur_u
    move.w  8(a0),d7
    swap    d7
    clr.w   d7                      ; cur_v
    move.w  10(a0),d0
    swap    d0
    clr.w   d0                      ; cur_s

    lea     v2_g_edge_buf,a2

.gse_lp:
    cmp.w   #127,d3
    ble.s   .gse_ylim
    move.w  #127,d3
.gse_ylim:
    tst.w   d1
    bmi.s   .gse_adv
    cmp.w   d3,d1
    bgt.s   .gse_done

    move.w  d1,d2
    mulu.w  #40,d2
    lea     (a2,d2.l),a3

    move.l  d4,d2
    swap    d2
    cmp.w   (a3),d2
    bge.s   .gchk_r
    move.l  d4,(a3)
    move.l  d5,4(a3)
    move.l  d6,8(a3)
    move.l  d7,12(a3)
    move.l  d0,16(a3)
.gchk_r:
    cmp.w   20(a3),d2
    ble.s   .gse_adv
    move.l  d4,20(a3)
    move.l  d5,24(a3)
    move.l  d6,28(a3)
    move.l  d7,32(a3)
    move.l  d0,36(a3)

.gse_adv:
    add.l   ge_dx(pc),d4
    add.l   ge_dz(pc),d5
    add.l   ge_du(pc),d6
    add.l   ge_dv(pc),d7
    add.l   ge_ds(pc),d0
    addq.w  #1,d1
    cmp.w   d3,d1
    ble.s   .gse_lp

.gse_done:
    movem.l (sp)+,d0-d7/a0-a3
    rts

    even
g_tex_ptr:  dc.l 0
g_dz:       dc.l 0
g_du:       dc.l 0
g_dv:       dc.l 0
g_ds:       dc.l 0
ge_dx:      dc.l 0
ge_dz:      dc.l 0
ge_du:      dc.l 0
ge_dv:      dc.l 0
ge_ds:      dc.l 0
g_ymin:     dc.w 0
g_ymax:     dc.w 0
g_cur_y:    dc.w 0
g_verts:    ds.w 18
v2_g_pkt:   ds.w 18

    section fastram_bss,bss_p
v2_g_edge_buf: ds.b 128*40

    section code,code

; ============================================================================
;  MODUL Z-BUFFERED 3D LIGHT ORBS (draw_z_orb_v2)
; ============================================================================
; Input: d0.w = world X, d1.w = world Y, d2.w = world Z
;        d3.w = bazowy promien (np. 1100 -> ~8 px przy Z=140)
;        d4.b = indeks koloru w pal256 (np. 62 = zloty, 220 = turkusowy)
draw_z_orb_v2:
    movem.l d0-d7/a0-a4,-(sp)
    move.b  d4,orb_base_col

    ; Transformacja kamery (cam_ox, cam_oy, cam_oz, cam_sin, cam_cos)
    sub.w   cam_ox(pc),d0
    sub.w   cam_oy(pc),d1
    sub.w   cam_oz(pc),d2

    move.w  d0,d4
    muls.w  cam_cos(pc),d4
    move.w  d2,d5
    muls.w  cam_sin(pc),d5
    sub.l   d5,d4
    asr.l   #8,d4                   ; rx

    muls.w  cam_sin(pc),d0
    muls.w  cam_cos(pc),d2
    add.l   d0,d2
    asr.l   #8,d2                   ; rz

    cmp.w   #24,d2
    blt.w   .orb_done               ; za kamera -> pomin
    move.w  d2,orb_z                ; zachowaj Z do Z-Buffera

    ; Rzutowanie perspektywiczne na 160x128
    ext.l   d4
    ext.l   d1
    ext.l   d2
    muls.l  #128,d4
    muls.l  #128,d1
    divs.l  d2,d4
    divs.l  d2,d1
    add.w   #80,d4                  ; cx
    add.w   #64,d1                  ; cy
    move.w  d4,orb_cx
    move.w  d1,orb_cy

    ; Perspektywiczny promien ekranowy r = d3 / rz (clamp 2..14)
    ext.l   d3
    divs.w  orb_z(pc),d3
    cmp.w   #2,d3
    bge.s   .r_min
    moveq   #2,d3
.r_min:
    cmp.w   #14,d3
    ble.s   .r_max
    moveq   #14,d3
.r_max:
    move.w  d3,orb_r
    move.w  d3,d0
    muls.w  d0,d0
    move.w  d0,orb_r2               ; r^2 (granica poswiaty)
    lsr.w   #2,d0
    move.w  d0,orb_core_r2          ; (r/2)^2 (granica jasnego rdzenia)

    ; Przygotuj kolory: rdzen (jasnosc 15) i poswiata (jasnosc 8)
    lea     shade_lut_v2,a0
    moveq   #0,d0
    move.b  orb_base_col(pc),d0
    move.b  15*256(a0,d0.w),orb_core_col
    move.b  8*256(a0,d0.w),orb_halo_col

    ; Petla dy = -r .. +r
    move.w  orb_r(pc),d7
    neg.w   d7                      ; dy = -r
.oy_lp:
    move.w  orb_cy(pc),d5
    add.w   d7,d5                   ; py = cy + dy
    bmi.s   .oy_next
    cmp.w   #127,d5
    bgt.w   .orb_done

    move.w  d7,d4
    muls.w  d4,d4                   ; dy^2

    lea     chunky_buf,a1
    lea     zbuf_3d,a2
    move.w  d5,d0
    mulu.w  #160,d0
    add.l   d0,a1
    add.l   d0,d0
    add.l   d0,a2

    move.w  orb_r(pc),d6
    neg.w   d6                      ; dx = -r
    move.w  orb_z(pc),d3
    move.w  orb_r2(pc),d2
    move.w  orb_core_r2(pc),a3

.ox_lp:
    move.w  orb_cx(pc),d5
    add.w   d6,d5                   ; px = cx + dx
    bmi.s   .ox_next
    cmp.w   #159,d5
    bgt.s   .oy_next

    move.w  d6,d0
    muls.w  d0,d0
    add.w   d4,d0                   ; dist2 = dx^2 + dy^2
    cmp.w   d2,d0
    bgt.s   .ox_next

    ; Test 16-bitowego Z-Buffera!
    cmp.w   (a2,d5.w*2),d3
    bge.s   .ox_next
    move.w  d3,(a2,d5.w*2)

    cmp.w   a3,d0
    ble.s   .is_core
    move.b  orb_halo_col(pc),(a1,d5.w)
    bra.s   .ox_next
.is_core:
    move.b  orb_core_col(pc),(a1,d5.w)

.ox_next:
    addq.w  #1,d6
    cmp.w   orb_r(pc),d6
    ble.s   .ox_lp

.oy_next:
    addq.w  #1,d7
    cmp.w   orb_r(pc),d7
    ble.w   .oy_lp

.orb_done:
    movem.l (sp)+,d0-d7/a0-a4
    rts

    even
orb_z:        dc.w 0
orb_cx:       dc.w 0
orb_cy:       dc.w 0
orb_r:        dc.w 0
orb_r2:       dc.w 0
orb_core_r2:  dc.w 0
orb_base_col: dc.b 0
orb_core_col: dc.b 0
orb_halo_col: dc.b 0

; ============================================================================
;  MODUL PELNEJ KAMERY 3D 6DOF (Yaw / Pitch / Roll) - Krok 2
; ============================================================================
;     even
; build_cam_matrix_3d: wylicza macierz obrotu kamery cam_m00..cam_m22
; Input: d0.b = cam_yaw, d1.b = cam_pitch, d2.b = cam_roll
    even
build_cam_matrix_3d:
    movem.l d0-d7/a0-a1,-(sp)
    bsr.w   build_rot_matrix_3d
    lea     rot_m00(pc),a0
    lea     cam_m00(pc),a1
    ; Transpozycja macierzy obiektu = odwrotny obrot kamery!
    move.w  (a0),(a1)               ; cam_m00 = rot_m00
    move.w  6(a0),2(a1)             ; cam_m01 = rot_m10
    move.w  12(a0),4(a1)            ; cam_m02 = rot_m20
    move.w  2(a0),6(a1)             ; cam_m10 = rot_m01
    move.w  8(a0),8(a1)             ; cam_m11 = rot_m11
    move.w  14(a0),10(a1)           ; cam_m12 = rot_m21
    move.w  4(a0),12(a1)            ; cam_m20 = rot_m02
    move.w  10(a0),14(a1)           ; cam_m21 = rot_m12
    move.w  16(a0),16(a1)           ; cam_m22 = rot_m22
    move.b  #1,cam_3d_active
    movem.l (sp)+,d0-d7/a0-a1
    rts

    even
cam_m00: dc.w 256
cam_m01: dc.w 0
cam_m02: dc.w 0
cam_m10: dc.w 0
cam_m11: dc.w 256
cam_m12: dc.w 0
cam_m20: dc.w 0
cam_m21: dc.w 0
cam_m22: dc.w 256
cam_3d_active: dc.b 0,0

; ============================================================================
;  MODUL 3D VERTEX MORPHING (Krok 4 - Interpolacja siatek 3D na M68020)
;  Input: a0 -> mesh_A [x.w, y.w, z.w] * N
;         a1 -> mesh_B [x.w, y.w, z.w] * N
;         a2 -> out_verts [x.w, y.w, z.w] * N (w Fast RAM)
;         d0.w -> waga alpha (0 = 100% mesh_A, 256 = 100% mesh_B)
;         d7.w -> liczba wierzcholkow N
; ============================================================================
morph_verts_3d:
    movem.l d0-d7/a0-a2,-(sp)
    subq.w  #1,d7
    bmi.s   .mv_done
    move.w  #256,d6
    sub.w   d0,d6                   ; d6 = 256 - alpha (waga A), d0 = alpha (waga B)
.mv_lp:
    ; X
    move.w  (a0)+,d1
    muls.w  d6,d1
    move.w  (a1)+,d2
    muls.w  d0,d2
    add.l   d2,d1
    asr.l   #8,d1
    move.w  d1,(a2)+
    ; Y
    move.w  (a0)+,d1
    muls.w  d6,d1
    move.w  (a1)+,d2
    muls.w  d0,d2
    add.l   d2,d1
    asr.l   #8,d1
    move.w  d1,(a2)+
    ; Z
    move.w  (a0)+,d1
    muls.w  d6,d1
    move.w  (a1)+,d2
    muls.w  d0,d2
    add.l   d2,d1
    asr.l   #8,d1
    move.w  d1,(a2)+
    dbf     d7,.mv_lp
.mv_done:
    movem.l (sp)+,d0-d7/a0-a2
    rts

    section fastram_bss,bss_p
v2_morph_buf: ds.w 2048*3
    section code,code
