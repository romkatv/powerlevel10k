ARG base
FROM p9k:${base}

COPY docker/omz/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY docker/omz/zshrc .zshrc
COPY ./ p9k/
