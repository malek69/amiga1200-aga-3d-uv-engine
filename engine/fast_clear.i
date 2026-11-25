clear_chunky:
    movem.l d0-d7/a0-a6,-(sp)
    ifd FULL_RES
    lea     chunky_buf+81920,a0
    bsr.s   .cc_block
    bsr.s   .cc_block
    movem.l (sp)+,d0-d7/a0-a6
    rts
.cc_block:
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
    movem.l d0-d7/a1-a6,-(a0)
    movem.l d0-d5,-(a0)
    move.l  #146-1,-(sp)
.cc_lp:
    REPT 5
    movem.l d0-d7/a1-a6,-(a0)
    ENDR
    subq.l  #1,(sp)
    bpl.s   .cc_lp
    addq.l  #4,sp
    ifd FULL_RES
    rts
    else
    movem.l (sp)+,d0-d7/a0-a6
    rts
    endif

clear_zbuffer_v2:
    movem.l d0-d7/a0-a6,-(sp)
    ifd FULL_RES
    lea     zbuf_3d+163840,a0
    bsr.s   .cz_block
    bsr.s   .cz_block
    movem.l (sp)+,d0-d7/a0-a6
    rts
.cz_block:
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
    movem.l d0-d7/a1-a4,-(a0)
    move.l  #86-1,-(sp)
.cz_lp:
    REPT 17
    movem.l d0-d7/a1-a6,-(a0)
    ENDR
    subq.l  #1,(sp)
    bpl.s   .cz_lp
    addq.l  #4,sp
    ifd FULL_RES
    rts
    else
    movem.l (sp)+,d0-d7/a0-a6
    rts
    endif
