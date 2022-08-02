# Defold Template

This project is a template for [Defold](https://defold.com) games.

## Prerequisites

### Tooling

On macOS, you need the following tools installed:

```
brew install coreutils gettext graphicsmagick imagemagick wine-stable
```

### Environment variables

There's also a bunch of environment variables you need to adjust for your project. You can start with the provided `.env.example`:

```
cp .env.example .env
```

You can then export all those variables by running something like:

```
export $(cat .env | xargs)
```

### Project name

You'll also want to tweak the project name. Make sure to change it both in `game.project`, and in `Makefile`.

## Test

To run unit tests for a specific platforms, do:

```
$ make test-macos
```

## Run

To build a debug version of the project and run it, do:

```
$ make run-macos
```

## Build

To build a release version of the project for all platforms, do:

```
$ make all APP_VERSION=0.0.1
```

To build for a specific platform, do something like:

```
$ make dist-macos APP_VERSION=0.0.1
```

## Publish

To publish on all portals, do:

```
$ make publish APP_VERSION=0.0.1
```

To publish on a specific platform, do something like:

```
$ make publish-itchio APP_VERSION=0.0.1
```

## Meta

- Code: `git clone https://github.com/unindented/defold-template.git`
- Home: <https://www.unindented.org/>

## Contributors

Daniel Perez Alvarez ([daniel@unindented.org](mailto:daniel@unindented.org))

## License

Copyright (c) 2022 Daniel Perez Alvarez ([unindented.org](https://www.unindented.org/)). This is free software, and may be redistributed under the terms specified in the LICENSE file.
