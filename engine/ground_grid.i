; ============================================================================
; AURA-3D AGA Engine v1.3 - 3D Perspective Textured/Checkered Floor + Z-Buffer
; ============================================================================
; Renderuje wypelniona podloge 3D na plaszczyznie Y = shadow_ground_y (62)
; metoda perspektywicznego skanowania linii (raycasting) z pelnym zapisem
; glebokosci sz do 16-bitowego Z-Buffera oraz tlumieniem mgly przy horyzoncie.
; ============================================================================

    even
draw_3d_ground_grid:
    tst.b   grid_enabled(pc)
    beq.w   .flr_ret
    movem.l d0-d7/a0-a6,-(sp)

    ; Wysokosc kamery nad podloga: h_cam = shadow_ground_y - cam_oy
    move.w  shadow_ground_y,d4
    sub.w   cam_oy,d4
    cmp.w   #8,d4
    blt.w   .flr_done                   ; kamera pod ziemia -> nie rysuj

    ; Przesuw wzdluz osi Z w rytm vbl_tick
    move.l  vbl_tick(pc),d0
    add.l   d0,d0
    move.w  d0,floor_scroll_z

    ; Pobierz obrot kamery w poziomie (cam_sin / cam_cos lub cam_m00 / cam_m02)
    tst.b   cam_3d_active
    beq.s   .use_cam_y
    move.w  cam_m00,floor_cos
    move.w  cam_m02,floor_sin
    bra.s   .cam_ready
.use_cam_y:
    move.w  cam_cos,floor_cos
    move.w  cam_sin,floor_sin
.cam_ready:

    ifd FULL_RES
    ext.l   d4
    lsl.l   #8,d4                       ; d4.l = (ground_y - cam_oy) * 256
    move.w  #130,d7
    lea     chunky_buf,a0
    lea     zbuf_3d,a1
    adda.l  #130*320,a0
    adda.l  #130*640,a1
.fy_lp:
    move.w  d7,d1
    sub.w   #128,d1
    else
    ; Skala h_cam * 128
    ext.l   d4
    lsl.l   #7,d4                       ; d4.l = (ground_y - cam_oy) * 128

    ; Skanuj wiersze ekranu ponizej horyzontu: py = 66 .. 127
    moveq   #66,d7
    lea     chunky_buf,a0
    lea     zbuf_3d,a1
    adda.l  #66*320,a0
    adda.l  #66*640,a1

.fy_lp:
    ; dy = py - 64 (>= 2)
    move.w  d7,d1
    sub.w   #64,d1
    endif

    ; Glebokosc w ukladzie kamery: rz = (h_cam * 128) / dy
    move.l  d4,d2
    divs.w  d1,d2                       ; d2.w = rz
    cmp.w   #12,d2
    blt.w   .fnext_y
    cmp.w   #1600,d2
    bgt.w   .fnext_y                    ; za daleko za horyzontem -> zostaw tlo Coppera

    ; Dobierz pare kolorow kafelkow (jasny / ciemny) zaleznie od odleglosci rz
    cmp.w   #115,d2
    bge.s   .f_col_mid
    move.b  #214,d5                     ; jasny turkusowy kafel z przodu
    move.b  #206,d6                      ; ciemny stalowy granat
    bra.s   .f_col_ok
.f_col_mid:
    cmp.w   #185,d2
    bge.s   .f_col_far
    move.b  #204,d5                     ; sredni przygaszony turkus (#478c91)
    move.b  #198,d6                     ; ciemny morski granat (#2b636c)
    bra.s   .f_col_ok
.f_col_far:
    move.b  #196,d5                     ; mgla przy horyzoncie (#20545e)
    move.b  #192,d6                     ; gleboki granat horyzontu (#08303e)
