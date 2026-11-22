; ============================================================================
;  PLIK / FILE: main.s
;  PROJEKT: Grotto 3D v2.0 - Amiga 1200 AGA / M68020 Demo
;  AUTORZY: malek69 & Gemini AI (2026)
; ----------------------------------------------------------------------------
;  OPIS MODULU:
;    - Glowny punkt wejscia programu (start) i przejecie systemu AmigaOS.
;    - Petla glowna zsynchronizowana z przerwaniem VBL 50 Hz PAL (wait_vbl).
;    - Czyszczenie 3 bitplanow Blitterem oraz wywolanie silnika 3D (render_realtime_3d).
;    - Wyjscie z dema: lewy przycisk myszy (CIAAPRA bit 6) lub klawisz ESC.
; ============================================================================

BPL_SIZE equ 40*256
    machine 68020
    section code,code

start:
    movem.l d0-a6,-(sp)
    bsr.w   sys_takeover
    tst.l   d0
    beq.w   exit_program

    move.l  #0,vbl_tick

mainloop:
    bsr.w   wait_vbl
    bsr.w   clear_draw_bpl
    move.l  draw_bpl3(pc),a0
    bsr.w   blit_clear_full
    bsr.w   wait_blitter

    ; Synchronizacja klatki z audio 16497 Hz: frame = (pcm_played * 10) / 5499
    move.l  vbl_tick(pc),d0
    mulu.l  #2,d0
    divu.l  #5,d0
    move.w  vec_frame_count(pc),d1
    cmp.w   d1,d0
    blo.s   .f_ok
    moveq   #0,d0
.f_ok:
    move.w  d0,cur_frame

    bsr.w   render_realtime_3d

    btst    #6,CIAAPRA
    beq.s   shutdown
    cmp.b   #$75,$bfec01
    bne.w   mainloop

shutdown:
    bsr.w   sys_restore
exit_program:
    movem.l (sp)+,d0-a6
    moveq   #0,d0
    rts

    include "gfx_engine.i"
    include "vec3d_engine.i"
    include "scene_player.i"
    include "pt_player.i"
    include "demo_gfx.i"
    include "engine3d_core.i"
    include "c2p_chunky.i"
    include "realtime_3d.i"

    section uv_data,data
    even
uv_tex_bank: incbin "uv_textures.bin"
    even
tunnel_lut:  incbin "tunnel_lut.bin"
    even
aga_pal256:  incbin "pal256.bin"
    even
scroll_font: ds.b 1024

    section chip_mod,data_c
    even
mod_data:    incbin "music.mod"

    section fastram_bss,bss
    even
chunky_buf:  ds.b 160*128
edge_buf:    ds.b 256*8
