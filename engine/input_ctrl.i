; ============================================================================
; AURA-3D AGA Engine v1.14 - Kontroler Joysticka (Port 2) i Klawiatury CIA-A
; ============================================================================

    even
input_update_controls:
    movem.l d0-d3,-(sp)

    ; 1. Odczyt Joysticka w Porcie 2 ($DFF00C = JOY1DAT, Fire = bit 7 $BFE001)
    move.w  $dff00c,d0
    move.w  d0,d1
    lsr.w   #1,d1
    eor.w   d0,d1

    btst    #7,$bfe001
    bne.s   .joy_normal

    btst    #8,d1
    beq.s   .jf_no_up
    subq.w  #3,user_zoom
.jf_no_up:
    btst    #0,d1
    beq.s   .joy_lr
    addq.w  #3,user_zoom
    bra.s   .joy_lr

.joy_normal:
    btst    #8,d1
    beq.s   .jn_no_up
    subq.w  #2,user_pitch
.jn_no_up:
    btst    #0,d1
    beq.s   .joy_lr
    addq.w  #2,user_pitch

.joy_lr:
    btst    #9,d0
    beq.s   .j_no_left
    subq.w  #2,user_yaw
.j_no_left:
    btst    #1,d0
    beq.s   .read_kbd
    addq.w  #2,user_yaw

    ; 2. Odczyt klawiatury z CIA-A ($BFED01 ICR + $BFEC01 SDR)
.read_kbd:
    move.b  $bfec01,d0
    cmp.b   kbd_last_sdr(pc),d0
    beq.w   .held_keys
    move.b  d0,kbd_last_sdr
    ; Wyslij impuls potwierdzenia ACK do klawiatury (SPMODE=1 przez ~85 us)
    or.b    #$40,$bfee01
    move.b  $dff006,d1
.ack1:
    cmp.b   $dff006,d1
    beq.s   .ack1
    move.b  $dff006,d1
.ack2:
    cmp.b   $dff006,d1
    beq.s   .ack2
    and.b   #$bf,$bfee01

    ; Dekoduj surowy skankod Amigi: not.b d0 -> bit 0 = 0 (wcisniety) / 1 (puszczony), bity 7..1 = rawkey
    not.b   d0
    lsr.b   #1,d0                       ; Carry = 1 jesli puszczony (key-up), d0 = czysty rawkey ($00..$7f)
    bcs.w   .key_up

    move.b  d0,kbd_held_raw

    ; Obsluga klawiszy jednorazowych (wyzwolenie przy kazdym wcisnieciu!):
    cmp.b   #$25,d0                     ; H = pokaz / ukryj panel pomocy (HELP)
    bne.s   .n_h
    eor.b   #1,keymap_visible
    bra.w   .held_keys
.n_h:
    cmp.b   #$28,d0                     ; L = przelacznik jezyka PL <-> ENG (Help + Info)
    bne.s   .n_l
    eor.b   #1,hud_lang
    bra.w   .held_keys
.n_l:
    cmp.b   #$27,d0                     ; K = wlacz / wylacz flary soczewkowe 3D
    bne.s   .n_k
    eor.b   #1,flare_enabled
    bra.w   .held_keys
.n_k:
    cmp.b   #$17,d0                     ; I = pokaz / ukryj HUD (FPS + Info)
    bne.s   .n_i
    eor.b   #1,hud_enabled
    move.b  hud_enabled(pc),info_visible
    bra.w   .held_keys
.n_i:
    cmp.b   #$19,d0                     ; P = wlacz / wylacz cieniowanie Phonga
    bne.s   .n_p
    eor.b   #1,phong_enabled
    bra.w   .held_keys
.n_p:
    cmp.b   #$24,d0                     ; G = wlacz / wylacz podloge 3D
    bne.s   .n_g
    eor.b   #1,grid_enabled
    bra.w   .held_keys
.n_g:
    cmp.b   #$37,d0                     ; M = wlacz / wylacz lustro 3D
    bne.s   .n_m
    eor.b   #1,mirror_enabled
    bra.w   .held_keys
.n_m:
    cmp.b   #$33,d0                     ; C = wlacz / wylacz cienie 3D
    bne.s   .n_c
    eor.b   #1,shadows_enabled
    bra.w   .held_keys
.n_c:
    cmp.b   #$23,d0                     ; F = wlacz / wylacz mgle Z-Fog
    bne.s   .n_f
    eor.b   #1,zfog_enabled
    bra.w   .held_keys
.n_f:
    cmp.b   #$40,d0                     ; Spacja = reset kamery
    beq.s   .do_rst
    cmp.b   #$13,d0                     ; R = reset kamery
    bne.s   .n_rst
.do_rst:
    clr.w   user_yaw
    clr.w   user_pitch
    clr.w   user_zoom
    bra.w   .held_keys
.n_rst:
    cmp.b   #$01,d0                     ; 1 = niebo 1
    bne.s   .n_1
    moveq   #0,d0
    jsr     copper_set_sky_theme
    bra.w   .held_keys
.n_1:
    cmp.b   #$02,d0                     ; 2 = niebo 2
    bne.s   .n_2
    moveq   #1,d0
    jsr     copper_set_sky_theme
    bra.w   .held_keys
