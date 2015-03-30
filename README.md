## powerlevel9k Theme for Oh-My-Zsh

This is a theme for [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh). This
theme uses [Powerline Fonts](https://github.com/Lokaltog/powerline-fonts), thus
giving you the most epic terminal styling in the universe.

Look like a bad-ass. Impress everyone in 'Screenshot Your Desktop' threads. Use powerlevel9k.

In addition to looking amazing, this theme actually provides a lot of useful
information.

### Features

* Shows lots of information about Git and Hg repositories, including:
    * branch / tag name
    * current action status (rebasing, merging, etc.,)
    * being behind / ahead of your remote
    * conditionally shows remote tracking branch if it differs from local
    * various local working tree statuses
* Shows command number in right-prompt (so you can `$ !<num>` to re-run)
* Shows return-code of command if it is an error code
* Shows system time in right-prompt
* Indicates background jobs with a gear
* Will conditionally display the `user@host` string
* Plenty of other segments you can enable if you want them (e.g., ruby, AWS)
* Can be used as a single or double-lined prompt (see screenshots below)
* Several built-in color configurations to choose from

**If you would like an OMZ theme that provides most of the same features but
doesn't require Powerline fonts, check out the sister font,
[hackersaurus](https://github.com/bhilburn/hackersaurus).**

These screenshots should give you an idea of what `powerlevel9k` looks like:

![](http://bhilburn.org/content/images/2014/12/powerlevel9k.png)

![](http://bhilburn.org/content/images/2015/01/pl9k-improved.png)


### Installation

First, you need to install Powerline Fonts. You can find the [installation
instructions
here](https://powerline.readthedocs.org/en/latest/installation/linux.html#fonts-installation).
You can also find the raw font files [in this Github
repository](https://github.com/powerline/fonts) if you want to manually install
them for your OS.

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
* **status** - The return code of the previous command, and status of background jobs.
* **time** - System time.
* **vcs** - Information about this `git` or `hg` repository (if you are in one).

To specify which segments you want, just add the following variables to your
`~/.zshrc`. If you don't customize this, the below configuration is the default:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)

If you want to show the current changeset in a `git` or `hg` repository, enable
`POWERLEVEL9K_SHOW_CHANGESET` in your `~/.zshrc`:

    POWERLEVEL9K_SHOW_CHANGESET=true

#### The AWS Profile Segment

If you would like to display the [current AWS
profile](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), add
the `aws` segment to one of the prompts, and define `AWS_DEFAULT_PROFILE` in
your `~/.zshrc`:

    export AWS_DEFAULT_PROFILE=<profile_name>

#### The 'context' Segment

The `context` segment (user@host string) is conditional. This lets you enable it, but only display
it if you are not your normal user or on a remote host (basically, only print it
when it likely you need it).

To use this feature, make sure the `context` segment is enabled in your prompt
elements (it is by default), and define a `DEFAULT_USER` in your `~/.zshrc`:

    export DEFAULT_USER=<your username>

<<<<<<< HEAD
### Styling

You can configure the look and feel of your prompt easily with some built-in
options.

#### Double-Lined Prompt

By default, `powerlevel9k` is a single-lined prompt. If you would like to have
the segments display on one line, and print the command prompt below it, simply
define `POWERLEVEL9K_PROMPT_ON_NEWLINE` in your `~/.zshrc`:

    export POWERLEVEL9K_PROMPT_ON_NEWLINE=true

#### Light Color Theme

If you prefer to use "light" colors, simply set `POWERLEVEL9K_COLOR_SCHEME`
to `light` in your `~/.zshrc`, and you're all set!

    POWERLEVEL9K_COLOR_SCHEME='light'

#### Solarized colors

If you want your terminal colors not so bright, you may want to use an alternate 
color scheme. One of them is "solarized": https://github.com/altercation/solarized

### Bugs / Contact

If you have any requests or bug reports, please use the tracker in this Github
repository.

