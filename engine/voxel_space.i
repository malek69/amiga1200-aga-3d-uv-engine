; ============================================================================
; AETHER FALCON: VANGUARD - Silnik Wokselowy 3D (Gory, Woda, Wyspy/Lady, Wieze)
; ============================================================================
        section code,code
        cnop    0,4
terrain_3d_init:
af_voxel_init_mission:
        movem.l d0-d7/a0-a3,-(sp)
        lea     af_vox_hmap,a0
        lea     af_vox_cmap,a1
        lea     sin_tab,a2
        move.w  af_mission,d7
        moveq   #0,d5
.vi_z:  moveq   #0,d4
.vi_x:  move.w  d4,d0
        muls.w  #6,d0
        and.w   #255,d0
        move.w  (a2,d0.w*2),d1
        move.w  d5,d0
        muls.w  #5,d0
        add.w   #64,d0
        and.w   #255,d0
        add.w   (a2,d0.w*2),d1
        move.w  d4,d0
        add.w   d5,d0
        lsl.w   #3,d0
        and.w   #255,d0
        move.w  (a2,d0.w*2),d2
        asr.w   #1,d2
        add.w   d2,d1
        cmp.w   #1,d7
        beq.w   .gen_m2
        cmp.w   #2,d7
        beq.w   .gen_m3
        asr.w   #5,d1
        add.w   #12,d1
        cmp.w   #8,d1
        bgt.s   .m1_l
        move.b  #8,(a0)+
        move.b  #1,(a1)+
        bra.w   .vi_nx
.m1_l:  move.b  d1,(a0)+
        cmp.w   #13,d1
        bgt.s   .m1_g
        move.b  #2,(a1)+
        bra.w   .vi_nx
.m1_g:  cmp.w   #20,d1
        bgt.s   .m1_p
        move.b  #3,(a1)+
        bra.w   .vi_nx
.m1_p:  move.b  #4,(a1)+
        bra.w   .vi_nx
.gen_m2:move.w  d4,d0
        sub.w   #32,d0
        bpl.s   .m2_a
        neg.w   d0
.m2_a:  asr.w   #5,d1
        cmp.w   #6,d0
        bgt.s   .m2_c
        move.b  #6,(a0)+
        move.b  #1,(a1)+
        bra.w   .vi_nx
.m2_c:  move.w  d0,d2
        lsl.w   #1,d2
        add.w   d1,d2
        cmp.w   #32,d2
        ble.s   .m2_h
        moveq   #32,d2
.m2_h:  move.b  d2,(a0)+
        cmp.w   #34,d2
        bgt.s   .m2_t
        move.b  #5,(a1)+
        bra.w   .vi_nx
.m2_t:  move.b  #4,(a1)+
        bra.w   .vi_nx
.gen_m3:asr.w   #5,d1
        add.w   #16,d1
        move.w  d4,d0
        and.w   #15,d0
        cmp.w   #4,d0
        blo.s   .m3_g
        cmp.w   #7,d0
        bhi.s   .m3_g
        move.w  d5,d2
        and.w   #15,d2
        cmp.w   #4,d2
        blo.s   .m3_g
        cmp.w   #7,d2
        bhi.s   .m3_g
        move.b  #30,(a0)+
        move.b  #6,(a1)+
        bra.s   .vi_nx
.m3_g:  cmp.w   #9,d1
        bgt.s   .m3_r
        move.b  #9,(a0)+
        move.b  #7,(a1)+
        bra.s   .vi_nx
.m3_r:  move.b  d1,(a0)+
        move.b  #5,(a1)+
.vi_nx: addq.w  #1,d4
        cmp.w   #64,d4
        blo.w   .vi_x
        addq.w  #1,d5
        cmp.w   #64,d5
        blo.w   .vi_z
        movem.l (sp)+,d0-d7/a0-a3
        rts
render_3d_terrain_flyover:
        movem.l d0-d7/a0-a6,-(sp)
        tst.b   vox_inited(pc)
        bne.s   .vrdy
        move.b  #1,vox_inited
        bsr.w   af_voxel_init_mission
.vrdy:  lea     vox_ybuf(pc),a0
        ifd FULL_RES
        move.w  #255,d0
        else
        moveq   #127,d0
        endif
        moveq   #79,d1
