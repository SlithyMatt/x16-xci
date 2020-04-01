.ifndef SFX_INC
SFX_INC = 1

__sfx_playing:    .byte 0
__sfx_end:        .word 0

SOUND_0_PTR = RAM_WIN+3
PCM_RATE    = 12  ; 4578 Hz

enable_sfx:
   lda #1
   sta sfx_enabled
   rts

disable_sfx:
   stz sfx_enabled
   stz VERA_audio_rate
   rts

play_sfx:   ; A: sound index
   ; check for sfx enabled
   ldx sfx_enabled
   beq @return
   ; initialize PCM
   stz VERA_audio_rate
   ldx #$8F ; reset to 8-bit mono, max volume
   stx VERA_audio_ctrl
   ; get address of sound start pointer
   asl
   tay
   lda #<SOUND_0_PTR
   sta ZP_PTR_1
   lda #>SOUND_0_PTR
   sta ZP_PTR_1+1
   ; get sound start pointer
   lda music_bank
   sta RAM_BANK
   lda (ZP_PTR_1),y
   clc
   adc #<RAM_WIN
   sta SFX_PTR
   iny
   lda (ZP_PTR_1),y
   adc #>RAM_WIN
   sta SFX_PTR+1
   ; get sound end pointer, immediately following
   iny
   lda (ZP_PTR_1),y
   clc
   adc #<RAM_WIN
   sta __sfx_end
   iny
   lda (ZP_PTR_1),y
   adc #>RAM_WIN
   sta __sfx_end+1
   ; start playing
   lda #1
   sta __sfx_playing
   jsr sfx_fill_fifo
   lda #PCM_RATE
   sta VERA_audio_rate
@return:
   rts

sfx_tick:
   lda sfx_enabled
   bne @check_playing
   jmp @return
@check_playing:
   lda __sfx_playing
   bne @check_fifo
   jmp @return
@check_fifo:
   lda aflow_trig
   beq @return
   stz aflow_trig
   jsr sfx_fill_fifo
@return:
   rts

sfx_fill_fifo:
   bra @start
@remaining: .word 0
@start:
   lda music_bank
   sta RAM_BANK
   stz @remaining
   lda #08
   sta @remaining+1  ; 2048 bytes remaining to write
@data_loop:
   lda @remaining+1
   bne @more
   lda @remaining
   bne @more
   jmp @return
@more:
   lda SFX_PTR+1
   cmp __sfx_end+1
   bne @write_data
   lda SFX_PTR
   cmp __sfx_end
   bne @write_data
   stz __sfx_playing
   bra @return
@write_data:
   lda (SFX_PTR)
   sta VERA_audio_data
   lda SFX_PTR
   clc
   adc #1
   sta SFX_PTR
   lda SFX_PTR+1
   adc #0
   sta SFX_PTR+1
   lda @remaining
   sec
   sbc #1
   sta @remaining
   lda @remaining+1
   sbc #0
   sta @remaining+1
   bra @data_loop
@return:
   rts

.endif
