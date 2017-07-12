ARG base
FROM p9k:${base}

COPY docker/zplug/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
COPY docker/zplug/zshrc .zshrc
