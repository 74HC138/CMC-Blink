    defc FAT_BLOCKSIZE = 512
    defc FAT_DISPLAY_VOLUMESTRING = 1
    defc FAT_DISPLAY_VOLUMEID = 1

    defc _FAT_OEMName = 3
    defc _FAT_BytsPerSec = 11
    defc _FAT_SecPerClus = 13
    defc _FAT_RsvdSecCnt = 14
    defc _FAT_NumFats = 16
    defc _FAT_RootEntCnt = 17
    defc _FAT_TotSec16 = 19
    defc _FAT_FATsz16 = 22


    struct FILE
        CurrentCluster:
            dc 2
        InitialCluster:
            dc 2
        Offset:
            dc 2
        Size:
            dc 4
        Remainder:
            dc 4
    endstruct

    struct FILEEntry
        Name:
            dc 11
        Atr:
            dc 1
        Rsrvd1:
            dc 2
        CreatT:
            dc 2
        CreatD:
            dc 2
        AccessD:
            dc 2
        Rsrvd2:
            dc 2
        ModiT:
            dc 2
        ModiD:
            dc 2
        Cluster:
            dc 2
        Size:
            dc 4
    endstruct


    dsect
FAT:
    .pReadFunction:
        dc 2
    .pWriteFunction:
        dc 2
    .dataBuffer:
        dc FAT_BLOCKSIZE
    .iRoot:
        dc 2
    .iFat:
        dc 2
    .RootCnt:
        dc 1
    dend

;Initializes FAT driver
;Parameters:
;(void readFunction)(uint16_t LBA, uint8_t* buffer)
;(void writeFunction)(uint16_t LBA, uint8_t* buffer)
;Returns:
;0: succes
;>0: error
FAT.init:
        DSPeekBC 0
        ld (.pWriteFunction), bc
        DSPeekBC 2
        cpBCNN 0x0000
        ld a, 0x01
        ret z ;return 0x01 when no read function is given
        ld (.pReadFunction), bc

        ;read first block
        DSPushNN 0x0000
        DSPushNN .dataBuffer
        callNNin .pReadFunction
        DSRestore 4
        ld iy, .dataBuffer

        ;check signature
        ld a, (iy+38)
        cp 0x28
        jr z, .initSignatureOK
        cp 0x29
        jr z, .initSignatureOK
        ld a, 0x02
        ret ;return 0x02 if signature check failed -> this is not fat12/16
    .initSignatureOK:

        
        ;get root directory index
        ;reservedSectors + (FATSize * FATCnt)
        ld l, (iy + _FAT_FATsz16)
        ld h, (iy + (_FAT_FATsz16 + 1))
        ld a, (iy + _FAT_NumFats)
    .initFATMul:
        cp 0x01
        jr z, .initFATMulEnd
        jr c, .initFATMulEnd
        add hl, hl
        dec a
        jr .initFATMul
    .initFATMulEnd:
        ld c, (iy + _FAT_RsvdSecCnt)
        ld b, (iy + (_FAT_RsvdSecCnt + 1))
        add hl, bc
        ld (FAT.iRoot), hl
        
        ;get root entry count
        ld l, (iy + _FAT_RootEntCnt)
        ld h, (iy + (_FAT_RootEntCnt + 1))
        ld a, 0x00
        cp h
        ld a, 0x03
        ret nz ;return 0x03 when root entry count > 255. Cant handle that
        ld a, l
        ld (FAT.RootCnt), a

        ;get FAT index
        ld l, (iy + _FAT_RsvdSecCnt)
        ld h, (iy + (_FAT_RsvdSecCnt + 1))
        ld (FAT.iFat), hl

    if FAT_DISPLAY_VOLUMESTRING
        ;display the volume string if flag is set
        DSPushNN .initVolumeStringPrefix
        call Serial1.puts
        DSRestore 2
        ld hl, .dataBuffer
        ld bc, 0x002b
        add hl, bc
        ld d, 11
    .initDisplayStringLoop:
        ld a, (hl)
        DSPush a
        call Serial1.putc
        DSRestore 1
        inc hl
        dec d
        ld a, 0x00
        cp d
        jr nz, .initDisplayStringLoop
        ld a, '\n'
        DSPush a
        call Serial1.putc
        DSRestore 1
    endif
    if FAT_DISPLAY_VOLUMEID
        ;display the volume ID if flag is set
        DSPushNN .initVolumeIDPrefix
        call Serial1.puts
        DSRestore 2
        ld hl, .dataBuffer
        ld bc, 0x002a
        add hl, bc
        repeat 4
            ld a, (hl)
            dec hl
            DSPush a
        endrepeat
        call stdio.putu32h
        DSRestore 4
        ld a, '\n'
        DSPush a
        call Serial1.putc
        DSRestore 1
    endif

        ld a, 0x00
        ret



    .initVolumeStringPrefix:
        string "Volume Label:"
    .initVolumeIDPrefix:
        string "Volume ID:"

