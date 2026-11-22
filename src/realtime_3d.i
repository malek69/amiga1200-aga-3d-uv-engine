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
    move.l  vbl_tick(pc),d7
    cmp.l   #260,d7
    blo.w   .set_tun_pal
    ; --- PALETA AKTU II: GROTA (32 kolory AGA: skaly 1..7, drewno 8..11, zloto 12..15, liscie 16..20, piasek 21..23, woda 24..28) ---
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0000,2(a1)            ; 0: czern
    move.w  #$0112,6(a1)            ; 1: gleboki cien skaly
    move.w  #$0224,10(a1)           ; 2: ciemna skala
    move.w  #$0336,14(a1)           ; 3: skala groty
    move.w  #$0458,18(a1)           ; 4: jasniejsza skala
    move.w  #$0435,22(a1)           ; 5: fioletowo-mineralna zyla
    move.w  #$0646,26(a1)           ; 6: rozswietlona mineralna skala
    move.w  #$0865,30(a1)           ; 7: cieply odblask na skale
    lea     $dff190,a1
    move.w  #$0321,(a1)+            ; 8: ciemna kora drzewa
    move.w  #$0531,(a1)+            ; 9: kora pnia
    move.w  #$0742,(a1)+            ; 10: konary drzewa
    move.w  #$0963,(a1)+            ; 11: jasna kora w swietle
    move.w  #$0a72,(a1)+            ; 12: bursztynowy blask
    move.w  #$0d93,(a1)+            ; 13: zlote swiatlo
    move.w  #$0fe5,(a1)+            ; 14: zloty swietlik #1
    move.w  #$0fff,(a1)+            ; 15: bialy rdzen
    move.w  #$0131,(a1)+            ; 16: ciemny cien pod liscmi
    move.w  #$0162,(a1)+            ; 17: lesna zielen lisci
    move.w  #$0293,(a1)+            ; 18: soczyste zielone liscie
    move.w  #$04c4,(a1)+            ; 19: jasne liscie w swietle
    move.w  #$07e6,(a1)+            ; 20: sloneczne mlode liscie
    move.w  #$0862,(a1)+            ; 21: ciemny piasek wyspy
    move.w  #$0b94,(a1)+            ; 22: zlocisty piasek wyspy
    move.w  #$0ec6,(a1)+            ; 23: jasny piasek
    move.w  #$0125,(a1)+            ; 24: gleboka woda jeziora
    move.w  #$0148,(a1)+            ; 25: woda jeziora
    move.w  #$027b,(a1)+            ; 26: falujaca woda / wodospad
    move.w  #$04ad,(a1)+            ; 27: turkusowa fala / swietlik #2
    move.w  #$07ef,(a1)+            ; 28: piana wodospadu
    move.w  #$09ef,(a1)+            ; 29: mgielka nad jeziorem
    move.w  #$0cff,(a1)+            ; 30: poswiata rusalki
    move.w  #$0fff,(a1)+            ; 31: biala rusalka
    cmp.l   #320,d7
    blo.w   act2_cavern_emerge
    bra.w   act3_360_grotto
.set_tun_pal:
    ; --- PALETA AKTU I: TUNEL 3D (granatowo-szare skaly + cieple bursztynowo-zlote swiatlo) ---
    move.l  cop_pal_ptr(pc),a1
    move.w  #$0000,2(a1)
    move.w  #$0113,6(a1)
    move.w  #$0225,10(a1)
    move.w  #$0347,14(a1)
    move.w  #$0421,18(a1)
    move.w  #$0631,22(a1)
    move.w  #$0851,26(a1)
    move.w  #$0b72,30(a1)
    lea     $dff190,a1
    move.w  #$0741,(a1)+
    move.w  #$0962,(a1)+
    move.w  #$0c83,(a1)+
    move.w  #$0fb4,(a1)+
    move.w  #$0235,(a1)+
    move.w  #$0357,(a1)+
    move.w  #$0579,(a1)+
    move.w  #$0fff,(a1)+
    bra.w   act1_round_tunnel
act2_cavern_emerge:
    ; Przejscie 260..319: Grota wylania sie z ciemnosci, oswietlana stopniowo przez oba swietliki!
    bsr.w   clear_chunky
    sub.l   #260,d7                 ; t = 0..59
    ; Jezeli t < 15 -> pelna ciemnosc po wyjsciu z tunelu
    cmp.w   #15,d7
    blo.w   .em_done
    ; Stopniowo zapalaj swiatla w grocie (najpierw same swietliki, potem coraz szersza poswiata)
    move.w  #-16,cam_oy
    move.w  #-235,cam_oz
    clr.w   cam_sin
    move.w  #256,cam_cos
    move.w  #-35,l1_x
    move.w  #-18,l1_y
    move.w  #40,l1_z
    move.w  #45,l2_x
    move.w  #-10,l2_y
    move.w  #60,l2_z
    cmp.w   #35,d7
    blo.s   .only_ff
    lea     cavern_env_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    lea     cavern_fg_mesh(pc),a4
    bsr.w   render_uv_mesh_list
    bsr.w   draw_chunky_rusalka
    bsr.w   draw_grotto_mist
