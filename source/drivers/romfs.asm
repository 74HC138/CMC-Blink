        defc ROMFs_STARTPAGE    = 0x03
        defc ROMFs_RETURNPAGE   = 0x21

;Read block from ROMFs
;Parameters
;uint16_t LBA
;uint8_t* Buffer
ROMFsRead:
        push BC
        push DE
        push HL

        ;calculate real address
        DSPeekBC 2 ;get LBA
        ld d, b
        ld b, c
        ld c, 0
        sla b
        rl d
        sla b
        rl d
        sla b
        rl d
        srl b
        srl b
        ld a, b
        and 0x7f
        or 0x40
        ld b, a
        ld a, d
        add ROMFs_STARTPAGE
        sla a
        sla a
        sla a 
        sla a
        or 0x01
        ;pointer in bc
        ;page address in a

        out (ROM_BA), a
        DSPeekDE 0 ;get buffer pointer
        ld h, b
        ld l, c
        ld bc, 512
        ldir

        ld a, ROMFs_RETURNPAGE
        out (ROM_BA), a

        pop HL
        pop DE
        pop BC
        ret