.n_2:
    cmp.b   #$03,d0                     ; 3 = niebo 3
    bne.s   .n_3
    moveq   #2,d0
    jsr     copper_set_sky_theme
    bra.w   .held_keys
.n_3:
    cmp.b   #$04,d0                     ; 4 = niebo 4
    bne.s   .n_4
    moveq   #3,d0
    jsr     copper_set_sky_theme
    bra.w   .held_keys
.n_4:
    cmp.b   #$50,d0                     ; F1 = Plansza tytulowa 256 kolorow AGA
    bne.s   .n_f1
    move.l  #0,vbl_tick
    bra.w   .held_keys
.n_f1:
    cmp.b   #$51,d0                     ; F2 = Scena 1 (Morphing)
    bne.s   .n_f2
    move.l  #150,vbl_tick
    bra.w   .held_keys
.n_f2:
    cmp.b   #$52,d0                     ; F3 = Scena 2 (Wahadlowiec + Flara)
    bne.s   .n_f3
    move.l  #470,vbl_tick
    bra.w   .held_keys
.n_f3:
    cmp.b   #$53,d0                     ; F4 = Scena 3 (System Planetarny)
    bne.s   .n_f4
    move.l  #790,vbl_tick
    bra.w   .held_keys
.n_f4:
    cmp.b   #$54,d0                     ; F5 = Scena 4 (Przelot przez Torus)
    bne.s   .n_f5
    move.l  #1130,vbl_tick
    bra.w   .held_keys
.n_f5:
    cmp.b   #$55,d0                     ; F6 = Scena 5 (Model 3D Suzanne)
    bne.s   .n_f6
    move.l  #1410,vbl_tick
    bra.w   .held_keys
.n_f6:
    cmp.b   #$56,d0                     ; F7 = Scena 6 (Teren 3D)
    bne.s   .n_f7
    move.l  #1730,vbl_tick
    bra.w   .held_keys
.n_f7:
    cmp.b   #$57,d0                     ; F8 = Scena 7 (Final 3D)
    bne.s   .n_f8
    move.l  #2050,vbl_tick
    bra.w   .held_keys
.n_f8:
    cmp.b   #$42,d0                     ; Tab = nastepna scena
    bne.w   .held_keys
    move.l  vbl_tick(pc),d1
    cmp.l   #150,d1
    bhs.s   .tb1
    move.l  #150,vbl_tick
    bra.w   .held_keys
.tb1:
    cmp.l   #470,d1
    bhs.s   .tb2
    move.l  #470,vbl_tick
    bra.w   .held_keys
.tb2:
    cmp.l   #790,d1
    bhs.s   .tb3
    move.l  #790,vbl_tick
    bra.w   .held_keys
.tb3:
    cmp.l   #1130,d1
    bhs.s   .tb4
    move.l  #1130,vbl_tick
    bra.w   .held_keys
.tb4:
    cmp.l   #1410,d1
    bhs.s   .tb5
    move.l  #1410,vbl_tick
    bra.w   .held_keys
.tb5:
    cmp.l   #1730,d1
    bhs.s   .tb6
    move.l  #1730,vbl_tick
    bra.w   .held_keys
.tb6:
    cmp.l   #2050,d1
    bhs.s   .tb7
    move.l  #2050,vbl_tick
    bra.w   .held_keys
.tb7:
    move.l  #0,vbl_tick
    bra.w   .held_keys

.key_up:
    cmp.b   kbd_held_raw(pc),d0
    bne.w   .held_keys
    move.b  #$ff,kbd_held_raw

.held_keys:
    move.b  kbd_held_raw(pc),d0
    cmp.b   #$4f,d0                     ; Strzalka w lewo
    bne.s   .h_nl
    subq.w  #2,user_yaw
.h_nl:
    cmp.b   #$4e,d0                     ; Strzalka w prawo
    bne.s   .h_nr
    addq.w  #2,user_yaw
.h_nr:
    cmp.b   #$4c,d0                     ; Strzalka w gore
    bne.s   .h_nu
    subq.w  #2,user_pitch
.h_nu:
    cmp.b   #$4d,d0                     ; Strzalka w dol
    bne.s   .h_nd
    addq.w  #2,user_pitch
.h_nd:
    cmp.b   #$11,d0                     ; W = Zoom in
    bne.s   .h_nw
    subq.w  #3,user_zoom
.h_nw:
    cmp.b   #$21,d0                     ; S = Zoom out
    bne.s   .clamp_zoom
    addq.w  #3,user_zoom

.clamp_zoom:
    move.w  user_zoom(pc),d0
    cmp.w   #-80,d0
    bge.s   .zmin
    move.w  #-80,user_zoom
    bra.s   .done
.zmin:
    cmp.w   #180,d0
    ble.s   .done
    move.w  #180,user_zoom
.done:
    movem.l (sp)+,d0-d3
    rts

    even
user_yaw:       dc.w 0
user_pitch:     dc.w 0
user_zoom:      dc.w 0
kbd_held_raw:   dc.b $ff
kbd_last_sdr:   dc.b $ff
