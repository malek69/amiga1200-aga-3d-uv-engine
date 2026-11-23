; ============================================================================
; AURA-3D AGA Engine v1.1 - 3D World-Space Particle Trail (M68020+)
; ============================================================================
; Wymaga: rot_m00..rot_m22 (aktualna macierz obiektu), draw_z_orb_v2
; ============================================================================

PTRAIL_MAX      equ 64                  ; potega 2 (64 czasteczki * 16B = 1024B)
PTRAIL_MASK     equ (PTRAIL_MAX-1)
PTRAIL_LIFE     equ 32                  ; czas zycia pojedynczej czasteczki

; Struktura czasteczki (16 bajtow):
;  0.w : wx (pozycja X w swiecie)
;  2.w : wy (pozycja Y w swiecie)
;  4.w : wz (pozycja Z w swiecie)
;  6.w : vx (predkosc X w 1/16 jednostki)
;  8.w : vy (predkosc Y w 1/16 jednostki)
; 10.w : vz (predkosc Z w 1/16 jednostki)
; 12.w : life (licznik klatek; 0 = nieaktywna)
; 14.w : col_base (indeks bazowy w palecie)

; ----------------------------------------------------------------------------
; ptrail_reset - Zeruje pule czasteczek (wywolac przy starcie sceny)
; ----------------------------------------------------------------------------
ptrail_reset:
    movem.l d0/a0,-(sp)
    lea     ptrail_pool,a0
    move.w  #(PTRAIL_MAX*4)-1,d0
.clr_lp:
    clr.l   (a0)+
    dbf     d0,.clr_lp
    clr.w   ptrail_head
    clr.w   ptrail_tick
    movem.l (sp)+,d0/a0
    rts

; ----------------------------------------------------------------------------
; ptrail_emit_twin_nozzles
; Emituje 2 czasteczki z dysz (-9,0,-36) i (+9,0,-36) w przestrzeni swiata.
; Wejscie:
;   d4.w = obiekt tx (World X)
;   d5.w = obiekt ty (World Y)
;   d6.w = obiekt tz (World Z)
;   rot_m00..rot_m22 = aktualna macierz obrotu obiektu (8.8 fixed-point)
; ----------------------------------------------------------------------------
ptrail_emit_twin_nozzles:
    movem.l d0-d7/a0-a2,-(sp)

    ; Emituj co druga klatke, aby smuga byla dluga i plynna
    addq.w  #1,ptrail_tick
    btst    #0,ptrail_tick+1(pc)
    bne.w   .emit_done

    lea     rot_m00(pc),a2

    ; Wektor odrzutu wzdluz lokalnej osi -Z obiektu (kolumna 2 macierzy * -1)
    move.w  4(a2),d5                ; m02
    neg.w   d5
    asr.w   #3,d5                   ; thrust_vx

    move.w  10(a2),d6               ; m12
    neg.w   d6
    asr.w   #3,d6                   ; thrust_vy

    move.w  16(a2),d7               ; m22
    neg.w   d7
    asr.w   #3,d7                   ; thrust_vz

    ; --- LEWA DYSZA: lokalnie (-9, 0, -36) ---
    move.w  (a2),d0
    muls.w  #-9,d0
    move.w  4(a2),d1
    muls.w  #-36,d1
    add.l   d1,d0
    asr.l   #8,d0
    add.w   16+2(sp),d0             ; + tx

    move.w  6(a2),d1
    muls.w  #-9,d1
    move.w  10(a2),d2
    muls.w  #-36,d2
    add.l   d2,d1
    asr.l   #8,d1
    add.w   20+2(sp),d1             ; + ty

    move.w  12(a2),d2
    muls.w  #-9,d2
    move.w  16(a2),d3
    muls.w  #-36,d3
    add.l   d3,d2
    asr.l   #8,d2
    add.w   24+2(sp),d2             ; + tz

    bsr.s   .alloc_and_write

    ; --- PRAWA DYSZA: lokalnie (+9, 0, -36) ---
    move.w  (a2),d0
    muls.w  #9,d0
    move.w  4(a2),d1
    muls.w  #-36,d1
    add.l   d1,d0
    asr.l   #8,d0
    add.w   16+2(sp),d0             ; + tx

    move.w  6(a2),d1
    muls.w  #9,d1
    move.w  10(a2),d2
    muls.w  #-36,d2
    add.l   d2,d1
    asr.l   #8,d1
    add.w   20+2(sp),d1             ; + ty

    move.w  12(a2),d2
    muls.w  #9,d2
    move.w  16(a2),d3
    muls.w  #-36,d3
    add.l   d3,d2
    asr.l   #8,d2
    add.w   24+2(sp),d2             ; + tz

    bsr.s   .alloc_and_write

