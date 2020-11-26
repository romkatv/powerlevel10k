ZSH := $(shell command -v zsh 2> /dev/null)

all:

pkg:
	$(MAKE) -C gitstatus pkg
	$(or $(ZSH),:) -fc 'for f in *.zsh-theme internal/*.zsh; do zcompile -R -- $$f.zwc $$f || exit; done'
