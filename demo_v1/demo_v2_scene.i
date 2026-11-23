demo_act0_v2_zbuffer:
    jsr     clear_chunky
    jsr     clear_zbuffer_v2
    jsr     draw_256_starfield

    clr.w   cam_ox
    clr.w   cam_oy
    move.w  #-150,cam_oz
    move.w  #0,cam_sin
    move.w  #256,cam_cos

    move.w  d7,d0
    move.w  d7,d1
    lsr.w   #1,d1
    move.w  d7,d2
    lsr.w   #2,d2
    jsr     build_rot_matrix_3d

    lea     v2_octa_verts(pc),a0
    lea     v2_proj_buf,a1
    moveq   #6,d7
    moveq   #0,d4
    moveq   #0,d5
    moveq   #0,d6
    jsr     transform_and_project_verts

    lea     v2_octa_mesh(pc),a0
    lea     v2_proj_buf,a1
    lea     v2_tex_bank,a2
    jsr     draw_mesh_v2

    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    add.w   d0,d0
    move.w  d7,d1
    move.w  d7,d2
    neg.w   d2
    jsr     build_rot_matrix_3d

    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d4
    asr.w   #3,d4
    move.w  128(a2,d0.w*2),d6
    asr.w   #3,d6
    moveq   #0,d5

    lea     v2_cube_verts(pc),a0
    lea     v2_proj_buf,a1
    moveq   #8,d7
    jsr     transform_and_project_verts

    lea     v2_cube_mesh(pc),a0
    lea     v2_proj_buf,a1
    lea     v2_tex_bank,a2
    jsr     draw_mesh_v2
    rts

    even
v2_cube_verts:
    dc.w    -34,-34,-34
    dc.w     34,-34,-34
    dc.w     34, 34,-34
    dc.w    -34, 34,-34
    dc.w    -34,-34, 34
    dc.w     34,-34, 34
    dc.w     34, 34, 34
    dc.w    -34, 34, 34

v2_cube_mesh:
    dc.w    12
    dc.w    0,3,2
    dc.b    0,0, 0,63, 63,63
    dc.w    0,5
    dc.w    0,2,1
    dc.b    0,0, 63,63, 63,0
    dc.w    0,5
    dc.w    5,6,7
    dc.b    0,0, 0,63, 63,63
    dc.w    0,5
    dc.w    5,7,4
    dc.b    0,0, 63,63, 63,0
    dc.w    0,5
    dc.w    4,7,3
    dc.b    0,0, 0,63, 63,63
    dc.w    1,5
    dc.w    4,3,0
    dc.b    0,0, 63,63, 63,0
    dc.w    1,5
    dc.w    1,2,6
    dc.b    0,0, 0,63, 63,63
    dc.w    1,5
    dc.w    1,6,5
    dc.b    0,0, 63,63, 63,0
    dc.w    1,5
    dc.w    4,0,1
    dc.b    0,0, 0,63, 63,63
    dc.w    0,6
    dc.w    4,1,5
    dc.b    0,0, 63,63, 63,0
    dc.w    0,6
    dc.w    3,7,6
    dc.b    0,0, 0,63, 63,63
    dc.w    0,4
    dc.w    3,6,2
    dc.b    0,0, 63,63, 63,0
    dc.w    0,4

v2_octa_verts:
    dc.w     0,-54,  0
    dc.w     0, 54,  0
    dc.w   -50,  0,  0
    dc.w    50,  0,  0
    dc.w     0,  0,-50
    dc.w     0,  0, 50

v2_octa_mesh:
    dc.w    8
    dc.w    0,2,4
    dc.b    32,0, 0,63, 63,63
    dc.w    1,6
    dc.w    0,4,3
    dc.b    32,0, 0,63, 63,63
    dc.w    1,6
    dc.w    0,3,5
    dc.b    32,0, 0,63, 63,63
    dc.w    1,6
    dc.w    0,5,2
    dc.b    32,0, 0,63, 63,63
    dc.w    1,6
    dc.w    1,4,2
    dc.b    32,63, 63,0, 0,0
    dc.w    1,5
    dc.w    1,3,4
    dc.b    32,63, 63,0, 0,0
    dc.w    1,5
    dc.w    1,5,3
    dc.b    32,63, 63,0, 0,0
    dc.w    1,5
    dc.w    1,2,5
    dc.b    32,63, 63,0, 0,0
    dc.w    1,5

v2_tex_bank:
    incbin  "v2_textures.bin"

demo_act0b_v2_gouraud_torus:
    jsr     clear_chunky
    jsr     clear_zbuffer_v2
    jsr     draw_256_starfield

    clr.w   cam_ox
    clr.w   cam_oy
    move.w  #-145,cam_oz
    move.w  #0,cam_sin
    move.w  #256,cam_cos

    ; Orbitujace zrodlo swiatla 3D dla Gourauda
    lea     sin_tab,a2
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #1,d1
    move.w  d1,light_vx
    move.w  128(a2,d0.w*2),d1
    asr.w   #1,d1
    neg.w   d1
    move.w  d1,light_vz
    move.w  #-120,light_vy

    ; Obrot Torusa 3D w 3 osiach
    move.w  d7,d0
    move.w  d7,d1
    lsr.w   #1,d1
    add.w   #32,d1
    move.w  d7,d2
    lsr.w   #2,d2
    jsr     build_rot_matrix_3d

    lea     torus3d_verts,a0
    lea     v2_proj_buf,a1
    move.w  #torus3d_vert_count,d7
    moveq   #0,d4
    moveq   #0,d5
    moveq   #0,d6
    jsr     transform_and_project_verts

    lea     torus3d_norms,a0
    lea     v2_env_buf,a1
    move.w  #torus3d_vert_count,d7
    jsr     transform_normals_envmap

    lea     torus3d_env_mesh,a0
    lea     v2_proj_buf,a1
    lea     v2_chrome_bank,a2
    lea     v2_env_buf,a3
    jsr     draw_gouraud_env_mesh_v2
    rts

    include "torus_mesh.i"
    even
v2_chrome_bank:
    incbin  "chrome_tex.bin"