.yb_cl: move.w  d0,(a0)+
        move.w  d0,(a0)+
        dbf     d1,.yb_cl
        move.l  vbl_tick(pc),d0
        lsr.l   #1,d0
        move.w  d0,vox_cam_z
        move.w  af_ship_dx,d0
        asr.w   #3,d0
        add.w   #32,d0
        move.w  d0,vox_cam_x
        lea     af_vox_hmap,a3
        lea     af_vox_cmap,a4
        lea     recip_table_32(pc),a5
        moveq   #28,d7
.vz_lp: move.l  (a5,d7.w*4),d6
        move.w  d7,d0
        lsr.w   #2,d0
        add.w   vox_cam_z(pc),d0
        and.w   #63,d0
        lsl.w   #6,d0
        move.w  d0,vox_row_off
        move.w  vox_cam_x(pc),d0
        swap    d0
        clr.w   d0
        move.w  d7,d1
        ext.l   d1
        ifd FULL_RES
        lsl.l   #7,d1
        move.l  d1,vox_dx_step
        move.l  d1,d2
        muls.l  #80,d2
        else
        lsl.l   #8,d1
        add.l   d1,d1
        move.l  d1,vox_dx_step
        move.l  d1,d2
        muls.l  #20,d2
        endif
        sub.l   d2,d0
        lea     vox_ybuf(pc),a1
        lea     chunky_buf,a2
        moveq   #0,d5
.vx_lp: move.l  d0,d2
        swap    d2
        and.w   #63,d2
        add.w   vox_row_off(pc),d2
        moveq   #0,d3
        move.b  (a3,d2.w),d3
        move.w  #44,d4
        sub.w   d3,d4
        ext.l   d4
        muls.l  d6,d4
        asr.l   #8,d4
        asr.l   #1,d4
        ifd FULL_RES
        add.l   #134,d4
        cmp.l   #134,d4
        bge.s   .sy_hi
        move.w  #134,d4
.sy_hi: cmp.l   #255,d4
        ble.s   .sy_ok
        move.w  #255,d4
        else
        asr.l   #1,d4
        add.l   #67,d4
        cmp.l   #67,d4
        bge.s   .sy_hi
        moveq   #67,d4
.sy_hi: cmp.l   #127,d4
        ble.s   .sy_ok
        moveq   #127,d4
        endif
.sy_ok: move.w  (a1),d3
        cmp.w   d3,d4
        bge.w   .vx_nx
        move.w  d4,(a1)
        moveq   #0,d1
        move.b  (a4,d2.w),d1
        bsr.s   .vpc
        sub.w   d4,d3
        ble.w   .vx_nx
        subq.w  #1,d3
        mulu.w  #320,d4
        move.l  a2,a6
        add.l   d4,a6
        move.b  d1,d4
        lsl.w   #8,d4
        move.b  d1,d4
        ifd FULL_RES
.vcf:   move.w  d4,(a6)
        lea     320(a6),a6
        dbf     d3,.vcf
.vx_nx: addq.l  #2,a1
        addq.l  #2,a2
        add.l   vox_dx_step(pc),d0
        addq.w  #1,d5
        cmp.w   #160,d5
        blo.w   .vx_lp
        addq.w  #6,d7
        else
        move.w  d4,d1
        swap    d4
        move.w  d1,d4
.vcf:   move.l  d4,(a6)
        move.l  d4,4(a6)
        lea     320(a6),a6
        dbf     d3,.vcf
.vx_nx: addq.l  #2,a1
        addq.l  #8,a2
        add.l   vox_dx_step(pc),d0
        addq.w  #1,d5
        cmp.w   #40,d5
        blo.w   .vx_lp
        add.w   #14,d7
        endif
        cmp.w   #224,d7
        blo.w   .vz_lp
        movem.l (sp)+,d0-d7/a0-a6
        rts
.vpc:   move.l  d4,-(sp)
        bsr.s   .vpc_in
        move.l  (sp)+,d4
        rts
.vpc_in:cmp.b   #1,d1
        bne.s   .vp2
        move.l  vbl_tick(pc),d1
        lsr.l   #2,d1
        add.w   d2,d1
        and.w   #3,d1
        add.w   #212,d1
        rts
.vp2:   cmp.b   #2,d1
        bne.s   .vp3
        move.w  #122,d1
        cmp.w   #2,af_mission
        bne.s   .vps
        move.w  #24,d1                  ; mroczny bazalt wokol Cytadeli Lewiatana
        bra.s   .vps
