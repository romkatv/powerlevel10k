## powerlevel9k Theme for Oh-My-Zsh

This is a theme for [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh). This
theme uses [Powerline Fonts](https://github.com/Lokaltog/powerline-fonts), thus
giving you the most epic terminal styling in the universe.

Look like a bad-ass. Impress everyone in 'Screenshot Your Desktop' threads. Use powerlevel9k.

In addition to looking amazing, this theme actually provides a lot of useful
information in configurable prompt segments.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Features](#features)
- [Installation](#installation)
  - [Install Powerlevel9k](#install-powerlevel9k)
  - [Install Powerline Fonts for Normal Configuration](#install-powerline-fonts-for-normal-configuration)
  - [Alternative Configuration: Über](#alternative-configuration-%C3%BCber)
  - [Alternative Configuration: Bare Bones](#alternative-configuration-bare-bones)
- [Segment Customization](#segment-customization)
  - [The AWS Profile Segment](#the-aws-profile-segment)
  - [The 'context' Segment](#the-context-segment)
  - [The 'time' segment](#the-time-segment)
  - [Unit Test Ratios](#unit-test-ratios)
  - [The 'vcs' Segment](#the-vcs-segment)
    - [Symbols](#symbols)
- [Styling](#styling)
  - [Double-Lined Prompt](#double-lined-prompt)
  - [Light Color Theme](#light-color-theme)
  - [Further color customizations](#further-color-customizations)
- [Troubleshooting](#troubleshooting)
  - [Gaps Between Segments](#gaps-between-segments)
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
* Can conditionally display the `user@host` string when needed
* Provides segment for command history (so you can `$ !<num>` to re-run)
* Plenty of additional segments to choose from (e.g., AWS, ruby)
* Can be used as a single or double-lined prompt (see screenshots below)
* Several built-in color configurations to choose from

**If you would like an OMZ theme that provides some of the same features but
doesn't require Powerline fonts, check out the sister font,
[hackersaurus](https://github.com/bhilburn/hackersaurus).**

Here are some screenshots of `powerlevel9k` with default settings:

![](http://bhilburn.org/content/images/2014/12/powerlevel9k.png)

![](http://bhilburn.org/content/images/2015/01/pl9k-improved.png)


### Installation
There are three different forms of installation that you can use to make use of
this theme:

* Normal - Theme + Powerline Fonts
* Über - Theme + Awesome Powerline Fonts
* Bare Bones - Theme Only

#### Install Powerlevel9k

To install this theme, clone this repository into your Oh-My-Zsh `custom/themes`
directory.

    $ cd ~/.oh-my-zsh/custom
    $ git clone https://github.com/bhilburn/powerlevel9k.git themes/powerlevel9k

You then need to select this theme in your `~/.zshrc`:

    ZSH_THEME="powerlevel9k/powerlevel9k"


#### Install Powerline Fonts for Normal Configuration

You can find the [installation instructions for Powerline Fonts here]
(https://powerline.readthedocs.org/en/latest/installation/linux.html#fonts-installation).
You can also find the raw font files [in this Github
repository](https://github.com/powerline/fonts) if you want to manually install
them for your OS.

After you have installed Powerline fonts, make the default font in your terminal
emulator the Powerline font you want to use.

This is the default mode for `Powerlevel9k`, and no further configuration is
necessary.

#### Alternative Configuration: Über

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

#### Alternative Configuration: Bare Bones

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
* **rbenv** - Ruby environment information (if one is active).
* **rspec_stats** - Show a ratio of test classes vs code classes for RSpec.
* **status** - The return code of the previous command, and status of background jobs.
* **symfony2_tests** - Show a ratio of test classes vs code classes for Symfony2.
* **time** - System time.
* **virtualenv** - Your Python [VirtualEnv](https://virtualenv.pypa.io/en/latest/).
* **vcs** - Information about this `git` or `hg` repository (if you are in one).

To specify which segments you want, just add the following variables to your
`~/.zshrc`. If you don't customize this, the below configuration is the default:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)

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

#### The 'time' segment

By default the time is show in 'H:M:S' format. If you want to change it, 
just set another format in your `~/.zshrc`:

    # Reversed time format
    POWERLEVEL9K_TIME_FORMAT='%D{%S:%M:%H}' 

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
set `POWERLEVEL9K_CHANGESET_HASH_LENTH` to any value you want.
Example:

    # enable the vcs segment in general
    POWERLEVEL9K_SHOW_CHANGESET=true
    # just show the 6 first characters of changeset
    POWERLEVEL9K_CHANGESET_HASH_LENGTH=6

##### Symbols

The `vcs` segment uses various symbols to tell you the state of your repository.
These symbols depend on your installed font and selected `POWERLEVEL9K_MODE`
from the [Installation](#Installation) section above.

| `Bare Bones` | `Normal` | `Über` | explanation
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

#### Light Color Theme

If you prefer to use "light" colors, simply set `POWERLEVEL9K_COLOR_SCHEME`
to `light` in your `~/.zshrc`, and you're all set!

    POWERLEVEL9K_COLOR_SCHEME='light'

The 'light' color scheme works well for ['Solarized
Light'](https://github.com/altercation/solarized) users. Check it out:

![](http://bhilburn.org/content/images/2015/03/solarized-light.png)

#### Further color customizations

For each segment in your prompt, you can specify a foreground and background
color by setting them in your `~/.zshrc`. For example, to change the appearance
of the `time` segment, you would use:

    POWERLEVEL9K_TIME_FOREGROUND='red'
    POWERLEVEL9K_TIME_BACKGROUND='blue'

Use the segment names from the above section `Segment Customization`.  Some of
the Segments have special color variables, as they change the colors according
to some internal rules. These Segments are `vcs`, `rspec_stats`, `symfony2_tests`:

    # General VCS color segments:
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

You could also use a colorcode value. Example:

    POWERLEVEL9K_VCS_FOREGROUND='021' # Dark blue

For a full list of supported colors, run the `spectrum_ls` program in your
terminal.

### Troubleshooting

Here are some fixes to some common problems.

#### Gaps Between Segments

You can see this issue in the screenshot, below:

![](http://bhilburn.org/content/images/2014/12/font_issue.png)

Thankfully, this is easy to fix. This happens if you have successfully installed
Powerline fonts, but did not make a Powerline font the default font in your
terminal emulator (e.g., 'terminator', 'gnome-terminal', 'konsole', etc.,).

### Contributions / Bugs / Contact

If you have any requests or bug reports, please use the tracker in this Github
repository.

I'm happy to accept code contributions from anyone who has an improvement!
Please submit your contribution as a Github pull-request.

If you would like to contact me directly, you can find my e-mail address on my
[Github profile page](https://github.com/bhilburn).

