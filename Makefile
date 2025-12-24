.PHONY: tools apt-update

DOTFILES_ROOT := $(CURDIR)
BIN_DIR := $(DOTFILES_ROOT)/bin.local
TOOLS_DIR := $(DOTFILES_ROOT)/.tools
SUDO := $(shell if [ "$$(id -u)" -eq 0 ]; then echo ""; else echo "sudo"; fi)
APT := apt-get -qq
APT_DOWNLOAD := apt-get -qq -o APT::Sandbox::User=root download

tools:
	@echo "No tools configured. Add rules below."

apt-update:
	@$(SUDO) $(APT) update

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(TOOLS_DIR):
	@mkdir -p $(TOOLS_DIR)

# Example:
# tools: apt-update $(BIN_DIR)/ack
#
# $(TOOLS_DIR)/ack.deb: | $(TOOLS_DIR)
# 	@cd $(TOOLS_DIR) && $(APT_DOWNLOAD) ack && mv ack_*.deb ack.deb
#
# $(BIN_DIR)/ack: $(TOOLS_DIR)/ack.deb | $(BIN_DIR)
# 	@rm -rf $(TOOLS_DIR)/ack
# 	@mkdir -p $(TOOLS_DIR)/ack
# 	@dpkg-deb -x $(TOOLS_DIR)/ack.deb $(TOOLS_DIR)/ack
# 	@if [ -x $(TOOLS_DIR)/ack/usr/bin/ack ]; then \
# 		install -m 0755 $(TOOLS_DIR)/ack/usr/bin/ack $(BIN_DIR)/ack; \
# 	else \
# 		install -m 0755 $(TOOLS_DIR)/ack/usr/bin/ack-grep $(BIN_DIR)/ack; \
# 	fi