.vp3:   cmp.b   #3,d1
        bne.s   .vp4
        move.w  #114,d1
        bra.s   .vps
.vp4:   cmp.b   #4,d1
        bne.s   .vp6
        move.w  #28,d1
        bra.s   .vps
.vp6:   cmp.b   #6,d1
        bne.s   .vp7
        move.b  #253,d1
        btst    #0,d2
        beq.s   .vpr
        move.w  #24,d1
.vpr:   rts
.vp7:   cmp.b   #7,d1
        bne.s   .vp5
        move.b  #254,d1
        rts
.vp5:   move.w  #23,d1                  ; ciemny bazalt / skala wulkaniczna (czysta skala szarosci)
.vps:   move.w  d2,d4
        addq.w  #1,d4
        and.w   #4095,d4
        move.b  (a3,d4.w),d4
        sub.b   (a3,d2.w),d4
        ext.w   d4
        asr.w   #2,d4
        add.w   d4,d1
        cmp.w   #140,d7
        ble.s   .vpc_c
        subq.w  #2,d1
.vpc_c: cmp.w   #18,d1
        bge.s   .vpc_d
        moveq   #18,d1
.vpc_d: rts
        even
vox_inited:     dc.b 0,0
vox_cam_x:      dc.w 32
vox_cam_z:      dc.w 0
vox_row_off:    dc.w 0
vox_dx_step:    dc.l 0
vox_ybuf:       ds.w 160

; ============================================================================
; af_draw_3d_clouds - Wielowarstwowe Chmury 3D na Niebie (M68020+ / AGA)
; ============================================================================
        cnop    0,4
af_draw_3d_clouds:
        movem.l d0-d7/a0-a4,-(sp)
        lea     af_cloud_table(pc),a3
        lea     recip_table_32(pc),a4
        move.l  vbl_tick(pc),d0
        lsl.l   #2,d0
        move.w  d0,cld_scroll_z
        move.w  af_ship_dx,d0
        asr.w   #1,d0
        move.w  d0,cld_cam_x
        moveq   #15,d7                  ; 16 formacji chmur 3D
.cld_lp:
        ; Wylicz Z chmury w petli 120..1140
        move.w  4(a3),d2                ; bazowe Z
        sub.w   cld_scroll_z(pc),d2
        and.w   #1023,d2
        add.w   #120,d2                 ; d2 = Z (120..1143)
        move.l  (a4,d2.w*4),d6          ; d6 = inv_z (16.16)
        ; Rzutuj X chmury
        move.w  (a3),d0                 ; world_x (-420..+420)
        sub.w   cld_cam_x(pc),d0
        ext.l   d0
        muls.l  d6,d0
        asr.l   #8,d0
        add.w   #160,d0                 ; ekranowe X
        ; Rzutuj Y chmury (wysoko na niebie ponad gorami)
        move.w  2(a3),d1                ; world_y (-130..-45)
        ext.l   d1
        muls.l  d6,d1
        asr.l   #8,d1
        ifd FULL_RES
        add.w   #126,d1
        cmp.w   #128,d1
        bgt.w   .cld_nx
        else
        asr.w   #1,d1
        add.w   #63,d1
        cmp.w   #64,d1
        bgt.w   .cld_nx
        endif
        cmp.w   #-40,d0
        blt.w   .cld_nx
        cmp.w   #360,d0
        bgt.w   .cld_nx
        ; Promien poziomy chmury w zaleznosci od 1/Z: rx = (size * inv_z) >> 9
        move.w  6(a3),d3                ; promien bazowy chmury
        ext.l   d3
        muls.l  d6,d3
        asr.l   #8,d3
        asr.l   #1,d3
        cmp.w   #6,d3
        bge.s   .rx_ok
        moveq   #6,d3
.rx_ok: cmp.w   #56,d3
        ble.s   .rx_max
        moveq   #56,d3
.rx_max:
        ; Dobierz palete chmury zaleznie od misji (0=Cumulus, 1=Burza, 2=Cytadela)
        move.b  #216,d4                 ; podstawa chmury (blekit atmosferyczny)
        move.b  #30,d5                  ; srodek chmury (jasny szary)
        move.b  #255,cld_top_col        ; szczyt chmury (czysta biel)
        cmp.w   #1,af_mission
        bne.s   .chk_m3_cld
        move.b  #20,d4                  ; ciemna podstawa burzowa
        move.b  #24,d5                  ; chmura burzowa
        move.b  #218,cld_top_col        ; blysk burzowy
        bra.s   .draw_puffs
