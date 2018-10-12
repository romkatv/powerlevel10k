## v0.6.6

- The `rbenv` segment is no longer a default segment in the LPROMPT.
- PR #959 - Fixing issue in v0.6.5 where we changed some color codes.
- PR #934 - Add Tests
- PR #884 - test-in-docker: fix with newer ZSH versions
- PR #928 - [Docs] Add etc state description in dir docs
- PR #937 - Use SUDO_COMMAND to check for sudo
- PR #925 - [Bugfix] Resolve #918 Transparent background
- PR #923 - Fix font issue debugging script
- PR #921 - Add missing colors to fix color comparison
- PR #951 - Add fallback icon for missing linux distro icons
- PR #956 - Fix broken link in readme
- Fixed #936 - fallback icons for Linux distros
- Fixed #926 - `etc` state for `dir` segment in docs
- Fixed #852 - `sudo` detection got crazy, there. sorry, everyone.
- Fixed #927 - more default color issues.

## v0.6.5

- Multiple PRs: General fixes to README, improved documentation.
- Multiple PRs: Improvements to icons / glyphs.
- PR #777: now possible to always show the Ruby env segment.
- PR #773: Fixed issue with home abbreviation in directory segment.
- PR #789: Now properly working around some odd ZSH status return codes.
- PR #716: Now possible to configure the colors of the VCS segment in rebase mode.
- PR #722: Removed dependency on `bc` for `load` segment.
- PR #686: Fixed issue where whitespaces in path occasionally broke `dir` segment.
- PR #685: No longer accidentally invoking user `grep` aliases.
- PR #680: Using env variable for `PYENV` properly, now.
- PR #676, #611: Fixes for Kubernetes segment.
- PR #667: Supporting multiple AWS profiles.
- PR #660: Fixing directory parsing issue with PYTHONPATH.
- PR #663: Fixed silly issues causing ZSH warnings.
- PR #647: Fixing `public_ip` segment for macOS.
- PR #643: Fixing `vpn_ip` segment naming.
- PR #636: `context` segment now grabs user with command rather than env.
- PR #618: Fix issue where `su -` didn't change context segment.
- PR #608: Load average selection in `load` segment.

### New Segment: `laravel_version`

Displays the current laravel version.

## v0.6.4

- `load` segment now has configurable averages.
- Update to `dir` segment to add `dir_writable` feature.
- `status` segment can now display POSIX signal name of exit code.
- Added `teardown` command to turn off P9k prompt.
- Fixes for P9k in Cygwin and 32-bit systems.
- Better colors in virtualization segments.
- Added 'Gopher' icon to the `go_version` segment.
- Improved detection in `nvm`
- Added option to support command status reading from piped command sequences.
- Fixed issue with visual artifacts with quick consecutive commands.
- Updated 'ananconda' segment for more uniform styling.
- `rvm` segment can now support usernames with dashes.
- Fixed Python icon reference in some font configurations.
- Vi mode indicator fixed.
- Fixes for Docker segment.
- Added new Docker-based testing system.
- Significant enhancements to the `battery` segment. Check out the README to
  read more!
- New truncation strategy that truncates until the path becomes unique.

### New Segments: `host` and `user`

Provides two separate segments for `host` and `user` in case you don't wont both
in one (per the `context` segment).

### New Segment: `newline`

Allows you to split segments across multiple lines.

### New Segment: `kubecontext`

Shows the current context of your `kubectl` configuration.

### New Segment: `vpn`

Shows current `vpn` interface.

## v0.6.3