.only_ff:
    move.w  l1_x(pc),d0
    move.w  l1_y(pc),d1
    move.w  l1_z(pc),d2
    bsr.w   proj_uv_160
    moveq   #14,d7
    bsr.w   draw_textured_firefly_2d
    move.w  l2_x(pc),d0
    move.w  l2_y(pc),d1
    move.w  l2_z(pc),d2
    bsr.w   proj_uv_160
    moveq   #27,d7
    bsr.w   draw_textured_firefly_2d
.em_done:
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
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
    move.w  tun_cy(pc),d0
    add.w   #16,d0
    mulu.w  #448,d0
    add.l   d0,a0
    move.w  tun_cx(pc),d0
    add.w   #16,d0
    add.w   d0,d0
    add.w   d0,a0
    lea     chunky_buf,a1
    lea     uv_tex_bank,a2
    move.w  d7,d5
    lsr.w   #1,d5
    move.w  d7,d6
    ; Plynne kolysanie kamery 3D w tunelu (cam_dx, cam_dy z sin_tab)
    lea     sin_tab,a3
    move.w  d7,d0
    add.w   d7,d0
    and.w   #$ff,d0
    move.w  (a3,d0.w*2),d1
    asr.w   #4,d1
    move.w  d1,tun_cx
    add.w   #64,d0
    and.w   #$ff,d0
    move.w  (a3,d0.w*2),d1
    asr.w   #5,d1
    move.w  d1,tun_cy
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
    moveq   #0,d4
    move.b  d0,d4
    lsl.w   #6,d4
    sub.l   d4,d1                   ; modulacja zasiegu swiatla przez nierownosci skaly!
    cmp.l   #90,d1
    bhi.s   .gl_m
    addq.b  #1,d0
    bra.s   .gl_c
.gl_m: cmp.l #220,d1
    bhi.s   .gl_f
    addq.b  #1,d0
    bra.s   .gl_c
.gl_f: cmp.l #420,d1
    bhi.s   .wr_p
    addq.b  #1,d0
.gl_c: cmp.b #10,d0
    ble.s   .wr_p
    moveq   #10,d0
.wr_p: cmp.l #225,vbl_tick
    blo.s   .no_fd
    move.l  vbl_tick(pc),d1
    sub.w   #225,d1
    lsr.w   #3,d1
    sub.b   d1,d0
    bpl.s   .no_fd
    moveq   #0,d0
.no_fd: move.b d0,(a1)+
    addq.w  #1,d2
    cmp.w   #160,d2
    blo.w   .tx
    lea     128(a0),a0
    addq.w  #1,d3
    cmp.w   #128,d3
    blo.w   .ty
    bra.s   .dn_t
.is_hole: clr.b (a1)+
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
    moveq   #14,d7
    bsr.w   draw_textured_firefly_2d
    move.w  l2_x(pc),d0
    move.w  l2_y(pc),d1
    move.w  l2_z(pc),d2
    bsr.w   proj_uv_160
    moveq   #27,d7
    bsr.w   draw_textured_firefly_2d
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
proj_uv_160:
    ; Input: d0=X, d1=Y, d2=Z -> Output: d0=sx, d1=sy (lub d0=-999 jesli za kamera Z<=40)
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
    sub.w   cam_oz(pc),d2
    cmp.w   #5,d2
    bge.s   .zo
    move.w  #-999,d0
    move.w  #-999,d1
    rts
.zo: move.w d3,d0
    ext.l   d0
    ext.l   d1
    ext.l   d2
    muls.l  #135,d0
    muls.l  #135,d1
    divs.l  d2,d0
    divs.l  d2,d1
    add.w   #80,d0
    add.w   #64,d1
    rts
act3_360_grotto:
    bsr.w   clear_chunky
    lea     sin_tab,a2
    sub.l   #320,d7
    ; Wolniejszy obrot kamery 360 st. z odleglosci 245 jednostek od wyspy
    move.w  d7,d0
    lsr.w   #2,d0
    and.w   #$ff,d0
    move.w  (a2,d0.w*2),cam_sin
    move.w  128(a2,d0.w*2),cam_cos
    clr.w   cam_ox
    move.w  #-16,cam_oy
    move.w  #-235,cam_oz
    ; Swietlik #1 (zloty z tunelu) oraz Swietlik #2 (turkusowy z groty) kraza wokol drzewa
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
    sub.w   #16,d2
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
    sub.w   #14,d2
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
    moveq   #14,d7
    bsr.w   draw_textured_firefly_2d
    move.w  l2_x(pc),d0
    move.w  l2_y(pc),d1
    move.w  l2_z(pc),d2
    bsr.w   proj_uv_160
    moveq   #27,d7
    bsr.w   draw_textured_firefly_2d
    bsr.w   c2p_160x128_to_aga
    movem.l (sp)+,d0-d7/a0-a5
    rts
