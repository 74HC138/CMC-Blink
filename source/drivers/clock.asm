
;-----------------------------------------------{
    dsect
Clock:
    .systick:
        dc 2
    dend
;-----------------------------------------------}

;-----------------------------------------------{
Clock.Init:
        ld a, 0x00 ;interrupt vector 0
        out (CTC_CH0), a
        ld a, 0b00100101 ;timer, div 256, time constant follows
        out (CTC_CH2), a
        ld a, 144 ;3.6864Mhz / 256 / 144 = 10ms
        out (CTC_CH2), a
        ld hl, Clock.systick
        ld (hl), 0
        inc hl
        ld (hl), 0
        ei
        ld a, 0b10100001 ;enable interrupts ch2
        out (CTC_CH2), a
        ret

;reads systick value
;returns deciseconds in HL
Clock.Read:
        ld hl, (Clock.systick)
        ret

;sets systick valie
;expects deciseconds on DS
Clock.Set:
        DSPeekHL 0
        ld a, h
        ld (Clock.systick), A
        ld a, l
        ld (Clock.systick+1), A
        ret

;sleeps for n deciseconds
;expects timeout on DS
Clock.Sleep:
        DSPeekHL 0
        ld bc, (Clock.systick)
        add hl, bc
    .SleepLoop:
        ld bc, (Clock.systick)
        cpBCHL
        jr nz, .SleepLoop
        ret

;interrupt handler
Clock.Interrupt:
    defc InterruptVec02 = Clock.Interrupt
        ex AF, AF'
        exx

        ld hl, (Clock.systick)
        inc hl
        ld (Clock.systick), hl

        exx
        ex AF, AF'
        ei
        reti

;-----------------------------------------------}