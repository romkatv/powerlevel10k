# Structure

The Unit-Tests do not follow exactly the file structure of Powerlevel9k itself.

## Basic Tests

Basic Tests belong in `test/powerlevel9k.spec` if they test basic functionality of
Powerlevel9k itself. Basic functions from the `functions` directory have their
Tests in separate files under `test/functions`.

## Segment Tests

These Tests tend to be more complex in setup than the basic tests. To avoid ending
up in a huge single file, there is one file per segment in `test/segments`.

# Test-VMs

If unit tests are not sufficient (e.g. you have an issue with your prompt that
occurs only in a specific ZSH framework), then you could use our Test-VMs!
Currently there are two test VMs. `test-vm` is an Ubuntu machine with several
pre-installed ZSH frameworks. And there is `test-bsd-vm` which is a FreeBSD!
For how to run the machines see [here](test-vm/README.md).