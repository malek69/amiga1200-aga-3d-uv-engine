[1mdiff --git a/src/demo_gfx.i b/src/demo_gfx.i[m
[1mindex 57417fd..5c5e0b4 100644[m
[1m--- a/src/demo_gfx.i[m
[1m+++ b/src/demo_gfx.i[m
[36m@@ -66,7 +66,7 @@[m [mdraw_aga_overlays:[m
     dbf     d5,.sc_ch[m
     movem.l (sp)+,d0-d6/a0-a3[m
     rts[m
[31m-scroll_text: dc.b "   *** WATERFALL & FIREFLIES 3D V2.0 *** MUSIC: FANTASEA (COMPOSED BY ABSYS) VIA AMINET *** CODE & 3D ENGINE: MALEK69 & GEMINI AI (VIBE CODING) ***   "[m
[32m+[m[32mscroll_text: dc.b "   *** GROTTO 3D V2.0 *** FOLLOW THE FIREFLY THROUGH THE DARK TUNNEL INTO THE MOONLIT WET GROTTO WITH LAKE, ISLAND TREE, RUSALKA, WATERFALL MIST AND 2 COLORFUL FIREFLIES *** MUSIC: 1991-NOT A NUMBER (/MODS/DEMO/1991NOTANUMBER.LHA) VIA AMINET *** CODE: MALEK69 & GEMINI AI ***   "[m
     even[m
 [m
 draw_starfield_3d:[m
[1mdiff --git a/src/gfx_engine.i b/src/gfx_engine.i[m
[1mindex ed08c94..1850c30 100644[m
[1m--- a/src/gfx_engine.i[m
[1m+++ b/src/gfx_engine.i[m
[36m@@ -138,7 +138,7 @@[m [msys_takeover:[m
 [m
     move.l  #copperlist,COP1LC(a5)[m
     move.w  d0,COPJMP1(a5)[m
[31m-    move.w  #$83ef,DMACON(a5)[m
[32m+[m[32m    move.w  #$83cf,DMACON(a5)[m
     move.w  #$c020,INTENA(a5)[m
     moveq   #1,d0[m
     rts[m
[36m@@ -290,7 +290,7 @@[m [mset_col01_shade:[m
 [m
 build_copper:[m
     lea     copperlist,a0[m
[31m-    move.l  #(FMODE<<16)|$000c,(a0)+[m
[32m+[m[32m    move.l  #(FMODE<<16)|$0000,(a0)+[m
     move.l  #(DIWSTRT<<16)|$2c81,(a0)+[m
     move.l  #(DIWSTOP<<16)|$2cc1,(a0)+[m
     move.l  #(DDFSTRT<<16)|$0038,(a0)+[m
[36m@@ -335,17 +335,6 @@[m [mbuild_copper:[m
     move.l  #(COLOR05<<16)|$0247,(a0)+[m
     move.l  #(COLOR06<<16)|$05df,(a0)+[m
     move.l  #(COLOR07<<16)|$0fff,(a0)+[m
[31m-    move.l  #($01a2<<16)|$02e6,(a0)+[m
[31m-    move.l  #($01a4<<16)|$0fe0,(a0)+[m
[31m-    move.l  #($01a6<<16)|$0f24,(a0)+[m
[31m-    lea     eq_sprite,a1[m
[31m-    move.l  #$f0480000,(a1)[m
[31m-    move.l  a1,d0[m
[31m-    move.w  #$0122,(a0)+[m
[31m-    move.w  d0,(a0)+[m
[31m-    swap    d0[m
[31m-    move.w  #$0120,(a0)+[m
[31m-    move.w  d0,(a0)+[m
     move.l  a0,cop_sky_ptr[m
     moveq   #31,d2[m
     move.w  #$2c07,d3[m
[1mdiff --git a/src/main.s b/src/main.s[m
[1mindex cfda350..85f7f5d 100644[m
[1m--- a/src/main.s[m
[1m+++ b/src/main.s[m
[36m@@ -134,12 +134,6 @@[m [minv_tab:[m
     [m
 [m
 [m
[31m-    section chip_mod,data_c[m
[31m-    even[m
[31m-mod_data:[m
[31m-    incbin  "demo_tune.mod"[m
[31m-    dcb.b   256,0[m
[31m-    even[m
 [m
 logo_b1: incbin "logo_bpl1.bin"[m
 logo_b2: incbin "logo_bpl2.bin"[m
[36m@@ -159,6 +153,13 @@[m [mdma_buf_b: ds.b 2048[m
 [m
 [m
 [m
[32m+[m[32m    even[m
[32m+[m
[32m+[m[32m    section chip_mod,data_c[m
[32m+[m[32m    even[m
[32m+[m[32mmod_data:[m
[32m+[m[32m    incbin  "demo_tune.mod"[m
[32m+[m[32m    dcb.b   256,0[m
     even[m
 [m
     section fastram_bss,bss[m
[1mdiff --git a/src/demo_gfx.i b/src/demo_gfx.i[m
[1mindex 57417fd..5c5e0b4 100644[m
[1m--- a/src/demo_gfx.i[m
[1m+++ b/src/demo_gfx.i[m
[36m@@ -66,7 +66,7 @@[m [mdraw_aga_overlays:[m
     dbf     d5,.sc_ch[m
     movem.l (sp)+,d0-d6/a0-a3[m
     rts[m
[31m-scroll_text: dc.b "   *** WATERFALL & FIREFLIES 3D V2.0 *** MUSIC: FANTASEA (COMPOSED BY ABSYS) VIA AMINET *** CODE & 3D ENGINE: MALEK69 & GEMINI AI (VIBE CODING) ***   "[m
[32m+[m[32mscroll_text: dc.b "   *** GROTTO 3D V2.0 *** FOLLOW THE FIREFLY THROUGH THE DARK TUNNEL INTO THE MOONLIT WET GROTTO WITH LAKE, ISLAND TREE, RUSALKA, WATERFALL MIST AND 2 COLORFUL FIREFLIES *** MUSIC: 1991-NOT A NUMBER (/MODS/DEMO/1991NOTANUMBER.LHA) VIA AMINET *** CODE: MALEK69 & GEMINI AI ***   "[m
     even[m
 [m
 draw_starfield_3d:[m
[1mdiff --git a/src/gfx_engine.i b/src/gfx_engine.i[m
[1mindex ed08c94..1850c30 100644[m
[1m--- a/src/gfx_engine.i[m
[1m+++ b/src/gfx_engine.i[m
[36m@@ -138,7 +138,7 @@[m [msys_takeover:[m
 [m
     move.l  #copperlist,COP1LC(a5)[m
     move.w  d0,COPJMP1(a5)[m
[31m-    move.w  #$83ef,DMACON(a5)[m
[32m+[m[32m    move.w  #$83cf,DMACON(a5)[m
     move.w  #$c020,INTENA(a5)[m
     moveq   #1,d0[m
     rts[m
[36m@@ -290,7 +290,7 @@[m [mset_col01_shade:[m
 [m
 build_copper:[m
     lea     copperlist,a0[m
[31m-    move.l  #(FMODE<<16)|$000c,(a0)+[m
[32m+[m[32m    move.l  #(FMODE<<16)|$0000,(a0)+[m
     move.l  #(DIWSTRT<<16)|$2c81,(a0)+[m
     move.l  #(DIWSTOP<<16)|$2cc1,(a0)+[m
     move.l  #(DDFSTRT<<16)|$0038,(a0)+[m
[36m@@ -335,17 +335,6 @@[m [mbuild_copper:[m
     move.l  #(COLOR05<<16)|$0247,(a0)+[m
     move.l  #(COLOR06<<16)|$05df,(a0)+[m
     move.l  #(COLOR07<<16)|$0fff,(a0)+[m
[31m-    move.l  #($01a2<<16)|$02e6,(a0)+[m
[31m-    move.l  #($01a4<<16)|$0fe0,(a0)+[m
[31m-    move.l  #($01a6<<16)|$0f24,(a0)+[m
[31m-    lea     eq_sprite,a1[m
[31m-    move.l  #$f0480000,(a1)[m
[31m-    move.l  a1,d0[m
[31m-    move.w  #$0122,(a0)+[m
[31m-    move.w  d0,(a0)+[m
[31m-    swap    d0[m
[31m-    move.w  #$0120,(a0)+[m
[31m-    move.w  d0,(a0)+[m
     move.l  a0,cop_sky_ptr[m
     moveq   #31,d2[m
     move.w  #$2c07,d3[m
[1mdiff --git a/src/main.s b/src/main.s[m
[1mindex cfda350..85f7f5d 100644[m
[1m--- a/src/main.s[m
[1m+++ b/src/main.s[m
[36m@@ -134,12 +134,6 @@[m [minv_tab:[m
     [m
 [m
 [m
[31m-    section chip_mod,data_c[m
[31m-    even[m
[31m-mod_data:[m
[31m-    incbin  "demo_tune.mod"[m
[31m-    dcb.b   256,0[m
[31m-    even[m
 [m
 logo_b1: incbin "logo_bpl1.bin"[m
 logo_b2: incbin "logo_bpl2.bin"[m
[36m@@ -159,6 +153,13 @@[m [mdma_buf_b: ds.b 2048[m
 [m
 [m
 [m
[32m+[m[32m    even[m
[32m+[m
[32m+[m[32m    section chip_mod,data_c[m
[32m+[m[32m    even[m
[32m+[m[32mmod_data:[m
[32m+[m[32m    incbin  "demo_tune.mod"[m
[32m+[m[32m    dcb.b   256,0[m
     even[m
 [m
     section fastram_bss,bss[m
