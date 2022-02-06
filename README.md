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

`nvide` is a C/C++, Go, Lua Integrated Development Environment. It inherits the version number from [ericwq/golangIDE](https://github.com/ericwq/golangIDE). It also tries to combine [ericwq/golangIDE](https://github.com/ericwq/golangIDE) with [ericwq/gccIDE](https://github.com/ericwq/gccIDE) into one: `nvide`. `nvide` is based on [NvChad](https://github.com/NvChad/NvChad), with additional packages and custom configuration.

## Files description

- `custom` directory : contains additional packages and custom configuration for `NvChad`.
- `conf` directory : contains part of the `neovim` configuration, mainly clipboard related.
- `build.md` : contains the docker commands to build and run the image.
- `nvim.dockerfile` : the docker file.
- `reference.md` : the references (most of) about how to setup `nvide`.

## Additional packages

- `nathom/filetype.nvim`
- `romgrk/nvim-treesitter-context`
- `folke/which-key.nvim`
- `simrat39/symbols-outline.nvim`
- `windwp/nvim-ts-autotag`
- `jose-elias-alvarez/null-ls.nvim`

## Require

- [docker desktop](https://www.docker.com/products/docker-desktop) for mac / windows
- git

## In-stock image

The easy way to use `nvide` is to use the in-stock image. See [here](https://hub.docker.com/repository/docker/ericwq057/nvide).

- The first `exec` command login the docker container as normal user.
- The second `exec` command login the docker container as root user.

```
% docker pull ericwq057/nvide:0.7.2
% docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        ericwq057/nvide:0.7.2
% docker exec -u ide -it nvide ash
% docker exec -u root -it nvide ash
```

## Build image

Run the following command to build the docker image by yourself.

```
% git clone https://github.com/ericwq/nvide.git
% cd nvide
% docker build -t nvide:0.7.2 -f nvim.dockerfile .
```

## Sample project

Please refer the `build.md` to create the `nvide` docker image. Currently, c/c++, go and `lua` language server are ready.

- See [grpc-go project in nvide](reference.md#grpc-go-project-in-nvide) for example.
- See [ccls project in nvide](reference.md#ccls-project-in-nvide) for example.
- See [lua project in nvide](referencemd#lua-project-in-nvide) for example.

## Unresolved problem

- For `clangd`, cross-file navigation may result the single file mode.
- It's not intuitive to operate the [reference or implementation quickfix window](reference.md#reference-or-implementation-quickfix-window).
