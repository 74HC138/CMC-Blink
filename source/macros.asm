;-----------------------------------------------
;data stack
    macro DSPush
        dec ix
        ld (ix), \1
    endmacro
    macro DSPop
        ld \1, (ix)
        inc ix
    endmacro
    macro DSPushBC
        dec ix
        ld (ix), b
        dec ix
        ld (ix), c
    endmacro
    macro DSPopBC
        ld c, (ix)
        inc ix
        ld b, (ix)
        inc ix
    endmacro
    macro DSPushDE
        dec ix
        ld (ix), d
        dec ix
        ld (ix), e
    endmacro
    macro DSPopDE
        ld e, (ix)
        inc ix
        ld d, (ix)
        inc ix
    endmacro
    macro DSPushAF
        dec ix
        ld (ix), a
        dec ix
        ld (ix), f
    endmacro
    macro DSPopAF
        ld f, (ix)
        inc ix
        ld a, (ix)
        inc ix
    endmacro
    macro DSPushHL
        dec ix
        ld (ix), h
        dec ix
        ld (ix), l
    endmacro
    macro DSPopHL
        ld l, (ix)
        inc ix
        ld h, (ix)
        inc ix
    endmacro
    macro DSPushIY
        push bc
        ld bc, iy
        DSPushBC
        pop bc
    endmacro
    macro DSPopIY
        push bc
        DSPopBC
        ld iy, bc
        pop bc
    endmacro
    macro DSPushN
        dec ix
        ld (ix), \1
    endmacro
    macro DSPushNN
        dec ix
        ld (ix), >\1
        dec ix
        ld (ix), <\1
    endmacro
    macro DSPushNNin
        push bc
        ld bc, \1
        DSPushBC
        pop bc
    endmacro
    macro DSPopNNin
        push bc
        DSPopBC
        ld (\1), bc
        pop bc
    endmacro
    macro DSRestore
        repeat \1
            inc ix
        endrepeat
    endmacro
    macro DSPeek
        ld \1, (ix+\2)
    endmacro
    macro DSPeekBC
        ld c, (ix+\1)
        ld b, (ix+\1+1)
    endmacro
    macro DSPeekDE
        ld e, (ix+\1)
        ld d, (ix+\1+1)
    endmacro
    macro DSPeekAF
        ld f, (ix+\1)
        ld a, (ix+\1+1)
    endmacro
    macro DSPeekHL
        ld l, (ix+\1)
        ld h, (ix+\1+1)
    endmacro
    macro DSPeekIY
        push bc
        DSPeekBC \1
        push bc
        pop iy
        pop bc
    endmacro
    macro DSPeekNNin
        push bc
        DSPeekBC \1
        ld (\2), bc
        pop bc
    endmacro

;-----------------------------------------------
;16 bit compare
    macro cpBCDE
        DSPush a
        ld a, b
        cp d
        jr nz, $+4
        ld a, c
        cp e
        DSPop a
    endmacro
    macro cpBCHL
        DSPush a
        ld a, b
        cp h
        jr nz, $+4
        ld a, c
        cp l
        DSPop a
    endmacro
    macro cpDEHL
        DSPush a
        ld a, d
        cp h
        jr nz, $+4
        ld a, e
        cp l
        DSPop a
    endmacro
    macro cpBCIY
        DSPush a
        ld a, b
        cp iyh
        jr nz, $+5
        ld a, c
        cp iyl
        DSPop a
    endmacro
    macro cpDEIY
        DSPush a
        ld a, d
        cp iyh
        jr nz, $+5
        ld a, e
        cp iyl
        DSPop a
    endmacro
    macro cpHLIY
        DSPush a
        ld a, h
        cp iyh
        jr nz, $+5
        ld a, l
        cp iyl
        DSPop a
    endmacro
    macro cpHLDE 
        DSPush a
        ld a, h
        cp d
        jr nz, $+4
        ld a, l
        cp e
        DSPop a
    endmacro
    macro cpBCNN
        DSPush a
        ld a, b
        cp >\1
        jr nz, $+5
        ld a, c
        cp <\1
        DSPop a
    endmacro
    macro cpDENN
        DSPush a
        ld a, d
        cp >\1
        jr nz, $+5
        ld a, e
        cp <\1
        DSPop a
    endmacro
    macro cpHLNN
        DSPush a
        ld a, h
        cp >\1
        jr nz, $+5
        ld a, l
        cp <\1
        DSPop a
    endmacro
    macro cpIYNN
        DSPush a
        ld a, iyh
        cp >\1
        jr nz, $+6
        ld a, iyl
        cp <\1
        DSPop a
    endmacro

;-----------------------------------------------
;Function calls
    macro callNNin
        push hl
        ld hl, $+8
        push hl;1
        ld hl, (\1) ;3
        jp (hl) ;1
        pop hl
    endmacro

;-----------------------------------------------
;IO
    macro print
        DSPushNN \1
        call stdio.puts
        DSRestore 2
    endmacro
    macro printNL
        DSPushN 10 ;\n does not get escaped corretly... for some reason *shrug*
        call stdio.putc
        DSRestore 1
    endmacro
;-----------------------------------------------
;Structures

;-----------------------------------------------