;Get number of files in root folder
;Returns:
;number of root files
FAT.getRootFileCount:
        push hl
        push bc
        push de
        push iy

        ld hl, (.iRoot)
        ld a, (.RootCnt)
        ld d, a
        ld bc, 0

    .getRootFileCountOuterLoop:
        DSPushHL
        DSPushNN .dataBuffer
        callNNin .pReadFunction
        DSRestore 4
        ld iy, .dataBuffer
        ld e, 16

    .getRootFileCountInnerLoop:
            ld a, (iy + 0)
            cp 0
            jr z, .getRootFileCountExit
            ld a, (iy + 11)
            bit 3, a
            jr nz, .getRootFileCountSkip
            inc c
    .getRootFileCountSkip:
            push bc
            ld bc, 32
            add iy, bc
            pop bc
            dec e
            dec d
            ld a, 0
            cp d
            jr z, .getRootFileCountExit
            cp e
            jr nz, .getRootFileCountInnerLoop

        inc hl
        jr .getRootFileCountOuterLoop

    .getRootFileCountExit:
        pop iy
        pop de
        ld a, c
        pop bc
        pop hl
        ret
;Gets the information of the indexed file in the root folder
;Parameters:
;uint8_t index
;(char[32]) infoBuffer
;Returns:
;0: OK
;>0: Error
FAT.getRootFile:
        push hl
        push bc
        push iy
        push de

        ld hl, (.iRoot)
        DSPeek c, 2

    .getRootFileOuterLoop:
        DSPushHL
        DSPushNN .dataBuffer
        callNNin .pReadFunction
        DSRestore 4
        ld iy, .dataBuffer
        ld e, 16
    .getRootFileInnerLoop:
            ld a, (iy + 0)
            cp 0
            jr z, .getRootFileExit
            ld a, (iy + 11)
            bit 3, a
            jr nz, .getRootFileSkip
            
            ld a, 0
            cp c
            jr z, .getRootFileFound
            dec c
    .getRootFileSkip:
            push bc
            ld bc, 32
            add iy, bc
            pop bc
            dec e
            ld a, 0
            cp e
            jr nz, .getRootFileInnerLoop

        inc hl
        jr .getRootFileOuterLoop

    .getRootFileExit:
        pop de
        pop iy
        pop bc
        pop hl
        ld a, 1
        ret

    .getRootFileFound:
        DSPeekDE 0
        push iy
        pop hl
        ld bc, 32
        ldir
        pop de
        pop iy
        pop bc
        pop hl
        ld a, 0
        ret

;Gets the next cluster index
;Parameters:
;uint16_t cluster
;Returns:
;uint16_t nextCluster

