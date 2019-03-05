---
name: Bug report
about: Create a report to help us improve
title: ''
labels: ''
assignees: ''

---

Thanks for opening an issue! For a project that deals with as many different things as P9k, debugging problems can be difficult. Please follow the guide, below, to create a bug report that will help us help you!

### Before Opening a Bug
P9k is lovingly maintained by volunteers, and we are happy to help you! You can help us by first making sure your issue hasn't already been solved before opening a new one. Please check the [Troubleshooting Guide](https://github.com/bhilburn/powerlevel9k/wiki/Troubleshooting) first. Many issues are actually local configuration problems, which may have previously been solved by another user - be sure to also [search the existing issues](https://github.com/bhilburn/powerlevel9k/issues?utf8=%E2%9C%93&q=is%3Aissue) before opening a new one.

Once you've done these things, you can delete this section and proceed `=)`

-----

#### Describe Your Issue
What is happening?

Most issues are best explained with a screenshot. Please share one if you can!

#### Have you tried to debug or fix it?

Have you tinkered with your settings, and what happened when you did? Did you find a bit of code that you think might be the culprit? Let us know what you've done so far!

#### Environment Information

This information will help us understand your configuration.

  - What version of ZSH are you using? You can use `zsh --version` to see this.
  - Do you use a ZSH framework (e.g., Oh-My-ZSH, Antigen)?
  - How did you install P9k (cloning the repo, by tarball, a package from your OS, etc.,)?
  - What version of P9k are you using?
  - Which terminal emulator do you use?

#### Issues with Fonts & Icons
You may delete this section if your issue is not font / icon related.

  - Which font do you use?
  - Which [font configuration mode](https://github.com/bhilburn/powerlevel9k/wiki/About-Fonts) are you using? You can check this with (`echo $POWERLEVEL9K_MODE`).
  - Please share the contents of `$P9k/debug/font-issues.zsh`.
  - If this is an icon problem, does the output of `$ get_icon_names` look correct?
