# Recommended font: Meslo Nerd Font patched for Powerlevel10k

Gorgeous monospace font designed by Jim Lyles for Bitstream, customized by the same for Apple,
further customized by André Berg, and finally patched by yours truly with customized scripts
originally developed by Ryan L McIntyre of Nerd Fonts. Contains all glyphs and symbols that
Powerlevel10k may need. Battle-tested in dozens of different terminals on all major operating
systems.

*FAQ*: [How was the recommended font created?](README.md#how-was-the-recommended-font-created)

#### Automatic font installation

If you are using iTerm2 or Termux, `p10k configure` can install the recommended font for you.
Simply answer `Yes` when asked whether to install *Meslo Nerd Font*.

If you are using a different terminal, proceed with manual font installation. 👇

#### Manual font installation

Download these four ttf files:

- [MesloLGS NF Regular.ttf](
    https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold.ttf](
    https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic.ttf](
    https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic.ttf](
    https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

Double-click on each file and click "Install". This will make `MesloLGS NF` font available to all
applications on your system. Configure your terminal to use this font:

- **iTerm2**: Type `p10k configure` and answer `Yes` when asked whether to install
  *Meslo Nerd Font*. Alternatively, open *iTerm2 → Preferences → Profiles → Text* and set *Font* to
  `MesloLGS NF`.
- **Apple Terminal**: Open *Terminal → Preferences → Profiles → Text*, click *Change* under *Font*
  and select `MesloLGS NF` family.
- **Hyper**: Open *Hyper → Edit → Preferences* and change the value of `fontFamily` under
  `module.exports.config` to `MesloLGS NF`.
- **Visual Studio Code**: Open *File → Preferences → Settings*, enter
  `terminal.integrated.fontFamily` in the search box and set the value to `MesloLGS NF`.
- **GNOME Terminal** (the default Ubuntu terminal): Open *Terminal → Preferences* and click on the
  selected profile under *Profiles*. Check *Custom font* under *Text Appearance* and select
  `MesloLGS NF Regular`.
- **Konsole**: Open *Settings → Edit Current Profile → Appearance*, click *Select Font* and select
  `MesloLGS NF Regular`.
- **Tilix**: Open *Tilix → Preferences* and click on the selected profile under *Profiles*. Check
  *Custom font* under *Text Appearance* and select `MesloLGS NF Regular`.
- **Windows Console Host** (the old thing): Click the icon in the top left corner, then
  *Properties → Font* and set *Font* to `MesloLGS NF`.
- **Windows Terminal** by Microsoft (the new thing): Open *Settings* (`Ctrl+,`), search for
  `fontFace` and set value to `MesloLGS NF` for every profile.
- **IntelliJ** (and other IDEs by Jet Brains): Open *IDE → Edit → Preferences → Editor →
  Color Scheme → Console Font*. Select *Use console font instead of the default* and set the font
  name to `MesloLGS NF`.
- **Termux**: Type `p10k configure` and answer `Yes` when asked whether to install
  *Meslo Nerd Font*.
- **Blink**: Type `config`, go to *Appearance*, tap *Add a new font*, tap *Open Gallery*, select
  *MesloLGS NF.css*, tap *import* and type `exit` in the home view to reload the font.
- **Terminus**: Open *Settings → Appearance* and set *Font* to `MesloLGS NF`.
- **Terminator**: Open *Preferences* using the context menu. Under *Profiles* select the *General*
  tab (should be selected already), uncheck *Use the system fixed width font* (if not already)
  and select `MesloLGS NF Regular`. Exit the Preferences dialog by clicking *Close*.
- **Guake**: Right Click on an open terminal and open *Preferences*. Under *Appearance*
  tab, uncheck *Use the system fixed width font* (if not already) and select `MesloLGS NF Regular`.
  Exit the Preferences dialog by clicking *Close*.
- **MobaXterm**: Open *Settings* → *Configuration* → *Terminal* → (under *Terminal look and feel*)
  and change *Font* to `MesloLGS NF`.
- **Asbrú Connection Manager**: Open *Preferences → Local Shell Options → Look and Feel*, enable
  *Use these personal options* and change *Font:* under *Terminal UI* to `MesloLGS NF Regular`.
  To change the font for the remote host connections, go to *Preferences → Terminal Options →
  Look and Feel* and change *Font:* under *Terminal UI* to `MesloLGS NF Regular`.
- **WSLtty**: Right click on an open terminal and then on *Options*. In the *Text* section, under
  *Font*, click *"Select..."* and set Font to `MesloLGS NF Regular`.
- **Alacritty**: Create or open `~/.config/alacritty/alacritty.yml` and add the following section
  to it:
  ```yaml
  font:
    normal:
      family: "MesloLGS NF"
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
