; [EN/PL] MODULE: realtime_3d.i | Real-Time M68020 3D Matrix, Backface Culling & Flat Shading
render_realtime_3d:
    movem.l d0-d7/a0-a5,-(sp)
    move.l  vbl_tick(pc),d0
    move.w  d0,d1
    lsr.w   #8,d1
    lsr.w   #1,d1
    and.w   #3,d1
    lea     scene_palettes(pc),a0
    move.w  (a0,d1.w*8),d2
    move.l  cop_pal_ptr(pc),a1
    move.w  d2,2(a1)
    move.w  2(a0,d1.w*8),6(a1)
    move.w  4(a0,d1.w*8),10(a1)
    move.w  6(a0,d1.w*8),18(a1)
    bsr.w   update_copper_sky

    ; Wybor bryly 3D wg sceny (0/3: Szescian 3D, 1: Osmioscian 3D, 2: Krysztal 3D)
    lea     mesh_table(pc),a0
    move.l  (a0,d1.w*4),a4

    ; Kat obrotu X, Y, Z z zegara VBL 50 Hz
    move.l  vbl_tick(pc),d7
    move.w  d7,d4
    add.w   d4,d4
    and.w   #$ff,d4                 ; ax
    move.w  d7,d5
    mulu.w  #3,d5
    and.w   #$ff,d5                 ; ay
    move.w  d7,d6
    and.w   #$ff,d6                 ; az

    lea     sin_tab,a2
    move.w  (a2,d4.w*2),s_x
    move.w  128(a2,d4.w*2),c_x
    move.w  (a2,d5.w*2),s_y
    move.w  128(a2,d5.w*2),c_y
    move.w  (a2,d6.w*2),s_z
    move.w  128(a2,d6.w*2),c_z

    ; Transformacja wierzcholkow 3D -> 2D
    move.w  (a4)+,d7                ; num_verts - 1
    lea     proj_verts(pc),a3
.v_loop:
    move.w  (a4)+,d0                ; x
    move.w  (a4)+,d1                ; y
    move.w  (a4)+,d2                ; z

    ; Obrot wokol X: y1 = (y*cx - z*sx)>>8, z1 = (y*sx + z*cx)>>8
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
    move.w  d1,d2                   ; z1
    move.w  d3,d1                   ; y1

    ; Obrot wokol Y: x2 = (x*cy + z1*sy)>>8, z2 = (-x*sy + z1*cy)>>8
    move.w  d0,d3
    muls.w  c_y(pc),d3
    move.w  d2,d4
    muls.w  s_y(pc),d4
    add.l   d4,d3
    asr.l   #8,d3
    muls.w  s_y(pc),d0
    muls.w  c_y(pc),d2
    sub.l   d0,d2
    asr.l   #8,d2                   ; z2
    move.w  d3,d0                   ; x2

    ; Obrot wokol Z: x3 = (x2*cz - y1*sz)>>8, y3 = (x2*sz + y1*cz)>>8
    move.w  d0,d3
    muls.w  c_z(pc),d3
    move.w  d1,d4
    muls.w  s_z(pc),d4
    sub.l   d4,d3
    asr.l   #8,d3
    muls.w  s_z(pc),d0
    muls.w  c_z(pc),d1
    add.l   d1,d0
    asr.l   #8,d0
    move.w  d0,d1                   ; y3
    move.w  d3,d0                   ; x3

    ; Rzut perspektywiczny z pulsowaniem basu (beat_boost)
    moveq   #0,d4
    move.b  beat_boost(pc),d4
    lsl.w   #3,d4
    add.w   #270,d4
    muls.w  d4,d0
    muls.w  d4,d1
    add.w   #380,d2
    cmp.w   #160,d2
    bge.s   .z_ok
    move.w  #160,d2
.z_ok:
    ext.l   d2
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #160,d0
    add.w   #128,d1
    cmp.w   #4,d0
    bge.s   .x_lo
    moveq   #4,d0
.x_lo: cmp.w #315,d0
    ble.s   .x_hi
    move.w  #315,d0
.x_hi: cmp.w #4,d1
    bge.s   .y_lo
    moveq   #4,d1
.y_lo: cmp.w #251,d1
    ble.s   .y_hi
    move.w  #251,d1
.y_hi:
    move.w  d0,(a3)+
    move.w  d1,(a3)+
    dbf     d7,.v_loop

    ; Rysowanie widocznych scian (Backface Culling + BPL1/BPL2 Shading)
    move.w  (a4)+,d7                ; num_faces - 1
    lea     proj_verts(pc),a3
.f_loop:
    move.w  (a4)+,d0                ; plane op (0=BPL1, 2=BPL2)
    move.w  (a4)+,d6                ; num_pts
    lea     poly_tmp(pc),a1
    move.w  d6,(a1)+
    move.w  d6,d5
    subq.w  #1,d5
.cp_v:
    move.w  (a4)+,d1
    move.l  (a3,d1.w*4),(a1)+
    dbf     d5,.cp_v

    ; Test iloczynu wektorowego 2D (x1-x0)*(y2-y0) - (y1-y0)*(x2-x0)
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
    movem.l (sp)+,d0-d7/a0-a5
    rts
    even
s_x: dc.w 0
c_x: dc.w 0
s_y: dc.w 0
c_y: dc.w 0
s_z: dc.w 0
c_z: dc.w 0
proj_verts: ds.l 32
poly_tmp:   ds.w 20
scene_palettes:
    dc.w $0315,$0eee,$0f46,$0879
    dc.w $0521,$0fe2,$0fff,$0986
    dc.w $0136,$04ef,$0f38,$079b
    dc.w $0242,$08f4,$0ff4,$0795
mesh_table: dc.l mesh_cube,mesh_octa,mesh_prism,mesh_cube
mesh_cube:
    dc.w 7
    dc.w -75,-75,-75, 75,-75,-75, 75,75,-75, -75,75,-75
    dc.w -75,-75,75,  75,-75,75,  75,75,75,  -75,75,75
    dc.w 5
    dc.w 0,4, 0,1,2,3
    dc.w 2,4, 5,4,7,6
    dc.w 0,4, 4,0,3,7
    dc.w 2,4, 1,5,6,2
    dc.w 0,4, 4,5,1,0
    dc.w 2,4, 3,2,6,7
mesh_octa:
    dc.w 5
    dc.w 0,-115,0, 105,0,0, 0,0,105, -105,0,0, 0,0,-105, 0,115,0
    dc.w 7
    dc.w 0,3, 0,2,1
    dc.w 2,3, 0,3,2
    dc.w 0,3, 0,4,3
    dc.w 2,3, 0,1,4
    dc.w 2,3, 5,1,2
    dc.w 0,3, 5,2,3
    dc.w 2,3, 5,3,4
    dc.w 0,3, 5,4,1
mesh_prism:
    dc.w 7
    dc.w 0,-120,0, 95,-25,0, 0,-25,95, -95,-25,0, 0,-25,-95, 65,95,65, -65,95,65, 0,95,-85
    dc.w 9
    dc.w 2,3, 0,2,1
    dc.w 0,3, 0,3,2
    dc.w 2,3, 0,4,3
    dc.w 0,3, 0,1,4
    dc.w 0,4, 1,2,5,7
    dc.w 2,4, 2,3,6,5
    dc.w 0,4, 3,4,7,6
    dc.w 2,3, 4,1,7
    dc.w 0,3, 5,6,7
    dc.w 2,3, 1,5,7
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
