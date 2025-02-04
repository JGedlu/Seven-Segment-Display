# include "hardware/regs/addressmap.h"
# include "hardware/regs/sio.h"
# include "hardware/regs/io_bank0.h"
# include "hardware/regs/pads_bank0.h"

.align 4
gpiobase: .word SIO_BASE
iobank0: .word IO_BANK0_BASE
padsbank0: .word PADS_BANK0_BASE
setoffset: .word REG_ALIAS_SET_BITS

gpioinit:
@ initialize the GPIO
        MOV R3, #1
        LSL R3, R0 @ shift to pin position
        LDR R2, gpiobase
        STR R3, [R2, #SIO_GPIO_OE_SET_OFFSET]
        STR R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]
        @ enable I/O for the pin
        LDR R2, padsbank0
        LSL R3, R0, #2 @ pin * 4 for register address
        ADD R2, R3 @ actual registers for the pin
        MOV R1, #PADS_BANK0_GPIO0_IE_BITS
        LDR R4, setoffset
        ORR R2, R4
        STR R1, [R2, #PADS_BANK0_GPIO0_OFFSET]
        @ set the function to SIO
        LSL R0, #3
        LDR R2, iobank0
        ADD R2, R0
        MOV R1, #IO_BANK0_GPIO3_CTRL_FUNCSEL_VALUE_SIO_3
        STR R1, [R2, #IO_BANK0_GPIO0_CTRL_OFFSET]
        BX LR @ return to caller , note that the caller must have
        @ jumped here using BX or BLX for this to work

gpio_on:
        MOV R3, #1
        LSL R3, R0
        LDR R2, gpiobase
        STR R3, [R2, #SIO_GPIO_OUT_SET_OFFSET]
        BX LR

gpio_off:
        MOV R3, #1
        LSL R3, R0
        LDR R2, gpiobase
        STR R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]
        BX LR

.thumb_func @ Tell the assembler which type of ARM
.global main @ Provide program starting address to linker

main:
        ADD R0, #1
        
