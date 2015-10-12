## powerlevel9k Theme for ZSH

Powerlevel9k is a theme for ZSH which uses [Powerline
Fonts](https://github.com/powerline/fonts). It can be used with vanilla
ZSH, [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh), or
[Prezto](https://github.com/sorin-ionescu/prezto), and can also be installed
using [antigen](https://github.com/zsh-users/antigen).

Look like a bad-ass. Impress everyone in 'Screenshot Your Desktop' threads. Use powerlevel9k.

![](http://bhilburn.org/content/images/2015/01/pl9k-improved.png)

There are a number of Powerline ZSH themes available, now. The developers of
this theme focus on four primary goals:

1. Give users a great out-of-the-box configuration with no additional
   configuration required.
2. Make customization easy for users who do want to tweak their prompt.
3. Provide useful segments that you can enable to make your prompt even more
   effective and helpful. We have prompt segments for everything from unit test
   coverage to your AWS instance.
4. Optimize the code for execution speed as much as possible. A snappy terminal
   is a happy terminal.

Here is a detailed screenshot showing `powerlevel9k` with default settings and
varying terminal status indicators:

![](http://bhilburn.org/content/images/2014/12/powerlevel9k.png)

### Installation
There are two installation steps to go from a lame terminal to a "Power Level
9000" terminal. Once you are done, you can optionally customize your prompt.

[Installation Instructions](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions)

1. [Install the Powerlevel9k Theme](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-1-install-powerlevel9k)
2. [Install Powerline-Patched Fonts](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-2-install-powerline-fonts)

No configuration is necessary post-installation if you like the default
settings, but there are plenty of segment customization options available if you
are interested.

### Customization

#### Customizing Prompt Segments
Customizing your prompt is easy! Select the segments you want to have displayed,
and then assign them to either the left or right prompt by adding the following
variables to your `~/.zshrc`. If you don't customize this, the below
configuration is the default:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)

#### Available Prompt Segments
The segments that are currently available are:

* [aws](#aws) - The current AWS profile, if active.
* [context](#context) - Your username and host.
* [dir](#dir) - Your current working directory.
* **history** - The command number for the current line.
* [ip](#ip) - Shows the current IP address.
* **load** - Your machines 5 minute load average and free RAM.
* **node_version** - Show the version number of the installed Node.js.
* **os_icon** - Display a nice little icon, depending on your operating system.
* **php_version** - Show the current PHP version.
* [rbenv](#rbenv) - Ruby environment information (if one is active).
* [rspec_stats](#rspec_stats) - Show a ratio of test classes vs code classes for RSpec.
* [status](#status) - The return code of the previous command, and status of background jobs.
* [symphony2_tests](#symphony2_tests) - Show a ratio of test classes vs code classes for Symfony2.
* **symphony2_version** - Show the current Symfony2 version, if you are in a Symfony2-Project dir.
* [time](#time) - System time.
* [vi_mode](#vi_mode)- Vi editing mode (NORMAL|INSERT).
* **virtualenv** - Your Python [VirtualEnv](https://virtualenv.pypa.io/en/latest/).
* [vcs](#vcs) - Information about this `git` or `hg` repository (if you are in one).


##### aws

If you would like to display the [current AWS
profile](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), add
the `aws` segment to one of the prompts, and define `AWS_DEFAULT_PROFILE` in
your `~/.zshrc`:

    export AWS_DEFAULT_PROFILE=<profile_name>

##### context

The `context` segment (user@host string) is conditional. This lets you enable it, but only display
it if you are not your normal user or on a remote host (basically, only print it
when it's likely you need it).

To use this feature, make sure the `context` segment is enabled in your prompt
elements (it is by default), and define a `DEFAULT_USER` in your `~/.zshrc`:

    export DEFAULT_USER=<your username>

##### dir

The `dir` segment shows the current working directory. You can limit the output
to a certain length:

    # Limit to the last two folders
    POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

To change the way how the current working directory is truncated, just set:

    # truncate the middle part
    POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
    # truncate from right, leaving the first X characters untouched
    POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
    # default behaviour is to truncate whole directories

In each case you have to specify the length you want to shorten the directory
to. So in some cases `POWERLEVEL9K_SHORTEN_DIR_LENGTH` means characters, in 
others whole directories.

##### ip

This segment shows you your current internal IP address. It tries to examine
all currently used network interfaces and prints the first address it finds.
In the case that this is not the right IP address you can specify the correct
network interface by setting:

    POWERLEVEL9K_IP_INTERFACE="eth0"

##### rspec_stats

See [Unit Test Ratios](#unit-test-ratios), below.

##### status

This segment shows the return code of the last command, and the presence of any
background jobs. By default, this segment will always print, but you can
customize it to only print if there is an error or a forked job by setting the
following variable in your `~/.zshrc`.

    POWERLEVEL9K_STATUS_VERBOSE=false

##### symphony2_tests

See [Unit Test Ratios](#unit-test-ratios), below.

##### time

By default the time is show in 'H:M:S' format. If you want to change it,
just set another format in your `~/.zshrc`. As an example, this is a reversed
time format:

    # Reversed time format
    POWERLEVEL9K_TIME_FORMAT='%D{%S:%M:%H}'

If you are using an "Awesome Powerline Font", you can add a time symbol to this
segment, as well:

    # Output time, date, and a symbol from the "Awesome Powerline Font" set
    POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S \uE868  %d.%m.%y}"

##### vcs

By default, the `vcs` segment will provide quite a bit of information. If you
would also like for it to display the current hash / changeset, simply define
`POWERLEVEL9K_SHOW_CHANGESET` in your `~/.zshrc`. If activated, it will show
the first 12 characters of the changeset id. To change the amount of characters,
set `POWERLEVEL9K_CHANGESET_HASH_LENGTH` to any value you want.

    # enable the vcs segment in general
    POWERLEVEL9K_SHOW_CHANGESET=true
    # just show the 6 first characters of changeset
    POWERLEVEL9K_CHANGESET_HASH_LENGTH=6

You can also disable the branch icon in your prompt by setting
`POWERLEVEL9K_HIDE_BRANCH_ICON` to `true`:

    # Hide the branch icon
    POWERLEVEL9K_HIDE_BRANCH_ICON=true

**vcs Symbols**

The `vcs` segment uses various symbols to tell you the state of your repository.
These symbols depend on your installed font and selected `POWERLEVEL9K_MODE`
from the [Installation](#Installation) section above.

| `Compatible` | `Powerline` | `Awesome Powerline` | Explanation
|--------------|---------------------|-------------------|--------------------------
| `↑4`         | `↑4`                | ![icon_outgoing](https://cloud.githubusercontent.com/assets/1544760/7976089/b5904d6e-0a76-11e5-8147-5e873ac52d79.gif)4  | Number of commits your repository is ahead of your remote branch
| `↓5`         | `↓5`                | ![icon_incoming](https://cloud.githubusercontent.com/assets/1544760/7976091/b5909c9c-0a76-11e5-9cad-9bf0a28a897c.gif)5  | Number of commits your repository is behind of your remote branch
| `⍟3`         | `⍟3`                | ![icon_stash](https://cloud.githubusercontent.com/assets/1544760/7976094/b5ae9346-0a76-11e5-8cc7-e98b81824118.gif)3 | Number of stashes, here 3.
| `●`          | `●`                 | ![icon_unstaged](https://cloud.githubusercontent.com/assets/1544760/7976096/b5aefa98-0a76-11e5-9408-985440471215.gif) | There are unstaged changes in your working copy
| `✚`          | `✚`                 | ![icon_staged](https://cloud.githubusercontent.com/assets/1544760/7976095/b5aecc8a-0a76-11e5-8988-221afc6e8982.gif) | There are staged changes in your working copy
| `?`          | `?`                 | ![icon_untracked](https://cloud.githubusercontent.com/assets/1544760/7976098/b5c7a2e6-0a76-11e5-8c5b-315b595b2bc4.gif)  | There are files in your working copy, that are unknown to your repository
| `→`          | `→`                 | ![icon_remote_tracking_branch](https://cloud.githubusercontent.com/assets/1544760/7976093/b5ad2c0e-0a76-11e5-9cd3-62a077b1b0c7.gif) | The name of your branch differs from its tracking branch.
| `☿`          | `☿`                 | ![icon_bookmark](https://cloud.githubusercontent.com/assets/1544760/7976197/546cfac6-0a78-11e5-88a6-ce3a1e0a174e.gif) | A mercurial bookmark is active.
| `@`         | ![icon_branch_powerline](https://cloud.githubusercontent.com/assets/1544760/8000852/e7e8d8a0-0b5f-11e5-9834-de9b25c92284.gif) | ![](https://cloud.githubusercontent.com/assets/1544760/7976087/b58bbe3e-0a76-11e5-8d0d-7a5c1bc7f730.gif) | Branch Icon
| None         |  None               | ![icon_commit](https://cloud.githubusercontent.com/assets/1544760/7976088/b58f4e50-0a76-11e5-9e70-86450d937030.gif)2c3705 | The current commit hash. Here "2c3705"
| None         |  None               | ![icon_git](https://cloud.githubusercontent.com/assets/1544760/7976092/b5909f80-0a76-11e5-9950-1438b9d72465.gif) | Repository is a git repository
| None         |  None               | ![icon_mercurial](https://cloud.githubusercontent.com/assets/1544760/7976090/b5908da6-0a76-11e5-8c91-452b6e73f631.gif) | Repository is a Mercurial repository

##### vi_mode

This Segment shows the current mode of your ZSH. If you want to use your ZSH in
VI-Mode, you need to configure it separately in your `~/.zshrc`:

    # VI-Mode
    # general activation
    bindkey -v

    # set some nice hotkeys
    bindkey '^P' up-history
    bindkey '^N' down-history
    bindkey '^?' backward-delete-char
    bindkey '^h' backward-delete-char
    bindkey '^w' backward-kill-word
    bindkey '^r' history-incremental-search-backward

    # make it more responsive
    export KEYTIMEOUT=1

#### Unit Test Ratios

The `symfony2_tests` and `rspec_stats` segments both show a ratio of "real"
classes vs test classes in your source code. This is just a very simple ratio,
and does not show your code coverage or any sophisticated stats. All this does
is count your source files and test files, and calculate the ratio between them.
Just enough to give you a quick overview about the test situation of the project
you are dealing with.


### Styling

You can configure the look and feel of your prompt easily with some built-in
options.

#### Double-Lined Prompt

By default, `powerlevel9k` is a single-lined prompt. If you would like to have
the segments display on one line, and print the command prompt below it, simply
define `POWERLEVEL9K_PROMPT_ON_NEWLINE` in your `~/.zshrc`:

    POWERLEVEL9K_PROMPT_ON_NEWLINE=true

Here is what it looks like:

![](http://bhilburn.org/content/images/2015/03/double-line.png)

You can customize the icons used to draw the multiline prompt by setting the
following variables in your `~/.zshrc`:

    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"
    POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX="↳ "

#### Disable Right Prompt

If you do not want a right prompt, you can disable it by setting:

    POWERLEVEL9K_DISABLE_RPROMPT=true

#### Light Color Theme

If you prefer to use "light" colors, simply set `POWERLEVEL9K_COLOR_SCHEME`
to `light` in your `~/.zshrc`, and you're all set!

    POWERLEVEL9K_COLOR_SCHEME='light'

The 'light' color scheme works well for ['Solarized
Light'](https://github.com/altercation/solarized) users. Check it out:

![](http://bhilburn.org/content/images/2015/03/solarized-light.png)

#### Icon Customization

Each icon used can be customized too by specifying a variable named like
the icon and prefixed with 'POWERLEVEL9K'. If you want to use another icon
as segment separators, you can easily do that:

    POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\uE0B1'
    POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\uE0B3'

You could get a list of all icons defined in random colors, by adding the 
special segment `icons_test` to your prompt:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(icons_test)

This special prompt does not work on the right side, as it would be too long,
and ZSH hides it automatically. Also have in mind, that the output depends on
your `POWERLEVEL9K_MODE` settings.

You can change any icon by setting a environment variable. To get a full list
of icons just type `get_icon_names` in your terminal.

#### Segment Color Customization

For each segment in your prompt, you can specify a foreground and background
color by setting them in your `~/.zshrc`. Use the segment names from the above
section `Segment Customization`. For example, to change the appearance of the
`time` segment, you would use:

    POWERLEVEL9K_TIME_FOREGROUND='red'
    POWERLEVEL9K_TIME_BACKGROUND='blue'

Note that you can also use a colorcode value. Example:

    POWERLEVEL9K_VCS_FOREGROUND='021' # Dark blue

For a full list of supported colors, run the `spectrum_ls` program in your
terminal.

#### Special Segment Colors

Some segments have additional color options if you want to customize the look of
your prompt even further. These Segments are `context`, `vcs`, `rspec_stats`,
`symfony2_tests`:

    # Customizing `context` colors for root and non-root users
    POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND="green"
    POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND="cyan"
    POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND="red"
    POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND="blue"

    # Advanced `vcs` color customization
    POWERLEVEL9K_VCS_FOREGROUND='blue'
    POWERLEVEL9K_VCS_DARK_FOREGROUND='black'
    POWERLEVEL9K_VCS_BACKGROUND='green'
    # If VCS changes are detected:
    POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
    POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='cyan'

    # rspec_stats for good test coverage
    POWERLEVEL9K_RSPEC_STATS_GOOD_FOREGROUND='blue'
    POWERLEVEL9K_RSPEC_STATS_GOOD_BACKGROUND='green'
    # rspec_stats for average test coverage
    POWERLEVEL9K_RSPEC_STATS_AVG_FOREGROUND='black'
    POWERLEVEL9K_RSPEC_STATS_AVG_BACKGROUND='cyan'
    # rspec_stats for poor test coverage
    POWERLEVEL9K_RSPEC_STATS_BAD_FOREGROUND='red'
    POWERLEVEL9K_RSPEC_STATS_BAD_BACKGROUND='white'

    # symfony2_tests for good test coverage
    POWERLEVEL9K_SYMFONY2_TESTS_GOOD_FOREGROUND='blue'
    POWERLEVEL9K_SYMFONY2_TESTS_GOOD_BACKGROUND='green'
    # symfony2_tests for average test coverage
    POWERLEVEL9K_SYMFONY2_TESTS_AVG_FOREGROUND='black'
    POWERLEVEL9K_SYMFONY2_TESTS_AVG_BACKGROUND='cyan'
    # symfony2_tests for poor test coverage
    POWERLEVEL9K_SYMFONY2_TESTS_BAD_FOREGROUND='red'
    POWERLEVEL9K_SYMFONY2_TESTS_BAD_BACKGROUND='white'
