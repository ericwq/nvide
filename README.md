# nvide

```text
ooooo      ooo oooooo     oooo ooooo oooooooooo.   oooooooooooo
`888b.     `8'  `888.     .8'  `888' `888'   `Y8b  `888'     `8
 8 `88b.    8    `888.   .8'    888   888      888  888
 8   `88b.  8     `888. .8'     888   888      888  888oooo8
 8     `88b.8      `888.8'      888   888      888  888    '
 8       `888       `888'       888   888     d88'  888       o
o8o        `8        `8'       o888o o888bood8P'   o888ooooood8
```

## Introduction

`nvide` is a C/C++, Go, Lua Integrated Development Environment. It inherits the version number from [ericwq/golangIDE](https://github.com/ericwq/golangIDE). It also tries to combine [ericwq/golangIDE](https://github.com/ericwq/golangIDE) with [ericwq/gccIDE](https://github.com/ericwq/gccIDE) into one: `nvide`. `nvide` is based on [NvChad](https://github.com/NvChad/NvChad), with additional packages and custom configuration.

### Files description

- `custom` directory : contains additional packages and custom configuration for `NvChad`.
- `conf` directory : contains part of the `neovim` configuration, mainly clipboard related.
- `build.md` : contains the docker commands to build and run the image.
- `nvim.dockerfile` : the normal docker file.
- `sshd-nvim.dockerfile`: the SSH/mosh docker file.
- `reference.md` : the references (most of) about how to setup `nvide`.

### Additional packages

- `romgrk/nvim-treesitter-context`
- `folke/which-key.nvim`
- `simrat39/symbols-outline.nvim`
- `windwp/nvim-ts-autotag`
- `jose-elias-alvarez/null-ls.nvim`

## Client requirement

- [docker desktop](https://www.docker.com/products/docker-desktop) for mac / windows
- git
- brew
- Use `xcode-select –install` to install Command Line Tools. (For mac user)

### Intstall terminal emulator

Install one or all of the terminal emulators. Please note the item2 mouse support is not as good as kitty and alacritty.

```sh
brew install --cask alacritty
brew install --cask kitty
brew install --cask wezterm
brew install --cask iterm2
```

Copy the config file from the `$GIT_CLONE_NVIDE` to your local `$HOME`. `$GIT_CLONE_NVIDE` is where you clone the `nvide`.

```sh
cp $GIT_NVIDE/conf/emulator/alacritty.yml $HOME/.config/alacritty/alacritty.yml
cp $GIT_NVIDE/conf/emulator/kitty.conf    $HOME/.config/kitty/kitty.conf
cp $GIT_NVIDE/conf/emulator/wezterm.lua	  $HOME/.config/wezterm/wezterm.lua

```

### Install fonts

Install one or all of the fonts, It's required by `nvide`.

```
% brew tap homebrew/cask-fonts
% brew install --cask font-jetbrains-mono-nerd-font
% brew install --cask font-hack-nerd-font
% brew install --cask font-cousine-nerd-font
```

remeber to set font family as `JetbrainsMono Nerd Font` in `~/.config/kitty/kitty.conf`

### TERM environment variable

If you encounter this problem [filling up buffer with nvim commands](https://github.com/NvChad/NvChad/issues/926) or "WARNING: terminal is not fully functional", please change the TERM to `alacritty` or `kitty` instead of the default value: `xterm-256color`

```sh
$ export TERM=alacritty
```
or you can run the following script
```sh
kitty +kitten ssh ide@localhost
kitty +kitten ssh root@localhost
```
according to [xterm-kitty: unknown terminal type - redgreen](https://redgreen.no/2020/05/10/kitty-unknown-terminal-type.html#:~:text=In%20order%20to%20copy%20over%20a%20terminfo%20file,on%20every%20session%20from%20kitty%20in%20the%20future.)

## Run In-stock image

The easy way to use `nvide` is to use the in-stock image. See [here](https://hub.docker.com/repository/docker/ericwq057/nvide).

- The first `exec` command login the docker container as normal user.
- The second `exec` command login the docker container as root user.

```sh
% docker pull ericwq057/nvide:0.8.4
% docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        ericwq057/nvide:0.8.4
% docker exec -u ide -it nvide ash
% docker exec -u root -it nvide ash
```
## Build customized image

why we need a customized image? Here you need to choose the password for `ide` and `root` account, you also need to create ssh keys and install them in the image.

### Build base image

Run the following command to build the base image.

```sh
% git clone https://github.com/ericwq/nvide.git
% cd nvide
% docker build -t nvide:0.8.4 -f nvim.dockerfile .
```

### Creating SSH Keys

Before build [openrc-nvide image](#build-openrc-nvide-image), you need to creat ssh keys first. On your local machine (for me, it's my Mac book). Make sure your `~/.ssh/id_rsa.pub` file exist in your SSH client side. If it doesn't, use `% ssh_keygen` command to generate it for you.

```shell
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/qiwang/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/qiwang/.ssh/id_rsa
Your public key has been saved in /Users/qiwang/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:wkLkm5ts4MeSBPovZz1q/zRqbuDpp1y4QSJ3/K/Y75E qiwang@gauss.local
The key's randomart image is:
+---[RSA 3072]----+
|    .            |
|   o             |
|.   o            |
|.. o +           |
|o = B o S        |
| * O.* . .       |
|  =.X+o E        |
|  .****+ o       |
|   *OO**=        |
+----[SHA256]-----+
```

check the keys by listing the content in `~/.ssh`.
```sh
$ ls -al ~/.ssh
total 16
drwx------   4 qiwang  staff   128 Feb 10 14:45 .
drwxr-xr-x+ 38 qiwang  staff  1216 Feb 10 14:42 ..
-rw-------   1 qiwang  staff  2602 Feb 10 14:45 id_rsa
-rw-r--r--   1 qiwang  staff   572 Feb 10 14:45 id_rsa.pub
```

it's a good idea to add your keys to the SSH agent.
```sh
$ ssh-add /Users/qiwang/.ssh/id_rsa
```

### Build openrc-nvide image

With the generated keys and passwords for your accounts, it's time to build the `openrc-nvide` image. Please note the `openrc-nvide` image is based on `nvide:0.8.4`. You need [base image](#build-base-image) to build the `openrc-nvide` image.

```sh
$ docker build --build-arg ROOT_PWD=password \
        --build-arg USER_PWD=password \
        --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
        --progress plain -t openrc-nvide:0.10.2 -f openrc-nvim.dockerfile .
```

- `ROOT_PWD` is the root password.
- `USER_PWD` is the `ide` user password.
- `SSH_PUB_KEY` is the public key we just created.


### Run the openrc-nvide container

Please NOTE: the `openrc-nvide` image accepts both the password and public key login, user/password is supported if the public key is invalid/missing. Use the following command to start the container.

```sh
$ docker run --env TZ=Asia/Shanghai --tty --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
    -h openrc-nvide --name openrc-nvide -d -p 22:22  -p 8100:8100/udp  -p 8101:8101/udp -p 8102:8102/udp \
    -p 8103:8103/udp openrc-nvide:0.10.2
```

The `openrc-nvide` container listens on the port 22. Use the following command to login to the openrc-nvide container.

```sh
% rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old
% ssh ide@localhost
% ssh root@localhost
```

<!-- Or you can login to the SSH/mosh container. -->
<!---->
<!-- ```sh -->
<!-- $ mosh ide@localhost -->
<!-- $ mosh root@localhost -->
<!-- ``` -->

## Sample project

Please refer the `build.md` to create the `nvide` docker image. Currently, c/c++, go and `lua` language server are ready.

- See [grpc-go project in nvide](reference.md#grpc-go-project-in-nvide) for example.
- See [ccls project in nvide](reference.md#ccls-project-in-nvide) for example.
- See [st project in nvide](https://github.com/ericwq/examples/blob/main/tty/ref.md#st) for example.
- See [mosh project in nvide](https://github.com/ericwq/examples/blob/main/tty/ref.md#mosh) for example.
- See [zutty project in nvide](https://github.com/ericwq/examples/blob/main/tty/ref.md#zutty) for example.
- See [lua project in nvide](reference.md#lua-project-in-nvide) for example.

## Unresolved problem

- `neovim` text color doesn't work for `mosh` connection, while it works for `ssh` connection. see [Any chance we could get a new release? #1115](https://github.com/mobile-shell/mosh/issues/1115)
- For `clangd`, cross-file navigation may result the single file mode.
- It's not intuitive to operate the [reference or implementation quickfix window](reference.md#reference-or-implementation-quickfix-window).