render_uv_mesh_list:
    move.w  (a4)+,d4
.um_lp: move.w d4,-(sp)
    move.w  (a4)+,d6
    clr.w   uv_anim_v
    cmp.w   #6,d5
    bne.s   .no_wf
    move.l  vbl_tick(pc),d0
    neg.w   d0
    and.w   #63,d0
    move.w  d0,uv_anim_v
.no_wf:
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
    move.w  uv_anim_v(pc),(a1)+
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
    cmp.w   #-500,uv_tri
    blt.s   .skip_t
    cmp.w   #-500,uv_tri+8
    blt.s   .skip_t
    cmp.w   #-500,uv_tri+16
    blt.s   .skip_t
    move.l  a4,-(sp)
    lea     uv_tri(pc),a4
    move.w  d5,d7
    bsr.w   draw_uv_tri
    move.l  (sp)+,a4
.skip_t: move.w (sp)+,d4
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
    cmp.w   #220,d0
    bhi.s   .c2
    moveq   #7,d0
    movem.l (sp)+,d1-d5
    rts
.c2: cmp.w #220,d3
    bhi.s   .cm
    moveq   #5,d0
    movem.l (sp)+,d1-d5
    rts
.cm: cmp.w d3,d0
    ble.s   .md
    move.w  d3,d0
.md: cmp.w #340,d0
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
    move.b  d7,d2
    move.b  d2,-324(a0)
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
draw_grotto_mist:
    move.l  vbl_tick(pc),d6
    lea     mist_coords(pc),a4
    moveq   #11,d5
.gm: move.w (a4)+,d0
    move.w  (a4)+,d1
    add.w   d6,d1
    and.w   #$0f,d1
    neg.w   d1
    add.w   #46,d1
    move.w  (a4)+,d2
    bsr.w   proj_uv_160
    cmp.w   #156,d0
    bhi.s   .gn
    cmp.w   #124,d1
    bhi.s   .gn
    lea     chunky_buf,a0
    mulu.w  #160,d1
    add.w   d0,d1
    add.w   d1,a0
    move.b  #29,(a0)
    move.b  #28,1(a0)
.gn: dbf d5,.gm
    rts
    even
