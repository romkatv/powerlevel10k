ARG base
FROM p9k:${base}

COPY docker/prezto/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
