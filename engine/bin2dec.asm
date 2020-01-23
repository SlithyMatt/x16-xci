.ifndef BIN2DEC_INC
BIN2DEC_INC = 1

word2ascii: ; Input:
            ;  ZP_PTR_1: address of 16-bit binary word
            ;  ZP_PTR_2: address of buffer for ASCII string (up to 5 bytes)
            ; Output:
            ;  A: length of string at ZP_PTR_2
            
   rts

.endif
