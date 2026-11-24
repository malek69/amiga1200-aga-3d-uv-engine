; ============================================================================
;  PLIK / FILE: gfx_engine.i
;  OPIS: Sterowanie ukladem AGA (Copperlista 3 bitplany, podwojne buforowanie
;        ekranu swap_buffers, czyszczenie bitplanow Blitterem blit_clear_full).
; ============================================================================

CUSTOM      equ $dff000
DMACONR     equ $002
INTENA      equ $09a
INTENAR     equ $01c
INTREQR     equ $01e
INTREQ      equ $09c
DMACON      equ $096
BLTCON0     equ $040
BLTCON1     equ $042
BLTAFWM     equ $044
BLTALWM     equ $046
BLTCPTH     equ $048
BLTBPTH     equ $04c
BLTAPTH     equ $050
BLTDPTH     equ $054
BLTSIZE     equ $058
BLTCMOD     equ $060
BLTBMOD     equ $062
BLTAMOD     equ $064
BLTDMOD     equ $066
BLTADAT     equ $074
COP1LC      equ $080
COPJMP1     equ $088
DIWSTRT     equ $08e
DIWSTOP     equ $090
DDFSTRT     equ $092
DDFSTOP     equ $094
BPLCON0     equ $100
BPLCON1     equ $102
BPLCON2     equ $104
BPLCON3     equ $106
BPL1MOD     equ $108
BPL2MOD     equ $10a
FMODE       equ $1fc
COLOR00     equ $180
COLOR01     equ $182
COLOR02     equ $184
COLOR03     equ $186
COLOR04     equ $188
COLOR05     equ $18a
COLOR06     equ $18c
COLOR07     equ $18e
AUD0LCH     equ $0a0
AUD0LEN     equ $0a4
AUD0PER     equ $0a6
AUD0VOL     equ $0a8
AUD1LCH     equ $0b0
AUD1LEN     equ $0b4
AUD1PER     equ $0b6
AUD1VOL     equ $0b8
AUD2LCH     equ $0c0
AUD2LEN     equ $0c4
AUD2PER     equ $0c6
AUD2VOL     equ $0c8
AUD3LCH     equ $0d0
AUD3LEN     equ $0d4
AUD3PER     equ $0d6
AUD3VOL     equ $0d8
CIAAPRA     equ $bfe001

_LVOSupervisor    equ -30
_LVOForbid        equ -132
_LVOPermit        equ -138
_LVOOpenLibrary   equ -552
_LVOCloseLibrary  equ -414
_LVOLoadView      equ -222
_LVOWaitTOF       equ -270
_LVOOwnBlitter    equ -456
_LVODisownBlitter equ -462

sys_takeover:
    movem.l d0-d7/a0-a6,-(sp)
    move.l  4.w,a6
    jsr     -132(a6)
    lea     $dff000,a5
    move.w  #$7fff,DMACON(a5)
    move.w  #$7fff,INTENA(a5)
    move.w  #$7fff,INTREQ(a5)
    move.w  #$8240,DMACON(a5)
    move.l  #$00080000,disp_bpl1
    move.l  #$00082800,disp_bpl2
    move.l  #$00085000,disp_bpl3
    move.l  #$00087800,disp_bpl4
    move.l  #$0008a000,disp_bpl5
    move.l  #$0008c800,disp_bpl6
    move.l  #$0008f000,disp_bpl7
    move.l  #$00091800,disp_bpl8
    move.l  #$00094000,draw_bpl1
    move.l  #$00096800,draw_bpl2
    move.l  #$00099000,draw_bpl3
    move.l  #$0009b800,draw_bpl4
    move.l  #$0009e000,draw_bpl5
    move.l  #$000a0800,draw_bpl6
    move.l  #$000a3000,draw_bpl7
    move.l  #$000a5800,draw_bpl8
    bsr.w   build_copper
    move.l  #$000a8000,COP1LC(a5)
    move.w  d0,COPJMP1(a5)
    move.w  #$83cf,DMACON(a5)
    lea     mod_data,a0
    bsr.w   pt_init
    move.l  #vbl_irq_handler,$6c.w
    move.w  #$c020,INTENA(a5)
    movem.l (sp)+,d0-d7/a0-a6
    moveq   #1,d0
    rts

wait_vbl:
    bsr.w   wait_blitter
    move.b  #1,swap_ready
.wv: tst.b  swap_ready
    bne.s   .wv
    rts

clear_draw_bpl:
    rts

swap_buffers:
    lea     disp_bpl1(pc),a1
    lea     cop_bpl1_ptr(pc),a2
    lea     $0e0(a5),a3
    moveq   #7,d2
.sw_lp:
    move.l  (a1),d0
    move.l  4(a1),d1
    move.l  d1,(a1)+
    move.l  d0,(a1)+
    move.l  d1,(a3)+
    move.l  (a2)+,a0
    move.w  d1,2(a0)
    swap    d1
    move.w  d1,6(a0)
    dbf     d2,.sw_lp
    rts

load_aga_256_palette:
    ; a0 -> 256 longwords ($00RRGGBB) -> laduje 8 bankow po 32 kolory 24-bitowe AGA!
    movem.l d0-d5/a0-a2,-(sp)
    lea     $dff000,a2
    moveq   #0,d4
