.ifndef STATE_INC
STATE_INC = 1

STATE_BANK = 63
STATE_VISITED  = RAM_WIN
STATE_FLAGS    = RAM_WIN + $200

init_state:
   lda #STATE_BANK
   jsr reset_bank
   rts

__state_mask: .byte 0

__get_visited_addr:  ; Input:
                     ;  X: Level
                     ;  Y: Zone
                     ; Output:
                     ;  A: visited bit mask
                     ;  ZP_PTR_1: address of byte containing visited bit
   lda #STATE_BANK
   sta RAM_BANK
   lda #<STATE_VISITED
   sta ZP_PTR_1
   lda #>STATE_VISITED
   sta ZP_PTR_1+1
   tya
   asl
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   cpx #8
   bpl @high
   lda #1
   bra @loop
@high:
   txa
   sec
   sbc #8
   tax
   lda ZP_PTR_1
   clc
   adc #1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   lda #1
@loop:
   cpx #0
   beq @return
   asl
   dex
   bra @loop
@return:
   rts

check_visited: ; Input:
               ;  X: Level
               ;  Y: Zone
               ; Output:
               ;  A: 0 = not visited, 1 = visited
   lda #STATE_BANK
   sei
   sta RAM_BANK
   jsr __get_visited_addr
   sta __state_mask
   lda (ZP_PTR_1)
   cli
   and __state_mask
   beq @return
   lda #1
@return:
   rts

set_visited:   ;  X: Level
               ;  Y: Zone
   lda #STATE_BANK
   sei
   sta RAM_BANK
   jsr __get_visited_addr
   sta __state_mask
   lda (ZP_PTR_1)
   ora __state_mask
   sta (ZP_PTR_1)
   cli
   rts

__get_state_addr: ; Input:
                  ;  X/Y: state index
                  ; Output:
                  ;  A: state bit mask
                  ;  ZP_PTR_1: address of byte containing state bit
   bra @start
@offset: .word 0
@bit:    .byte 0
@start:
   stx @offset
   sty @offset+1
   stz @bit
   lsr @offset+1  ; divide index by 8 to get offset
   ror @offset
   ror @bit
   lsr @offset+1
   ror @offset
   ror @bit
   lsr @offset+1
   ror @offset
   ror @bit
   ror @bit
   ror @bit
   ror @bit
   ror @bit
   ror @bit       ; offset % 8
   lda #<STATE_FLAGS
   clc
   adc @offset
   sta ZP_PTR_1
   lda #>STATE_FLAGS
   adc @offset+1
   sta ZP_PTR_1+1
   ldx @bit
   lda #1
@loop:
   cpx #0
   beq @return
   asl
   dex
   bra @loop
@return:
   rts

get_state:  ; Input: X/Y - state index
            ; Ouput: A - state value: 0 = clear, 1 = set
   lda #STATE_BANK
   sei
   sta RAM_BANK
   jsr __get_state_addr
   sta __state_mask
   lda (ZP_PTR_1)
   cli
   and __state_mask
   beq @return
   lda #1
@return:
   rts

set_state:  ;  A: value: 0 = clear, 1+ = set
            ;  X/Y - state index
   bra @start
@set: .byte 0
@start:
   sta @set
   lda #STATE_BANK
   sei
   sta RAM_BANK
   jsr __get_state_addr
   sta __state_mask
   lda @set
   beq @clear
   lda (ZP_PTR_1)
   ora __state_mask
   bra @return
@clear:
   lda __state_mask
   eor #$FF
   sta __state_mask
   lda (ZP_PTR_1)
   and __state_mask
@return:
   sta (ZP_PTR_1)
   cli
   rts


.endif
