;-----------------------------------------------{
;Variables
    dsect
Clock:
    .systick:
        dc 2
    .TimeMillis:
        dc 2
    .TimeSeconds:
        dc 1
    .TimeMinutes:
        dc 1
    .TimeHours:
        dc 1
    .DateDay:
        dc 1
    .DateMonth:
        dc 1
    .DateYear:
        dc 2
    dend
;-----------------------------------------------}
;-----------------------------------------------{
;Macros
    macro Sleep
        DSPushNN (\1 / 10)
        call Clock.SleepFn
        DSRestore 2
    endmacro
    macro SetTime
        DSPushN \1
        DSPushN \2
        DSPushN \3
        call Clock.SetTimeFn
        DSRestore 3
    endmacro
    macro SetDate
        DSPushN \1
        DSPushN \2
        DSPushNN \3
        call Clock.SetDateFn
        DSRestore 4
    endmacro

;-----------------------------------------------}
;-----------------------------------------------{
;Functions
Clock.Init:
        push hl
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
        pop hl
        ret

;reads systick value
;returns deciseconds in HL
Clock.ReadTick:
        ld hl, (Clock.systick)
        ret

;sets systick valie
;expects deciseconds on DS
Clock.SetTick:
        push hl
        DSPeekHL 0
        ld a, h
        ld (Clock.systick), A
        ld a, l
        ld (Clock.systick+1), A
        pop hl
        ret

Clock.ReadMillisFn:
        ld hl, (Clock.TimeMillis)
        ret

Clock.ReadSecondsFn:
        ld a, (Clock.TimeSeconds)
        ret

Clock.ReadMinutesFn:
        ld a, (Clock.TimeMinutes)
        ret

Clock.ReadHoursFn:
        ld a, (Clock.TimeHours)
        ret

Clock.ReadDayFn:
        ld a, (Clock.DateDay)
        ret

Clock.ReadMontFn:
        ld a, (Clock.DateMonth)
        ret

Clock.ReadYearFn:
        ld hl, (Clock.DateYear)
        ret

;sets the time
;Parameters (byte seconds, byte minutes, byte hours)
Clock.SetTimeFn:
        di
        DSPeek a, 0
        ld (Clock.TimeHours), a
        DSPeek a, 1
        ld (Clock.TimeMinutes), a
        DSPeek a, 2
        ld (Clock.TimeSeconds), a
        ei
        ret

;set the date
;Parameters (byte day, byte month, word year)
Clock.SetDateFn:
        push hl
        di
        DSPeekHL 0
        ld (Clock.DateYear), hl
        DSPeek a, 2
        ld (Clock.DateMonth), a
        DSPeek a, 3
        ld (Clock.DateDay), a
        ei
        pop hl
        ret

;sleeps for n deciseconds
;expects timeout on DS
Clock.SleepFn:
        push bc
        push hl
        DSPeekHL 0
        ld bc, (Clock.systick)
        add hl, bc
    .SleepLoop:
        ld bc, (Clock.systick)
        cpBCHL
        jr nz, .SleepLoop
        pop hl
        pop bc
        ret

;interrupt handler
Clock.Interrupt:
    defc InterruptVec02 = Clock.Interrupt
        ex AF, AF'
        exx

        ld hl, (Clock.systick)
        inc hl
        ld (Clock.systick), hl

        ;date counter
        ;milliseconds
        ld hl, (Clock.TimeMillis)
        ld bc, 10
        add hl, bc
        ld (Clock.TimeMillis), hl
        ld bc, 999
        cpBCHL
        jr nc, .InterruptExit
        ld bc, 1000
        and a
        sbc hl, bc
        ld (Clock.TimeMillis), hl
        ;seconds
        ld a, (Clock.TimeSeconds)
        inc a
        ld (Clock.TimeSeconds), a
        cp 59
        jr nc, .InterruptExit
        ld a, 0
        ld (Clock.TimeSeconds), a
        ;minutes
        ld a, (Clock.TimeMinutes)
        inc a
        ld (Clock.TimeMinutes), a
        cp 59
        jr nc, .InterruptExit
        ld a, 0
        ld (Clock.TimeMinutes), a
        ;hours
        ld a, (Clock.TimeHours)
        inc a
        ld (Clock.TimeHours), a
        cp 23
        jr nc, .InterruptExit
        ld a, 0
        ld (Clock.TimeHours), a
        ;day
        ld a, (Clock.DateDay)
        inc a
        ld (Clock.DateDay), a
        ld b, 0
        push AF
        ld a, (Clock.DateMonth)
        ld c, a
        pop AF
        ld hl, .InterruptDateTable
        add hl, bc
        ld b, (hl)
        cp b
        jr c, .InterruptExit
        ld a, 0
        ld (Clock.DateDay), a
        ;month
        ld a, (Clock.DateMonth)
        inc a
        ld (Clock.DateMonth), a
        cp 11
        jr nc, .InterruptExit
        ld a, 0
        ld (Clock.DateMonth), a
        ;year
        ld hl, (Clock.DateYear)
        inc hl
        ld (Clock.DateYear), hl

    .InterruptExit:
        exx
        ex AF, AF'
        ei
        reti

    .InterruptDateTable:
        db 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

;-----------------------------------------------}