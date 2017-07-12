ARG base
FROM p9k:${base}

COPY docker/zgen/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
COPY docker/zgen/zshrc .zshrc