mist_coords: dc.w 64,0,144, 70,4,140, 76,8,136, 82,12,132, 88,2,128, 94,6,124, 100,10,120, 106,14,116, 72,3,134, 84,7,126, 96,11,122, 108,5,118
draw_chunky_rusalka:
    move.w  #-16,d0
    move.w  #26,d1
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
    lea     rusalka_seated_bmp(pc),a1
    moveq   #17,d5
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
uv_anim_v: dc.w 0
cur_v: dc.w 0
cur_dy2: dc.l 0
tun_cx: dc.w 0
tun_cy: dc.w 0
ff_sx: dc.w 80
ff_sy: dc.w 64
uv_tri: ds.w 12
rusalka_seated_bmp: dc.w $0380,$07c0,$0fe0,$0ee0,$07c0,$0380,$07c0,$0fe0,$1ff0,$1ff0,$0fe0,$0fe0,$1ff8,$3ffc,$3ffe,$1fff,$07ff,$03fe
cavern_env_mesh:
    dc.w 178
    dc.w 1,4,0,48,0,0,48,75,28,48,69
    dc.w 1,4,0,48,75,0,48,132,52,48,127
    dc.w 1,4,0,48,75,52,48,127,28,48,69
    dc.w 1,4,0,48,132,0,48,182,68,48,157
    dc.w 1,4,0,48,132,68,48,157,52,48,127
    dc.w 0,0,0,-40,182,68,-40,157,68,48,157
    dc.w 0,0,0,-40,182,68,48,157,0,48,182
    dc.w 0,0,0,-112,182,68,-112,157,68,-40,157
    dc.w 0,0,0,-112,182,68,-40,157,0,-40,182
    dc.w 0,2,0,-112,182,68,-112,157,0,-142,0
    dc.w 0,1,13,-120,113,31,-120,113,22,-68,113
    dc.w 1,4,0,48,0,28,48,69,53,48,53
    dc.w 1,4,28,48,69,52,48,127,88,48,91
    dc.w 1,4,28,48,69,88,48,91,53,48,53
    dc.w 1,4,52,48,127,68,48,157,114,48,122
    dc.w 1,4,52,48,127,114,48,122,88,48,91
    dc.w 0,0,68,-40,157,114,-40,122,114,48,122
    dc.w 0,0,68,-40,157,114,48,122,68,48,157
    dc.w 0,0,68,-112,157,114,-112,122,114,-40,122
    dc.w 0,0,68,-112,157,114,-40,122,68,-40,157
    dc.w 0,2,68,-112,157,114,-112,122,0,-142,0
    dc.w 0,1,51,-120,93,69,-120,93,60,-68,93
    dc.w 1,4,0,48,0,53,48,53,69,48,28
    dc.w 1,4,53,48,53,88,48,91,124,48,52
    dc.w 1,4,53,48,53,124,48,52,69,48,28
    dc.w 1,4,88,48,91,114,48,122,159,48,67
    dc.w 1,4,88,48,91,159,48,67,124,48,52
    dc.w 0,0,114,-40,122,159,-40,67,159,48,67
    dc.w 0,0,114,-40,122,159,48,67,114,48,122
    dc.w 0,0,114,-112,122,159,-112,67,159,-40,67
    dc.w 0,0,114,-112,122,159,-40,67,114,-40,122
    dc.w 0,2,114,-112,122,159,-112,67,0,-142,0
    dc.w 0,1,82,-120,63,100,-120,63,91,-68,63
    dc.w 1,4,0,48,0,69,48,28,75,48,0
    dc.w 1,4,69,48,28,124,48,52,136,48,0
    dc.w 1,4,69,48,28,136,48,0,75,48,0
    dc.w 1,4,124,48,52,159,48,67,175,48,0
    dc.w 1,4,124,48,52,175,48,0,136,48,0
    dc.w 0,0,159,-40,67,175,-40,0,175,48,0
    dc.w 0,0,159,-40,67,175,48,0,159,48,67
    dc.w 0,0,159,-112,67,175,-112,0,175,-40,0
    dc.w 0,0,159,-112,67,175,-40,0,159,-40,67
    dc.w 0,2,159,-112,67,175,-112,0,0,-142,0
    dc.w 0,1,102,-120,22,120,-120,22,111,-68,22
    dc.w 1,4,0,48,0,75,48,0,69,48,-28
    dc.w 1,4,75,48,0,136,48,0,112,48,-47
    dc.w 1,4,75,48,0,112,48,-47,69,48,-28
    dc.w 1,4,136,48,0,175,48,0,160,48,-68
    dc.w 1,4,136,48,0,160,48,-68,112,48,-47
    dc.w 0,0,175,-40,0,160,-40,-68,160,48,-68
    dc.w 0,0,175,-40,0,160,48,-68,175,48,0
    dc.w 0,0,175,-112,0,160,-112,-68,160,-40,-68
    dc.w 0,0,175,-112,0,160,-40,-68,175,-40,0
    dc.w 0,2,175,-112,0,160,-112,-68,0,-142,0
    dc.w 0,1,102,-120,-23,120,-120,-23,111,-68,-23
    dc.w 1,4,0,48,0,69,48,-28,53,48,-53
    dc.w 1,4,69,48,-28,112,48,-47,88,48,-92
    dc.w 1,4,69,48,-28,88,48,-92,53,48,-53
    dc.w 1,4,112,48,-47,160,48,-68,126,48,-125
    dc.w 1,4,112,48,-47,126,48,-125,88,48,-92
    dc.w 0,0,160,-40,-68,126,-40,-125,126,48,-125
    dc.w 0,0,160,-40,-68,126,48,-125,160,48,-68
    dc.w 0,0,160,-112,-68,126,-112,-125,126,-40,-125
    dc.w 0,0,160,-112,-68,126,-40,-125,160,-40,-68
    dc.w 0,2,160,-112,-68,126,-112,-125,0,-142,0
    dc.w 0,1,86,-120,-65,104,-120,-65,95,-68,-65
    dc.w 1,4,0,48,0,53,48,-53,28,48,-69
    dc.w 1,4,53,48,-53,88,48,-92,47,48,-125
    dc.w 1,4,53,48,-53,47,48,-125,28,48,-69
    dc.w 1,4,88,48,-92,126,48,-125,63,48,-161
    dc.w 1,4,88,48,-92,63,48,-161,47,48,-125
    dc.w 0,0,126,-40,-125,63,-40,-161,63,48,-161
    dc.w 0,0,126,-40,-125,63,48,-161,126,48,-125
    dc.w 0,0,126,-112,-125,63,-112,-161,63,-40,-161
    dc.w 0,0,126,-112,-125,63,-40,-161,126,-40,-125
    dc.w 0,2,126,-112,-125,63,-112,-161,0,-142,0
    dc.w 0,1,54,-120,-96,72,-120,-96,63,-68,-96
    dc.w 1,4,0,48,0,28,48,-69,0,48,-75
    dc.w 1,4,28,48,-69,47,48,-125,0,48,-137
    dc.w 1,4,28,48,-69,0,48,-137,0,48,-75
    dc.w 1,4,47,48,-125,63,48,-161,0,48,-181
    dc.w 1,4,47,48,-125,0,48,-181,0,48,-137
    dc.w 0,0,63,-40,-161,0,-40,-181,0,48,-181
    dc.w 0,0,63,-40,-161,0,48,-181,63,48,-161
    dc.w 0,0,63,-112,-161,0,-112,-181,0,-40,-181
    dc.w 0,0,63,-112,-161,0,-40,-181,63,-40,-161
    dc.w 0,2,63,-112,-161,0,-112,-181,0,-142,0
    dc.w 0,1,12,-120,-114,30,-120,-114,21,-68,-114
    dc.w 1,4,0,48,0,0,48,-75,-28,48,-69
    dc.w 1,4,0,48,-75,0,48,-137,-50,48,-118
    dc.w 1,4,0,48,-75,-50,48,-118,-28,48,-69
    dc.w 1,4,0,48,-137,0,48,-181,-67,48,-160
    dc.w 1,4,0,48,-137,-67,48,-160,-50,48,-118
    dc.w 0,0,0,-40,-181,-67,-40,-160,-67,48,-160
    dc.w 0,0,0,-40,-181,-67,48,-160,0,48,-181
    dc.w 0,0,0,-112,-181,-67,-112,-160,-67,-40,-160
    dc.w 0,0,0,-112,-181,-67,-40,-160,0,-40,-181
    dc.w 0,2,0,-112,-181,-67,-112,-160,0,-142,0
    dc.w 0,1,-32,-120,-114,-14,-120,-114,-23,-68,-114
    dc.w 1,4,0,48,0,-28,48,-69,-53,48,-53
    dc.w 1,4,-28,48,-69,-50,48,-118,-94,48,-91
    dc.w 1,4,-28,48,-69,-94,48,-91,-53,48,-53
    dc.w 1,4,-50,48,-118,-67,48,-160,-125,48,-120
    dc.w 1,4,-50,48,-118,-125,48,-120,-94,48,-91
    dc.w 0,0,-67,-40,-160,-125,-40,-120,-125,48,-120
    dc.w 0,0,-67,-40,-160,-125,48,-120,-67,48,-160
    dc.w 0,0,-67,-112,-160,-125,-112,-120,-125,-40,-120
    dc.w 0,0,-67,-112,-160,-125,-40,-120,-67,-40,-160
    dc.w 0,2,-67,-112,-160,-125,-112,-120,0,-142,0
    dc.w 0,1,-73,-120,-94,-55,-120,-94,-64,-68,-94
    dc.w 1,4,0,48,0,-53,48,-53,-69,48,-28
    dc.w 1,4,-53,48,-53,-94,48,-91,-122,48,-50
    dc.w 1,4,-53,48,-53,-122,48,-50,-69,48,-28
    dc.w 1,4,-94,48,-91,-125,48,-120,-161,48,-68
    dc.w 1,4,-94,48,-91,-161,48,-68,-122,48,-50
    dc.w 0,0,-125,-40,-120,-161,-40,-68,-161,48,-68
    dc.w 0,0,-125,-40,-120,-161,48,-68,-125,48,-120
    dc.w 0,0,-125,-112,-120,-161,-112,-68,-161,-40,-68
    dc.w 0,0,-125,-112,-120,-161,-40,-68,-125,-40,-120
    dc.w 0,2,-125,-112,-120,-161,-112,-68,0,-142,0
    dc.w 0,1,-105,-120,-63,-87,-120,-63,-96,-68,-63
    dc.w 1,4,0,48,0,-69,48,-28,-75,48,0
    dc.w 1,4,-69,48,-28,-122,48,-50,-134,48,0
    dc.w 1,4,-69,48,-28,-134,48,0,-75,48,0
    dc.w 1,4,-122,48,-50,-161,48,-68,-177,48,0
    dc.w 1,4,-122,48,-50,-177,48,0,-134,48,0
    dc.w 0,0,-161,-40,-68,-177,-40,0,-177,48,0
    dc.w 0,0,-161,-40,-68,-177,48,0,-161,48,-68
    dc.w 0,0,-161,-112,-68,-177,-112,0,-177,-40,0
    dc.w 0,0,-161,-112,-68,-177,-40,0,-161,-40,-68
    dc.w 0,2,-161,-112,-68,-177,-112,0,0,-142,0
    dc.w 0,1,-122,-120,-23,-104,-120,-23,-113,-68,-23
    dc.w 1,4,0,48,0,-75,48,0,-69,48,28
    dc.w 1,4,-75,48,0,-134,48,0,-114,48,50
    dc.w 1,4,-75,48,0,-114,48,50,-69,48,28
    dc.w 1,4,-134,48,0,-177,48,0,-164,48,61
    dc.w 1,4,-134,48,0,-164,48,61,-114,48,50
    dc.w 0,0,-177,-40,0,-164,-40,61,-164,48,61
    dc.w 0,0,-177,-40,0,-164,48,61,-177,48,0
    dc.w 0,0,-177,-112,0,-164,-112,61,-164,-40,61
    dc.w 0,0,-177,-112,0,-164,-40,61,-177,-40,0
    dc.w 0,2,-177,-112,0,-164,-112,61,0,-142,0
    dc.w 0,1,-123,-120,20,-105,-120,20,-114,-68,20
    dc.w 1,4,0,48,0,-69,48,28,-53,48,53
    dc.w 1,4,-69,48,28,-114,48,50,-87,48,92
    dc.w 1,4,-69,48,28,-87,48,92,-53,48,53
    dc.w 1,4,-114,48,50,-164,48,61,-127,48,119
    dc.w 1,4,-114,48,50,-127,48,119,-87,48,92
    dc.w 0,0,-164,-40,61,-127,-40,119,-127,48,119
    dc.w 0,0,-164,-40,61,-127,48,119,-164,48,61
    dc.w 0,0,-164,-112,61,-127,-112,119,-127,-40,119
    dc.w 0,0,-164,-112,61,-127,-40,119,-164,-40,61
    dc.w 0,2,-164,-112,61,-127,-112,119,0,-142,0
    dc.w 0,1,-106,-120,60,-88,-120,60,-97,-68,60
    dc.w 1,4,0,48,0,-53,48,53,-28,48,69
    dc.w 1,4,-53,48,53,-87,48,92,-50,48,125
    dc.w 1,4,-53,48,53,-50,48,125,-28,48,69
    dc.w 1,4,-87,48,92,-127,48,119,-63,48,150
    dc.w 1,4,-87,48,92,-63,48,150,-50,48,125
    dc.w 0,0,-127,-40,119,-63,-40,150,-63,48,150
    dc.w 0,0,-127,-40,119,-63,48,150,-127,48,119
    dc.w 0,0,-127,-112,119,-63,-112,150,-63,-40,150
    dc.w 0,0,-127,-112,119,-63,-40,150,-127,-40,119
    dc.w 0,2,-127,-112,119,-63,-112,150,0,-142,0
    dc.w 0,1,-73,-120,89,-55,-120,89,-64,-68,89
    dc.w 1,4,0,48,0,-28,48,69,0,48,75
    dc.w 1,4,-28,48,69,-50,48,125,0,48,132
    dc.w 1,4,-28,48,69,0,48,132,0,48,75
    dc.w 1,4,-50,48,125,-63,48,150,0,48,182
    dc.w 1,4,-50,48,125,0,48,182,0,48,132
    dc.w 0,0,-63,-40,150,0,-40,182,0,48,182
    dc.w 0,0,-63,-40,150,0,48,182,-63,48,150
    dc.w 0,0,-63,-112,150,0,-112,182,0,-40,182
    dc.w 0,0,-63,-112,150,0,-40,182,-63,-40,150
    dc.w 0,2,-63,-112,150,0,-112,182,0,-142,0
    dc.w 0,1,-30,-120,110,-12,-120,110,-21,-68,110
    dc.w 1,6,66,-105,148,110,-105,120,118,48,116
    dc.w 1,6,66,-105,148,118,48,116,60,48,150
    dc.w 1,6,48,44,154,128,44,110,88,32,126
