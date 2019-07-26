

if [[ -n $AWESOME_GLYPHS_LOADED ]]; then
  echo awesome-mapped-fontconfig
else
  echo $'\uE0B2\uE0B0'
  echo "Does this look like a diamond (square rotated 45 degrees)?"
  $'\uE0B2\uE0B0'
  
  if N; then
    echo nothing
    return
  fi
  echo 1 $'\UE138'
  echo 2 $'\UF023'
  echo "Which of these looks like a lock?"
  if neither; then
    echo powerline
    return
  fi
  if 1; then
    echo awesome-patched
    return
  fi
  echo $'\ue63c'
  echo "Does it look like a Python logo? https://commons.wikimedia.org/wiki/File:Python-logo-notext.svg"
  if yes; then
    echo awesome-fontconfig
    return
  fi
  echo nerfont-complete
fi

awesome-mapped-fontconfig)
  has $AWESOME_GLYPHS_LOADED

'flat'|'awesome-patched')
  LOCK_ICON $'\UE138'

'awesome-fontconfig')
  LOCK_ICON $'\UF023'

'nerdfont-complete'|'nerdfont-fontconfig')
  LOCK_ICON $'\UF023'

*)
 LOCK_ICON $'\UE0A2'

ROOT_ICON
awesome-fontconfig \uF201
nerfont            \uE614
flat|awesome-patched               \uE801

1. Nerd Fonts

Lock: $'\UF023'

2. Awesome Fontconfig (fallback strategy)

Lock: $'\UF023'
Lightning: $'\uF201'

3. Awesome Fontconfig (patch strategy)

Lock: $'\UE138'
Lightning: $'\uE801'

---------------------------
This is the Z Shell configuration function for new users,
zsh-newuser-install.
You are seeing this message because you have no zsh startup files
(the files .zshenv, .zprofile, .zshrc, .zlogin in the directory
~).  This function can help you with a few settings that should
make your use of the shell easier.

You can:

(q)  Quit and do nothing.  The function will be run again next time.

(0)  Exit, creating the file ~/.zshrc containing just a comment.
     That will prevent this function being run again.

(1)  Continue to the main menu.

(2)  Populate your ~/.zshrc with the configuration recommended
     by the system administrator and exit (you will need to edit
     the file by hand, if so desired).

--- Type one of the keys in parentheses --- 

Please pick one of the following options:

(1)  Configure settings for history, i.e. command lines remembered
     and saved by the shell.  (Recommended.)

(2)  Configure the new completion system.  (Recommended.)

(3)  Configure how keys behave when editing command lines.  (Recommended.)

(4)  Pick some of the more common shell options.  These are simple "on"
     or "off" switches controlling the shell's features.  

(0)  Exit, creating a blank ~/.zshrc file.

(a)  Abort all settings and start from scratch.  Note this will overwrite
     any settings from zsh-newuser-install already in the startup file.
     It will not alter any of your other settings, however.

(q)  Quit and do nothing else.  The function will be run again next time.
--- Type one of the keys in parentheses --- 

History configuration
=====================

# (1) Number of lines of history kept within the shell.
HISTSIZE=1000                                                                                                                                                  (not yet saved)
# (2) File where history is saved.
HISTFILE=~/.histfile                                                                                                                                           (not yet saved)
# (3) Number of lines of history to save to $HISTFILE.
SAVEHIST=1000                                                                                                                                                  (not yet saved)

# (0)  Remember edits and return to main menu (does not save file yet)
# (q)  Abandon edits and return to main menu

--- Type one of the keys in parentheses --- 