- Fixed susceptibility to [pw3nage exploit](https://github.com/njhartwell/pw3nage).
- Added support for Android
- The abbreviation for $HOME is now configurable (doesn't have to be `~`).
- Fixed colorization of VCS segment in Subversion repos.
- Improved handling of symlinks in installation paths.

## v0.6.2

- Fixed some issues with the new `nerdfont-fontconfig` option.
- Fixed typo in README.
- The `get_icon_names` function can now print sorted output, and show which
  icons users have overridden.
- Added a FreeBSD VM for testing.

### Add debug script for iTerm2 issues

A new script `debug/iterm.zsh` was added for easier spotting problems with your iTerm2 configuration.

### Add debug script for font issues

A new script `debug/font-issues.zsh` was added, so that problems with your font could be spotted easier.

### `ram` changes

The `ram` segment now shows the available ram instead of free.

### Add new segments `host` and `user`

The user and host segments allow you to have different icons and colors for both the user and host segments
depending on their state.

## v0.6.0

- Fixed a bug where the tag display was broken on detached HEADs.
- Fixed a bug where SVN detection sometimes failed.
- Fixed the `load` and `ram` segments for BSD.
- Fixed code-points that changed in Awesome fonts.
- Fixed display of "OK_ICON" in `status` segment in non-verbose mode.
- Fixed an issue where dir name truncation that was very short sometimes failed.
- Speed & accuracy improvements to the battery segment.
- Added Github syntax highlighting to README.
- Various documentation cleanup.

### New Font Option: nerd-fonts

There is now an option to use [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) with P9k. Simply configure the `nerdfont-fontconfig`, and you'll be set!

### `vcs` changes

The VCS segment can now display icons for remote repo hosting services, including Github, Gitlab, and 'other'.

### `dir` changes

Added an option to configure the path separator. If you want something
else than an ordinary slash, you could set
`POWERLEVEL9K_DIR_PATH_SEPARATOR` to whatever you want.

#### `truncate_with_package_name` now searches for `composer.json` as well

Now `composer.json` files are searched as well. By default `package.json` still takes
precedence. If you want to change that, set `POWERLEVEL9K_DIR_PACKAGE_FILES=(composer.json package.json)`.

### New segment `command_execution_time` added

Shows the duration a command needed to run. By default only durations over 3 seconds
are shown (can be adjusted by setting POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD).

### New segment `dir_writable` added

This segment displays a lock icon if your user has no write permissions in the current folder.

### New segment `disk_usage` added

This segment will show the usage level of your current partition.

### New segment `public_ip` added

Fetches your Public IP (using ident.me) and displays it in your prompt.

### New segment `swift_version` added

This segment displays the version of Swift that is installed / in your path.

### New segment `detect_virt` added

Detects and reports if you are in a virtualized session using `systemd`.

## v0.5.0

### `load` and `ram` changes

These two segments now support BSD.

### `vcs` changes

- We implemented a huge speed improvement for this segment.
- Now this segment supports Subversion repositories.
- Add ability to hide tags by setting `POWERLEVEL9K_VCS_HIDE_TAGS` to true.

## `anaconda` changes

Speed improvements for `anaconda` segment.

## v0.4.0

### Development changes

From now on, development makes use of a CI system "travis".

### `vcs` changes

The default state was renamed to `clean`. If you overrode foreground
or background color in the past, you need to rename your variables to:

```zsh
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='cyan'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='white'
```

Additionaly the vcs segment now has an `untracked` state which
indicates that you have untracked files in your repository.

The foreground color of actionformat is now configurable via:
```zsh
POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND='green'
```

Also, the vcs segment uses the foreground color it was configured to.
That said, the variables `POWERLEVEL9K_VCS_FOREGROUND` and
`POWERLEVEL9K_VCS_DARK_FOREGROUND` are no longer used. Instead use
the proper variable `POWERLEVEL9K_VCS_<STATE>_FOREGROUND` to change
foreground color.

### `dir` Shortening Strategies

There is now a path shortening strategy that will use the `package.json` file to
shorten your directory path. See the documentation for the `dir` segment for more
details.

Also, the shorten delimiter was changed to an unicode ellipsis. It is configurable
via `POWERLEVEL9K_SHORTEN_DELIMITER`.

### `rbenv` changes

The `rbenv` segment now makes use of the full rbenv command, so the correct
ruby version is now shown if it differs from the globally one.

### `node`, `nvm` Segments

Improvements to speed / reliability.

### `ram` changes

The `ram` segment was split up into `ram` and `swap`. The
`POWERLEVEL9K_RAM_ELEMENTS` variable is obsolete.

### New segment `swap` added

Due to the split up of the ram segment, this one was created. It
shows the currently used swap size.

### New segment `nodeenv` added

Added new `nodeenv` segment that shows the currently used node environment.

### New segment `aws_eb_env` added

This segment displays the current Elastic Beanstalk environment.

### New segment `chruby` added

Added new `chruby` segment to support this version manager.

### New segment `docker_machine` added

Added new `docker_machine` segment that will show your Docker machine.

### New segment `anaconda` added

A new segment `anaconda` was added that shows the current used
anaconda environment.

## New segment `pyenv` added

This segment shows your active python version as reported by `pyenv`.


## v0.3.2

### `vcs` changes

A new state `UNTRACKED` was added to the `vcs` segment. So we now
have 3 states for repositories: `UNTRACKED`, `MODIFIED`, and the
default state. The `UNTRACKED` state is active when there are files
in the repository directory which have not been added to the repo
(the same as when the `+` icon appears). The default color for the
`UNTRACKED` state is now yellow, and the default color for the
`MODIFIED` state is now read, but those colors can be changed by
setting these variables, for example:

```zsh
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='white'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='green'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='blue'
```

## v0.3.1

### `dir` changes

A new state `HOME_SUBFOLDER` was added. So if you want to overwrite
colors for this segment, also set this variables:
```zsh
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='black'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='white'
```

### `background_jobs` changes
Now displays the number of background jobs if there's more than 1.
You can disable it by setting :
```zsh
POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
```

## v0.3.0

### Introduced "visual identifiers" to the segments

Now almost every segment can have a visual identifier, which is an
icon whose color could be adjusted by users.

### Added ability for "joined" segments

You can now merge segments together by suffixing the segment name with "_joined".
For Developers: Be aware that the order of parameters in left/right_prompt_segment
has changed. Now a boolean parameter must be set as second parameter (true if joined).

### `dir` changes

This segment now has "state", which means you now can change the colors seperatly
depending if you are in your homefolder or not.
Your variables for that should now look like:
```zsh
POWERLEVEL9K_DIR_HOME_BACKGROUND='green'
POWERLEVEL9K_DIR_HOME_FOREGROUND='cyan'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='red'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='yellow'
```

### `status` changes

The `status` segment was split up into three segments. `background_jobs` prints
an icon if there are background jobs. `root_indicator` prints an icon if the user
is root. The `status` segment focuses now on the status only.
The `status` segment also now has "state". If you want to overwrite the colors,
you have to add the state to your variables:
```zsh
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='green'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='cyan'
POWERLEVEL9K_STATUS_OK_BACKGROUND='red'
POWERLEVEL9K_STATUS_OK_FOREGROUND='yellow'
```

### New segment `custom_command` added

A new segment that allows users to define a custom command was added.

### `virtualenv` changes

This segment now respects `VIRTUAL_ENV_DISABLE_PROMPT`. If this variable is set
to `true`, the segments does not get rendered.

### `load` changes

The `load` segement was split and a new segment `ram` was extracted. This new
segment is able to show the free ram and used swap.

### `vcs` changes

This prompt uses the `VCS_INFO` subsystem by ZSH. From now on this subsystem
is only invoked if a `vcs` segment was configured.

### `rvm` changes

This segment now does not invoke RVM directly anymore. Instead, is relys on the
circumstance that RVM was invoked beforehand and just reads the environment
variables '$GEM_HOME' and '$MY_RUBY_HOME'. It also now displays the used gemset.

### New segment `battery` added

A new segment that shows the battery status of your laptop was added.

### New segment `go_version` added

This segment shows the GO version.

### New segment `nvm` added

This segment shows your NodeJS version by using NVM (and if it is not 'default').

### New segment `todo` added

This segment shows your ToDos from [todo.sh](http://todotxt.com/).

### New segment `rust_version` added

This segment shows your local rust version.

## v0.2.0

### `longstatus` is now `status`

The segments got merged together. To show the segment only if an error occurred,
set `POWERLEVEL9K_STATUS_VERBOSE=false` (this is the same behavior as the old
`status` segment.

### Icon overriding mechanism added

All icons can now be overridden by setting a variable named by the internal icon
name. You can get a full list of icon name by calling `get_icon_names`.

### Same color segements get visual separator

This separator can be controlled by setting `POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR`
or `POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR`. By default this separator is
printed in the foreground color.

### `dir` segment has different strategies for truncation

Now you can choose between `truncate_middle` or `truncate_from_right` by setting
`POWERLEVEL9K_SHORTEN_STRATEGY`. Default behavior is unchanged (truncate whole
directories). `POWERLEVEL9K_SHORTEN_DIR_LENGTH` can be used to influence how
much will be truncated (either direcories or chars).

### New segment `ip` added

This segment shows your internal IP address. You can define which interfaces IP
will be shown by specifying it via `POWERLEVEL9K_IP_INTERFACE`.

### New segment `load` added

This segment shows your computers 5min load average.

### New segment `os_icon` added

This segment shows a little indicator which OS you are running.

### New segment `php_version` added

This segment shows your PHP version.

### New segment `vi_mode` added

This segment gives you a hint in which VI-mode you currently are. This
segment requires a proper configured VI-mode.

### Added the ability to have empty left or right prompts

By setting the according variable to an empty array, the left or right
prompt will be empty.

## v0.1.0

This is the first release
