# STM32 Template Creator

This project aims to create a generic makefile useful for developing for STM32 without SPL or other libraries - just the
CMSIS. While it is not perfect, it does its job. I believe it's good for most STM32 microprocessors (apart from the blink
`main.c` - this will only work in special cases). If you don't want to retype everything every time, you can create a 
file with just the answers to the questions, such as `in` - then project creation will be as simple as `./stm32_template < in`!

The script assumes you have downloaded ARM CMSIS from [official ARM website](www.arm.com), as well as have a folder
containing needed STM32Cubes, available at [official ST website](www.st.com). You need (once!) to write those locations
as appropriate variables in `stm32_template`.

Sample run:
```
[adam@adam-Y510P /tmp]λ ./stm32_template
Hello! This script will interactively create a STM32 project.
Config variables:
ARM CMSIS location: /home/adam/stm32/ARM_CMSIS
Generic makefile: /home/adam/stm32/generic/makefile
Location of STM32Cubes: /home/adam/stm32

Please type project name: justTest

Creating project justTest...

Listing possible architecture choices:

ARMCM3
ARMCM4
ARMSC000
ARMCM0
ARMSC300
ARMCM7
ARMCM0plus
Please choose architecture (one of above): ARMCM0
You chose ARMCM0.
Copying linker script and startup assembly file...
Listing possible core files:

core_cm0.h
core_cm4.h
core_cm3.h
core_cm7.h
core_cm0plus.h
Please choose one fitting your project: core_cm0.h
You chose core_cm0.h.
Copying core_cm0.h and cmsis_gcc.h...
Listing STM32 Cubes:

STM32Cube_F2
STM32Cube_F1
STM32Cube_F3
STM32Cube_F4
STM32Cube_F0
Please choose one fitting your project: STM32Cube_F0
You chose STM32Cube_F0.
Listing include files:

stm32f070xb.h
stm32f031x6.h
stm32f071xb.h
stm32f030xc.h
stm32f070x6.h
stm32f091xc.h
stm32f078xx.h
stm32f072xb.h
stm32f048xx.h
stm32f051x8.h
stm32f030x6.h
stm32f030x8.h
stm32f0xx.h
stm32f042x6.h
stm32f058xx.h
stm32f098xx.h
stm32f038xx.h
Please choose the most generic one - probably ending in 'xx.h': stm32f0xx.h
You chose stm32f0xx.h.
Now read the file and find macro (for example STM32F405xx) and include file (for example stm32f405xx.h) corresponding to your device.
Press enter to continue.
Type the macro, for example STM32F405xx: STM32F030x6
You chose STM32F030x6.
Type the include file, for example stm32f405xx.h: stm32f030x6.h
You chose stm32f030x6.h.
Creating simple blink file - hopefully it compiles.
Patching linker script...
How big in bytes is flash: 0x4000
How big in bytes is RAM: 0x1000
Patching makefile...
How big in bytes the stack is: 0x400
How big in bytes the heap is: 0x0
Which mcpu to use - for example cortex-m0: cortex-m0
Which mode to use - thumb or arm: thumb
Which float abi to use: soft, softfp or hard: soft
Patching core file...
```
Now we can go into our new folder, check that everything is OK, compile and flash the device:
```
[adam@adam-Y510P /tmp]λ cd justTest/
[adam@adam-Y510P /tmp/justTest]λ ls -R
.:
inc  lnk  makefile  obj  src

./inc:
cmsis_gcc.h  core_cm0.h  stm32f030x6.h  stm32f0xx.h

./lnk:
gcc_arm.ld

./obj:

./src:
main.c  system

./src/system:
startup_ARMCM0.S
[adam@adam-Y510P /tmp/justTest]λ make flash
Compiling src/main.c
arm-none-eabi-gcc -c src/main.c -I"inc" -mcpu=cortex-m0 -mthumb -mfloat-abi=soft  -O0 -g3 -Wall -Wextra -ffunction-sections  -MMD -MP -DSTM32F030x6 -D__STACK_SIZE=0x400 -D__HEAP_SIZE=0x0 -std=c11 -o obj/main.o

Compiling src/system/startup_ARMCM0.S
arm-none-eabi-gcc -c src/system/startup_ARMCM0.S -I"inc" -mcpu=cortex-m0 -mthumb -mfloat-abi=soft  -O0 -g3 -Wall -Wextra -ffunction-sections  -MMD -MP -DSTM32F030x6 -D__STACK_SIZE=0x400 -D__HEAP_SIZE=0x0 -o obj/system/startup_ARMCM0.o

Linking final ELF...
arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb -mfloat-abi=soft  -T"lnk/gcc_arm.ld" -Wl,--gc-sections  -fno-exceptions -fno-rtti -o obj/justTest.elf obj/main.o  obj/system/startup_ARMCM0.o -lm

Creating bin file...
arm-none-eabi-objcopy -O binary obj/justTest.elf obj/justTest.bin

Creating lst file...
arm-none-eabi-objdump -h -S obj/justTest.elf > obj/justTest.lst

Printing size...
arm-none-eabi-size --format=berkeley obj/justTest.elf
   text	   data	    bss	    dec	    hex	filename
   1504	   1080	     28	   2612	    a34	obj/justTest.elf

Flashing...
st-flash --reset write obj/justTest.bin 0x08000000
2016-05-02T19:37:47 INFO src/stlink-common.c: Loading device parameters....
2016-05-02T19:37:47 INFO src/stlink-common.c: Device connected is: F0 small device, id 0x10006444
2016-05-02T19:37:47 INFO src/stlink-common.c: SRAM size: 0x1000 bytes (4 KiB), Flash: 0x4000 bytes (16 KiB) in pages of 1024 bytes
2016-05-02T19:37:48 INFO src/stlink-common.c: Attempting to write 2584 (0xa18) bytes to stm32 address: 134217728 (0x8000000)
Flash page at addr: 0x08000800 erased
2016-05-02T19:37:48 INFO src/stlink-common.c: Finished erasing 3 pages of 1024 (0x400) bytes
2016-05-02T19:37:48 INFO src/stlink-common.c: Starting Flash write for VL/F0/F3 core id
2016-05-02T19:37:48 INFO src/stlink-common.c: Successfully loaded flash loader in sram
  2/2 pages written
2016-05-02T19:37:48 INFO src/stlink-common.c: Starting verification of write complete
2016-05-02T19:37:48 INFO src/stlink-common.c: Flash written and verified! jolly good!
```
