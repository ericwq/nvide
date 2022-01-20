# nvide

```text
ooooo      ooo oooooo     oooo ooooo oooooooooo.   oooooooooooo
`888b.     `8'  `888.     .8'  `888' `888'   `Y8b  `888'     `8
 8 `88b.    8    `888.   .8'    888   888      888  888
 8   `88b.  8     `888. .8'     888   888      888  888oooo8
 8     `88b.8      `888.8'      888   888      888  888    "
 8       `888       `888'       888   888     d88'  888       o
o8o        `8        `8'       o888o o888bood8P'   o888ooooood8
```

`nvide` is a C/C++, Go, Lua Integrated Development Environment. It inherits the version number from [ericwq/golangIDE](https://github.com/ericwq/golangIDE). It also tries to combine [ericwq/golangIDE](https://github.com/ericwq/golangIDE) with [ericwq/gccIDE](https://github.com/ericwq/gccIDE) into one: `nvide`.

## Files description

- `custom` directory : contains custom configuration for [NvChad](https://github.com/NvChad/NvChad).
- `conf` directory : contains part of the configuration.
- `build.md` : contains the docker commands to build and run the image.
- `nvim.dockerfile` : the docker file.
- `reference.md` : the references (most of) about how to setup `nvide`.

## Requirement

- [docker desktop](https://www.docker.com/products/docker-desktop) for mac / windows
- git

## Build image

Run the following command to build the docker image. Note [NvChad](https://github.com/NvChad/NvChad) directory is necessary: if it doesn't exist. Run `git clone https://github.com/NvChad/NvChad.git` to get it.

```
% git clone https://github.com/ericwq/nvide.git
% cd nvide
% git clone https://github.com/NvChad/NvChad.git
% docker build -t nvide:0.7.0 -f nvim.dockerfile .
```

## Sample project

Please refer the `build.md` to create the `nvide` docker image. Currently, c/c++, go and `lua` language server are ready.

- See [grpc-go project in nvide](reference.md#grpc-go-project-in-nvide) for example.
- See [c/c++ project in nvide](reference.md#ccls-project-in-nvide) for example.
- See [lua project in nvide](referencemd#lua-project-in-nvide) for example.

## Unresolved problem

- It's not intuitive to operate the [reference or implementation quickfix window](reference.md#reference-or-implementation-quickfix-window).
- It's lack of something like [preservim/tagbar](https://github.com/preservim/tagbar) or [simrat39/symbols-outline.nvim](https://github.com/simrat39/symbols-outline.nvim).
