
;divide register A by B, result in C remainder in A
Math.divu8b8:
        ld c, 0x00
    .divu8b8divLoop:
        cp b
        ret c
        sub b
        inc c
        jr .divu8b8divLoop

;divide register HL by DE, result in BC remainder in HL
Math.divu16b16:
        ld bc, 0x00000
    .divu16b16divLoop:
        cpHLDE
        ret c
        or a ;reset carry
        sbc hl, de
        inc bc
        jr .divu16b16divLoop


        