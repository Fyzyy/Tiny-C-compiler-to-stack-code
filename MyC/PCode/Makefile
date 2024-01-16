CC = gcc
CFLAGS = -c
OBJS = PCode.o
BUILD_DIR = build
SRC_DIR = src


pcode: $(SRC_DIR)/PCode.c $(SRC_DIR)/PCode.h
	$(CC) $(CFLAGS) $(SRC_DIR)/PCode.c -o $(BUILD_DIR)/PCode.o

Ex%: pcode $(SRC_DIR)/Ex%_pcode.c
	$(CC) $(BUILD_DIR)/PCode.o $(SRC_DIR)/Ex$*_pcode.c -o $(BUILD_DIR)/$@

clean:
	rm -f $(SRC_DIR)/*_pcode.c $(BUILD_DIR)/*.o $(BUILD_DIR)/Ex*
