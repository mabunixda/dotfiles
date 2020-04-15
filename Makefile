.PHONY: all bin dotfiles etc test shellcheck

all: bin dotfiles etc

bin:
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done
	if [ ! -f "/usr/local/bin/cfssl" ]; then \
		sudo curl -s -L -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64; \
	fi; \
	if [ ! -f "/usr/local/bin/cfssljson" ]; then \
		sudo curl -s -L -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64; \
	fi; \
	sudo chmod +x /usr/local/bin/{cfssl,cfssljson}; \
	sudo ln -sf $(CURDIR)/bin/browser-exec /usr/local/bin/xdg-open

dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitconfig" -not -name ".ssh" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".travis.yml" -not -name ".irssi" -not -name ".gnupg" -not -name ".config"); do \
        if [ -f $$file ]; then \
    		f=$$(basename $$file); \
	    	ln -sfn $$file $(HOME)/$$f; \
        fi; \
	done; \
	ln -sfn $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf; \
	ln -sfn $(CURDIR)/.gitconfig $(HOME)/.gitconfig.core; \
        ln -sfn $(CURDIR)/.vim $(HOME)/.vim; \
	ln -sfn $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
#	ln -fn $(CURDIR)/gitignore $(HOME)/.gitignore;


etc:
	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
		sudo ln -f $$file $$f; \
	done
	systemctl --user daemon-reload
	sudo systemctl daemon-reload

test: shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh
