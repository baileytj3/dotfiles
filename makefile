.PHONY: submodules backup clean install

all: update submodules backup install

update:
	@# Update the current repo getting any changes
	@echo "==> Updating local repo"
	@git pull --rebase

submodules:
	@# Update any submodules within this repo
	@echo "==> Updating submodules"
	@git submodule update --init --recursive

backup:
	@# If a file will be symlinked in the dotfiles: target
	@#and it currently exists in the $HOME directory,
	@#then back it up into a backup directory
	@echo "==> Backing up existing files to $(CURDIR)/backup"
	@mkdir -p $(CURDIR)/backup
	@for file in $(shell find "$(CURDIR)/files"	\
				-mindepth 1 -maxdepth 1			\
				-not -name '.*.swp'				\
			); do								\
		f=$$(basename $$file);					\
		if [ -a "$(HOME)/$$f" -a ! -L "$(HOME)/$$f" ]; then	\
			cp -R "$(HOME)/$$f" "$(CURDIR)/backup/$$f";	\
		fi;										\
	done;

clean:
	@# Clean up the "installation". If a file exists
	@# in the /files directory and exists in the $HOME
	@# directory as a symlink, remove it from the $HOME
	@# directory. Then copy all files in the /backup
	@# directory into the $HOME directory as long as
	@# they don't already exist
	@echo "==> Restoring backup copies"
	@for file in $(shell find "$(CURDIR)/files"	\
				-mindepth 1 -maxdepth 1			\
		); do									\
		f=$$(basename $$file);					\
		if [ -L "$(HOME)/$$f" ]; then			\
			rm $(HOME)/$$f;						\
		fi;										\
	done;
	@for file in $(shell find "$(CURDIR)/files/.rc.d" \
				-mindepth 1 -maxdepth 1			\
		); do									\
		f=$$(basename $$file);					\
		if [ -L "$(HOME)/.rc.d/$$f" ]; then		\
			rm $(HOME)/.rc.d/$$f;				\
		fi;										\
	done;
	@rmdir $(HOME)/.rc.d 2>/dev/null
	@for file in $(shell find "$(CURDIR)/backup"\
				-mindepth 1 -maxdepth 1			\
		); do									\
		f=$$(basename $$file);					\
		cp -Rn $(CURDIR)/backup/$$f $(HOME)/$$f; \
	done;
			
install:
	@echo "==> Creating RC Directory"
	@mkdir -p ~/.rc.d
	@echo "==> Symlinking dotfiles into $(HOME)"
	@for file in $(shell find "$(CURDIR)/files"	\
				-mindepth 1 -maxdepth 1			\
				-not -name '.*.swp'				\
				-not -name '.rc.d'				\
			); do								\
		f=$$(basename $$file);					\
		if [ -d "$(HOME)/$$f" ]; then			\
			rm -rf "$(HOME)/$$f";				\
		fi;										\
		ln -sfn "$$file" "$(HOME)/$$f";			\
	done;
	@for file in $(shell find "$(CURDIR)/files/.rc.d" \
				-mindepth 1 -maxdepth 1			\
				-not -name '.*.swp'				\
			); do								\
		f=$$(basename $$file);					\
		if [ -d "$(HOME)/$$f" ]; then			\
			rm -rf "$(HOME)/$$f";				\
		fi;										\
		ln -sfn "$$file" "$(HOME)/.rc.d/$$f";	\
	done;

	@source ~/.bashrc
