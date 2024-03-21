    dsect
stdio:
    .pPutcFunction:
        dc 2
    .pGetcFunction:
        dc 2
    dend


;initialize stdio driver
;Parameters:
;(void putc)(char)
;(char getc)(void)
stdio.init:
        push bc

        DSPeekBC 0
        ld (.pGetcFunction), bc
        DSPeekBC 2
        ld (.pPutcFunction), bc
        
        pop bc
        ret

;write unsigned lowercase hex char to output
;Parameters:
;char c
stdio.putu8h:
        push bc
        push hl

        ld b, 0x00
        DSPeek c, 0
        srl c
        srl c
        srl c
        srl c
        ld hl, .hexTableLowercase
        add hl, bc
        ld a, (hl)
        DSPush a
        callNNin .pPutcFunction
        DSRestore 1

        DSPeek a, 0
        and 0x0f
        ld c, a
        ld hl, .hexTableLowercase
        add hl, bc
        ld a, (hl)
        DSPush a
        callNNin .pPutcFunction
        DSRestore 1

        pop hl
        pop bc
        ret

;write unsigned uppercase hex char to output
;Parameters:
;char c
stdio.putu8H:
        push bc
        push hl

        ld b, 0x00
        DSPeek c, 0
        srl c
        srl c
        srl c
        srl c
        ld hl, .hexTableUppercase
        add hl, bc
        ld a, (hl)
        DSPush a
        callNNin .pPutcFunction
        DSRestore 1

        DSPeek a, 0
        and 0x0f
        ld c, a
        ld hl, .hexTableUppercase
        add hl, bc
        ld a, (hl)
        DSPush a
        callNNin .pPutcFunction
        DSRestore 1

        pop hl
        pop bc
        ret

;write unsigned lowercase hex word to output
;Parameters:
;uint16_t c
stdio.putu16h:
        DSPeek a, 1
        DSPush a
        call .putu8h
        DSRestore 1
        DSPeek a, 0
        DSPush a
        call .putu8h
        DSRestore 1
        ret

;write unsigned uppercase hex word to output
;Parameters:
;uint16_t c
stdio.putu16H:
        DSPeek a, 1
        DSPush a
        call .putu8H
        DSRestore 1
        DSPeek a, 0
        DSPush a
        call .putu8H
        DSRestore 1
        ret

;write unsigned lowercase hex long word to output
;Parameters:
;uint32_t c
stdio.putu32h:
        DSPeek a, 3
        DSPush a
        call .putu8h
        DSRestore 1
        DSPeek a, 2
        DSPush a
        call .putu8h
        DSRestore 1
        DSPeek a, 1
        DSPush a
        call .putu8h
        DSRestore 1
        DSPeek a, 0
        DSPush a
        call .putu8h
        DSRestore 1
        ret
;write unsigned uppercase hex long word to output
;Parameters:
;uint32_t c
stdio.putu32H:
        DSPeek a, 3
        DSPush a
        call .putu8H
        DSRestore 1
        DSPeek a, 2
        DSPush a
        call .putu8H
        DSRestore 1
        DSPeek a, 1
        DSPush a
        call .putu8H
        DSRestore 1
        DSPeek a, 0
        DSPush a
        call .putu8H
        DSRestore 1
        ret

;write unsigned decimal char
;Parameters:
;uint8_t c
stdio.putu8d:
        push bc
        push de
        push hl

        DSPeek a, 0
        ld d, 0
    .putu8dFillLoop:
        cp 0
        jr z, .putu8dFillEnd
        ld b, 10
        call Math.divu8b8
        add '0'
        DSPush a
        ld a, c
        inc d
        jr .putu8dFillLoop

    .putu8dFillEnd:
        ld a, 0
        cp d
        jr z, .putu8dOutputZero
    .putu8dOutputLoop:
        callNNin .pPutcFunction
        DSRestore 1
        dec d
        ld a, 0
        cp d
        jr nz, .putu8dOutputLoop

        pop hl
        pop de
        pop bc
        ret

    .putu8dOutputZero:
        DSPushN '0'
        callNNin .pPutcFunction
        DSRestore 1
        pop hl
        pop de
        pop bc
        ret

;write unsigned decimal word
;Parameters:
;uint16_t c
stdio.putu16d:
        push bc
        push de
        push hl

        DSPeekHL 0
        ld d, 0
    .putu16dFillLoop:
        cpHLNN 0x0000
        ;we can reuse the output function from the unsigned 8 decimal
        jr z, .putu8dFillEnd
        push de
        ld de, 10
        call Math.divu16b16
        pop de
        ld a, l
        add '0'
        DSPush a
        ld h, b
        ld l, c
        inc d
        jr .putu16dFillLoop

;write signed decimal byte
;Parameters:
;int8_t c
stdio.puts8d:
        push bc

        DSPeek a, 0 
        bit 7, a
        jr z, .puts8dSkip
        res 7, a
        ld b, a
        ld a, 0x80
        sub b
        push af
        DSPushN '-'
        callNNin .pPutcFunction
        DSRestore 1
        pop af
    .puts8dSkip:
        DSPush a
        call .putu8d
        DSRestore 1

        pop bc
        ret

;write signed decimal word
;Parameters:
;int16_t c
stdio.puts16d:
        push hl
        push de

        DSPeekHL 0
        bit 7, h
        jr z, .puts16dSkip
        res 7, h
        ex de, hl
        ld hl, 0x8000
        or a ;clear carry flag
        sbc hl, de
        DSPushN '-'
        callNNin .pPutcFunction
        DSRestore 1
    .puts16dSkip:
        DSPushHL
        call .putu16d
        DSRestore 2

        pop de
        pop hl
        ret

stdio.puts:
        push hl
        DSPeekHL 0
    .putsloop:
        ld a, (hl)
        cp 0x00
        jr z, .putsexit
        DSPush a
        callNNin .pPutcFunction
        DSRestore 1
        inc hl
        jr .putsloop

    .putsexit:
        pop hl
        ret 

stdio.putc:
        callNNin .pPutcFunction
        ret








stdio.hexTableLowercase:
        byte "0123456789abcdef"
stdio.hexTableUppercase:
        byte "0123456789ABCDEF"
stdio.hexPrefix:
        string "0x"
stdio.binPrefix:
        string "0b"