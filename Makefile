PHONY: tools apt-update

DOTFILES_ROOT := $(CURDIR)
BIN_DIR := $(DOTFILES_ROOT)/bin.local
SUDO := $(shell if [ "$$(id -u)" -eq 0 ]; then echo ""; else echo "sudo"; fi)
APT := apt-get -qq
APT_DOWNLOAD := apt-get -qq -o APT::Sandbox::User=root download

tools:
	@echo "No tools configured. Add rules below."

apt-update:
	@$(SUDO) $(APT) update

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

