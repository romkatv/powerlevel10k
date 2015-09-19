## powerlevel9k Theme for ZSH

Powerlevel9k is a theme for ZSH which uses [Powerline
Fonts](https://github.com/Lokaltog/powerline-fonts). It can be used with vanilla
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

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Features](#features)
- [Installation](#installation)
  - [Step 1: Install Powerlevel9k](#step-1-install-powerlevel9k)
    - [Option 1: Install for Vanilla ZSH](#option-1-install-for-vanilla-zsh)
    - [Option 2: Install for Oh-My-ZSH](#option-2-install-for-oh-my-zsh)
    - [Option 3: Install for Prezto](#option-3-install-for-prezto)
    - [Option 4: Install for antigen](#option-4-install-for-antigen)
  - [Step 2: Install Powerline Fonts](#step-2-install-powerline-fonts)
    - [Option 1: Install Powerline Fonts](#option-1-install-powerline-fonts)
    - [Option 2: Install Awesome Powerline Fonts](#option-2-install-awesome-powerline-fonts)
    - [Option 3: Compatible Mode](#option-3-compatible-mode)
- [Segment Customization](#segment-customization)
  - [The AWS Profile Segment](#the-aws-profile-segment)
  - [The 'context' Segment](#the-context-segment)
  - [The 'dir' segment](#the-dir-segment)
  - [The 'time' segment](#the-time-segment)
  - [Unit Test Ratios](#unit-test-ratios)
  - [The 'vcs' Segment](#the-vcs-segment)
    - [Symbols](#symbols)
- [Styling](#styling)
  - [Double-Lined Prompt](#double-lined-prompt)
  - [Disable Right Prompt](#disable-right-prompt)
  - [Light Color Theme](#light-color-theme)
  - [Segment Color Customization](#segment-color-customization)
  - [Special Segment Colors](#special-segment-colors)
- [Troubleshooting](#troubleshooting)
  - [Gaps Between Segments](#gaps-between-segments)
  - [Segment Colors are Wrong](#segment-colors-are-wrong)
- [Meta](#meta)
  - [Kudos](#kudos)
  - [Developing](#developing)
  - [Contributions / Bugs / Contact](#contributions--bugs--contact)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Features

* Supports `git` and `mercurial` repo information through ZSH's `VCS_INFO`:
    * branch / tag name
    * current action status (rebasing, merging, etc.,)
    * being behind / ahead of your remote by some number of commits
    * number of stashes (git only)
    * conditionally shows remote tracking branch if the name differs from local
    * current active bookmark (mercurial only)
    * various working tree statuses (e.g., unstaged, staged, etc.,)
* Shows return-code of the last command if it is an error code
* Indicates background jobs with a gear icon
* Can conditionally display the `user@host` string when needed (e.g., SSH)
* Provides segment for command history (so you can `$ !<num>` to re-run)
* Plenty of additional segments to choose from (e.g., AWS, ruby)
* Can be used as a single or double-lined prompt (see screenshots below)
* Several built-in color configurations to choose from

**If you would like an OMZ theme that provides some of the same features but
doesn't require Powerline fonts, check out the sister font,
[hackersaurus](https://github.com/bhilburn/hackersaurus).**

Here is a detailed screenshot showing `powerlevel9k` with default settings and
varying terminal status indicators:

![](http://bhilburn.org/content/images/2014/12/powerlevel9k.png)

### Installation
There are two steps to start using this theme:

1. Install the Powerlevel9k theme.
2. Install Powerline-patched fonts.
3. [Optional] Configuration

To get the most out of Powerlevel9k, you need to install both the theme as well
as Powerline-patched fonts, if you don't have them installed already. If you
cannot install Powerline-patched fonts for some reason, follow the instructions
below for a `compatible` install.

No configuration is necessary post-installation if you like the default
settings, but there is plenty of segment configuration available if you are
interested.

#### Step 1: Install Powerlevel9k
There are four ways to install and use the Powerlevel9k theme: vanilla ZSH,
Oh-My-Zsh, Prezto, and antigen. Do one of the following:

##### Option 1: Install for Vanilla ZSH

If you use just a vanilla ZSH install, simply clone this repository and
reference it in your `~/.zshrc`:

    $ git clone https://github.com/bhilburn/powerlevel9k.git
    $ echo 'source  powerlevel9k/powerlevel9k.zsh-theme' >> ~/.zshrc

##### Option 2: Install for Oh-My-ZSH

To install this theme for
[Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh), clone this repository
into your OMZ `custom/themes` directory.

    $ cd ~/.oh-my-zsh/custom
    $ git clone https://github.com/bhilburn/powerlevel9k.git themes/powerlevel9k

You then need to select this theme in your `~/.zshrc`:

    ZSH_THEME="powerlevel9k/powerlevel9k"

##### Option 3: Install for Prezto

To install this theme for use in Prezto, clone this repository into your
[Prezto](https://github.com/sorin-ionescu/prezto) `prompt/external` directory.

    $ cd ~.zprezto/modules/prompt/external
    $ git clone https://github.com/bhilburn/powerlevel9k.git
    $ ln -s powerlevel9k/powerlevel9k.zsh-theme ../functions/prompt_powerlevel9k_setup

You then need to select this theme in your `~/.zpreztorc`:

    zstyle ':prezto:module:prompt' theme 'powerlevel9k'

##### Option 4: Install for antigen

If you prefer [antigen](https://github.com/zsh-users/antigen), just add this
theme to the antigen config in your `~/.zshrc`:

    $ echo 'antigen theme bhilburn/powerlevel9k powerlevel9k' >> ~/.zshrc
    $ echo 'antigen apply' >> ~/.zshrc

Note that you should define any customizations before calling `antigen theme`
(i.e. setting the `POWERLEVEL9K_*` variables) in your `.zshrc`.

#### Step 2: Install Powerline Fonts
Technically, you don't *have* to install Powerline fonts. If you are using
a font that has some of the basic glyphs we need, you can use the theme in
`compatible` mode - see the third option, below.

To get the most out of theme, though, you'll want Powerline-patched fonts. There
are two varieties of these: 'Powerline Fonts' and 'Awesome Powerline
Fonts'. The latter includes additional glyphs that aren't required for a normal
install.

Do one of the following:

##### Option 1: Install Powerline Fonts

You can find the [installation instructions for Powerline Fonts here]
(https://powerline.readthedocs.org/en/latest/installation/linux.html#fonts-installation).
You can also find the raw font files [in this Github
repository](https://github.com/powerline/fonts) if you want to manually install
them for your OS.

After you have installed Powerline fonts, make the default font in your terminal
emulator the Powerline font you want to use.

This is the default mode for `Powerlevel9k`, and no further configuration is
necessary.

**N.B.:** If Powerlevel9k is not working properly, it is almost always the case
that the fonts were not properly installed, or you have not configured your
terminal to use a Powerline-patched font!

##### Option 2: Install Awesome Powerline Fonts

Alternatively, you can install [Awesome Powerline
Fonts](https://github.com/gabrielelana/awesome-terminal-fonts), which provide
a number of additional glyphs.

You then need to indicate that you wish to use the additional glyphs by defining
the following in your `~/.zshrc`:

    POWERLEVEL9K_MODE='awesome-patched'

If you choose to make use of this, your prompt will look something like this:

![](https://cloud.githubusercontent.com/assets/1544760/7959660/67612918-09fb-11e5-9ef2-2308363c3c51.png)

Note that if you prefer flat segment transitions, you can use the following with
`Awesome Powerline Fonts` installed:

    POWERLEVEL9K_MODE='flat'

Which looks like this:

![](https://cloud.githubusercontent.com/assets/1544760/7981324/76d0eb5a-0aae-11e5-9608-d662123d0b0a.png)

##### Option 3: Compatible Mode

This option is best if you prefer not to install additional fonts. This option
will work out-of-the-box if your your terminal font supports the segment
separator characters `\uE0B0` (left segment separator) and `\uE0B2` (right
segment separator).

All you need to do to in this case is install the `Powerlevel9k` theme itself,
as explained above, and then define the following in your `~/.zshrc`:

    POWERLEVEL9K_MODE='compatible'

Note that depending on your terminal font, this may still not render
appropriately. This configuration should be used as a back-up.

### Segment Customization

Customizing your prompt is easy! Select the segments you want to have displayed,
and then assign them to either the left or right prompt. The segments that are
currently available are:

* **aws** - The current AWS profile, if active (more info below)
* **context** - Your username and host (more info below)
* **dir** - Your current working directory.
* **history** - The command number for the current line.
* **node_version** - Show the version number of the installed Node.js.
* **rbenv** - Ruby environment information (if one is active).
* **rspec_stats** - Show a ratio of test classes vs code classes for RSpec.
* **status** - The return code of the previous command, and status of background jobs.
* **longstatus** - Same as previous, except this creates a status segment for the *right* prompt.
* **symfony2_tests** - Show a ratio of test classes vs code classes for Symfony2.
* **symfony2_version** - Show the current Symfony2 version, if you are in a Symfony2-Project dir.
* **time** - System time.
* **virtualenv** - Your Python [VirtualEnv](https://virtualenv.pypa.io/en/latest/).
* **vcs** - Information about this `git` or `hg` repository (if you are in one).

To specify which segments you want, just add the following variables to your
`~/.zshrc`. If you don't customize this, the below configuration is the default:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(longstatus history time)

#### The AWS Profile Segment

If you would like to display the [current AWS
profile](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), add
the `aws` segment to one of the prompts, and define `AWS_DEFAULT_PROFILE` in
your `~/.zshrc`:

    export AWS_DEFAULT_PROFILE=<profile_name>

#### The 'context' Segment

The `context` segment (user@host string) is conditional. This lets you enable it, but only display
it if you are not your normal user or on a remote host (basically, only print it
when it's likely you need it).

To use this feature, make sure the `context` segment is enabled in your prompt
elements (it is by default), and define a `DEFAULT_USER` in your `~/.zshrc`:

    export DEFAULT_USER=<your username>

#### The 'dir' segment

The `dir` segment shows the current working directory. You can limit the output
to a certain length:

    # Limit to the last two folders
    POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

#### The 'time' segment

By default the time is show in 'H:M:S' format. If you want to change it,
just set another format in your `~/.zshrc`. As an example, this is a reversed
time format:

    # Reversed time format
    POWERLEVEL9K_TIME_FORMAT='%D{%S:%M:%H}'

If you are using an "Awesome Powerline Font", you can add a time symbol to this
segment, as well:

    # Output time, date, and a symbol from the "Awesome Powerline Font" set
    POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S \uE868  %d.%m.%y}"

#### Unit Test Ratios

The `symfony2_tests` and `rspec_tests` segments both show a ratio of "real"
classes vs test classes in your source code. This is just a very simple ratio,
and does not show your code coverage or any sophisticated stats. All this does
is count your source files and test files, and calculate the ratio between them.
Just enough to give you a quick overview about the test situation of the project
you are dealing with.

#### The 'vcs' Segment

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

##### Symbols

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

### Troubleshooting

Here are some fixes to some common problems.

#### Gaps Between Segments

You can see this issue in the screenshot, below:

![](http://bhilburn.org/content/images/2014/12/font_issue.png)

Thankfully, this is easy to fix. This happens if you have successfully installed
Powerline fonts, but did not make a Powerline font the default font in your
terminal emulator (e.g., 'terminator', 'gnome-terminal', 'konsole', etc.,).

#### Segment Colors are Wrong

If the color display within your terminal seems off, it's possible you are using
a reduced color set. You can check this by invoking `echotc Co` in your
terminal, which should yield `256`. If you see something different, try setting
`xterm-256color` in your `~/.zshrc`:

    TERM=xterm-256color

### Meta

#### Kudos

This theme wouldn't have happened without inspiration from the original
[agnoster](https://gist.github.com/agnoster/3712874) Oh-My-ZSH theme.

Before creating this theme, I also tried [jeremyFreeAgent's
theme](https://github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme) and
[maverick2000's theme, ZSH2000](https://github.com/maverick2000/zsh2000).

#### Developing

Documentation for developers is kept on the [Powerlevel9k Github
wiki](https://github.com/bhilburn/powerlevel9k/wiki/Developer's-Guide).

#### Contributions / Bugs / Contact

If you have any requests or bug reports, please use the tracker in this Github
repository.

I'm happy to accept code contributions from anyone who has a bug fix, new
feature, or just a general improvement! Please submit your contribution as
a Github pull-request.

If you would like to contact me directly, you can find my e-mail address on my
[Github profile page](https://github.com/bhilburn).
