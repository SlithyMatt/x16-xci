.ifndef X16_INC
X16_INC  = 1

__CX16__ = 1

; RAM Addresses

; Kernal Registers
r0						= $02
r0L					= r0
r0H					= r0+1
r1						= $04
r1L					= r1
r1H					= r1+1
r2						= $06
r2L					= r2
r2H					= r2+1
r3						= $08
r3L					= r3
r3H					= r3+1
r4						= $0A
r4L					= r4
r4H					= r4+1
r5						= $0C
r5L					= r5
r5H					= r5+1
r6						= $0E
r6L					= r6
r6H					= r6+1
r7						= $10
r7L					= r7
r7H					= r7+1
r8						= $12
r8L					= r8
r8H					= r8+1
r9						= $14
r9L					= r9
r9H					= r9+1
r10					= $16
r10L					= r10
r10H					= r10+1
r11					= $18
r11L					= r11
r11H					= r11+1
r12					= $1A
r12L					= r12
r12H					= r12+1
r13					= $1C
r13L					= r13
r13H					= r13+1
r14					= $1E
r14L					= r14
r14H					= r14+1
r15					= $20
r15L					= r15
r15H					= r15+1

; Zero-Page userspace
ZP_PTR_1          = $00	; first four pointers for temporary use only
ZP_PTR_2          = $22
ZP_PTR_3          = $24
ZP_PTR_4          = $26

; I/O Registers
VERA_addr_low     = $9F20
VERA_addr_high    = $9F21
VERA_addr_bank    = $9F22
VERA_data0        = $9F23
VERA_data1        = $9F24
VERA_ctrl         = $9F25
VERA_irq_ctrl     = $9F26
VERA_irq          = $9F27

ROM_BANK          = $9F60
RAM_BANK          = $9F61

YM_reg            = $9FE0
YM_data           = $9FE1

; Emulator Registers
GIF_ctrl          = $9FB5

; Banked Addresses
RAM_WIN           = $A000
RAM_WIN_SIZE      = $2000
ROM_WIN           = $C000

; Kernal Subroutines
GRAPH_LL_init                  := $FEF6
GRAPH_LL_get_info              := $FEF9
GRAPH_LL_set_palette           := $FEFC
GRAPH_LL_cursor_position       := $FEFF
GRAPH_LL_cursor_next_line      := $FF02
GRAPH_LL_get_pixel             := $FF05
GRAPH_LL_get_pixels            := $FF08
GRAPH_LL_set_pixel             := $FF0B
GRAPH_LL_set_pixels            := $FF0E
GRAPH_LL_set_8_pixels          := $FF11
GRAPH_LL_set_8_pixels_opaque   := $FF14
GRAPH_LL_fill_pixels           := $FF17
GRAPH_LL_filter_pixels         := $FF1A
GRAPH_LL_move_pixels           := $FF1D
JOYSTICK_SCAN     := $FF53
JOYSTICK_GET		:= $FF56
MOUSE_CONFIG		:= $FF68
MOUSE_GET			:= $FF6B
MOUSE_SCAN        := $FF71
SETLFS            := $FFBA
SETNAM            := $FFBD
LOAD              := $FFD5


; VRAM Addresses

VRAM_composer  = $F0000
VRAM_hscale    = VRAM_composer+1
VRAM_vscale    = VRAM_composer+2
VRAM_palette   = $F1000
VRAM_layer0    = $F2000
VRAM_layer1    = $F3000
VRAM_sprreg    = $F4000
VRAM_sprattr   = $F5000
VRAM_audio     = $F6000
VRAM_spi       = $F7000
VRAM_uart      = $F8000

LAYER_CTRL_0      = 0
LAYER_CTRL_1      = 1
LAYER_MAP_BASE    = 2
LAYER_TILE_BASE   = 4
LAYER_HSCROLL     = 6
LAYER_BM_OFFSET   = 7
LAYER_VSCROLL     = 8

VROM_petscii   = $1F000

; IRQs
IRQVec         := $0314
BRKVec         := $0316
NMIVec         := $0318

;   Macros

.macro VERA_SET_ADDR addr, stride
	.ifnblank stride
		lda #((^addr) | (stride << 4))
	.else
		lda #(^addr) | $10
	.endif

	sta VERA_addr_bank
	lda #(>addr)
	sta VERA_addr_high
	lda #(<addr)
	sta VERA_addr_low
.endmacro


.endif
