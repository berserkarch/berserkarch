# Makefile for building Berserk Arch with archiso

ISO_NAME := berserkarch
ISO_LABEL := BERSERK_ARCH
PROFILE_DIR := src
OUT_DIR := out
WORK_DIR := work
BRANCH ?= main


all: build
build:
	@echo "--- Starting Berserk Arch Build ---"
	sudo mkarchiso -v -w $(WORK_DIR) -o $(OUT_DIR) -L "$(ISO_LABEL)" "$(PROFILE_DIR)"
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

gitlab:
	@git push -u origin $(BRANCH)
	@echo "--- ✅ Pushed to Gitlab (origin) ---"

github:
	@git push -u github $(BRANCH)
	@echo "--- ✅ Pushed to Github (github) ---"

push-all:
	@make gitlab
	@make github
	@echo "--- 🚀 Pushed to both GitLab and GitHub ---"

# Phony targets: These are not actual files.
.PHONY: all build clean run test gitlab github push-all
