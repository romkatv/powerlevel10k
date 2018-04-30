ARG base
FROM p9k:${base}

COPY docker/antibody/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
COPY docker/antibody/zshrc .zshrc
