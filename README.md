# Membrane Multimedia Framework: MPEG-TS

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_mpegts_plugin.svg)](https://hex.pm/packages/membrane_mpegts_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_mpegts_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_mpegts_plugin)

This package provides an element that can be used for muxing MPEG-TS.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

The package can be installed by adding `membrane_mpegts_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_mpegts_plugin, "~> 0.6.0"}
  ]
end
```

The docs can be found at [HexDocs](https://hexdocs.pm/membrane_mpegts_plugin).

## Usage
For usage examples, visit `examples/` directory:
```
cd examples/
```

There you can run an example of muxing AAC audio and H.264 video read from files:
```
elixir examples/mux_audio_and_video.exs
```

When the command terminates, you should be able to play the result `out.ts` file e.g.
with the use of `ffplay` command:
```
ffplay out.ts
```

## Copyright and License

Copyright 2019, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_mpegts_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_mpegts_plugin)

Licensed under the [Apache License, Version 2.0](https://github.com/membraneframework/membrane_mpegts_plugin/blob/master/LICENSE)
