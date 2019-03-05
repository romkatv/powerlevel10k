---
name: Performance Issue
about: For performance Issues
title: "[Performance]"
labels: performance
assignees: ''

---

Sorry to hear that the performance of P9K is not adequate. To fix this, please provide us with some hints.

### Your Hardware

Disk I/O is critical for P9K, so do you use a spinning disk, or a SSD?

### Virtualization

Do you use P9K in some sort of virtualization? This is also the case, if you use WSL on Windows..

### How Fast is Fast

Could you quantify how fast the specific segment is, that you think is slow?
For example, if you think the `vcs` segment is slow, could you execute this command in the directory, where the segment is slow:

```zsh
time (repeat 10; do; prompt_vcs left 1 false >/dev/null; done;)
```

Also, please provide us with some context around the segment. In the `vcs` example:

- How big is the repo?
- Does it contain a lot of untracked files?
- Does it contain a lot of git submodules?
- Does it contain a lot of files in general?

Additionally, you could install [zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark), to benchmark the general performance of ZSH and P9K.

If you don't know which segment is slow, could you remove one by one, and spot the one that made the greatest impact?