.PHONY: all clean test

# Compiler options
CC = gcc
CFLAGS = -Wextra
LDFLAGS = -lm

# Directories
BUILD_DIR = PCode/build
SRC_DIR = PCode/src

# Files
LANG_SOURCES = lex.yy.c y.tab.c
LANG_OBJECTS = $(BUILD_DIR)/PCode.o Table_des_symboles.o Table_des_chaines.o symb_list.o

# Targets
all: lang

# Bison and Flex rules
y.tab.c lex.yy.c: lang.y lang.l
	bison -v -y -d -Wcounterexamples lang.y
	flex lang.l

# Compile PCode
$(BUILD_DIR)/PCode.o: $(SRC_DIR)/PCode.c $(SRC_DIR)/PCode.h
	$(MAKE) -C PCode pcode

# Compile language
lang: $(LANG_SOURCES) $(LANG_OBJECTS)
	$(CC) $(CFLAGS) $(LANG_SOURCES) $(LANG_OBJECTS) -o $@ $(LDFLAGS)

# Clean
clean:
	rm -f $(LANG_SOURCES) *.o y.tab.h lang *~ *.output
	$(MAKE) -C PCode clean