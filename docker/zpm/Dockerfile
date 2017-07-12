ARG base
FROM p9k:${base}

COPY docker/zpm/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
COPY docker/zpm/zshrc .zshrc