cavern_fg_mesh:
    dc.w 121
    dc.w 0,7,0,48,54,38,48,38,0,32,0
    dc.w 0,5,38,48,38,54,48,0,0,32,0
    dc.w 0,5,54,48,0,38,48,-38,0,32,0
    dc.w 0,7,38,48,-38,0,48,-54,0,32,0
    dc.w 0,5,0,48,-54,-38,48,-38,0,32,0
    dc.w 0,5,-38,48,-38,-54,48,0,0,32,0
    dc.w 0,7,-54,48,0,-38,48,38,0,32,0
    dc.w 0,5,-38,48,38,0,48,54,0,32,0
    dc.w 0,3,-7,34,0,7,34,0,0,-20,0
    dc.w 0,3,0,34,-7,0,34,7,0,-20,0
    dc.w 0,3,-3,-10,0,-38,-26,16,-28,-32,12
    dc.w 0,3,3,-12,0,38,-26,-16,28,-32,-12
    dc.w 0,3,0,-12,3,0,-28,36,0,-34,26
    dc.w 0,3,0,-12,-3,0,-28,-36,0,-34,-26
    dc.w 2,7,0,-44,38,32,-44,19,0,-64,0
    dc.w 2,7,0,-44,38,32,-44,19,0,-34,0
    dc.w 2,7,32,-44,19,32,-44,-18,0,-64,0
    dc.w 2,7,32,-44,19,32,-44,-18,0,-34,0
    dc.w 2,7,32,-44,-18,0,-44,-38,0,-64,0
    dc.w 2,7,32,-44,-18,0,-44,-38,0,-34,0
    dc.w 2,7,0,-44,-38,-32,-44,-19,0,-64,0
    dc.w 2,7,0,-44,-38,-32,-44,-19,0,-34,0
    dc.w 2,7,-32,-44,-19,-32,-44,19,0,-64,0
    dc.w 2,7,-32,-44,-19,-32,-44,19,0,-34,0
    dc.w 2,7,-32,-44,19,0,-44,38,0,-64,0
    dc.w 2,7,-32,-44,19,0,-44,38,0,-34,0
    dc.w 2,7,-34,-30,42,-9,-30,28,-34,-46,14
    dc.w 2,7,-34,-30,42,-9,-30,28,-34,-22,14
    dc.w 2,7,-9,-30,28,-9,-30,0,-34,-46,14
    dc.w 2,7,-9,-30,28,-9,-30,0,-34,-22,14
    dc.w 2,7,-9,-30,0,-34,-30,-14,-34,-46,14
    dc.w 2,7,-9,-30,0,-34,-30,-14,-34,-22,14
    dc.w 2,7,-34,-30,-14,-58,-30,0,-34,-46,14
    dc.w 2,7,-34,-30,-14,-58,-30,0,-34,-22,14
    dc.w 2,7,-58,-30,0,-58,-30,28,-34,-46,14
    dc.w 2,7,-58,-30,0,-58,-30,28,-34,-22,14
    dc.w 2,7,-58,-30,28,-34,-30,42,-34,-46,14
    dc.w 2,7,-58,-30,28,-34,-30,42,-34,-22,14
    dc.w 2,7,34,-30,14,58,-30,0,34,-46,-14
    dc.w 2,7,34,-30,14,58,-30,0,34,-22,-14
    dc.w 2,7,58,-30,0,58,-30,-27,34,-46,-14
    dc.w 2,7,58,-30,0,58,-30,-27,34,-22,-14
    dc.w 2,7,58,-30,-27,34,-30,-42,34,-46,-14
    dc.w 2,7,58,-30,-27,34,-30,-42,34,-22,-14
    dc.w 2,7,34,-30,-42,9,-30,-28,34,-46,-14
    dc.w 2,7,34,-30,-42,9,-30,-28,34,-22,-14
    dc.w 2,7,9,-30,-28,9,-30,0,34,-46,-14
    dc.w 2,7,9,-30,-28,9,-30,0,34,-22,-14
    dc.w 2,7,9,-30,0,33,-30,14,34,-46,-14
    dc.w 2,7,9,-30,0,33,-30,14,34,-22,-14
    dc.w 2,7,0,-30,60,24,-30,46,0,-46,32
    dc.w 2,7,0,-30,60,24,-30,46,0,-22,32
    dc.w 2,7,24,-30,46,24,-30,18,0,-46,32
    dc.w 2,7,24,-30,46,24,-30,18,0,-22,32
    dc.w 2,7,24,-30,18,0,-30,4,0,-46,32
    dc.w 2,7,24,-30,18,0,-30,4,0,-22,32
    dc.w 2,7,0,-30,4,-24,-30,17,0,-46,32
    dc.w 2,7,0,-30,4,-24,-30,17,0,-22,32
    dc.w 2,7,-24,-30,17,-24,-30,46,0,-46,32
    dc.w 2,7,-24,-30,17,-24,-30,46,0,-22,32
    dc.w 2,7,-24,-30,46,0,-30,60,0,-46,32
    dc.w 2,7,-24,-30,46,0,-30,60,0,-22,32
    dc.w 2,7,0,-32,-4,24,-32,-17,0,-48,-32
    dc.w 2,7,0,-32,-4,24,-32,-17,0,-24,-32
    dc.w 2,7,24,-32,-17,24,-32,-45,0,-48,-32
    dc.w 2,7,24,-32,-17,24,-32,-45,0,-24,-32
    dc.w 2,7,24,-32,-45,0,-32,-60,0,-48,-32
    dc.w 2,7,24,-32,-45,0,-32,-60,0,-24,-32
    dc.w 2,7,0,-32,-60,-24,-32,-46,0,-48,-32
    dc.w 2,7,0,-32,-60,-24,-32,-46,0,-24,-32
    dc.w 2,7,-24,-32,-46,-24,-32,-17,0,-48,-32
    dc.w 2,7,-24,-32,-46,-24,-32,-17,0,-24,-32
    dc.w 2,7,-24,-32,-17,0,-32,-4,0,-48,-32
    dc.w 2,7,-24,-32,-17,0,-32,-4,0,-24,-32
    dc.w 2,7,-22,-42,5,0,-42,-7,-22,-57,-20
    dc.w 2,7,-22,-42,5,0,-42,-7,-22,-35,-20
    dc.w 2,7,0,-42,-7,0,-42,-32,-22,-57,-20
    dc.w 2,7,0,-42,-7,0,-42,-32,-22,-35,-20
    dc.w 2,7,0,-42,-32,-21,-42,-45,-22,-57,-20
    dc.w 2,7,0,-42,-32,-21,-42,-45,-22,-35,-20
    dc.w 2,7,-21,-42,-45,-43,-42,-32,-22,-57,-20
    dc.w 2,7,-21,-42,-45,-43,-42,-32,-22,-35,-20
    dc.w 2,7,-43,-42,-32,-43,-42,-7,-22,-57,-20
    dc.w 2,7,-43,-42,-32,-43,-42,-7,-22,-35,-20
    dc.w 2,7,-43,-42,-7,-22,-42,5,-22,-57,-20
    dc.w 2,7,-43,-42,-7,-22,-42,5,-22,-35,-20
    dc.w 2,7,22,-42,45,43,-42,32,22,-57,20
    dc.w 2,7,22,-42,45,43,-42,32,22,-35,20
    dc.w 2,7,43,-42,32,43,-42,7,22,-57,20
    dc.w 2,7,43,-42,32,43,-42,7,22,-35,20
    dc.w 2,7,43,-42,7,22,-42,-5,22,-57,20
    dc.w 2,7,43,-42,7,22,-42,-5,22,-35,20
    dc.w 2,7,22,-42,-5,0,-42,7,22,-57,20
    dc.w 2,7,22,-42,-5,0,-42,7,22,-35,20
    dc.w 2,7,0,-42,7,0,-42,32,22,-57,20
    dc.w 2,7,0,-42,7,0,-42,32,22,-35,20
    dc.w 2,7,0,-42,32,21,-42,45,22,-57,20
    dc.w 2,7,0,-42,32,21,-42,45,22,-35,20
    dc.w 2,7,-20,-24,0,0,-24,-10,-20,-38,-22
    dc.w 2,7,-20,-24,0,0,-24,-10,-20,-17,-22
    dc.w 2,7,0,-24,-10,0,-24,-32,-20,-38,-22
    dc.w 2,7,0,-24,-10,0,-24,-32,-20,-17,-22
    dc.w 2,7,0,-24,-32,-19,-24,-44,-20,-38,-22
    dc.w 2,7,0,-24,-32,-19,-24,-44,-20,-17,-22
    dc.w 2,7,-19,-24,-44,-39,-24,-33,-20,-38,-22
    dc.w 2,7,-19,-24,-44,-39,-24,-33,-20,-17,-22
    dc.w 2,7,-39,-24,-33,-39,-24,-10,-20,-38,-22
    dc.w 2,7,-39,-24,-33,-39,-24,-10,-20,-17,-22
    dc.w 2,7,-39,-24,-10,-20,-24,0,-20,-38,-22
    dc.w 2,7,-39,-24,-10,-20,-24,0,-20,-17,-22
    dc.w 2,7,20,-24,44,39,-24,33,20,-38,22
    dc.w 2,7,20,-24,44,39,-24,33,20,-17,22
    dc.w 2,7,39,-24,33,39,-24,11,20,-38,22
    dc.w 2,7,39,-24,33,39,-24,11,20,-17,22
    dc.w 2,7,39,-24,11,20,-24,0,20,-38,22
    dc.w 2,7,39,-24,11,20,-24,0,20,-17,22
    dc.w 2,7,20,-24,0,0,-24,10,20,-38,22
    dc.w 2,7,20,-24,0,0,-24,10,20,-17,22
    dc.w 2,7,0,-24,10,0,-24,33,20,-38,22
    dc.w 2,7,0,-24,10,0,-24,33,20,-17,22
    dc.w 2,7,0,-24,33,19,-24,44,20,-38,22
    dc.w 2,7,0,-24,33,19,-24,44,20,-17,22
tunnel_arch_mesh:
    dc.w 2
    dc.w 0,3,-150,-110,-160,-55,-110,-160,-85,55,-160
    dc.w 0,3,55,-110,-160,150,-110,-160,85,55,-160
    dc.w 0,3,-85,-110,-160,85,-110,-160,0,-52,-160
vec_frame_count: dc.w 1
    even
vec_frame_table: dc.l 0
