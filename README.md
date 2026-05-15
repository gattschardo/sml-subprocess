# sml-subprocess [![CI](https://github.com/gattschardo/sml-subprocess/workflows/flake-checks/badge.svg)

Standard ML convenience wrapper around posix subprocesses.

Modeled after the python subprocess module.

## Overview of MLB files

- `lib/github.com/gattschardo/sml-subprocess/subprocess.mlb`:

  - **signature** [`SUBPROCESS`](lib/github.com/gattschardo/sml-subprocess/subprocess.sig)
  - **structure** `Subprocess` :> `SUBPROCESS`

## Use of the package

This library is set up to work well with the SML package manager
[smlpkg](https://github.com/diku-dk/smlpkg).  To use the package, in
the root of your project directory, execute the command:

```
$ smlpkg add github.com/diku-dk/sml-json
```

This command will add a _requirement_ (a line) to the `sml.pkg` file in your
project directory (and create the file, if there is no file `sml.pkg`
already).

To download the library into the directory
`lib/github.com/diku-dk/sml-json`, execute the command:

```
$ smlpkg sync
```

You can now reference the `mlb`-file using relative paths from within
your project's `mlb`-files.

Notice that you can choose either to treat the downloaded package as
part of your own project sources (vendoring) or you can add the
`sml.pkg` file to your project sources and make the `smlpkg sync`
command part of your build process.

## Authors

Copyright (c) 2026 Richard Wind
