sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zplugin/master/doc/install.sh)"

# The 'zplugin snippet' only copies the .zsh-theme file, not everything else.
mkdir -p ~/.zplugin/snippets
ln -nsf \
  ~/p9k/ \
~/.zplugin/snippets/--SLASH--home--SLASH--fred--SLASH--p9k--SLASH--powerlevel9k--DOT--zsh-theme

{
  echo
  echo "source ~/.zshrc.plugins"
} >> ~/.zshrc
