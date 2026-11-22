; [EN/PL] AUTHORS / AUTORZY: malek69 & Gemini AI (Vibe Coding Edition, 2026)
; [EN] MODULE: audio_player.i | 4-Channel Paula DMA Driver (Level 4 IRQ, LED Filter OFF)
; [PL] MODUL: audio_player.i | 4-kanalowy sterownik DMA Paula (IRQ4, filtr LED wylaczony)
AUDIO_BUF_SIZE equ 2048
setup_paula:
    movem.l d0-d1/a0-a1/a5,-(sp)
    bset    #1,$bfe001
    move.l  #pcm_start,pcm_pos
    clr.l   pcm_played
    move.l  #dma_buf_a,pcm_cur_buf
    move.l  #dma_buf_b,pcm_nxt_buf
    lea     dma_buf_a,a0
    bsr.w   fill_pcm_chunk
    lea     dma_buf_b,a0
    bsr.w   fill_pcm_chunk
    lea     $dff000,a5
    move.w  #$000f,$96(a5)
    move.l  #dma_buf_a,d0
    move.l  d0,$a0(a5)
    move.l  d0,$b0(a5)
    move.l  d0,$c0(a5)
    move.l  d0,$d0(a5)
    move.w  #(AUDIO_BUF_SIZE/2),$a4(a5)
    move.w  #(AUDIO_BUF_SIZE/2),$b4(a5)
    move.w  #(AUDIO_BUF_SIZE/2),$c4(a5)
    move.w  #(AUDIO_BUF_SIZE/2),$d4(a5)
    move.w  #322,$a6(a5)
    move.w  #322,$b6(a5)
    move.w  #322,$c6(a5)
    move.w  #322,$d6(a5)
    move.w  #22,$a8(a5)
    move.w  #22,$b8(a5)
    move.w  #22,$c8(a5)
    move.w  #22,$d8(a5)
    movec   vbr,a0
    move.l  $70(a0),old_aud_vec
    move.l  #aud0_irq_handler,$70(a0)
    move.w  #$0080,$9c(a5)
    move.w  #$8080,$9a(a5)
    move.w  #$820f,$96(a5)
    movem.l (sp)+,d0-d1/a0-a1/a5
    rts
aud0_irq_handler:
    movem.l d0-d1/a0-a1/a5,-(sp)
    lea     $dff000,a5
    move.w  #$0080,$9c(a5)
    move.l  pcm_nxt_buf(pc),d0
    move.l  pcm_cur_buf(pc),pcm_nxt_buf
    move.l  d0,pcm_cur_buf
    move.l  d0,$a0(a5)
    move.l  d0,$b0(a5)
    move.l  d0,$c0(a5)
    move.l  d0,$d0(a5)
    move.l  pcm_nxt_buf(pc),a0
    bsr.s   fill_pcm_chunk
    movem.l (sp)+,d0-d1/a0-a1/a5
    rte
fill_pcm_chunk:
    move.l  pcm_pos(pc),a1
    lea     pcm_end,a2
    move.w  #(AUDIO_BUF_SIZE/4)-1,d0
.cp_pcm:
    cmp.l   a2,a1
    blo.s   .ok_pcm
    lea     pcm_start,a1
.ok_pcm:
    move.l  (a1)+,(a0)+
    dbf     d0,.cp_pcm
    move.l  a1,pcm_pos
    add.l   #AUDIO_BUF_SIZE,pcm_played
    rts
vbl_irq_handler:
    addq.l  #1,vbl_tick
    move.w  #$0020,$dff09c
    rte
