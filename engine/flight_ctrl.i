        section code,code
flight_update_360:
        movem.l d0-d4/a0,-(sp)
        tst.b   cine_active
        bne.s   .skip_m
        move.w  mouse_dx(pc),d0
        asr.w   #2,d0
        add.w   d0,user_yaw
        move.w  mouse_dy(pc),d0
        asr.w   #2,d0
        add.w   d0,user_pitch
.skip_m:
        move.w  user_yaw(pc),d0
        and.w   #255,d0
        move.w  d0,d1
        sub.w   cam_yaw(pc),d1
        ext.w   d1
        cmp.w   #-128,d1
        bge.s   .dw1
        add.w   #256,d1
.dw1:   cmp.w   #128,d1
        ble.s   .dw2
        sub.w   #256,d1
.dw2:   asl.w   #2,d1
        add.w   ship_bank(pc),d1
        asr.w   #1,d1
        cmp.w   #-24,d1
        bge.s   .bk1
        move.w  #-24,d1
.bk1:   cmp.w   #24,d1
        ble.s   .bk2
        move.w  #24,d1
.bk2:   move.w  d1,ship_bank
        move.w  d0,cam_yaw
        lea     sin_tab,a0
        add.w   d0,d0
        move.w  (a0,d0.w),d1
        sub.w   #128,d0
        and.w   #510,d0
        move.w  (a0,d0.w),d2
        moveq   #1,d3
        cmp.b   #1,player_role
        bne.s   .r_sp
        moveq   #2,d3
.r_sp:  tst.b   fire_held
        beq.s   .sp_ok
        addq.w  #2,d3
.sp_ok: muls.w  d3,d1
        muls.w  d3,d2
        add.l   d1,cam_x
        add.l   d2,cam_y
        move.w  user_pitch(pc),d0
        cmp.w   #-45,d0
        bge.s   .pt1
        move.w  #-45,d0
.pt1:   cmp.w   #45,d0
        ble.s   .pt2
        move.w  #45,d0
.pt2:   move.w  d0,user_pitch
        move.w  #110,d1
        sub.w   d0,d1
        move.w  d1,cam_pitch
        move.w  #135,d1
        sub.w   d0,d1
        move.b  cam_y+2(pc),d2
        and.w   #255,d2
        lsl.w   #8,d2
        move.b  cam_x+2(pc),d0
        and.w   #255,d0
        or.w    d0,d2
        and.l   #$ffff,d2
        lea     exo_voxel_data,a0
        moveq   #0,d0
        move.b  (a0,d2.l),d0
        add.w   #14,d0
        cmp.w   d0,d1
        bge.s   .al_ok
        move.w  d0,d1
.al_ok: cmp.w   #215,d1
        ble.s   .al_hi
        move.w  #215,d1
.al_hi: move.w  d1,cam_alt
        movem.l (sp)+,d0-d4/a0
        rts
