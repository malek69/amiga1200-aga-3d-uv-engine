scene_timeline_table:
    dc.l    0,350,demo_act0_v2_zbuffer
    dc.l    350,850,demo_act0b_v2_gouraud_torus
    dc.l    850,1230,demo_act1_flyin
    dc.l    830,1630,demo_act2_orbit_zsort
    dc.l    1630,$ffffffff,demo_act3_hero_closeup

demo_act1_flyin:
    bsr.w   clear_chunky
    bsr.w   draw_256_starfield
    lea     sin_tab,a2
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #-18,cam_oy
    move.w  #380,d1
    sub.w   d7,d1
    lsr.w   #1,d1
    add.w   #185,d1
    neg.w   d1
    move.w  d1,cam_oz
    bsr.w   render_zsorted_hero
    rts

demo_act2_orbit_zsort:
    bsr.w   clear_chunky
    bsr.w   draw_256_starfield
    lea     sin_tab,a2
    move.w  d7,d0
    lsr.w   #1,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #-14,cam_oy
    move.w  #-185,cam_oz
    bsr.w   render_zsorted_hero
    bsr.w   draw_orbiting_lights
    rts

demo_act3_hero_closeup:
    bsr.w   clear_chunky
    bsr.w   draw_256_starfield
    lea     sin_tab,a2
    move.w  d7,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #12,cam_oy
    move.w  #-142,cam_oz
    bsr.w   render_zsorted_hero
    bsr.w   draw_orbiting_lights
    rts

draw_256_starfield:
    lea     chunky_buf,a0
    move.l  vbl_tick(pc),d5
    lea     hero_stars(pc),a1
    moveq   #31,d6
.st_lp: move.w (a1)+,d0
    add.w   d5,d0
    and.w   #127,d0
    add.w   #16,d0
    move.w  (a1)+,d1
    mulu.w  #160,d1
    add.w   d0,d1
    move.b  #246,(a0,d1.w)
    dbf     d6,.st_lp
    rts

draw_orbiting_lights:
    lea     sin_tab,a2
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    add.w   d0,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #1,d1
    move.w  128(a2,d0.w*2),d2
    asr.w   #1,d2
    move.w  d1,d0
    move.w  #-26,d1
    bsr.w   proj_uv_160
    moveq   #62,d7
    bsr.w   draw_256_firefly
    move.l  vbl_tick(pc),d7
    move.w  d7,d0
    add.w   d0,d0
    add.w   #128,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),d1
    asr.w   #1,d1
    move.w  128(a2,d0.w*2),d2
    asr.w   #1,d2
    move.w  d1,d0
    move.w  #8,d1
    bsr.w   proj_uv_160
    move.w  #220,d7
    bsr.w   draw_256_firefly
    rts
render_zsorted_hero:
    lea     imported_mesh(pc),a4
    lea     zsort_buf(pc),a3
    move.w  (a4)+,d4
    move.w  d4,zsort_cnt
.zs_prep:
    move.l  a4,2(a3)
    move.w  4(a4),d0
    add.w   10(a4),d0
    add.w   16(a4),d0
    divs.w  #3,d0
    move.w  8(a4),d2
    add.w   14(a4),d2
    add.w   20(a4),d2
    divs.w  #3,d2
    muls.w  cam_sin(pc),d0
    muls.w  cam_cos(pc),d2
    add.l   d0,d2
    asr.l   #8,d2
    move.w  d2,(a3)
    addq.l  #6,a3
    lea     22(a4),a4
    dbf     d4,.zs_prep
    ; Szybki Shell Z-Sort O(N log N) dla 1000+ trojkatow (kroki 384, 96, 24, 6 bajtow)
    move.w  zsort_cnt(pc),d7
    mulu.w  #6,d7                   ; max_off = cnt * 6
    lea     shell_gaps(pc),a5
.sh_glp:
    move.w  (a5)+,d6                ; gap_bytes
    beq.w   .zs_draw
    move.w  d6,d5                   ; i = gap_bytes
.sh_ilp:
    cmp.w   d7,d5
    bhi.s   .sh_glp
    lea     zsort_buf(pc),a3
    move.w  (a3,d5.w),d0            ; key_z
    move.l  2(a3,d5.w),d1           ; key_ptr
    move.w  d5,d4                   ; j = i
.sh_jlp:
    cmp.w   d6,d4
    blo.s   .sh_put
    move.w  d4,d3
    sub.w   d6,d3                   ; j - gap
    move.w  (a3,d3.w),d2
    cmp.w   d0,d2
    bge.s   .sh_put
    move.w  d2,(a3,d4.w)
    move.l  2(a3,d3.w),2(a3,d4.w)
    move.w  d3,d4
    bra.s   .sh_jlp