.bk_lp:
    move.w  d4,d5
    ror.w   #3,d5
    move.w  d5,$106(a2)
    lea     $180(a2),a1
    moveq   #31,d3
.hi_lp:
    move.l  (a0)+,d0
    move.l  d0,d1
    lsr.l   #4,d1
    and.w   #$000f,d1
    move.l  d0,d2
    lsr.l   #8,d2
    and.w   #$00f0,d2
    or.w    d2,d1
    swap    d0
    and.w   #$00f0,d0
    lsl.w   #4,d0
    or.w    d0,d1
    move.w  d1,(a1)+
    dbf     d3,.hi_lp
    lea     -128(a0),a0
    or.w    #$0200,d5
    move.w  d5,$106(a2)
    lea     $180(a2),a1
    moveq   #31,d3
.lo_lp:
    move.l  (a0)+,d0
    move.l  d0,d1
    and.w   #$000f,d1
    move.l  d0,d2
    lsr.w   #4,d2
    and.w   #$00f0,d2
    or.w    d2,d1
    swap    d0
    lsl.w   #8,d0
    and.w   #$0f00,d0
    or.w    d0,d1
    move.w  d1,(a1)+
    dbf     d3,.lo_lp
    addq.w  #1,d4
    cmp.w   #8,d4
    blo.s   .bk_lp
    move.w  #$0c00,$106(a2)
    movem.l (sp)+,d0-d5/a0-a2
    rts
wait_blitter:
    lea     $dff000,a5
    btst    #6,DMACONR(a5)
.wb: btst   #6,DMACONR(a5)
    bne.s   .wb
    rts

blit_clear_full:
    bsr.w   wait_blitter
    move.w  #$0100,BLTCON0(a5)
    move.w  #$0000,BLTCON1(a5)
    move.w  #0,BLTDMOD(a5)
    move.l  a0,BLTDPTH(a5)
    move.w  #$4014,BLTSIZE(a5)
    rts

build_copper:
    move.l  #$000a8000,a0
    move.l  #(FMODE<<16)|$0000,(a0)+
    ifd FULL_RES
    move.l  #(DIWSTRT<<16)|$2c81,(a0)+
    move.l  #(DIWSTOP<<16)|$2cc1,(a0)+
    move.l  #(DDFSTRT<<16)|$0038,(a0)+
    move.l  #(DDFSTOP<<16)|$00d0,(a0)+
    else
    move.l  #(DIWSTRT<<16)|$3881,(a0)+
    move.l  #(DIWSTOP<<16)|$1cc1,(a0)+
    move.l  #(DDFSTRT<<16)|$002c,(a0)+
    move.l  #(DDFSTOP<<16)|$00c4,(a0)+
    endif
    move.l  #(BPLCON0<<16)|$0210,(a0)+    ; 8 bitplanow AGA = 256 kolorow!
    move.l  #(BPLCON1<<16)|$0000,(a0)+
    move.l  #(BPLCON2<<16)|$0024,(a0)+
    move.l  #(BPL1MOD<<16)|$0000,(a0)+
    move.l  #(BPL2MOD<<16)|$0000,(a0)+
    move.l  #$0107fffe,(a0)+
    move.l  #(COLOR00<<16)|$0000,(a0)+
    move.l  #$2b07fffe,(a0)+
    move.l  #(COLOR00<<16)|$0000,(a0)+
    lea     disp_bpl1(pc),a1
    lea     cop_bpl1_ptr(pc),a2
    move.w  #$00e0,d2
    moveq   #7,d3
.cp_bp:
    move.l  a0,(a2)+
    move.l  (a1),d0
    addq.l  #8,a1
    move.w  d2,d1
    addq.w  #2,d1
    move.w  d1,(a0)+
    move.w  d0,(a0)+
    swap    d0
    move.w  d2,(a0)+
    move.w  d0,(a0)+
    addq.w  #4,d2
    dbf     d3,.cp_bp
    move.l  #(BPLCON3<<16)|$0c00,(a0)+
    move.l  #($010c<<16)|$0000,(a0)+
    move.l  #(COLOR00<<16)|$0000,(a0)+
    move.l  a0,cop_spr_ptr
    move.w  #$0120,d2
    moveq   #7,d3
.cp_sp:
    move.w  d2,(a0)+
    move.w  #0,(a0)+
    addq.w  #2,d2
    move.w  d2,(a0)+
    move.w  #0,(a0)+
    addq.w  #2,d2
    dbf     d3,.cp_sp
    move.l  a0,cop_sky_ptr
    move.l  #$fffffffe,(a0)+
    moveq   #0,d0
    jsr     copper_set_sky_theme
    rts
cop_spr_ptr: dc.l 0
cop_sky_ptr: dc.l 0
beat_boost:  dc.b 0,0
sys_restore:
    lea     $dff000,a5
    move.w  #$7fff,DMACON(a5)
    move.w  #$7fff,INTENA(a5)
    move.l  4.w,a6
    jsr     -138(a6)
    rts
    even
vbl_tick:       dc.l 0
cur_frame:      dc.w 0
swap_ready:     dc.b 0,0
cop_pal_ptr:    dc.l 0
    even
bbox_x1: dc.w 0
bbox_x2: dc.w 319
bbox_y1: dc.w 0
bbox_y2: dc.w 255
fill_lut: ds.b 256
