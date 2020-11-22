# Recommended font: Meslo Nerd Font patched for Powerlevel10k

Gorgeous monospace font designed by Jim Lyles for Bitstream, customized by the same for Apple,
further customized by André Berg, and finally patched by yours truly with customized scripts
originally developed by Ryan L McIntyre of Nerd Fonts. Contains all glyphs and symbols that
Powerlevel10k may need. Battle-tested in dozens of different terminals on all major operating
systems.

_FAQ_: [How was the recommended font created?](faq.md#how-was-the-recommended-font-created)

## Automatic font installation

If you are using iTerm2 or Termux, `p10k configure` can install the recommended font for you.
Simply answer `Yes` when asked whether to install _Meslo Nerd Font_.

If you are using a different terminal, proceed with manual font installation. 👇

## Manual font installation

Download these four ttf files:

- [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

Double-click on each file and click "Install". This will make `MesloLGS NF` font available to all
applications on your system. Configure your terminal to use this font:

- **iTerm2**: Open _iTerm2 → Preferences → Profiles → Text_ and set _Font_ to `MesloLGS NF`.
  Alternatively, type `p10k configure` and answer `Yes` when asked whether to install
  _Meslo Nerd Font_.
- **Apple Terminal** Open _Terminal → Preferences → Profiles → Text_, click _Change_ under _Font_
  and select `MesloLGS NF` family.
- **Hyper**: Open _Hyper → Edit → Preferences_ and change the value of `fontFamily` under
  `module.exports.config` to `MesloLGS NF`.
- **Visual Studio Code**: Open _File → Preferences → Settings_, enter
  `terminal.integrated.fontFamily` in the search box and set the value to `MesloLGS NF`.
- **GNOME Terminal** (the default Ubuntu terminal): Open _Terminal → Preferences_ and click on the
  selected profile under _Profiles_. Check _Custom font_ under _Text Appearance_ and select
  `MesloLGS NF Regular`.
- **Konsole**: Open _Settings → Edit Current Profile → Appearance_, click _Select Font_ and select
  `MesloLGS NF Regular`.
- **Tilix**: Open _Tilix → Preferences_ and click on the selected profile under _Profiles_. Check
  _Custom font_ under _Text Appearance_ and select `MesloLGS NF Regular`.
- **Windows Console Host** (the old thing): Click the icon in the top left corner, then
  _Properties → Font_ and set _Font_ to `MesloLGS NF`.
- **Windows Terminal** (the new thing): Open _Settings_ (`Ctrl+,`), search for `fontFace` and set
  value to `MesloLGS NF` for every profile.
- **Termux**: Type `p10k configure` and answer `Yes` when asked whether to install
  _Meslo Nerd Font_.
- **Blink** Type `config`, go to _Appearance_, tap _Add a new font_, tap _Open Gallery_, select
  _MesloLGS NF.css_, tap _import_ and type `exit` in the home view to reload the font.
- **Terminus**: Open _Settings → Appearance_ and set _Font_ to `MesloLGS NF`.
- **Terminator**: Open _Preferences_ using the context menu. Under _Profiles_ select the _General_
  tab (should be selected already), uncheck _Use the system fixed width font_ (if not already)
  and select `MesloLGS NF Regular`. Exit the Preferences dialog by clicking _Close_.
- **Guake**: Right Click on an open terminal and open _Preferences_. Under _Appearance_
  tab, uncheck _Use the system fixed width font_ (if not already) and select `MesloLGS NF Regular`.
  Exit the Preferences dialog by clicking _Close_.
- **Alacritty**: Create or open `~/.config/alacritty/alacritty.yml` and add the following section
  to it:

```yaml
font:
  normal:
    family: 'MesloLGS NF'
```

- **Kitty**: Create or open `~/.config/kitty/kitty.conf` and add the following line to it:

```text
font_family MesloLGS NF
```

Restart Kitty by closing all sessions and opening a new session.

**IMPORTANT:** Run `p10k configure` after changing terminal font. The old `~/.p10k.zsh` may work
incorrectly with the new font.

_Using a different terminal and know how to set the font for it? Share your knowledge by sending a
PR to expand the list!_
