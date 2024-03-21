# Directories
SRC_DIR := source
BUILD_DIR := build

# Tools
ASSEMBLER := vasmz80_oldstyle
ASSEMBLER_FLAGS := -Fbin -L $(BUILD_DIR)/listing.txt -esc -o

# Find all assembly files in the source directory
ASM_FILES := $(SRC_DIR)/main.asm

# Generate corresponding object filenames in the build directory
OBJ_FILES := $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.bin,$(ASM_FILES))

ROMFS_FOLDER := romfs
ROMFS_OUTPUT := $(BUILD_DIR)/romfs.bin
ROMFS_MOUNTPOINT := romfsMount
ROMFS_SIZE := 81920
PROGRAM_SIZE := 32768

MKFS_FLAGS := -f 1 -F 12 -i 0xDEADBEEF -n "Template" -s 1 -S 512 -v -r 32

BIN_OUTPUT := rom.bin

PORT = /dev/ttyACM0
UPLOADTOOL = CMCUpload

# Targets
all: bin

# Rule to assemble .asm files into .bin files
$(BUILD_DIR)/%.bin: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) $@ $<

# Rule to create the build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


upload: bin
	$(UPLOADTOOL) -p $(PORT) -r -v -i $(BUILD_DIR)/$(BIN_OUTPUT)

.PHONY: romfs
romfs: $(BUILD_DIR)
	touch $(ROMFS_OUTPUT)

	@if [ -d "$(ROMFS_FOLDER)" ]; then \
		dd if=/dev/zero of=$(ROMFS_OUTPUT) count=$(ROMFS_SIZE)B; \
		mkfs.fat $(ROMFS_OUTPUT) $(MKFS_FLAGS); \
		if [ -d "$(ROMFS_MOUNTPOINT)" ]; then \
			rm $(ROMFS_MOUNTPOINT) -r; \
		fi; \
		mkdir $(ROMFS_MOUNTPOINT); \
		sudo mount -t msdos -o loop $(ROMFS_OUTPUT) $(ROMFS_MOUNTPOINT); \
		sudo cp -r $(ROMFS_FOLDER)/. $(ROMFS_MOUNTPOINT)/.; \
		sudo umount $(ROMFS_MOUNTPOINT); \
		rm -rf $(ROMFS_MOUNTPOINT); \
	fi

bin: romfs $(OBJ_FILES)
	dd if=$(BUILD_DIR)/main.bin of=$(BUILD_DIR)/$(BIN_OUTPUT)
	truncate -s $(PROGRAM_SIZE) $(BUILD_DIR)/$(BIN_OUTPUT)
	truncate -s $(ROMFS_SIZE) $(ROMFS_OUTPUT)
	dd if=$(ROMFS_OUTPUT) of=$(BUILD_DIR)/$(BIN_OUTPUT) bs=1 conv=notrunc oflag=append

# Clean rule to remove build directory and all its contents
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(ROMFS_MOUNTPOINT)

.PHONY: all clean
