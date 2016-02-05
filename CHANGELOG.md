## v0.4.0 (next)

### `aws_eb_env` added

This segment displays the current Elastic Beanstalk environment.

### `ram` changes

The `ram` segment was split up into `ram` and `swap`. The `POWERLEVEL9K_RAM_ELEMENTS`
variable is void.

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
