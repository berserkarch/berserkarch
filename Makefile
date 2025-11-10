# Makefile for building Berserk Arch with archiso

ISO_NAME := berserkarch
ISO_LABEL := BERSERKARCH
PROFILE_DIR := src
OUT_DIR := out
WORK_DIR := work
BRANCH ?= main

TRACKERS := \
	udp://tracker.openbittorrent.com:80/announce \
	udp://tracker.opentrackr.org:1337/announce \
	udp://tracker.leechers-paradise.org:6969/announce

WEBSEED := https://iso.berserkarch.xyz

define get_iso
	ISO_FILE=$$(ls -t $(OUT_DIR)/$(ISO_NAME)*.iso 2>/dev/null | head -n 1); \
	if [ -z "$$ISO_FILE" ]; then \
		echo "❌ Error: No ISO file found in $(OUT_DIR)/" >&2; \
		exit 1; \
	fi; \
	echo "$$ISO_FILE"
endef

all: build checksums torrent
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

checksums:
	@sudo chown -R "$$(id -u -n):$$(id -g -n)" "$(OUT_DIR)"
	@ISO_FILE=$$($(get_iso)); \
	echo "[*] Generating checksums for $$ISO_FILE..."; \
	sha256sum "$$ISO_FILE" > "$$ISO_FILE.sha256"; \
	sha1sum   "$$ISO_FILE" > "$$ISO_FILE.sha1"; \
	md5sum    "$$ISO_FILE" > "$$ISO_FILE.md5"; \
	echo "https://iso.berserkarch.xyz/$$(basename "$$ISO_FILE")" > "$(OUT_DIR)/latest.txt"; \
	echo "[*] Created 'latest' file pointing to: $$(basename "$$ISO_FILE")"; \
	ls -lh "$$ISO_FILE"*

torrent: checksums
	@ISO_FILE=$$($(get_iso)); \
	ISO_FILENAME=$$(basename "$$ISO_FILE"); \
	DYNAMIC_WEBSEED="${WEBSEED}/$$ISO_FILENAME"; \
	echo "[*] Generating torrent for $$ISO_FILE..."; \
	echo "[*] Using dynamic webseed: $$DYNAMIC_WEBSEED"; \
	rm -f "$$ISO_FILE.torrent"; \
	TRACKER_ARGS=""; \
	for t in $(TRACKERS); do TRACKER_ARGS="$$TRACKER_ARGS -a $$t"; done; \
	mktorrent -l 21 $$TRACKER_ARGS -w "$$DYNAMIC_WEBSEED" -o "$$ISO_FILE.torrent" "$$ISO_FILE"; \
	echo "[+] Torrent created: $$ISO_FILE.torrent"; \
	echo "[+] Done."

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
.PHONY: all build devbuild clean checksums torrent run test