FAT.getNext:
        push hl
        push de
        push iy

        ;fat_offset = cluster * 1.5
        DSPeekHL 0
        DSPeekBC 0
        srl b
        rr c
        add hl, bc
        ;fat_sector = iFat + (fat_offset / sector_size)
        ld c, h
        srl c
        ld b, 0
        push hl
        ld hl, (FAT.iFat)
        add hl, bc
        ld d, h
        ld e, l
        pop hl

        ;ent_offset = fat_offset % sector_size
        ld a, h
        and 0x01
        ld h, a

        ld iy, .dataBuffer
        ld b, h
        ld c, l
        add iy, bc

        ;hl -> ent_offset
        ;de -> fat_sector
        ;iy -> &table_value

        DSPushDE
        DSPushNN .dataBuffer
        callNNin .pReadFunction
        DSRestore 4
        cpHLNN 511
        ld c, (iy)
        ld b, (iy+1)
        jr nz, .getNextNoStraddle
            ;when table_value is split between two clusters the lower byte must be loaded from cluster and the high byte from cluster + 1
            ld c, (iy)
            inc de
            DSPushDE
            DSPushNN .dataBuffer
            callNNin .pReadFunction
            DSRestore 4
            ld iy, .dataBuffer
            ld b, (iy)
    .getNextNoStraddle:
        DSPeek a, 0
        bit 0, a
        jr z, .getNextMask
            ;if (cluster & 1) table_value = table_value >> 4
            repeat 4
                srl b
                rr c
            endrepeat
            jp .getNextFATExit
    .getNextMask:
            ;if !(cluster & 1) table_value = table_value & 0x0fff
            ld a, b
            and 0x0f
            ld b, a
            jp .getNextFATExit

    .getNextFATExit:
        pop iy
        pop de
        pop hl
        ret

;Opens file
;Parameters:
;FILE* file
;char[11] name
;Returns:
;0: OK
;>0: Error
FAT.open:
        push hl
        push bc
        push iy
        push de

        ld hl, (.iRoot)

    .openOuterLoop:
        DSPushHL
        DSPushNN .dataBuffer
        callNNin .pReadFunction
        DSRestore 4
        ld iy, .dataBuffer
        ld e, 16
    .openInnerLoop:
            ld a, (iy + 0)
            cp 0
            jr z, .openError
            ld a, (iy + 11)
            bit 3, a
            jr nz, .openSkip
            
            push hl
            push de
            push iy
            pop hl
            DSPeekBC 0
            ld e, 11
    .openCompareLoop:
                ld a, 0
                cp e
                jr z, .openFound
                ld a, (bc)
                cp (hl)
                jr nz, .openCompareExit
                inc bc
                inc hl
                dec e
                jr .openCompareLoop
    .openCompareExit:
            pop de
            pop hl
    .openSkip:
            push bc
            ld bc, 32
            add iy, bc
            pop bc
            dec e
            ld a, 0
            cp e
            jr nz, .openInnerLoop

        inc hl
        jr .openOuterLoop

    .openError:
        pop de
        pop iy
        pop bc
        pop hl
        ld a, 1
        ret

    .openFound:
        pop de
        pop hl
        DSPeekHL 2
        push ix
        push hl
        pop ix
        ld c, (iy + FILEEntry.Cluster)
        ld b, (iy + FILEEntry.Cluster + 1)
        ld (ix + FILE.CurrentCluster), c
        ld (ix + FILE.CurrentCluster + 1), b
        ld (iy + FILE.InitialCluster), c
        ld (ix + FILE.InitialCluster + 1), b
        ld a, 0
        ld (ix + FILE.Offset), a
        ld (ix + FILE.Offset + 1), a
        ld c, (iy + FILEEntry.Size)
        ld b, (iy + FILEEntry.Size + 1)
        ld (ix + FILE.Size), c
        ld (ix + FILE.Size + 1), b
        ld (ix + FILE.Remainder), c
        ld (ix + FILE.Remainder + 1), b
        ld c, (iy + FILEEntry.Size + 2)
        ld b, (iy + FILEEntry.Size + 3)
        ld (ix + FILE.Size + 2), c
        ld (ix + FILE.Size + 3), b
        ld (ix + FILE.Remainder + 2), c
        ld (ix + FILE.Remainder + 3), b
        pop ix
        pop de
        pop iy
        pop bc
        pop hl
        ld a, 0
        ret

