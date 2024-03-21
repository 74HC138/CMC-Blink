    defc BAUD9600 = 23
    defc BAUD115200 = 1
    defc BAUD4800 = 47
    defc BAUD19200 = 11
    defc BAUD38400 = 5
    defc BAUD57600 = 3
    defc BAUD76800 = 2

    defc USE_RXINT = 1

    dsect
Serial:
    .Serial1Buf:
        dc 256
    .Serial1WI:
        dc 1
    .Serial1RI:
        dc 1
    .Serial2Buf:
        dc 256
    .Serial2WI:
        dc 1
    .Serial2RI:
        dc 1
    dend


;!!BORKED
;TODO unbork ASAP
;Initializes Serial port 1
;Parameters:
;Baudrate in (IX) data stack
Serial1.init:
        ld a, 0B01000101
        out (SIO_A_CLK), a
        DSPeek a, 0
        out (SIO_A_CLK), a

        ld a, 0B00011000
        out (SUSB_CMD), a ;channel reset
        ld a, 0B00000010
        out (SIO_B_CMD), a ;set interrupt vector
        ld a, 0B00010000
        out (SIO_B_CMD), a ;interrupt vector = 0x10
        ld a, 0B00010100
        out (SUSB_CMD), a
        ld a, 0B01000100
        out (SUSB_CMD), a ;CLK div 16, 1 stop bit, no parity
        ld a, 0B00000011
        out (SUSB_CMD), a
        ld a, 0B11100001
        out (SUSB_CMD), a ;8 bits per char, RTS CTS hw handshake, rx enabled
        ld a, 0B00000101
        out (SUSB_CMD), a
        ld a, 0B01101010
        out (SUSB_CMD), a ;8 bits per char, RTS set, tx enabled
        ld a, 0B00000001
        out (SIO_B_CMD), a
        ld a, 0B00000100
        out (SIO_B_CMD), a ;status effects vector
    if USE_RXINT == 1
        ld a, 0B00010001
        out (SUSB_CMD), a
        ld a, 0B00011100
        out (SUSB_CMD), a ;enable rx interrupts
    endif

        ei
        ret

Serial1.TXint:
    defc InterruptVec14 = Serial1.TXint
        ei
        reti

Serial1.RXint:
    defc InterruptVec16 = Serial1.RXint
    if USE_RXINT == 1
        ex AF, AF'
        exx
        ld b, 0x00
        ld a, (Serial.Serial1WI)
        ld c, a
        in a, (SIO_B_DAT)
        ld hl, Serial.Serial1Buf
        add hl, bc
        ld (hl), a
        inc c
        ld a, c
        ld (Serial.Serial1WI), a
        exx
        ex AF, AF'
    endif
        ei
        reti

;Send a single character via Serial port 1
;Parameters:
;Char in (IX) data stack
Serial1.putc:
        in a, (SIO_A_CMD)
        and 0B00000100
        jr z, Serial1.putc

        ld a, (IX)
        out (SIO_A_DAT), a
        ret

;Receive a single character via Serial port 1
;Returns char in A
Serial1.getc:
        push bc
        push hl
        ld a, (Serial.Serial1RI)
        ld b, a
    .loopGetc:
        ld a, (Serial.Serial1WI)
        cp b
        jr z, .loopGetc
        ld a, b

        ld b, 0x00
        ld c, a
        ld hl, Serial.Serial1Buf
        add hl, bc
        inc c
        ld a, c
        ld (Serial.Serial1RI), a
        ld a, (hl)

        pop hl
        pop bc
        ret

;Send a null terminated string via Serial port 1
;Parameters:
;String pointer in (IX) stack
Serial1.puts:
        push hl
        ld l, (ix)
        ld h, (ix + 1)
    .loopPuts:
        ld a, (hl)
        cp 0x00
        jr z, .exitPuts
        DSPush a
        call Serial1.putc
        DSRestore 1
        inc hl
        jr .loopPuts

    .exitPuts:
        pop hl
        ret 





