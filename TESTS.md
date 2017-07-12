# Structure

The Unit-Tests do not follow exactly the file structure of Powerlevel9k itself.

## Basic Tests

Basic Tests belong in `test/powerlevel9k.spec` if they test basic functionality of
Powerlevel9k itself. Basic functions from the `functions` directory have their
Tests in separate files under `test/functions`.

## Segment Tests

These Tests tend to be more complex in setup than the basic tests. To avoid ending
up in a huge single file, there is one file per segment in `test/segments`.

# Manual Testing

If unit tests are not sufficient (e.g. you have an issue with your prompt that
occurs only in a specific ZSH framework) then you can use either Docker or
or our Vagrant.

## Docker

This is the easiest to use _if_ you have Docker already installed and running.

The command `./test-in-docker` should make it fairly easy to get into a running
container with the framework of your choice.

Examples:

``` zsh
# Test Antigen with the oldest version of ZSH
$ ./test-in-docker antigen
```

``` zsh
# Test Prezto with ZSH version 5.2
$ ./test-in-docker --zsh 5.2 prezto
```

You can get Docker at <https://www.docker.com/community-edition>.

**Note:** Not all frameworks work with all versions of ZSH (or the underlying OS).

## Vagrant

Currently there are two test VMs. `test-vm` is an Ubuntu machine with several
pre-installed ZSH frameworks. And there is `test-bsd-vm` which is a FreeBSD!
For how to run the machines see [here](test-vm/README.md).
