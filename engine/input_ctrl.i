; ============================================================================
; AURA-3D AGA Engine v1.1 - Real-Time Joystick (Port 2) & Keyboard Controller
; ============================================================================

; Surowe kody CIA SDR ($BFEC01) dla wcisnietych klawiszy: ~(rawkey << 1)
KEY_UP      equ $67                     ; raw $4c
KEY_DOWN    equ $65                     ; raw $4d
KEY_RIGHT   equ $63                     ; raw $4e
KEY_LEFT    equ $61                     ; raw $4f
KEY_W       equ $dd                     ; raw $11
KEY_S       equ $bd                     ; raw $21
KEY_F       equ $b9                     ; raw $23
KEY_G       equ $b7                     ; raw $24
KEY_H       equ $b5                     ; raw $25
KEY_C       equ $99                     ; raw $33
KEY_R       equ $d9                     ; raw $13
KEY_SPACE   equ $7f                     ; raw $40
KEY_1       equ $fd                     ; raw $01
KEY_2       equ $fb                     ; raw $02
KEY_3       equ $f9                     ; raw $03
KEY_4       equ $f7                     ; raw $04

; ----------------------------------------------------------------------------
; input_update_controls - Wywolywane raz na klatke w mainloop
; ----------------------------------------------------------------------------
input_update_controls:
    movem.l d0-d3,-(sp)

    ; 1. Odczyt Joysticka w Porcie 2 ($DFF00C = JOY1DAT, Fire = bit 7 $BFE001)
    move.w  $dff00c,d0
    move.w  d0,d1
    lsr.w   #1,d1
    eor.w   d0,d1                   ; bit 0 = Down, bit 8 = Up

    ; Sprawdz przycisk Fire (Port 2 = bit 7 CIAAPRA, 0 = wcisniety)
    btst    #7,$bfe001
    bne.s   .joy_normal

    ; Fire wcisniety: Gora/Dol reguluje Zoom kamery
    btst    #8,d1
    beq.s   .jf_no_up
    subq.w  #3,user_zoom
.jf_no_up:
    btst    #0,d1
    beq.s   .joy_lr
    addq.w  #3,user_zoom
    bra.s   .joy_lr

.joy_normal:
    ; Bez Fire: Gora/Dol reguluje Pitch
    btst    #8,d1
    beq.s   .jn_no_up
    subq.w  #2,user_pitch
.jn_no_up:
    btst    #0,d1
    beq.s   .joy_lr
    addq.w  #2,user_pitch

.joy_lr:
    btst    #9,d0                   ; Left
    beq.s   .j_no_left
    subq.w  #2,user_yaw
.j_no_left:
    btst    #1,d0                   ; Right
    beq.s   .read_kbd
    addq.w  #2,user_yaw

    ; 2. Odczyt klawiatury z CIA SDR ($BFEC01) + sprzetowy handshake CIA-A ($BFEE01)
.read_kbd:
    move.b  $bfec01,d0
    cmp.b   input_last_key(pc),d0
    beq.s   .kbd_no_ack

    ; Nowy skankod z klawiatury -> wyslij impuls ACK (SPMODE=1 przez ~85 us)
    or.b    #$40,$bfee01
    move.b  $dff006,d1
.ack_wait:
    cmp.b   $dff006,d1
    beq.s   .ack_wait
    move.b  $dff006,d1
.ack_wait2:
    cmp.b   $dff006,d1
    beq.s   .ack_wait2
    and.b   #$bf,$bfee01

.kbd_no_ack:
    move.b  input_last_key(pc),d2
    move.b  d0,input_last_key

    ; Klawisze ciagle (trzymane):
    cmp.b   #KEY_LEFT,d0
    bne.s   .k_not_left
    subq.w  #2,user_yaw
.k_not_left:
    cmp.b   #KEY_RIGHT,d0
    bne.s   .k_not_right
    addq.w  #2,user_yaw
.k_not_right:
    cmp.b   #KEY_UP,d0
    bne.s   .k_not_up
    subq.w  #2,user_pitch
.k_not_up:
    cmp.b   #KEY_DOWN,d0
    bne.s   .k_not_down
    addq.w  #2,user_pitch
.k_not_down:
    cmp.b   #KEY_W,d0
    bne.s   .k_not_w
    subq.w  #3,user_zoom
.k_not_w:
    cmp.b   #KEY_S,d0
    bne.s   .k_toggles
    addq.w  #3,user_zoom

    ; Klawisze jednorazowe (wyzwolenie na zboczu wcisniecia d0 != d2):
.k_toggles:
    cmp.b   d0,d2
    beq.w   .clamp_zoom

    cmp.b   #KEY_SPACE,d0
    beq.s   .do_reset
    cmp.b   #KEY_R,d0
    bne.s   .k_not_rst
.do_reset:
    clr.w   user_yaw
    clr.w   user_pitch
    clr.w   user_zoom
    bra.s   .clamp_zoom
.k_not_rst:

    cmp.b   #KEY_F,d0
    bne.s   .k_not_fog
    eor.b   #1,zfog_enabled
    bra.s   .clamp_zoom
.k_not_fog:

    cmp.b   #KEY_H,d0
    bne.s   .k_not_hud
    eor.b   #1,hud_enabled
    bra.s   .clamp_zoom
.k_not_hud:

    cmp.b   #KEY_C,d0
    bne.s   .k_not_shd
    eor.b   #1,shadows_enabled
    bra.s   .clamp_zoom
.k_not_shd:

    cmp.b   #KEY_G,d0
    bne.s   .k_not_grd
    eor.b   #1,grid_enabled
    bra.s   .clamp_zoom
.k_not_grd:

    cmp.b   #KEY_1,d0
    bne.s   .k_not_1
    moveq   #0,d0
    jsr     copper_set_sky_theme
    bra.s   .clamp_zoom
.k_not_1:
    cmp.b   #KEY_2,d0
    bne.s   .k_not_2
    moveq   #1,d0
    jsr     copper_set_sky_theme
    bra.s   .clamp_zoom
.k_not_2:
    cmp.b   #KEY_3,d0
    bne.s   .k_not_3
    moveq   #2,d0
    jsr     copper_set_sky_theme
    bra.s   .clamp_zoom
.k_not_3:
    cmp.b   #KEY_4,d0
    bne.s   .clamp_zoom
    moveq   #3,d0
    jsr     copper_set_sky_theme

.clamp_zoom:
    move.w  user_zoom(pc),d0
    cmp.w   #-80,d0
    bge.s   .z_min_ok
    move.w  #-80,user_zoom
    bra.s   .inp_done
.z_min_ok:
    cmp.w   #180,d0
    ble.s   .inp_done
    move.w  #180,user_zoom

.inp_done:
    movem.l (sp)+,d0-d3
    rts

    even
user_yaw:       dc.w 0
user_pitch:     dc.w 0
user_zoom:      dc.w 0
input_last_key: dc.b $ff,0