.f_col_ok:

    ; Wspolczynnik skali poziomej: step_cam = rz / 128 (8.8 fixed point = rz << 1)
    ; Dla px = 0..159: rx = ((px - 80) * rz) / 128
    ; Srodek wiersza (px = 80): rx = 0, rz_pt = rz
    ; Transformacja odwrotna kamery -> World (wx, wz):
    ;   wx0 = cam_ox + (rz * sin) >> 8
    ;   wz0 = (cam_oz - user_zoom) + (rz * cos) >> 8 + floor_scroll_z
    ;   dwx_dx = (rz * cos) >> 7   (w 8.8 fixed point = (rz * cos) >> 7)
    ;   dwz_dx = -(rz * sin) >> 7  (w 8.8 fixed point)

    move.w  d2,d0
    muls.w  floor_sin(pc),d0            ; rz * sin (8.8)
    move.l  d0,d3
    asr.l   #8,d3
    add.w   cam_ox,d3                   ; wx_center (int)
    movem.l d4/a2,-(sp)
    lea     sin_tab,a2
    move.w  d7,d4
    lsl.w   #3,d4
    add.w   floor_scroll_z(pc),d4
    add.w   floor_scroll_z(pc),d4
    and.w   #$ff,d4
    move.w  (a2,d4.w*2),d4
    asr.w   #4,d4                       ; wyraźne falowanie poziome calej tafli wody
    add.w   d4,d3
    movem.l (sp)+,d4/a2

    move.w  d2,d1
    muls.w  floor_cos(pc),d1            ; rz * cos (8.8)
    move.l  d1,a2
    asr.l   #8,d1
    add.w   cam_oz,d1
    sub.w   user_zoom,d1
    add.w   floor_scroll_z(pc),d1       ; wz_center (int)

    ; Przyrosty na 1 piksel ekranu w 8.8 fixed point:
    ; dwx = (rz * cos) >> 7
    move.l  a2,d0
    asr.l   #8,d0                       ; dwx (8.8)
    ; dwz = -(rz * sin) >> 7
    neg.l   d3                          ; uwaga: zachowaj wx_center!
    neg.l   d3                          ; przywroc wx_center
    ; Oblicz dwz z (rz * sin):
    move.w  d2,a3
    move.w  d2,-(sp)
    muls.w  floor_sin(pc),d2
    neg.l   d2
    asr.l   #8,d2                       ; d2.l = dwz (8.8)

    ; Cofnij o 80 pikseli od srodka ekranu do lewej krawedzi (px = 0):
    ; cur_wx (8.8) = (wx_center << 8) - 80 * dwx
    ext.l   d3
    lsl.l   #8,d3
    move.l  d0,a4
    muls.l  #160,d0
    sub.l   d0,d3                       ; d3.l = cur_wx (8.8)
    move.l  a4,d0                       ; d0.l = dwx (8.8)

    ; cur_wz (8.8) = (wz_center << 8) - 80 * dwz
    ext.l   d1
    lsl.l   #8,d1
    move.l  d2,a4
    muls.l  #160,d2
    sub.l   d2,d1                       ; d1.l = cur_wz (8.8)
    move.l  a4,d2                       ; d2.l = dwz (8.8)

    move.w  (sp)+,d4                    ; d4.w = rz (glebokosc Z do Z-Buffera)
    lsl.w   #4,d4                       ; 16x precyzja Z-Buffera (zgodna z aura3d_v2.i)
    addq.w  #8,d4                       ; bias Z (+8), aby cienie i odbicia lezaly na tafli
    move.w  d4,a3

    move.w  d7,-(sp)                    ; zachowaj licznik wierszy py
    move.l  a0,a4                       ; wskaznik chunky w wierszu
    move.l  a1,a5                       ; wskaznik zbuf w wierszu
    move.w  a3,a6                       ; a6.w = rz + 3
    moveq   #79,d7                      ; 80 blokow x 4 piksele = 320 px (4x mniej skokow dbf!)

    CNOP    0,4
.fx_lp:
    cmp.w   (a5)+,a6
    bge.s   .fxs0
    move.w  a6,-2(a5)
    move.l  d3,d4
    eor.l   d1,d4
    btst    #13,d4
    beq.s   .fta0
    move.b  d5,(a4)+
    bra.s   .ftn0
.fta0:
    move.b  d6,(a4)+
    bra.s   .ftn0
.fxs0:
    addq.l  #1,a4
.ftn0:
    add.l   d0,d3
    add.l   d2,d1
    cmp.w   (a5)+,a6
    bge.s   .fxs1
    move.w  a6,-2(a5)
    move.l  d3,d4
    eor.l   d1,d4
    btst    #13,d4
    beq.s   .fta1
    move.b  d5,(a4)+
    bra.s   .ftn1
.fta1:
    move.b  d6,(a4)+
    bra.s   .ftn1
.fxs1:
    addq.l  #1,a4
.ftn1:
    add.l   d0,d3
    add.l   d2,d1
    cmp.w   (a5)+,a6
    bge.s   .fxs2
    move.w  a6,-2(a5)
    move.l  d3,d4
    eor.l   d1,d4
    btst    #13,d4
    beq.s   .fta2
    move.b  d5,(a4)+
    bra.s   .ftn2
.fta2:
    move.b  d6,(a4)+
    bra.s   .ftn2
.fxs2:
    addq.l  #1,a4
.ftn2:
    add.l   d0,d3
    add.l   d2,d1
    cmp.w   (a5)+,a6
    bge.s   .fxs3
    move.w  a6,-2(a5)
    move.l  d3,d4
    eor.l   d1,d4
    btst    #13,d4
    beq.s   .fta3
    move.b  d5,(a4)+
    bra.s   .ftn3
.fta3:
    move.b  d6,(a4)+
    bra.s   .ftn3
.fxs3:
    addq.l  #1,a4
.ftn3:
    add.l   d0,d3
    add.l   d2,d1
    dbf     d7,.fx_lp
.fx_end:
    move.w  (sp)+,d7                    ; przywroc licznik wierszy py

    ; Odbuduj d4.l = (ground_y - cam_oy) * 128 dla kolejnego wiersza
    move.w  shadow_ground_y,d4
    sub.w   cam_oy,d4
    ext.l   d4
    ifd FULL_RES
    lsl.l   #8,d4
    else
    lsl.l   #7,d4
    endif

.fnext_y:
    lea     320(a0),a0
    lea     640(a1),a1
    addq.w  #1,d7
    ifd FULL_RES
    cmp.w   #256,d7
    else
    cmp.w   #128,d7
    endif
    blo.w   .fy_lp

.flr_done:
    movem.l (sp)+,d0-d7/a0-a6
.flr_ret:
    rts


; ----------------------------------------------------------------------------
; ground_fill_screen_margins - Rozciaga skrajne piksele podlogi z chunky_buf
; na 16-pikselowe (2-bajtowe) marginesy boczne oraz dolne 12 linii bitplanow
; (pelne 320x228 bez naruszania c2p_chunky.i).
; ----------------------------------------------------------------------------
ground_fill_screen_margins:
    rts

    even
floor_scroll_z: dc.w 0
floor_sin:      dc.w 0
floor_cos:      dc.w 256
grid_enabled:   dc.b 1,0
