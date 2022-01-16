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

nvide is a C/C++, Go, Lua Integrated Development Environment. It inherits the version number from [ericwq/golangIDE](https://github.com/ericwq/golangIDE). It also tries to combine [ericwq/golangIDE](https://github.com/ericwq/golangIDE) with [ericwq/gccIDE](https://github.com/ericwq/gccIDE) into one: nvide.

- [NvChad](https://github.com/NvChad/NvChad) directory : if it doesn't exist. run `git clone https://github.com/NvChad/NvChad.git` to get it.
- `custom` directory : contains custom part for [NvChad](https://github.com/NvChad/NvChad).
- `conf` directory : contains part of the configuration file.
- `build.md` : contains the docker commands to build and run the image.
- `nvim.dockerfile` : the docker file.
- `reference.md` : the references (most of) about how to setup nvide.

Please refer the `build.md` to create the nvide docker image. Currently, only go and lua language server is ready. I am working on c/c++ language server.
