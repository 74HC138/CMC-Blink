    ifndef BASE
        defc BASE = 0x0000
    endif

    org BASE
SWI0_vec:
    ifdef BASE_PAGE
        ld a, BASE_PAGE
        out (ROM_BA), a
    endif
        jp Main

    org BASE + 0x08
SWI1_vec:
    ifdef SWI1
        jp SWI1
    else
        ret
    endif

    org BASE + 0x10
SWI2_vec:
    ifdef SWI2
        jp SWI2
    else
        ret
    endif

    org BASE + 0x18
SWI3_vec:
    ifdef SWI3
        jp SWI3
    else
        ret
    endif

    org BASE + 0x20
SWI4_vec:
    ifdef SWI4
        jp SWI4
    else
        ret
    endif

    org BASE + 0x28
SWI5_vec:
    ifdef SWI5
        jp SWI5
    else
        ret
    endif

    org BASE + 0x30
SWI6_vec:
    ifdef SWI6
        jp SWI6
    else
        ret
    endif

    org BASE + 0x38
SWI7_vec:
    ifdef SWI7
        jp SWI7
    else
        retn
    endif

IgnoreInterrupt:
        ei
        reti

    org BASE + 0x100

        addr InterruptVec00
        addr InterruptVec01
        addr InterruptVec02
        addr InterruptVec03
        addr InterruptVec04
        addr InterruptVec05
        addr InterruptVec06
        addr InterruptVec07
        addr InterruptVec08
        addr InterruptVec09
        addr InterruptVec0A;-----------------------------------------------{
        addr InterruptVec0B
        addr InterruptVec0C
        addr InterruptVec0D
        addr InterruptVec0E
        addr InterruptVec0F

        addr InterruptVec10
        addr InterruptVec11
        addr InterruptVec12
        addr InterruptVec13
        addr InterruptVec14
        addr InterruptVec15
        addr InterruptVec16
        addr InterruptVec17
        addr InterruptVec18
        addr InterruptVec19
        addr InterruptVec1A
        addr InterruptVec1B
        addr InterruptVec1C
        addr InterruptVec1D
        addr InterruptVec1E
        addr InterruptVec1F

        addr InterruptVec20
        addr InterruptVec21
        addr InterruptVec22
        addr InterruptVec23
        addr InterruptVec24
        addr InterruptVec25
        addr InterruptVec26
        addr InterruptVec27
        addr InterruptVec28
        addr InterruptVec29
        addr InterruptVec2A
        addr InterruptVec2B
        addr InterruptVec2C
        addr InterruptVec2D
        addr InterruptVec2E
        addr InterruptVec2F

        addr InterruptVec30
        addr InterruptVec31
        addr InterruptVec32
        addr InterruptVec33
        addr InterruptVec34
        addr InterruptVec35
        addr InterruptVec36
        addr InterruptVec37
        addr InterruptVec38
        addr InterruptVec39
        addr InterruptVec3A
        addr InterruptVec3B
        addr InterruptVec3C
        addr InterruptVec3D
        addr InterruptVec3E
        addr InterruptVec3F

        addr InterruptVec40
        addr InterruptVec41
        addr InterruptVec42
        addr InterruptVec43
        addr InterruptVec44
        addr InterruptVec45
        addr InterruptVec46
        addr InterruptVec47
        addr InterruptVec48
        addr InterruptVec49
        addr InterruptVec4A
        addr InterruptVec4B
        addr InterruptVec4C
        addr InterruptVec4D
        addr InterruptVec4E
        addr InterruptVec4F

        addr InterruptVec50
        addr InterruptVec51
        addr InterruptVec52
        addr InterruptVec53
        addr InterruptVec54
        addr InterruptVec55
        addr InterruptVec56
        addr InterruptVec57
        addr InterruptVec58
        addr InterruptVec59
        addr InterruptVec5A
        addr InterruptVec5B
        addr InterruptVec5C
        addr InterruptVec5D
        addr InterruptVec5E
        addr InterruptVec5F

        addr InterruptVec60
        addr InterruptVec61
        addr InterruptVec62
        addr InterruptVec63
        addr InterruptVec64
        addr InterruptVec65
        addr InterruptVec66
        addr InterruptVec67
        addr InterruptVec68
        addr InterruptVec69
        addr InterruptVec6A
        addr InterruptVec6B
        addr InterruptVec6C
        addr InterruptVec6D
        addr InterruptVec6E
        addr InterruptVec6F
        
        addr InterruptVec70
        addr InterruptVec71
        addr InterruptVec72
        addr InterruptVec73
        addr InterruptVec74
        addr InterruptVec75
        addr InterruptVec76
        addr InterruptVec77
        addr InterruptVec78
        addr InterruptVec79
        addr InterruptVec7A
        addr InterruptVec7B
        addr InterruptVec7C
        addr InterruptVec7D
        addr InterruptVec7E
        addr InterruptVec7F