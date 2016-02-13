# Structure

The Unit-Tests do not follow exactly the file structure of Powerlevel9k itself.

## Basic Tests

Basic Tests belong in `test/powerlevel9k.spec` if they test basic functionality of
Powerlevel9k itself. Basic functions from the `functions` directory have their
Tests in separate files under `test/functions`.

## Segment Tests

These Tests tend to be more complex in setup than the basic tests. To avoid ending
up in a huge single file, there is one file per segment in `test/segments`.
