## powerlevel9k Theme for Oh-My-Zsh

This is a theme for [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh). This
theme uses [Powerline Fonts](https://github.com/Lokaltog/powerline-fonts), thus
giving you the most epic terminal styling in the universe.

Look like a bad-ass. Impress everyone in 'Screenshot Your Desktop' threads. Use powerlevel9k.

In addition to looking amazing, this theme actually provides a lot of useful
information in configurable prompt segments.

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

There are two things you need to make this theme work correctly: Powerline
fonts, and the theme itself.

#### Install Powerline Fonts
First, you need to install Powerline Fonts. You can find the [installation
instructions
here](https://powerline.readthedocs.org/en/latest/installation/linux.html#fonts-installation).
You can also find the raw font files [in this Github
repository](https://github.com/powerline/fonts) if you want to manually install
them for your OS.

After you have installed Powerline fonts, make the default font in your terminal
emulator the Powerline font you want to use.

#### Install Powerlevel9k

To install this theme, clone this repository into your Oh-My-Zsh `custom/themes`
directory.

    $ cd ~/.oh-my-zsh/custom
    $ git clone https://github.com/bhilburn/powerlevel9k.git themes/powerlevel9k

You then need to select this theme in your `~/.zshrc`:

    ZSH_THEME="powerlevel9k/powerlevel9k"

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

#### Test ratio

The `symfony2_tests` and `rspec_tests` segments show both a ratio of "real" classes
vs test classes. This is just a very simple ratio, and does not show your code
coverage or any sophisticated stats. All this does is just to count your files
and test files and calculate the ratio between them. Not more, but is may give
a quick overview about the test situation of the project you are dealing with.

#### The 'time' segment

By default the time is show in 'H:M:S' format. If you want to change it, 
just set another format in your `~/.zshrc`:

    # Reversed time format
    POWERLEVEL9K_TIME_FORMAT='%D{%S:%M:%H}' 

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

The `vcs` segment uses various symbols to tell you the state of your repository:

* `↑4` - The number of commits your repository is ahead of your remote branch
* `↓5` - The number of commits your repository is behind of your remote branch
* `⍟3` - The number of stashes, here 3.
* `●`  - There are unstaged changes in your working copy
* `✚`  - There are staged changes in your working copy
* `?`  - There are files in your working copy, that are unknown to your repository
* `→`  - The name of your branch differs from its tracking branch.
* `☿`  - A mercurial bookmark is active.

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

