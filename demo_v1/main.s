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

    jsr     input_update_controls
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
    include "aura3d_v2.i"
    include "realtime_3d.i"
    include "demo_v2_scene.i"
    include "demo_scenes.i"
    include "particle_trail.i"
    include "copper_sky.i"
    include "input_ctrl.i"


    even
disp_bpl1:      dc.l 0
draw_bpl1:      dc.l 0
disp_bpl2:      dc.l 0
draw_bpl2:      dc.l 0
disp_bpl3:      dc.l 0
draw_bpl3:      dc.l 0
disp_bpl4:      dc.l 0
draw_bpl4:      dc.l 0
disp_bpl5:      dc.l 0
draw_bpl5:      dc.l 0
disp_bpl6:      dc.l 0
draw_bpl6:      dc.l 0
disp_bpl7:      dc.l 0
draw_bpl7:      dc.l 0
disp_bpl8:      dc.l 0
draw_bpl8:      dc.l 0
cop_bpl1_ptr:   dc.l 0
cop_bpl2_ptr:   dc.l 0
cop_bpl3_ptr:   dc.l 0
cop_bpl4_ptr:   dc.l 0
cop_bpl5_ptr:   dc.l 0
cop_bpl6_ptr:   dc.l 0
cop_bpl7_ptr:   dc.l 0
cop_bpl8_ptr:   dc.l 0
copper_ptr:     dc.l 0

    section uv_data,data
    even
uv_tex_bank: incbin "uv_textures.bin"
    even
tunnel_lut:  incbin "tunnel_lut.bin"
    even
aga_pal256:  incbin "pal256.bin"
    even
scroll_font: ds.b 1024
    even
ptrail_pool: ds.b 1024

    even
sin_tab:
    dc.w 0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92
    dc.w 98,104,109,115,121,126,132,137,142,147,152,157,162,167,172,177
    dc.w 181,185,190,194,198,202,206,209,213,216,220,223,226,229,231,234
    dc.w 237,239,241,243,245,247,248,250,251,252,253,254,255,255,256,256
    dc.w 256,256,256,255,255,254,253,252,251,250,248,247,245,243,241,239
    dc.w 237,234,231,229,226,223,220,216,213,209,206,202,198,194,190,185
    dc.w 181,177,172,167,162,157,152,147,142,137,132,126,121,115,109,104
    dc.w 98,92,86,80,74,68,62,56,50,44,38,31,25,19,13,6
    dc.w 0,-6,-13,-19,-25,-31,-38,-44,-50,-56,-62,-68,-74,-80,-86,-92
    dc.w -98,-104,-109,-115,-121,-126,-132,-137,-142,-147,-152,-157,-162,-167,-172,-177
    dc.w -181,-185,-190,-194,-198,-202,-206,-209,-213,-216,-220,-223,-226,-229,-231,-234
    dc.w -237,-239,-241,-243,-245,-247,-248,-250,-251,-252,-253,-254,-255,-255,-256,-256
    dc.w -256,-256,-256,-255,-255,-254,-253,-252,-251,-250,-248,-247,-245,-243,-241,-239
    dc.w -237,-234,-231,-229,-226,-223,-220,-216,-213,-209,-206,-202,-198,-194,-190,-185
    dc.w -181,-177,-172,-167,-162,-157,-152,-147,-142,-137,-132,-126,-121,-115,-109,-104
    dc.w -98,-92,-86,-80,-74,-68,-62,-56,-50,-44,-38,-31,-25,-19,-13,-6
    dc.w 0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92
    dc.w 98,104,109,115,121,126,132,137,142,147,152,157,162,167,172,177
    dc.w 181,185,190,194,198,202,206,209,213,216,220,223,226,229,231,234
    dc.w 237,239,241,243,245,247,248,250,251,252,253,254,255,255,256,256

    section chip_mod,data_c
    even
mod_data:    incbin "demo_tune.mod"

    section fastram_bss,bss
    even
chunky_buf:  ds.b 160*128
edge_buf:    ds.b 256*8
