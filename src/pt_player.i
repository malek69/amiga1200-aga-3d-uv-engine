; [EN/PL] MODULE: pt_player.i | Universal 31-Sample ProTracker M.K. Player (50Hz PAL)
pt_init:
    movem.l d0-d4/a0-a3,-(sp)
    bset    #1,$bfe001
    lea     mod_data,a0
    moveq   #0,d0
    move.b  950(a0),d0
    move.b  d0,pt_song_len
    moveq   #0,d1
    moveq   #127,d2
    lea     952(a0),a1
.mp_lp: move.b (a1)+,d3
    cmp.b   d1,d3
    ble.s   .mp_nx
    move.b  d3,d1
.mp_nx: dbf d2,.mp_lp
    addq.l  #1,d1
    lsl.l   #8,d1
    lsl.l   #2,d1
    lea     1084(a0,d1.l),a3        ; start of PCM sample data
    lea     pt_smp_ptrs(pc),a1
    lea     pt_smp_lens(pc),a2
    lea     pt_smp_rpts(pc),a4
    lea     pt_smp_rlns(pc),a5
    lea     pt_smp_vols(pc),a6
    lea     20(a0),a0
    moveq   #30,d0
.si_lp:
    move.l  a3,(a1)+
    moveq   #0,d1
    move.w  22(a0),d1
    move.w  d1,(a2)+
    move.b  25(a0),(a6)+
    moveq   #0,d2
    move.w  26(a0),d2
    add.l   d2,d2
    add.l   a3,d2
    move.l  d2,(a4)+
    move.w  28(a0),(a5)+
    cmp.w   #1,28(a0)
    bhi.s   .has_lp
    clr.w   (a3)
.has_lp:
    add.l   d1,d1
    add.l   d1,a3
    lea     30(a0),a0
    dbf     d0,.si_lp
    clr.w   pt_song_pos
    clr.w   pt_pat_row
    move.w  #5,pt_tick_cnt
    move.w  #6,pt_speed
    lea     $dff000,a5
    move.w  #$000f,$96(a5)
    movem.l (sp)+,d0-d4/a0-a3
    rts

pt_music:
    movem.l d0-d7/a0-a6,-(sp)
    addq.w  #1,pt_tick_cnt
    move.w  pt_tick_cnt(pc),d0
    cmp.w   pt_speed(pc),d0
    blo.w   .pt_done
    clr.w   pt_tick_cnt

    lea     mod_data,a0
    moveq   #0,d0
    move.w  pt_song_pos(pc),d0
    moveq   #0,d1
    move.b  952(a0,d0.w),d1
    lsl.l   #8,d1
    lsl.l   #2,d1
    lea     1084(a0,d1.l),a1
    move.w  pt_pat_row(pc),d0
    lsl.w   #4,d0
    add.w   d0,a1

    lea     $dff000,a5
    moveq   #0,d4
    moveq   #0,d5
.ch_lp:
    move.b  (a1)+,d0
    move.b  (a1)+,d1
    move.b  (a1)+,d2
    move.b  (a1)+,d3

    move.w  d0,d6
    and.w   #$0f,d6
    lsl.w   #8,d6
    move.b  d1,d6

    move.b  d2,d7
    and.w   #$0f,d7                 ; effect cmd
    cmp.w   #$0f,d7
    bne.s   .chk_vol
    tst.b   d3
    beq.s   .chk_vol
    cmp.b   #$20,d3
    bhs.s   .chk_vol
    moveq   #0,d1
    move.b  d3,d1
    move.w  d1,pt_speed
.chk_vol:
    and.w   #$f0,d0
    lsr.w   #4,d0
    lsr.b   #4,d2
    and.w   #$0f,d2
    or.w    d0,d2                   ; sample 1..31
    beq.s   .no_trig
    cmp.w   #31,d2
    bhi.s   .no_trig
    subq.w  #1,d2
    lea     pt_cur_smp(pc),a2
    move.w  d2,(a2,d5.w*2)
    tst.w   d6
    beq.s   .no_trig

    move.w  d5,d1
    lsl.w   #4,d1
    lea     $a0(a5,d1.w),a4
    moveq   #1,d1
    lsl.w   d5,d1
    move.w  d1,$96(a5)
    or.w    d1,d4

    lea     pt_smp_ptrs(pc),a2
    move.l  (a2,d2.w*4),(a4)
    lea     pt_smp_lens(pc),a2
    move.w  (a2,d2.w*2),4(a4)
    move.w  d6,6(a4)
    lea     pt_smp_vols(pc),a2
    moveq   #0,d1
    move.b  (a2,d2.w),d1
    cmp.w   #$0c,d7
    bne.s   .v_set
    moveq   #0,d1
    move.b  d3,d1
.v_set: cmp.w #64,d1
    ble.s   .v_ok
    moveq   #64,d1
.v_ok: move.w d1,8(a4)

.no_trig:
    addq.w  #1,d5
    cmp.w   #4,d5
    blo.w   .ch_lp

    tst.w   d4
    beq.s   .adv_row
    bsr.w   pt_wait_raster
    or.w    #$8200,d4
    move.w  d4,$96(a5)
    bsr.w   pt_wait_raster
    moveq   #0,d5
.lp_set:
    btst    d5,d4
    beq.s   .lp_nx
    lea     pt_cur_smp(pc),a2
    move.w  (a2,d5.w*2),d2
    move.w  d5,d1
    lsl.w   #4,d1
    lea     $a0(a5,d1.w),a4
    lea     pt_smp_rpts(pc),a2
    move.l  (a2,d2.w*4),(a4)
    lea     pt_smp_rlns(pc),a2
    move.w  (a2,d2.w*2),4(a4)
.lp_nx: addq.w #1,d5
    cmp.w   #4,d5
    blo.s   .lp_set

.adv_row:
    addq.w  #1,pt_pat_row
    cmp.w   #64,pt_pat_row
    blo.s   .pt_done
    clr.w   pt_pat_row
    addq.w  #1,pt_song_pos
    move.w  pt_song_pos(pc),d0
    moveq   #0,d1
    move.b  pt_song_len(pc),d1
    cmp.w   d1,d0
    blo.s   .pt_done
    clr.w   pt_song_pos
.pt_done:
    movem.l (sp)+,d0-d7/a0-a6
    rts
pt_song_pos: dc.w 0
pt_pat_row:  dc.w 0
pt_tick_cnt: dc.w 0
pt_speed:    dc.w 6
pt_song_len: dc.b 1,0
pt_cur_smp:  ds.w 4
pt_smp_ptrs: ds.l 32
pt_smp_lens: ds.w 32
pt_smp_rpts: ds.l 32
pt_smp_rlns: ds.w 32
pt_smp_vols: ds.b 32
pt_wait_raster:
    moveq   #4,d1
.wr_lp:
    move.b  $dff006,d0
.wr_sm:
    cmp.b   $dff006,d0
    beq.s   .wr_sm
    dbf     d1,.wr_lp
    rts
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
