![](https://raw.githubusercontent.com/bhilburn/powerlevel9k-logo/master/logo-banner.png)
---
[![Build Status](https://travis-ci.org/bhilburn/powerlevel9k.svg?branch=next)](https://travis-ci.org/bhilburn/powerlevel9k)
[![Join the chat at https://gitter.im/bhilburn/powerlevel9k](https://badges.gitter.im/bhilburn/powerlevel9k.svg)](https://gitter.im/bhilburn/powerlevel9k?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Powerlevel9k is a theme for ZSH which uses [Powerline
Fonts](https://github.com/powerline/fonts). It can be used with vanilla ZSH or
ZSH frameworks such as [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh),
[Prezto](https://github.com/sorin-ionescu/prezto),
[Antigen](https://github.com/zsh-users/antigen), and [many
others](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions).

Get more out of your terminal. Be a badass. Impress everyone in 'Screenshot Your
Desktop' threads. Use powerlevel9k.

![](http://bhilburn.org/content/images/2015/01/pl9k-improved.png)

You can check out some other users' configurations in our wiki: [Show Off Your
Config](https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config).

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

Here is `powerlevel9k` in action, with [some simple settings](https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config#natemccurdys-configuration).

![](https://camo.githubusercontent.com/80ec23fda88d2f445906a3502690f22827336736/687474703a2f2f692e696d6775722e636f6d2f777942565a51792e676966)

### Table of Contents

1. [Installation](#installation)
2. [Customization](#prompt-customization)
    1. [Stylizing Your Prompt](https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt)
    2. [Customizing Prompt Segments](#customizing-prompt-segments)
    3. [Available Prompt Segments](#available-prompt-segments)
3. [Troubleshooting](https://github.com/bhilburn/powerlevel9k/wiki/Troubleshooting)

Be sure to also [check out the Wiki](https://github.com/bhilburn/powerlevel9k/wiki)!

### Installation
There are two installation steps to go from a lame terminal to a "Power Level
9000" terminal. Once you are done, you can optionally customize your prompt.

[Installation Instructions](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions)

1. [Install the Powerlevel9k Theme](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-1-install-powerlevel9k)
2. [Install Powerline-Patched Fonts](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-2-install-powerline-fonts)

No configuration is necessary post-installation if you like the default
settings, but there are plenty of segment customization options available if you
are interested.

### Prompt Customization

Be sure to check out the wiki page on the additional prompt customization
options, including color and icon settings: [Stylizing Your Prompt](https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt)

#### Customizing Prompt Segments
Customizing your prompt is easy! Select the segments you want to have displayed,
and then assign them to either the left or right prompt by adding the following
variables to your `~/.zshrc`.

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`|`(context dir rbenv vcs)`|Segment list for left prompt|
|`POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS`|`(status history time)`|Segment list for right prompt|


So if you wanted to set these variables manually, you would put the following in
your `~/.zshrc`:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)

#### Available Prompt Segments
The segments that are currently available are:

**System Status Segments:**
* [`background_jobs`](#background_jobs) - Indicator for background jobs.
* [`battery`](#battery) - Current battery status.
* [`context`](#context) - Your username and host.
* [`dir`](#dir) - Your current working directory.
* `history` - The command number for the current line.
* [`ip`](#ip) - Shows the current IP address.
* `load` - Your machine's load averages.
* `os_icon` - Display a nice little icon, depending on your operating system.
* `ram` - Show free RAM.
* `root_indicator` - An indicator if the user has superuser status.
* [`status`](#status) - The return code of the previous command.
* `swap` - Prints the current swap size.
* [`time`](#time) - System time.
* [`vi_mode`](#vi_mode)- Your prompt's Vi editing mode (NORMAL|INSERT).

**Development Environment Segments:**
* [`vcs`](#vcs) - Information about this `git` or `hg` repository (if you are in one).

**Language Segments:**
* **GoLang Segments:**
    * `go_version` - Show the current GO version.
* **Javascript / Node.js Segments:**
    * `node_version` - Show the version number of the installed Node.js.
    * `nodeenv` - [nodeenv](https://github.com/ekalinin/nodeenv) prompt for displaying node version and environment name.
    * `nvm` - Show the version of Node that is currently active, if it differs from the version used by NVM
* **PHP Segments:**
    * `php_version` - Show the current PHP version.
    * [`symfony2_tests`](#symfony2_tests) - Show a ratio of test classes vs code classes for Symfony2.
    * `symfony2_version` - Show the current Symfony2 version, if you are in a Symfony2-Project dir.
* **Python Segments:**
    * `virtualenv` - Your Python [VirtualEnv](https://virtualenv.pypa.io/en/latest/).
    * [`anaconda`](#anaconda) - Your active [Anaconda](https://www.continuum.io/why-anaconda) environment.
    * `pyenv` - Your active python version as reported by the first word of [`pyenv version`](https://github.com/yyuu/pyenv). Note that the segment is not displayed if that word is _system_ i.e. the segment is inactive if you are using system python.
* **Ruby Segments:**
    * [`chruby`](#chruby) - Ruby environment information using `chruby` (if one is active).
    * [`rbenv`](#rbenv) - Ruby environment information using `rbenv` (if one is active).
    * [`rspec_stats`](#rspec_stats) - Show a ratio of test classes vs code classes for RSpec.
* **Rust Segments:**
    * `rust_version` - Display the current rust version and [logo](https://www.rust-lang.org/logos/rust-logo-blk.svg).

**Cloud Segments:**
* **AWS Segments:**
    * [`aws`](#aws) - The current AWS profile, if active.
    * `aws_eb_env` - The current Elastic Beanstalk Environment.
* `docker_machine` - The current Docker Machine.

**Other:**
* [`custom_command`](#custom_command) - Create a custom segment to display the
  output of an arbitrary command.
* [`todo`](http://todotxt.com/) - Shows the number of tasks in your todo.txt tasks file.

---------------------------------------------------------------------------------


##### anaconda

This segment shows your active anaconda environment. It relies on either the
`CONDA_ENV_PATH` or the `CONDA_PREFIX` (depending on the `conda` version)
environment variable to be set which happens when you properly `source
activate` an environment.

Special configuration variables:

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_ANACONDA_LEFT_DELIMITER`|"("|The left delimiter just before the environment name.|
|`POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER`|")"|The right delimiter just after the environment name.|

Additionally the following segment specific parameters can be used to customize
it: `POWERLEVEL9K_PYTHON_ICON`, `POWERLEVEL9K_ANACONDA_BACKGROUND`, and
`POWERLEVEL9K_ANACONDA_FOREGROUND`.

##### aws

If you would like to display the [current AWS
profile](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), add
the `aws` segment to one of the prompts, and define `AWS_DEFAULT_PROFILE` in
your `~/.zshrc`:

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`AWS_DEFAULT_PROFILE`|None|Your AWS profile name|

##### background_jobs

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE`|`true`|If there is more than one background job, this segment will show the number of jobs. Set this to `false` to turn this feature off.|

##### battery

This segment will display your current battery status (fails gracefully on
systems without a battery). It is supported on both OSX and Linux (note that it
requires `acpi` on Linux).

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_BATTERY_CHARGING`|`"yellow"`|Color to indicate a charging battery.|
|`POWERLEVEL9K_BATTERY_CHARGED`|`"green"`|Color to indicate a charged battery.|
|`POWERLEVEL9K_BATTERY_DISCONNECTED`|`$DEFAULT_COLOR`|Color to indicate absence of battery.|
|`POWERLEVEL9K_BATTERY_LOW_THRESHOLD`|`10`|Threshold to consider battery level critical.|
|`POWERLEVEL9K_BATTERY_LOW_COLOR`|`"red"`|Color to indicate critically low charge level.|
|`POWERLEVEL9K_BATTERY_VERBOSE`|`true`|Display time remaining next to battery level.|

Note that you can [modify the `_FOREGROUND`
color](https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt#segment-color-customization)
without affecting the icon color.

##### custom_command

The `custom_...` segment allows you to turn the output of a custom command into
a prompt segment. As an example, if you wanted to create a custom segment to
display your WiFi signal strength, you might define a custom segment called
`custom_wifi_signal` like this:

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context time battery dir vcs virtualenv custom_wifi_signal)
    POWERLEVEL9K_CUSTOM_WIFI_SIGNAL="echo signal: \$(nmcli device wifi | grep yes | awk '{print \$8}')"
    POWERLEVEL9K_CUSTOM_WIFI_SIGNAL_BACKGROUND="blue"
    POWERLEVEL9K_CUSTOM_WIFI_SIGNAL_FOREGROUND="yellow"

If you prefer, you can also define the function in your `.zshrc` rather than
putting it in-line with the variable export, as shown above. Just don't forget
to invoke your function from your segment! Example code that achieves the same
result as the above:

    zsh_wifi_signal(){
            local signal=$(nmcli device wifi | grep yes | awk '{print $8}')
            local color='%F{yellow}'
            [[ $signal -gt 75 ]] && color='%F{green}'
            [[ $signal -lt 50 ]] && color='%F{red}'
            echo -n "%{$color%}\uf230  $signal%{%f%}" # \uf230 is 
    }

    POWERLEVEL9K_CUSTOM_WIFI_SIGNAL="zsh_wifi_signal"
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context time battery dir vcs virtualenv custom_wifi_signal)

The command, above, gives you the wireless signal segment shown below:

![signal](http://i.imgur.com/hviMATC.png)

You can define as many custom segments as you wish. If you think you have
a segment that others would find useful, please consider upstreaming it to the
main theme distribution so that everyone can use it!

##### context

The `context` segment (user@host string) is conditional. This lets you enable
it, but only display it if you are not your normal user or on a remote host
(basically, only print it when it's likely you need it).

To use this feature, make sure the `context` segment is enabled in your prompt
elements (it is by default), and define a `DEFAULT_USER` in your `~/.zshrc`:

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`DEFAULT_USER`|None|Username to consider a "default context" (you can also use `$USER`)|

##### dir

The `dir` segment shows the current working directory. When using the "Awesome
Powerline" fonts, there are additional glyphs, as well:

| `Compatible` | `Powerline` | `Awesome Powerline` | Situation
|------------|-----------|-------------------|----------------------------
| None       | None      | ![](https://cloud.githubusercontent.com/assets/1544760/12183451/40ec4016-b58f-11e5-9b9e-74e2b2f0b8b3.png) | At the root of your home folder |
| None       | None      | ![](https://cloud.githubusercontent.com/assets/1544760/12369315/8a5d762c-bbf5-11e5-8a20-ca1179f48d6c.png) | Within a subfolder of your home directory |
| None       | None      | ![](https://cloud.githubusercontent.com/assets/1544760/12183452/40f79286-b58f-11e5-9b8c-ed1343a07b08.png) | Outside of your home folder |

To turn off these icons you could set these variables to an empty string.

    POWERLEVEL9K_HOME_ICON=''
    POWERLEVEL9K_HOME_SUB_ICON=''
    POWERLEVEL9K_FOLDER_ICON=''

You can limit the output to a certain length by truncating long paths.
Customizations available are:

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_SHORTEN_DIR_LENGTH`|`2`|If your shorten strategy, below, is entire directories, this field determines how many directories to leave at the end. If your shorten strategy is by character count, this field determines how many characters to allow per directory string.|
|`POWERLEVEL9K_SHORTEN_STRATEGY`|None|How the directory strings should be truncated. By default, it will truncate whole directories. Other options are `truncate_middle`, which leaves the start and end of the directory strings, and `truncate_from_right`, which cuts starting from the end of the string.  You can also use `truncate_with_package_name` to use the `package.json` `name` field to abbreviate the directory path.|
|`POWERLEVEL9K_SHORTEN_DELIMITER`|`..`|Delimiter to use in truncated strings. This can be any string you choose, including an empty string if you wish to have no delimiter.|

For example, if you wanted the truncation behavior of the `fish` shell, which
truncates `/usr/share/plasma` to `/u/s/plasma`, you would use the following:

    POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    POWERLEVEL9K_SHORTEN_DELIMITER=""
    POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

In each case you have to specify the length you want to shorten the directory
to. So in some cases `POWERLEVEL9K_SHORTEN_DIR_LENGTH` means characters, in
others whole directories.

The `truncate_with_package_name` strategy gives your directory path relative to the root of your project.  For example, if you have a project inside `$HOME/projects/my-project` with a `package.json` that looks like:

```json
{
  "name": "my-cool-project"
}
```

the path shown would be `my-cool-project`.  If you navigate to `$HOME/projects/my-project/src`, then the path shown would be `my-cool-project/src`.  Please note that this currently looks for `.git` directory to determine the root of the project.

##### ip

This segment tries to examine all currently used network interfaces and prints
the first address it finds.  In the case that this is not the right NIC, you can
specify the correct network interface by setting:

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_IP_INTERFACE`|None|The NIC for which you wish to display the IP address. Example: `eth0`.|

##### rbenv

This segment shows the version of Ruby being used when using `rbenv` to change your current Ruby stack.

It figures out the version being used by taking the output of the `rbenv version-name` command.

* If `rbenv` is not in $PATH, nothing will be shown.
* If the current Ruby version is the same as the global Ruby version, nothing will be shown.

##### rspec_stats

See [Unit Test Ratios](#unit-test-ratios), below.

##### status

This segment shows the return code of the last command.

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_STATUS_VERBOSE`|`true`|Set to false if you wish to hide this segment when the last command completed successfully.|

##### ram

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_RAM_ELEMENTS`|Both|Specify `ram_free` or `swap_used` to only show one or the other rather than both.|

##### symfony2_tests

See [Unit Test Ratios](#unit-test-ratios), below.

##### time

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_TIME_FORMAT`|`'H:M:S'`|ZSH time format to use in this segment.|

As an example, if you wanted a reversed time format, you would use this:

    # Reversed time format
    POWERLEVEL9K_TIME_FORMAT='%D{%S:%M:%H}'

If you are using an "Awesome Powerline Font", you can add a time symbol to this
segment, as well:

    # Output time, date, and a symbol from the "Awesome Powerline Font" set
    POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S \uE868  %d.%m.%y}"

##### vcs

By default, the `vcs` segment will provide quite a bit of information. Further
customization is provided via:

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_HIDE_BRANCH_ICON`|`false`|Set to `true` to hide the branch icon from the segment.|
|`POWERLEVEL9K_SHOW_CHANGESET`|`false`|Set to `true` to display the hash / changeset in the segment.|
|`POWERLEVEL9K_CHANGESET_HASH_LENGTH`|`12`|How many characters of the hash / changeset to display in the segment.|
|`POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY`|`true`|Set to `false` to not reflect submodule status in the top-level repository prompt.|
|`POWERLEVEL9K_VCS_HIDE_TAGS`|`false`|Set to `true` to stop tags being displayed in the segment.|


##### vcs symbols

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

This segment shows ZSH's current input mode. Note that this is only useful if
you are using the [ZSH Line Editor](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html)
(VI mode).  You can enable this either by `.zshrc` configuration or using a plugin, like
[Oh-My-Zsh's vi-mode plugin](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/vi-mode/vi-mode.plugin.zsh).

| Variable | Default Value | Description |
|----------|---------------|-------------|
|`POWERLEVEL9K_VI_INSERT_MODE_STRING`|`"INSERT"`|String to display while in 'Insert' mode.|
|`POWERLEVEL9K_VI_COMMAND_MODE_STRING`|`"NORMAL"`|String to display while in 'Command' mode.|

#### Unit Test Ratios

The `symfony2_tests` and `rspec_stats` segments both show a ratio of "real"
classes vs test classes in your source code. This is just a very simple ratio,
and does not show your code coverage or any sophisticated stats. All this does
is count your source files and test files, and calculate the ratio between them.
Just enough to give you a quick overview about the test situation of the project
you are dealing with.

### tl; dr

Want to just get a quick start? Check out the [Show Off Your
Config](https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config)
portion of the wiki to get going.

[The Wiki also has a ton of other useful
information!](https://github.com/bhilburn/powerlevel9k/wiki)

### License

Project: MIT

Logo: CC-BY-SA. Source repository: https://github.com/bhilburn/powerlevel9k-logo
