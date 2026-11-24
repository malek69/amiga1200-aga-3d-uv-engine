clear_chunky:
    movem.l d0-d7/a0-a6,-(sp)
    ifd FULL_RES
    lea     chunky_buf+81920,a0
    else
    lea     chunky_buf+40960,a0
    endif
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
    ifd FULL_RES
    movem.l d0-d7/a1-a3,-(a0)
    move.l  #292-1,-(sp)
    else
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d5,-(a0)
    move.l  #146-1,-(sp)
    endif
.cc_lp:
    REPT 5
    movem.l d0-d7/a1-a6,-(a0)
    ENDR
    subq.l  #1,(sp)
    bpl.s   .cc_lp
    addq.l  #4,sp
    movem.l (sp)+,d0-d7/a0-a6
    rts

clear_zbuffer_v2:
    movem.l d0-d7/a0-a6,-(sp)
    ifd FULL_RES
    lea     zbuf_3d+163840,a0
    else
    lea     zbuf_3d+81920,a0
    endif
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
    ifd FULL_RES
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d3,-(a0)
    move.l  #172-1,-(sp)
    else
    movem.l d0-d7/a1-a4,-(a0)
    move.l  #86-1,-(sp)
    endif
.cz_lp:
    REPT 17
    movem.l d0-d7/a1-a6,-(a0)
    ENDR
    subq.l  #1,(sp)
    bpl.s   .cz_lp
    addq.l  #4,sp
    movem.l (sp)+,d0-d7/a0-a6
    rts