.chk_m3_cld:
        cmp.w   #2,af_mission
        bne.s   .draw_puffs
        move.b  #20,d4                  ; ciemny oblok cytadeli
        move.b  #24,d5                  ; stalowy korpus chmury
        move.b  #29,cld_top_col         ; srebrzysty grzbiet chmury
.draw_puffs:
        ; Rysuj 3 warstwy wolumetryczne chmury (dolna podstawa, korpus i szczyt)
        movem.l d0-d3,-(sp)
        addq.w  #3,d1
        move.b  d4,d6
        bsr.s   .draw_cloud_puff
        movem.l (sp),d0-d3
        sub.w   d3,d0
        asr.w   #1,d3
        addq.w  #3,d3
        move.b  d5,d6
        bsr.s   .draw_cloud_puff
        movem.l (sp)+,d0-d3
        subq.w  #2,d1
        move.w  d3,d4
        asr.w   #2,d4
        sub.w   d4,d3
        move.b  cld_top_col(pc),d6
        bsr.s   .draw_cloud_puff
.cld_nx: addq.l  #8,a3
        dbf     d7,.cld_lp
        movem.l (sp)+,d0-d7/a0-a4
        rts

; Rysuje pojedyncza bryle chmury (srodek d0.w, d1.w, promien X d3.w, kolor d6.b)
.draw_cloud_puff:
        movem.l d0-d7/a0-a2,-(sp)
        move.w  d3,d5
        asr.w   #2,d5                   ; ry = rx / 4 (splaszczony oblok)
        cmp.w   #2,d5
        bge.s   .ry_ok
        moveq   #2,d5
.ry_ok: move.w  d1,d4
        sub.w   d5,d4                   ; y_start
        move.w  d5,d7
        add.w   d7,d7                   ; liczba wierszy = 2*ry
.cp_row:
        cmp.w   #4,d4
        blt.w   .cp_next
        ifd FULL_RES
        cmp.w   #130,d4
        else
        cmp.w   #65,d4
        endif
        bgt.w   .cp_next
        ; Wylicz szerokosc wiersza obloku (zaokraglony profil)
        move.w  d4,d2
        sub.w   d1,d2
        bpl.s   .dy_p
        neg.w   d2
.dy_p:  lsl.w   #1,d2
        move.w  d3,a2
        sub.w   d2,a2
        move.w  a2,d2                   ; polowa szerokosci w tym wierszu
        ble.s   .cp_next
        move.w  d0,a0
        sub.w   d2,a0                   ; x0
        move.w  d0,a1
        add.w   d2,a1                   ; x1
        cmp.w   #0,a0
        bge.s   .x0_ok
        lea     0.w,a0
.x0_ok: cmp.w   #319,a1
        ble.s   .x1_ok
        lea     319.w,a1
.x1_ok: move.w  a1,d2
        sub.w   a0,d2
        ble.s   .cp_next
        move.w  d4,a2
        mulu.w  #320,d4
        add.l   a0,d4
        lea     chunky_buf,a0
        add.l   d4,a0
        move.w  a2,d4
.cp_px: move.b  d6,(a0)+
        dbf     d2,.cp_px
.cp_next:
        addq.w  #1,d4
        dbf     d7,.cp_row
        movem.l (sp)+,d0-d7/a0-a2
        rts

        even
cld_scroll_z:   dc.w 0
cld_cam_x:      dc.w 0
cld_top_col:    dc.b 255,0
; 16 formacji chmur: [world_x.w, world_y.w, base_z.w, radius.w]
af_cloud_table:
        dc.w -320,-115,  40, 95,   140,-105, 110, 88,  -110,-125, 180,105,   290, -95, 240, 82
        dc.w -240, -90, 310, 84,    60,-120, 370,110,   350,-110, 430, 92,  -380,-100, 490, 98
        dc.w  190,-122, 560,104,  -150, -92, 620, 80,   310,-118, 690, 96,   -40,-108, 750, 90
        dc.w -290,-124, 820,108,   230, -96, 880, 85,   -90,-116, 940, 94,   370,-104,1000, 88

        section fastram_bss,bss_p
af_vox_hmap:    ds.b 64*64
af_vox_cmap:    ds.b 64*64
        section code,code
