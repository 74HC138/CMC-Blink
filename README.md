This is a *nearly* empty template project for the CMC32A128.
Please note that this project is still *very much* Work In Progress.

## Features

Included right now (and working) are:
- System defines for the CMC32A128
- Assembler macros and defines for math, data organisation and easy interrupt routines
- Driver for SIO (serial io)
- Driver for ROMFS (ROM filesystem)
- Buildfile with the ability to create a ROMFS and to upload the assembled binary via CMCUpload (still a bit buggy)

WIP included:
- Driver for FAT filesystem (fat.asm)
- Driver for printf and scanf (stdio.asm)

ToDo:
- Change buildfile to use userland mounting for the ROMFS to not require root
- Driver for PIO (parallel io)
- Driver for CTC (counter timer)

## Usage

Switch out the contents of the `Main` function in main.asm with your code. 
Make shure that `include "defaultDefines.asm"` stays at the end of that file or else the interrupt vector system **will break**.
To compile your code you need vasm installed and in your path variable. To use direct upload you also need CMCUpload from the CMCBL repo. ([link](https://github.com/74HC138/CMCBL))

To compile:
`make all`
To upload:
`make upload`

Heads up, the Makefle still has some problems and is a messy patchwork as of right now. One of the side effects is that you need root acces to create the romfs image (because of mount), that **anything but linux is untested** and that you need call `make clean` before compiling your code again.

## License

This project is licensed under GPL3.
That means:
- I dont take liability for my code
- You can share and modify my code for private and comercial use as long as you link back to this project
- Derivative works must also be licensed under GPL3. That means once opensource allways opensource

Have fun