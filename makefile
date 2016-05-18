
PROJ:=REPLACE_ME_PROJ

SRC:=src
OBJ:=obj

STFLASH:=st-flash

TOOLCHAIN:=arm-none-eabi

PROCESSOR:=REPLACE_ME_MCPU REPLACE_ME_THUMB REPLACE_ME_FLOAT 

OPT := -O0
DBG := -g3
WARN:= -Wall -Wextra

FLAGS:=-I"inc"
FLAGS+=$(PROCESSOR)
FLAGS+=$(OPT)
FLAGS+=$(DBG)
FLAGS+=$(WARN)
FLAGS+=-ffunction-sections 
FLAGS+=-fno-exceptions -fno-rtti
FLAGS+=-MMD -MP
FLAGS+=REPLACE_ME_DSTM REPLACE_ME_STACKSIZE REPLACE_ME_HEAPSIZE REPLACE_ME_FCPU

C_FLAGS:=   $(FLAGS) -std=c11
CPP_FLAGS:= $(FLAGS) -std=c++14
S_FLAGS:=   $(FLAGS)

LD_FLAGS:=$(PROCESSOR)
LD_FLAGS+=-T"lnk/gcc_arm.ld" -Wl,--gc-sections 
LD_FLAGS+=-fno_exceptions -fno-rtti

LIBS:=-lm -lc_nano

#----------------------------------------------------------------

C_SOURCES:=$(shell find $(SRC) -name *.c)
C_OBJECTS:=$(subst .c,.o,$(subst $(SRC),$(OBJ),$(C_SOURCES)))

CPP_SOURCES:=$(shell find $(SRC) -name *.cpp)
CPP_OBJECTS:=$(subst .cpp,.o,$(subst $(SRC),$(OBJ),$(CPP_SOURCES)))

S_SOURCES:=$(shell find $(SRC) -name *.S)
S_OBJECTS:=$(subst .S,.o,$(subst $(SRC),$(OBJ),$(S_SOURCES)))

OBJECTS:=$(C_OBJECTS) $(CPP_OBJECTS) $(S_OBJECTS)

ELFFILE:=$(OBJ)/$(PROJ).elf
BINFILE:=$(OBJ)/$(PROJ).bin
LSTFILE:=$(OBJ)/$(PROJ).lst

SRC_DIRS:=$(shell find $(SRC) -type d)
OBJ_DIRS:=$(subst $(SRC),$(OBJ),$(SRC_DIRS))

DEPS:=$(OBJECTS:.o=.d)

all: directories $(BINFILE) $(LSTFILE) printsize

flash: all
	@echo "Flashing..."
	$(STFLASH) --reset write $(BINFILE) 0x08000000
	@echo
	@echo "Remember to reset the board - it might be not fully reset."

$(C_OBJECTS): $(OBJ)/%.o: $(SRC)/%.c
	@echo "Compiling $<"
	$(TOOLCHAIN)-gcc -c $< $(C_FLAGS) -o $@
	@echo
flags_c:
	@echo $(C_FLAGS)
$(CPP_OBJECTS): $(OBJ)/%.o: $(SRC)/%.cpp
	@echo "Compiling $<"
	$(TOOLCHAIN)-g++ -c $< $(CPP_FLAGS) -o $@
	@echo
flags_cpp:
	@echo $(CPP_FLAGS)
$(S_OBJECTS): $(OBJ)/%.o: $(SRC)/%.S
	@echo "Compiling $<"
	$(TOOLCHAIN)-gcc -c $< $(S_FLAGS) -o $@
	@echo
flags_S:
	@echo $(S_FLAGS)

directories:
	@mkdir -p $(OBJ_DIRS)

$(ELFFILE): $(OBJECTS)
	@echo "Linking final ELF..."
	$(TOOLCHAIN)-gcc $(LD_FLAGS) -o $(ELFFILE) $(OBJECTS) $(LIBS)
	@echo

$(BINFILE): $(ELFFILE)
	@echo "Creating bin file..."
	$(TOOLCHAIN)-objcopy -O binary $(ELFFILE) $(BINFILE)
	@echo

$(LSTFILE): $(ELFFILE)
	@echo "Creating lst file..."
	$(TOOLCHAIN)-objdump -h -S $(ELFFILE) > $(LSTFILE)
	@echo

printsize: $(ELFFILE)
	@echo "Printing size..."
	$(TOOLCHAIN)-size --format=berkeley $(ELFFILE)
	@echo

clean:
	@echo "Cleaning objects..."
	-rm -rf $(OBJ)/*
	@echo

.PHONY: all clean printsize directories flags_c flags_cpp flags_S

-include $(DEPS)
