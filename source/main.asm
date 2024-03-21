;Includes
;-----------------------------------------------{
    include "CMC32A128.asm"
    include "macros.asm"
    defc BASE = ROM_BANK1
    defc BASE_PAGE = 0x11
    include "vector.asm"
    include "drivers/serial.asm"
    include "drivers/romfs.asm"
    include "drivers/fat.asm"
    include "drivers/stdio.asm"
    include "drivers/math.asm"
    include "drivers/clock.asm"
;-----------------------------------------------}
;Variables
;-----------------------------------------------{
    dsect
DataStack:
        dc 256
DataStackEnd:
Stack:
        dc 256
StackEnd:
    dend
;-----------------------------------------------}
;Functions
;-----------------------------------------------{

;Main function
;Bootstrap entry
Main:
        ;initialize bank
        ld a, 0x11
        out (ROM_BA), a
        jp Bootstrap
Bootstrap:
        ;switch high bank to bank 2 for 32k flat rom space
        ld a, 0x11
        out (ROM_BA), a
        ld sp, StackEnd
        ld ix, DataStackEnd
        ld a, >(BASE & 0xff00)
        ld i, a
        im 2
        call Setup
    .loop:
        call Loop
        jr .loop


Setup:
        DSPushN BAUD115200
        call Serial1.init
        DSRestore 1

        DSPushNN .greeting
        call Serial1.puts
        DSRestore 2

        call Clock.Init
        ret
    
    .greeting:
        string "Blink example\n"

Loop:
        DSPushNN .loopText
        call Serial1.puts
        DSRestore 2

        ld a, 0x00
        out (DAC_0), a
        ld a, 0xff
        out (DAC_1), a

        DSPushNN 50
        call Clock.Sleep
        DSRestore 2

        ld a, 0xff
        out (DAC_0), a
        ld a, 0x00
        out (DAC_1), a

        DSPushNN 50
        call Clock.Sleep
        DSRestore 2

        ret

    .loopText:
        string "Loopdiloop\n"

;-----------------------------------------------}
;Post program include
;Needs to be at the end
    include "defaultDefines.asm"