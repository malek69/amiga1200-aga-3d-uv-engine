; ============================================================================
; AURA-3D v1.15 - Ultra-Fast Buffer Clear (M68020+ movem.l unrolled)
; ============================================================================

clear_chunky:
    movem.l d0-d7/a0-a6,-(sp)
    lea     chunky_buf+20480,a0
    moveq   #0,d0
    move.l  d0,d1
    move.l  d0,d2
    move.l  d0,d3
    move.l  d0,d4
    move.l  d0,d5
    move.l  d0,d6
    move.l  d0,d7
    movea.l d0,a1
    movea.l d0,a2
    movea.l d0,a3
    movea.l d0,a4
    movea.l d0,a5
    movea.l d0,a6
    movem.l d0-d7/a1-a2,-(a0)
    move.l  #73-1,-(sp)
.cc_lp:
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d7/a1-a6,-(a0)
    subq.l  #1,(sp)
    bpl.s   .cc_lp
    addq.l  #4,sp
    movem.l (sp)+,d0-d7/a0-a6
    rts

clear_zbuffer_v2:
    movem.l d0-d7/a0-a6,-(sp)
    lea     zbuf_3d+40960,a0
    move.l  #$7fff7fff,d0
    move.l  d0,d1
    move.l  d0,d2
    move.l  d0,d3
    move.l  d0,d4
    move.l  d0,d5
    move.l  d0,d6
    move.l  d0,d7
    movea.l d0,a1
    movea.l d0,a2
    movea.l d0,a3
    movea.l d0,a4
    movea.l d0,a5
    movea.l d0,a6
    movem.l d0-d5,-(a0)
    move.l  #43-1,-(sp)
.cz_lp:
    REPT 17
    movem.l d0-d7/a1-a6,-(a0)
    ENDR
    subq.l  #1,(sp)
    bpl.s   .cz_lp
    addq.l  #4,sp
    movem.l (sp)+,d0-d7/a0-a6
    rts