.emit_done:
    movem.l (sp)+,d0-d7/a0-a2
    rts

; Wewnetrzna procedura zapisu czasteczki:
; d0=wx, d1=wy, d2=wz, d5=thrust_vx, d6=thrust_vy, d7=thrust_vz
.alloc_and_write:
    lea     ptrail_pool,a0
    move.w  ptrail_head(pc),d3
    move.w  d3,d4
    addq.w  #1,d4
    and.w   #PTRAIL_MASK,d4
    move.w  d4,ptrail_head

    lsl.w   #4,d3                   ; offset = idx * 16
    adda.w  d3,a0

    move.w  d0,(a0)+                ; wx
    move.w  d1,(a0)+                ; wy
    move.w  d2,(a0)+                ; wz

    ; Szybki PRNG (xorshift/rol) dla turbulencji +/- 3
    move.l  ptrail_seed(pc),d4
    rol.l   #5,d4
    eor.l   #$a53c9621,d4
    addq.l  #7,d4
    move.l  d4,ptrail_seed

    move.w  d4,d3
    and.w   #7,d3
    subq.w  #3,d3
    add.w   d5,d3
    move.w  d3,(a0)+                ; vx

    lsr.w   #4,d4
    move.w  d4,d3
    and.w   #7,d3
    subq.w  #3,d3
    add.w   d6,d3
    move.w  d3,(a0)+                ; vy

    lsr.w   #4,d4
    move.w  d4,d3
    and.w   #7,d3
    subq.w  #3,d3
    add.w   d7,d3
    move.w  d3,(a0)+                ; vz

    move.w  #PTRAIL_LIFE,(a0)+      ; life
    move.w  #62,(a0)+               ; col_base (jasny zar w palecie)
    rts

; ----------------------------------------------------------------------------
; ptrail_update_and_draw
; Aktualizuje fizyke wszystkich aktywnych czasteczek i rysuje je przez Z-Buffer
; ----------------------------------------------------------------------------
ptrail_update_and_draw:
    movem.l d0-d7/a0,-(sp)
    lea     ptrail_pool,a0
    move.w  #PTRAIL_MAX-1,d7

.upd_lp:
    move.w  12(a0),d5               ; life
    beq.s   .next_p

    ; Dekrementuj life
    subq.w  #1,d5
    move.w  d5,12(a0)
    beq.s   .next_p

    ; Calkowanie pozycji: pos += vel >> 4
    move.w  6(a0),d0                ; vx
    asr.w   #4,d0
    add.w   d0,(a0)                 ; wx += vx>>4

    move.w  8(a0),d1                ; vy
    asr.w   #4,d1
    add.w   d1,2(a0)                ; wy += vy>>4

    move.w  10(a0),d2               ; vz
    asr.w   #4,d2
    add.w   d2,4(a0)                ; wz += vz>>4

    ; Co 4 klatki lekkie wyhamowanie oporu osrodka (vel -= vel >> 3)
    move.w  d5,d0
    and.w   #3,d0
    bne.s   .no_drag
    move.w  6(a0),d0
    asr.w   #3,d0
    sub.w   d0,6(a0)
    move.w  8(a0),d0
    asr.w   #3,d0
    sub.w   d0,8(a0)
    move.w  10(a0),d0
    asr.w   #3,d0
    sub.w   d0,10(a0)
.no_drag:

    ; Przygotuj argumenty dla draw_z_orb_v2:
    ; d0=wx, d1=wy, d2=wz, d3=promien persp., d4=kolor
    move.w  (a0),d0
    move.w  2(a0),d1
    move.w  4(a0),d2

    ; Rozmiar: 240 + life * 16 (od ~750 przy dyszy do ~256 na ogonie)
    move.w  d5,d3
    lsl.w   #4,d3
    add.w   #240,d3

    ; Kolor bazowy z delikatnym przygaszaniem przy koncu zycia
    move.w  14(a0),d4
    cmp.w   #12,d5
    bge.s   .col_ok
    subq.w  #2,d4
.col_ok:
    jsr     draw_z_orb_v2

.next_p:
    lea     16(a0),a0
    dbf     d7,.upd_lp

    movem.l (sp)+,d0-d7/a0
    rts

; --- Dane bufora czasteczek ---
ptrail_head:    dc.w 0
ptrail_tick:    dc.w 0
ptrail_seed:    dc.l $19931200

