## v0.3.0 (next)

### Introduced "visual identifiers" to the segments

Now almost every segment can have a visual identifier, which is an
icon whose color could be adjusted by users.

### Added ability for "joined" segments

You can now merge segments together by suffixing the segment name with "_joined".
For Developers: Be aware that the order of parameters in left/right_prompt_segment
has changed. Now a boolean parameter must be set as second parameter (true if joined).

### `status` changes

The `status` segment was split up into three segments. `background_jobs` prints
an icon if there are background jobs. `root_indicator` prints an icon if the user
is root. The `status` segment focuses now on the status only.

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
