#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/pads_bank0.h"

.thumb_func @ Tell the assembler which type of ARM
.global main @ Provide program starting address to linker

.align 4
main:

        @ pin initialization for all pins corresponding to the pins for the seven segment display
        MOV R0, #16 @pin G
        BL gpioinit
        MOV R0, #17 @pin F
        BL gpioinit
        MOV R0, #18 @pin A
        BL gpioinit
        MOV R0, #19 @pin B
        BL gpioinit
        MOV R0, #20 @pin C
        BL gpioinit
        MOV R0, #21 @pin D
        BL gpioinit
        MOV R0, #22 @pin E
        BL gpioinit

@  0           1           2           3            4          5           6           7           8           9
@ #0b0111111, #0b0001100, #0b1011011, #0b0011110, #0b1101100, #0b1110110 ,#0b1110111, #0b0011100, #0b1111111, #0b1111100
@    GFABCDE

        loop:
        MOV R0, #16
        MOV R5, #0b0111111 @ loading data for the digit zero into register 5
        BL gpio_on @ uses the data in register 5 to stream the corresponding output in gpio
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b0001100 @ loading data for the digit one into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1011011 @ loading data for the digit two into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1011110 @ loading data for the digit three into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1101100 @ loading data for the digit four into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1110110 @ loading data for the digit five into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1110111 @ loading data for the digit six into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b0011100 @ loading data for the digit seven into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1111111 @ loading data for the digit eight into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        MOV R0, #16
        MOV R5, #0b1111100 @ loading data for the digit nine into register 5
        BL gpio_on
        BL delay
        BL gpio_off

        B loop

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
        MOV R3, R5 @turns on pins specified in register 5
        LSL R3, R0
        LDR R2, gpiobase
        STR R3, [R2, #SIO_GPIO_OUT_SET_OFFSET]
        BX LR

gpio_off:
        MOV R3, #0b1111111 @turns all of the pins in the output off
        LSL R3, R0
        LDR R2, gpiobase
        STR R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]
        BX LR

delay:
        MOV R2, #0
        MOV R3, #0xFF
        LSL R3, #17 @changes the end of the timer to 0xFF * 2^17 so it lasts longer (about a second)
        indelay:
        ADD R2, #1
        CMP R2, R3
        BCC indelay @ loop until R2 hits a value of 0 xFF
        BX LR

.align 4
        gpiobase: .word SIO_BASE
        iobank0: .word IO_BANK0_BASE
        padsbank0: .word PADS_BANK0_BASE
        setoffset: .word REG_ALIAS_SET_BITS



        
