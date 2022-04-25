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

`nvide` is a C/C++, Go, Lua Integrated Development Environment. It inherits the version number from [ericwq/golangIDE](https://github.com/ericwq/golangIDE). It also tries to combine [ericwq/golangIDE](https://github.com/ericwq/golangIDE) with [ericwq/gccIDE](https://github.com/ericwq/gccIDE) into one: `nvide`. `nvide` is based on [NvChad](https://github.com/NvChad/NvChad), with additional packages and custom configuration.

## Files description

- `custom` directory : contains additional packages and custom configuration for `NvChad`.
- `conf` directory : contains part of the `neovim` configuration, mainly clipboard related.
- `build.md` : contains the docker commands to build and run the image.
- `nvim.dockerfile` : the normal docker file.
- `sshd-nvim.dockerfile`: the SSH/mosh docker file.
- `reference.md` : the references (most of) about how to setup `nvide`.

## Additional packages

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
brew install --cask iterm2
```

Copy the config file from the `$GIT_CLONE_NVIDE` to your local `$HOME`. `$GIT_CLONE_NVIDE` is where you clone the `nvide`.

```sh
cp $GIT_NVIDE/conf/alacritty.yml $HOME/.config/alacritty.yml
cp $GIT_NVIDE/conf/kitty.conf    $HOME/.config/kitty.conf

```

### Install fonts

Install one or all of the fonts, It's required by `nvide`.

```
% brew tap homebrew/cask-fonts
% brew install --cask font-hack-nerd-font
% brew install --cask font-cousine-nerd-font
```

### TERM environment variable

If you encounter this problem [filling up buffer with nvim commands](https://github.com/NvChad/NvChad/issues/926), please change the TERM to `alacritty` or `kitty` instead of the default value: `xterm-256color`

```sh
$ export TERM=alacritty
```

## Run In-stock image

The easy way to use `nvide` is to use the in-stock image. See [here](https://hub.docker.com/repository/docker/ericwq057/nvide).

- The first `exec` command login the docker container as normal user.
- The second `exec` command login the docker container as root user.

```sh
% docker pull ericwq057/nvide:0.7.3
% docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        ericwq057/nvide:0.7.3
% docker exec -u ide -it nvide ash
% docker exec -u root -it nvide ash
```

## Build image

Run the following command to build the docker image by yourself.

```sh
% git clone https://github.com/ericwq/nvide.git
% cd nvide
% docker build -t nvide:0.7.3 -f nvim.dockerfile .
```

## Build and run the SSH/mosh image

Run the following commands to build the SSH/mosh image by yourself. Please note that SSH/mosh image is based on `ericwq057/nvide:0.7.3`. You need the latest base image to build the SSH/mosh image.

```sh
% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t nvide:0.8.0 -f sshd-nvim.dockerfile .
```

- `ROOT_PWD` is the root password.
- `USER_PWD` is the `ide` user password.
- `SSH_PUB_KEY` is the public key from the client(SSH) side.

Make sure your `~/.ssh/id_rsa.pub` file exist in your SSH client side. If it doesn't, use `% ssh_keygen` command to generate it in your SSH client side.

```sh
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ide/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ide/.ssh/id_rsa
Your public key has been saved in /home/ide/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:0WcUbGRYR6qpLVl+W8qwNIvq0vrgGexTev4SczZhdVg ide@nvide-ssh
The key's randomart image is:
+---[RSA 3072]----+
|           BEoo  |
|         .+o+o   |
|        ...o+    |
|        o. =     |
|       .S.+      |
|   .  + +*       |
|    ++ =+.* . .  |
|   o+++  + B +   |
|    =O=+o o +    |
+----[SHA256]-----+
$ ls ~/.ssh/
authorized_keys  id_rsa           id_rsa.pub
```

Please NOTE: the SSH/mosh image accepts both the password and public key login, user/password is supported if the public key is invalid/missing. Use the following command to start the SSH/mosh container.

```sh
% docker run -d -p 22:22 -p 60001:60001/udp -h nvide-ssh --env TZ=Asia/Shanghai --name nvide-ssh \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.8.0
% docker container ls
CONTAINER ID   IMAGE         COMMAND               CREATED        STATUS        PORTS                                          NAMES
9577cffac7ef   nvide:0.8.0   "/usr/sbin/sshd -D"   10 hours ago   Up 10 hours   0.0.0.0:22->22/tcp, 0.0.0.0:60001->60001/udp   nvide-ssh
```

The SSH/mosh container listens on the port 22. Use the following command to login to the SSH/mosh container.

```sh
% ssh ide@localhost
% ssh root@localhost
```

Or you can login to the SSH/mosh container.

```sh
$ mosh ide@localhost
$ mosh root@localhost
```

## Sample project

Please refer the `build.md` to create the `nvide` docker image. Currently, c/c++, go and `lua` language server are ready.

- See [grpc-go project in nvide](reference.md#grpc-go-project-in-nvide) for example.
- See [ccls project in nvide](reference.md#ccls-project-in-nvide) for example.
- See [st project in nvide](https://github.com/ericwq/examples/blob/main/tty/ref.md#st) for example.
- See [mosh project in nvide](https://github.com/ericwq/examples/blob/main/tty/ref.md#mosh) for example.
- See [lua project in nvide](referencemd#lua-project-in-nvide) for example.

## Unresolved problem

- `neovim` text color doesn't work for `mosh` connection, while it works for `ssh` connection. see [Any chance we could get a new release? #1115](https://github.com/mobile-shell/mosh/issues/1115)
- For `clangd`, cross-file navigation may result the single file mode.
- It's not intuitive to operate the [reference or implementation quickfix window](reference.md#reference-or-implementation-quickfix-window).
