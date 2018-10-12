# Tests

## Automated Tests

The Unit-Tests do not follow exactly the file structure of Powerlevel9k itself,
but we try to reflect the structure as much as possible. All tests are located
under `test/`. Segment specific tests under `test/segments/` (one file per
segment).

### Installation

In order to execute the tests you need to install `shunit2`, which is a
submodule. To install the submodule, you can execute 
`git submodule init && git submodule update`.

### Executing tests

The tests are shell scripts on their own. So you can execute them right away.
To execute all tests you could just execute `./test/suite.spec`.

### General Test Structure

The tests usually have a `setUp()` function which is executed before every
test function. Speaking of, test functions must be prefixed with `test`. In
the tests, you can do [different Assertions](https://github.com/kward/shunit2#-asserts).
It is always a good idea to mock the program you want to test (just have a
look at other tests), so that the testrunner does not have to have all
programs installed.

### Travis

We use [Travis](https://travis-ci.org/) for Continuous Integration. This
service executes our tests after every push. For now, we need to tell travis
where to find the tests, which is what happens in the `.travis.yml` file.

## Manual Testing

If unit tests are not sufficient (e.g. you have an issue with your prompt that
occurs only in a specific ZSH framework) then you can use either Docker or
or our Vagrant.

### Docker

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

### Vagrant

Currently there are two test VMs. `test-vm` is an Ubuntu machine with several
pre-installed ZSH frameworks. And there is `test-bsd-vm` which is a FreeBSD!
For how to run the machines see [here](test-vm/README.md).
