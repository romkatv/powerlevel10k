# gitstatus
**gitstatus** enables much faster vcs/git prompt in
[Powerlevel10k](https://github.com/romkatv/powerlevel10k) ZSH theme. It works on Mac OS, Linux, FreeBSD and WSL. See [benchmarks](https://github.com/romkatv/powerlevel10k#how-fast-is-it).

## Installation

1. Install [Powerlevel10k](https://github.com/romkatv/powerlevel10k) ZSH theme.

2. If you use WSL (even occasionally), it's a good idea to define this option in your `.zshrc`:

```zsh
# When running on WSL, do not scan dirty files in git repos with over 4k files.
[[ $(</proc/version) =~ Microsoft ]] && GITSTATUS_DIRTY_MAX_INDEX_SIZE=4096
```

With this option gitstatus won't be looking for dirty (unstaged and untracked) files in git repos with over 4k files. Scanning such repos is incredibly slow on WSL! The prompt will indicate with color that there _might_ be dirty files. With default color settings it means the prompt will never be green.

The option must be set before sourcing gitstatus.

3. Clone gitstatus repo.

```zsh
# Assuming oh-my-zsh at the standard location. Adjust to your circumstances.
git clone https://github.com/romkatv/gitstatus.git ~/.oh-my-zsh/custom/plugins/gitstatus
```

4. Either manually source `gitstatus.plugin.zsh` from your `.zshrc` or enable `gitstatus` plugin in oh-my-zsh.

## How it works

When using common tools such as [vcs_info](http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#vcs_005finfo-Quickstart) to embed git status in shell prompt, latency is high for three main reasons:

  1. About a dozen processes are created to generate each prompt. Creating processes and pipes to communicate with them is expensive.
  2. There is a lot of redundancy between different `git` commands that are invoked. For example, every command has to scan parent directories in search of `.git`. Many commands have to resolve HEAD. Several have to read index.
  3. There is redundancy between consecutive prompts, too. Even if you stay within the same repo, each prompt will read git index form disk before it can be rendered.

Some prompt generators attempt to work around this problem by rendering prompt asynchronously. This has undesirable effects. When you `cd` to another repo, or make changes to an existing repo such as creating a new untracked file, the prompt will either display incorrect repo state and fix later while you are typing, or not display the prompt at all and add it a second later.

**gitstatus** solves this problem by running a daemon next to each interactive shell. Whenever prompt needs to refresh, it sends the current directory to the daemon and receives git info back, all with a single roundtrip. The daemon is written in C++ and is using [libgit2](https://libgit2.org/) under the hood for heavy lifting. it keeps indices of all repos in memory for faster access. It never serves stale data -- every prompt receives accurate representation of the current state of the repo. Since fetching git info this way very fast, there is no need for asynchronous prompts.

## Requirements

*  To compile: C++17 compiler, GNU make, pkg-config, libgit2.
*  To run: GNU libc on Linux, FreeBSD and WSL; nothing on Mac OS.

## Compiling

There are prebuilt `gitstatusd` binaries for `{darwin,freebsd,linux}-x86_64` bundled with the plugin. When you source `gitstatus.plugin.zsh`, it'll pick the right binary for your architecture automatically.

If precompiled binaries don't work for you, you'll need to get your hands dirty. On Mac OS you'll first need to build [libiconv](https://www.gnu.org/software/libiconv/) as a static library. Then download, compile and install [libgit2](https://github.com/libgit2/libgit2). Compile it statically with all optional features disabled and all required features bundled.


```zsh
git clone https://github.com/libgit2/libgit2.git
cd libgit2
mkdir build
cd build
cmake                        \
  -DUSE_SSH=OFF              \
  -DUSE_HTTPS=OFF            \
  -DTHREADSAFE=OFF           \
  -DBUILD_SHARED_LIBS=OFF    \
  -DUSE_EXT_HTTP_PARSER=OFF  \
  -DUSE_BUNDLED_ZLIB=ON      \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make VERBOSE=1 -j 20
sudo make install
```

Then build gitstatus itself.

```zsh
git clone https://github.com/romkatv/gitstatus.git
cd gitstatus
make -j 20
```

You can use `CXX=clang++ make` to compile with clang (the default compiler is gcc). On Mac OS you'll also need to override `LDLIBS`:

```zsh
CXX=clang++ LDLIBS=-lgit2 make -j 20
```

In order to achieve static linking with libgit2 and iconv on MacOS, make sure linker cannot find the dynamic versions of these libraries.

Here's what the resulting binary should look like on Linux, FreeBSD and WSL:

```zsh
$ ldd ./gitstatusd
	linux-vdso.so.1 (0x00007ffccbfd4000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f59e6823000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f59e700b000)
```

On Mac OS:

```zsh
$ otool -L gitstatusd
gitstatusd:
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.4)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.200.5)
```

To verify that it works type the following command from a clean zsh shell (run `zsh -df` to get there):

```zsh
GITSTATUS_DAEMON=./gitstatusd source ./gitstatus.plugin.zsh && [[ -v GITSTATUS_DAEMON_PID ]] && echo works || echo broken
```

## More Docs

Run `gitstatusd --help` for help or read the same thing in [options.cc](https://github.com/romkatv/gitstatus/blob/master/src/options.cc).

There are also docs in [gitstatus.plugin.zsh](https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh).

## License

GNU General Public License v3.0. See [LICENSE](https://github.com/romkatv/gitstatus/blob/master/LICENSE).
