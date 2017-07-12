ARG base
FROM p9k:${base}

COPY docker/antigen/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
COPY docker/antigen/zshrc .zshrc
