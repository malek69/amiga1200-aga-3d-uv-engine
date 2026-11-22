; [EN/PL] MODULE: pt_player.i | Native 4-Channel ProTracker M.K. Player (50Hz PAL CIA/Paula)
pt_init:
    movem.l d0-d3/a0-a2,-(sp)
    bset    #1,$bfe001
    lea     mod_data,a0
    lea     pt_smp_ptrs(pc),a1
    lea     pt_smp_lens(pc),a2
    lea     1084+3072(a0),a3        ; start of sample data (3 patterns)
    lea     20(a0),a0
    moveq   #3,d0
.si_lp:
    move.l  a3,(a1)+
    moveq   #0,d1
    move.w  22(a0),d1
    move.w  d1,(a2)+
    add.l   d1,d1
    add.l   d1,a3
    lea     30(a0),a0
    dbf     d0,.si_lp
    clr.w   pt_song_pos
    clr.w   pt_pat_row
    move.w  #5,pt_tick_cnt
    lea     $dff000,a5
    move.w  #$000f,$96(a5)
    movem.l (sp)+,d0-d3/a0-a2
    rts

pt_music:
    movem.l d0-d7/a0-a5,-(sp)
    addq.w  #1,pt_tick_cnt
    cmp.w   #6,pt_tick_cnt
    blo.w   .pt_done
    clr.w   pt_tick_cnt

    lea     mod_data,a0
    moveq   #0,d0
    move.w  pt_song_pos(pc),d0
    move.b  952(a0,d0.w),d1         ; pattern number
    lsl.l   #8,d1
    lsl.l   #2,d1                   ; * 1024
    lea     1084(a0,d1.l),a1
    move.w  pt_pat_row(pc),d0
    lsl.w   #4,d0                   ; * 16 bytes/row
    add.w   d0,a1

    lea     $dff000,a5
    moveq   #0,d4                   ; DMA trigger mask
    moveq   #0,d5                   ; channel index 0..3
.ch_lp:
    move.b  (a1)+,d0
    move.b  (a1)+,d1
    move.b  (a1)+,d2
    move.b  (a1)+,d3

    move.w  d0,d6
    and.w   #$0f,d6
    lsl.w   #8,d6
    move.b  d1,d6                   ; period

    lsr.b   #4,d2                   ; sample 1..31
    and.w   #$0f,d2
    beq.s   .no_trig
    tst.w   d6
    beq.s   .no_trig
    subq.w  #1,d2
    cmp.w   #3,d2
    bhi.s   .no_trig

    move.w  d5,d7
    lsl.w   #4,d7
    lea     $a0(a5,d7.w),a4         ; AUDx base
    moveq   #1,d1
    lsl.w   d5,d1
    move.w  d1,$96(a5)              ; stop channel DMA
    or.w    d1,d4

    lea     pt_smp_ptrs(pc),a2
    move.l  (a2,d2.w*4),(a4)        ; AUDxLCH
    lea     pt_smp_lens(pc),a2
    move.w  (a2,d2.w*2),4(a4)       ; AUDxLEN
    move.w  d6,6(a4)                ; AUDxPER
    and.w   #$003f,d3
    bne.s   .v_ok
    moveq   #40,d3
.v_ok: move.w d3,8(a4)              ; AUDxVOL

.no_trig:
    addq.w  #1,d5
    cmp.w   #4,d5
    blo.s   .ch_lp

    tst.w   d4
    beq.s   .adv_row
    move.w  #350,d0
.dma_w: dbf d0,.dma_w
    or.w    #$8200,d4
    move.w  d4,$96(a5)              ; enable triggered channels
    move.w  #350,d0
.dma_w2: dbf d0,.dma_w2
    lea     pt_smp_ptrs(pc),a2
    move.l  8(a2),$c0(a5)           ; loop pointers for ch 2 & 3
    move.w  #32,$c4(a5)
    move.l  12(a2),$d0(a5)
    move.w  #32,$d4(a5)

.adv_row:
    addq.w  #1,pt_pat_row
    cmp.w   #64,pt_pat_row
    blo.s   .pt_done
    clr.w   pt_pat_row
    addq.w  #1,pt_song_pos
    cmp.w   #4,pt_song_pos
    blo.s   .pt_done
    clr.w   pt_song_pos
.pt_done:
    movem.l (sp)+,d0-d7/a0-a5
    rts
pt_song_pos: dc.w 0
pt_pat_row:  dc.w 0
pt_tick_cnt: dc.w 0
pt_smp_ptrs: ds.l 4
pt_smp_lens: ds.w 4
vbl_irq_handler:
    movem.l d0-d1/a0/a5,-(sp)
    lea     $dff000,a5
    move.w  #$0020,$9c(a5)
    addq.l  #1,vbl_tick
    bsr.w   pt_music
    tst.b   swap_ready
    beq.s   .no_swap
    clr.b   swap_ready
    bsr.w   swap_buffers
.no_swap:
    movem.l (sp)+,d0-d1/a0/a5
    rte