.sh_put:
    move.w  d0,(a3,d4.w)
    move.l  d1,2(a3,d4.w)
    addq.w  #6,d5
    bra.s   .sh_ilp
.zs_draw:
    lea     zsort_buf(pc),a3
    move.w  zsort_cnt(pc),d4
.zs_dlp: move.w d4,-(sp)
    move.l  2(a3),a4
    addq.l  #6,a3
    move.l  a3,-(sp)
    move.w  (a4)+,d6                ; tex_id
    move.w  (a4)+,d5                ; low byte = bank koloru, high byte = kierunkowa jasnosc 3D (N dot L)!
    move.w  d5,d3
    lsr.w   #8,d3                   ; d3 = shade_u (0..63)
    bne.s   .has_sh
    moveq   #36,d3                  ; domyslna jasnosc dla cokolu
.has_sh:
    and.w   #$00ff,d5               ; d5 = bank palety (0, 32, 128, 160, 192)
    ; Moduluj jasnosc U lekkim obrotem swiatla wraz z kamera!
    move.w  cam_sin(pc),d0
    asr.w   #5,d0
    add.w   d0,d3
    cmp.w   #63,d3
    ble.s   .u_hi
    moveq   #63,d3
.u_hi: cmp.w #2,d3
    bge.s   .u_ok
    moveq   #2,d3
.u_ok: move.w d3,u_tmp
    lea     uv_tri(pc),a1
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    move.w  d1,v_tmp
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  u_tmp(pc),(a1)+
    move.w  v_tmp(pc),d0
    add.w   #64,d0
    and.w   #63,d0
    move.w  d0,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    move.w  d1,v_tmp
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  u_tmp(pc),(a1)+
    move.w  v_tmp(pc),d0
    add.w   #64,d0
    and.w   #63,d0
    move.w  d0,(a1)+
    move.w  (a4)+,d0
    move.w  (a4)+,d1
    move.w  (a4)+,d2
    move.w  d1,v_tmp
    bsr.w   proj_uv_160
    move.w  d0,(a1)+
    move.w  d1,(a1)+
    move.w  u_tmp(pc),(a1)+
    move.w  v_tmp(pc),d0
    add.w   #64,d0
    and.w   #63,d0
    move.w  d0,(a1)+
    cmp.w   #-500,uv_tri
    blt.s   .zs_sk
    cmp.w   #-500,uv_tri+8
    blt.s   .zs_sk
    cmp.w   #-500,uv_tri+16
    blt.s   .zs_sk
    lea     uv_tri(pc),a4
    move.w  d5,d7
    bsr.w   draw_uv_tri
.zs_sk: move.l (sp)+,a3
    move.w  (sp)+,d4
    dbf     d4,.zs_dlp
    rts
    even
u_tmp: dc.w 0
v_tmp: dc.w 0
shell_gaps: dc.w 384,96,24,6,0
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
    cmp.w   #12,d2
    bge.s   .zo
    move.w  #-999,d0
    move.w  #-999,d1
    rts
.zo: move.w d3,d0
    ext.l   d0
    ext.l   d1
    ext.l   d2
    muls.l  #140,d0
    muls.l  #140,d1
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #80,d0
    add.w   #64,d1
    rts
draw_256_firefly:
    cmp.w   #8,d0
    blo.s   .fe
    cmp.w   #151,d0
    bhi.s   .fe
    cmp.w   #8,d1
    blo.s   .fe
    cmp.w   #119,d1
    bhi.s   .fe
    lea     chunky_buf,a0
    mulu.w  #160,d1
    add.w   d0,d1
    add.w   d1,a0
    move.b  d7,d2
    move.b  d2,-324(a0)
    move.b  d2,-316(a0)
    move.b  d2,-161(a0)
    move.b  d2,-160(a0)
    move.b  d2,-159(a0)
    move.b  d2,-2(a0)
    move.b  d2,-1(a0)
    move.b  #255,(a0)
    move.b  d2,1(a0)
    move.b  d2,2(a0)
    move.b  d2,160(a0)
.fe: rts
    even
zsort_cnt: dc.w 0
zsort_buf: ds.b 1200*6
uv_tri: ds.w 12
hero_stars: dc.w 12,8,45,14,88,6,115,19,23,28,67,22,102,31,134,12,19,44,54,39,93,48,128,36,8,62,41,58,76,66,119,54,31,78,63,84,99,73,138,81,14,96,49,92,84,104,122,98,27,112,58,118,91,109,131,116,17,21,73,33,108,42,44,71
    include "imported_mesh.i"
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
