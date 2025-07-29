# Makefile for building Berserk Arch with archiso

ISO_NAME := berserkarch
ISO_LABEL := BERSERKARCH
PROFILE_DIR := src
OUT_DIR := out
WORK_DIR := work
BRANCH ?= main


all: build
build:
	@echo "--- Starting Berserk Arch Build ---"
	sudo mkarchiso \
		-v \
		-w $(WORK_DIR) \
		-o $(OUT_DIR) \
		-L "$(ISO_LABEL)" \
		"$(PROFILE_DIR)"
		# -g B024DCEFADEF4328B5E3A848E7E0F2B78484DACF \
		# -G "Gaurav Raj (@thehackersbrain) <gauravraj@berserkarch.xyz>"
	@echo "--- Build Complete! ISO is in the '$(OUT_DIR)' directory. ---"

devbuild:
	@echo "--- Starting Berserk Arch Build ---"
	mkarchiso \
		-v \
		-w "../$(WORK_DIR)" \
		-o $(OUT_DIR) \
		-L "$(ISO_LABEL)" \
		"$(PROFILE_DIR)"
	@echo "--- Build Complete! ISO is in the '$(OUT_DIR)' directory. ---"

clean:
	@echo "--- Cleaning up build directories ---"
	sudo rm -rf $(WORK_DIR) $(OUT_DIR)
	@echo "--- Cleanup Complete. ---"

run test: #build # uncomment this to run build before testing
	@echo "--- Booting ISO in QEMU (UEFI) ---"
	qemu-system-x86_64 \
		-m 8G \
		-boot d \
		-cdrom $(OUT_DIR)/$(ISO_NAME)*.iso \
		-enable-kvm \
		# -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.fd \
		# -drive if=pflash,format=raw,file=/usr/share/edk2/x64/OVMF_VARS.fd

# Phony targets: These are not actual files.
.PHONY: all build devbuild clean run test
