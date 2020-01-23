.ifndef INVENTORY_INC
INVENTORY_INC = 1

INV_START_Y          = 0
INV_TILEMAP          = 1
INV_NUM_ITEMS        = 321
INV_ITEM_WIDTH       = 322
INV_ITEM_HEIGHT      = 323
INV_ITEM_START_X     = 324
INV_ITEM_STEP_X      = 325
INV_ITEM_QUANT_X     = 326
INV_ITEM_QUANT_WIDTH = 327
INV_ITEM_CFG         = 328
INV_MAX_ITEM_LABEL   = 16


__inv_tilemap_addr:  .word 0
__inv_scroll_up_x:   .byte 0
__inv_scroll_up_y:   .byte 0
__inv_scroll_down_x: .byte 0
__inv_scroll_down_y: .byte 0



init_inv:


   rts

show_inv:

   rts

inv_tick:

   rts

.endif
