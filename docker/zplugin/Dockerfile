ARG base
FROM p9k:${base}

COPY docker/zplugin/install.zsh /tmp/
RUN zsh /tmp/install.zsh

COPY ./ p9k/
COPY docker/zplugin/zshrc.plugins .zshrc.plugins