;Reads length bytes from file to buffer
;Parameters:
;FILE* file
;char* buffer
;int length
;Returns:
;0: OK
;1: Invalid Cluster
;2: OutOfData
;3: EndOfFile
;--------------------------------------------
    ;DOES NOT WORK. NEEDS TO BE REDON
    ;TERRIBLE CODE!!!
    ;TERRIBLY INEFICIENT!!!
    ;JUST NO!!!
;--------------------------------------------
FAT.read:
        push hl
        push bc
        push de
        push iy

        DSPeekIY 4
        ld l, (iy + FILE.CurrentCluster)
        ld h, (iy + FILE.CurrentCluster)
        cpHLNN 0x0002
        jp c, .readError
        DSPeekDE 0
        DSPeekBC 2
        ;bc: buffer
        ;de: length
        ;iy: file

        push ix
        ld ix, .dataBuffer
        push bc
        ld c, (iy + FILE.Offset)
        ld b, (iy + FILE.Offset + 1)
        push bc
        pop hl
        add ix, bc
        pop bc
        ;hl: offset

    .readOutterLoop:
            push hl
            ld l, (iy + FILE.CurrentCluster)
            ld h, (iy + FILE.CurrentCluster)
            pop ix
            DSPushHL
            DSPushNN .dataBuffer
            callNNin .pReadFunction
            DSRestore 4
            push ix
            pop hl
    .readInnerLoop:
                ld a, (ix)
                ld (bc), a
                inc ix
                inc bc
                inc hl
                dec de

                push hl
                push bc
                push de
                ld bc, 0
                ld l, (iy + FILE.Remainder)
                ld h, (iy + (FILE.Remainder + 1))
                scf
                sbc hl, bc
                ld (iy + FILE.Remainder), l
                ld (iy + (FILE.Remainder + 1)), h
                ld d, h
                ld e, l
                ld l, (iy + (FILE.Remainder + 2))
                ld h, (iy + (FILE.Remainder + 3))
                sbc hl, bc
                ld (iy + (FILE.Remainder + 2)), l
                ld (iy + (FILE.Remainder + 3)), h
                ld a, 0
                or d
                or e
                ld b, h
                ld c, l
                or b
                or c
                pop de
                pop bc
                pop hl
                jp z, .readEOF
                cpDENN 0
                jr z, .readExit
                cpHLNN 512
                jr nz, .readInnerLoop

            ld l, (iy + FILE.CurrentCluster)
            ld h, (iy + FILE.CurrentCluster)
            pop ix
            push bc
            DSPushHL
            call FAT.getNext
            DSRestore 2
            cpBCNN 0x0FF8
            jr nc, .readOutOfData
            ld (iy + FILE.CurrentCluster), c
            ld (iy + FILE.CurrentCluster + 1), b
            pop bc
            push ix
            ld ix, .dataBuffer
            ld hl, 0
            jp .readOutterLoop

    .readOutOfData:
        pop bc

        ld (iy + FILE.Remainder), 0
        ld (iy + (FILE.Remainder + 1)), 0
        ld (iy + (FILE.Remainder + 2)), 0
        ld (iy + (FILE.Remainder + 3)), 0

        pop iy
        pop de
        pop bc
        pop hl
        ld a, 2
        ret

    .readEOF:
        pop ix
        pop iy
        pop de
        pop bc
        pop hl
        ld a, 3
        ret

    .readExit:

        ld (iy + FILE.Offset), l
        ld (iy + (FILE.Offset + 1)), h

        pop ix
        pop iy
        pop de
        pop bc
        pop hl
        ld a, 0
        ret

    .readError:
        pop iy
        pop de
        pop bc
        pop hl
        ld a, 1
        ret

FAT.close:





