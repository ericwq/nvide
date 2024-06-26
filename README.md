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

`nvide` is a C/C++, Go, Lua Integrated Development Environment.  It combined project [ericwq/golangIDE](https://github.com/ericwq/golangIDE) and project [ericwq/gccIDE](https://github.com/ericwq/gccIDE) into one: `nvide`. It inherits version number from [ericwq/golangIDE](https://github.com/ericwq/golangIDE).`nvide` is based on [Lazy.nvim](https://www.lazyvim.org/), with additional packages and custom configuration.

### Files description

- `lazy` directory : additional packages and custom configuration for `Lazy.nvim`.
- `lazy/conf` directory : customized `osc52` clipboard support.
- `lazy/plugins` directory : customized color scheme, status line, etc.
- `lazy/emulator` directory : terminal emulator configuration files.
- `build.md` : step by step guide to build image and run container.
- `lazy.dockerfile` : the base image docker file.
- `sshd-lazy.dockerfile`: the docker file with ssh enabled.
- `reference.md` : the references about how to setup `nvide`.

## Client requirement

- [docker desktop](https://www.docker.com/products/docker-desktop) for mac / windows
- git
- brew
- Use the following command to install Command Line Tools. (For mac user)
```sh 
xcode-select -install
```

### Install terminal emulator

Install one or all of the terminal emulators. Please note the `item2` mouse support is not as good as kitty and `alacritty`.

```sh
brew install --cask alacritty
brew install --cask kitty
brew install --cask wezterm
brew install --cask iterm2
```

Copy the configuration file from `nvide` to `neovim` `.config` directory.The configuration file set default font as `JetbrainsMono Nerd Font` in `kitty`,`alacritty`,`wezterm`.

```sh
git clone https://github.com/ericwq/nvide.git
cd nvide/lazy/emulator
cp -r alacritty    ~/.config/
cp -r kitty        ~/.config/
cp -r wezterm      ~/.config/
```

### Install fonts

Install one or all of the fonts, It's required by `nvide`.

```sh
brew search '/font-.*-nerd-font/'                   # search nerd font
brew install --cask font-jetbrains-mono-nerd-font   # default font
brew install --cask font-hack-nerd-font             # set font family if choose this
brew install --cask font-cousine-nerd-font          # set font family if choose this
```

### TERM environment variable

If you got this problem [filling up buffer with nvim commands](https://github.com/NvChad/NvChad/issues/926) or `"WARNING: terminal is not fully functional"`, please change the TERM to `alacritty` or `kitty` instead of the default value: `xterm-256color`

```sh
$ export TERM=alacritty
```
or you can run the following script, according to [xterm-kitty: unknown terminal type - redgreen](https://redgreen.no/2020/05/10/kitty-unknown-terminal-type.html#:~:text=In%20order%20to%20copy%20over%20a%20terminfo%20file,on%20every%20session%20from%20kitty%20in%20the%20future.)
```sh
kitty +kitten ssh ide@localhost
kitty +kitten ssh root@localhost
```

## Run In-stock image

The easy way to use `nvide` is to use [in-stock image](https://hub.docker.com/repository/docker/ericwq057/nvide).

```sh
docker pull ericwq057/nvide:0.8.5
docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide ericwq057/nvide:0.8.5
docker exec -u ide -it nvide ash    # login as user ide
docker exec -u root -it nvide ash   # login as root
```
## Build customized image

Why we need a customized image? Maybe you want to choose the password for `ide` and `root` account, or you want to create your own ssh keys and copy them to the image.

### Build base image

Run the following command to build the base image.

```sh
% git clone https://github.com/ericwq/nvide.git
% cd nvide
% docker build -t nvide:0.8.5 -f lazy.dockerfile .
```

### Creating SSH Keys

Before build `sshd-lazy` image, you need to create ssh keys first. On your local machine (for me, it's my Mac book), make sure `~/.ssh/id_rsa.pub` file exist. If it doesn't, use `% ssh_keygen` to generate it.

Check ssh keys by list the content in `~/.ssh`.
```
$ ls -al ~/.ssh
total 16
drwx------   4 qiwang  staff   128 Feb 10 14:45 .
drwxr-xr-x+ 38 qiwang  staff  1216 Feb 10 14:42 ..
-rw-------   1 qiwang  staff  2602 Feb 10 14:45 id_rsa
-rw-r--r--   1 qiwang  staff   572 Feb 10 14:45 id_rsa.pub
```

```
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

It's a good idea to add your keys to the SSH agent.
```sh
$ ssh-add ~/.ssh/id_rsa
```

### Build sshd-lazy image

With the base image, ssh keys and passwords in hands, it's time to build the `sshd-lazy` image. Please note `sshd-lazy` image is based on `ericwq057/nvide:0.8.5`. Base image is required to build the `ssh-lazy` image.

- `ROOT_PWD` is the root password.
- `USER_PWD` is the `ide` user password.
- `SSH_PUB_KEY` is the public key we just created.

```sh
docker build -t nvide:0.8.5 -f lazy.dockerfile .
docker build --build-arg ROOT_PWD=password \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t sshd-lazy:0.10.3 -f sshd-lazy.dockerfile .
```

### Run sshd-lazy container

Please NOTE: `sshd-lazy` image accepts both public key and password authentication, public key authentication has higher priority than password authentication. Use the following command to start the container.

```sh
docker run --env TZ=Asia/Shanghai --tty --privileged \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -h sshd-lazy --name sshd-lazy -d -p 22:22  sshd-lazy:0.10.3
```

The `sshd-lazy` container listens on the port 22. Use the following command to login.

```sh
% rm ~/.ssh/known_hosts*
% ssh ide@localhost
% ssh root@localhost
```

## Sample projects

Please refer the [build.md](build.md) to build `nvide` docker image step by step. The following is `nvide` user guide for some sample projects.

- [grpc-go](reference.md#grpc-go-project-in-nvide) project
- [ccls](reference.md#ccls-project-in-nvide) project
- [st](https://github.com/ericwq/examples/blob/main/tty/ref.md#st) project
- [mosh](https://github.com/ericwq/examples/blob/main/tty/ref.md#mosh) project
- [zutty](https://github.com/ericwq/examples/blob/main/tty/ref.md#zutty) project
- [lua](reference.md#lua-project-in-nvide) project

## Unresolved problem

- mason can't install codelldb: error="The current platform is unsupported."
<!-- - osc clipboard: provider returned invalid data -->
