# Neovim IDE setup

Try to find the better solution for neovim IDE (golang, c, c++, java, lua, html, css, vim script, markdown, javascript)

## Base image

```
docker pull alpine:edge

docker run -it -h neovim --env TZ=Asia/Shanghai  --name neovim \
--mount source=proj-vol,target=/home/ide/proj \
--mount type=bind,source=/Users/qiwang/proj,target=/home/ide/develop \
alpine:edge
```

## go language server

### grpc-go project in nvide

Thanks to go module, It's easy to start with `grpc-go` project. Please enjoy the go language server: gopls.

```
% git clone https://github.com/grpc/grpc-go.git
% cd grpc-go
% go mod tidy
% vi clientconn.go
```

- `git` command clones the `grpc-go` project.
- `go mod tidy` add missing and remove unused modules.
- `vi` command will start the gopls language server. Now, you can navigate code, format code, diagnose code, etc.

## c/c++ language server

`cmake`, `autoconf`, `automake` and `bear` are general tools for c/c++ Development. So it's build-in packages for `nvide`.

### ccls project in nvide

[ccls build](https://github.com/MaskRay/ccls/wiki/Build) suggest the following commands for alpine. Which means `ccls` project needs more packages to build from the source.

```sh
% apk add alpine-sdk cmake make clang clang-static clang-dev llvm-dev llvm-static \
	&& git clone --depth=1 --recursive https://github.com/MaskRay/ccls \
	&& cd ccls \
	&& cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
	&& cmake --build Release --target install
```

With `nvide` in hands, you still need to install the following packages to compile the project. Otherwise, the compiler will complains some library is missing. Note, you need to install the following package with the root privilege for `nvide`.

```sh
# apk add clang-static llvm-dev llvm-static zlib-dev libxslt-dev
```

Next, the key point is to generate the `compile_commands.json` file for `ccls` project. You can use the following command to create the `compile_commands.json` file.

```sh
% git clone --depth=1 --recursive https://github.com/MaskRay/ccls
% cd ccls
% cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=YES
-- Using local RapidJSON
fatal: No names found, cannot describe anything.
-- Configuring done
-- Generating done
-- Build files have been written to: /home/ide/proj/ccls/Release
% ln -s Release/compile_commands.json .
% vi src/main.cc
```

- Note the `-DCMAKE_EXPORT_COMPILE_COMMANDS=YES` option is used.
- You can ignore the fatal error reported by `cmake`.
- Also note the `compile_commands.json` file is located in `.Release` directory. The link command set the root directory for `clangd`.

## lua language server

### lua project in nvide

`nvide` uses `lua` script to setup the `neovim` plugins. In `~/.config/nvim/` directory, there is a complete `lua` project (which contains a .git directory). Use the following command to enjoy the `lua` language server.

```sh
% cd ~/.config/nvim/
% vi init.lua
```

## After Installation

### reference or implementation quickfix window

`lua vim.lsp.buf.references()` and `lua vim.lsp.buf.implementation()` use [quickfix](https://neovim.io/doc/user/quickfix.html#quickfix) window to show the list. The following is the command to operate the `quickfix` window. Refer to [How do you use vim's quickfix feature?](https://stackoverflow.com/questions/1747091/how-do-you-use-vims-quickfix-feature/55117681) for detail.

```
:copen " Open the quickfix window
:ccl   " Close it
:cw    " Open it if there are "errors", close it otherwise (some people prefer this)
:cn    " Go to the next error in the window
:cp    " Go to the previous error in the window
:cnf   " Go to the first error in the next file
:.cc   " Go to error under cursor (if cursor is in quickfix window)
```

## Terminal

How the terminal works? Who is responsible for terminal rendering? Does GPU-rendering in terminal matter?

- [Linux terminals, tty, pty and shell](https://dev.to/napicella/linux-terminals-tty-pty-and-shell-192e)
- [Linux terminals, tty, pty and shell - part 2](https://dev.to/napicella/linux-terminals-tty-pty-and-shell-part-2-2cb2)
- [How does a Linux terminal work?](https://unix.stackexchange.com/questions/79334/how-does-a-linux-terminal-work)
- [How Zutty works: Rendering a terminal with an OpenGL Compute Shader](https://tomscii.sig7.se/2020/11/How-Zutty-works)
- [A totally biased comparison of Zutty (to some better-known X terminal emulators)](https://tomscii.sig7.se/2020/12/A-totally-biased-comparison-of-Zutty)
- [A look at terminal emulators, part 1](https://lwn.net/Articles/749992/)
- [A look at terminal emulators, part 2](https://lwn.net/Articles/751763/)
- [High performant 2D renderer in a terminal](https://blog.ghaiklor.com/2020/07/27/high-performant-2d-renderer-in-a-terminal/)
- [The TTY demystified](http://www.linusakesson.net/programming/tty/)

### typing

- [Typing with pleasure](https://pavelfatin.com/typing-with-pleasure/)
- [Measured: Typing latency of Zutty (compared to others)](https://tomscii.sig7.se/2021/01/Typing-latency-of-Zutty)

### reference links

- [Getting Started with Mosh (Mobile Shell)](https://bitlaunch.io/blog/getting-started-with-mosh/)
- [example language server](https://github.com/ChrisAmelia/dotfiles/blob/master/nvim/lua/lsp.lua#L108-L120)
- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [Add, Delete And Grant Sudo Privileges To Users In Alpine Linux](https://ostechnix.com/add-delete-and-grant-sudo-privileges-to-users-in-alpine-linux/)
- [Why is GO111MODULE everywhere, and everything about Go Modules](https://maelvls.dev/go111module-everywhere/#go111module-with-go-117)
- [Understanding go.mod and go.sum](https://faun.pub/understanding-go-mod-and-go-sum-5fd7ec9bcc34)
- [spellsitter.nvim](https://github.com/lewis6991/spellsitter.nvim)
- [Neovim Tips for a Better Coding Experience](https://alpha2phi.medium.com/neovim-tips-for-a-better-coding-experience-3d0f782f034e)
- [Neovim - Treesitter Syntax Highlighting](https://www.youtube.com/watch?v=hkxPa5w3bZ0)

### ssh in container

- [How to Add SSH Public Key to Server](https://linuxhandbook.com/add-ssh-public-key-to-server/)
- [How to SSH into a Docker Container](https://linuxhandbook.com/ssh-into-container/)
- [Running SSH in an Alpine Docker Container](https://dev.to/yakovlev_alexey/running-ssh-in-an-alpine-docker-container-3lop)
- [alpine-ssh](https://hub.docker.com/r/gotechnies/alpine-ssh)
- [Alpine ssh server](https://hub.docker.com/r/danielguerra/alpine-sshd)
- [How to install OpenSSH server on Alpine Linux](https://www.cyberciti.biz/faq/how-to-install-openssh-server-on-alpine-linux-including-docker/)
- [Docker-SSH 连接 docker 容器](https://www.jianshu.com/p/426f0d8e6cbf)
- [ssh 启动错误：no hostkeys available— exiting](https://wangxianggit.github.io/sshd%20no%20hostkeys%20available/)

```
docker build -t nide:0.1 -f nvim-tmux.dockerfile .

docker run -it -d -h ggg --env TZ=Asia/Shanghai -u ide --name ggg -p 8654:22 nide:0.1 bash

ssh ide@localhost -p 8654 -t "tmux a -t golangide"

tmux new-session -s "IDE"  -n "editor" -d "nvim"

tmux  attach-session -t "IDE"

server:
docker run -d -p 50001:22 --env TZ=Asia/Shanghai -h nvimIDE  --name nvimIDE \
	nvim:ide /usr/sbin/sshd -D

client:
ssh ide@localhost -p 50001
```

## NvChad

- [NvChad](https://github.com/siduck76/NvChad)
- [Lua in Y minutes](https://learnxinyminutes.com/docs/lua/)
- [Lua Quick Guide](https://github.com/medwatt/Notes/blob/main/Lua/Lua_Quick_Guide.ipynb)
- [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/)
- [Lua 简介](https://www.kancloud.cn/wizardforcel/w3school-lua/99412)
- [Text to Image](http://patorjk.com/software/taag/#p=display&f=Roman&t=NVIDE)

## tmux in container

- [container](https://stackoverflow.com/questions/51809181/how-to-run-tmux-inside-a-docker-container/51814791)
- [tmux seesion](https://stackoverflow.com/questions/65674604/docker-start-tmux-session-inside-of-dockerfile)
- [Copying to clipboard from tmux and Vim using OSC 52](https://sunaku.github.io/tmux-yank-osc52.html)
- [tmux in practice](https://medium.com/free-code-camp/tmux-in-practice-series-of-posts-ae34f16cfab0)
- [tmux in practice: integration with the system clipboard](https://medium.com/free-code-camp/tmux-in-practice-integration-with-system-clipboard-bcd72c62ff7b)
- [Getting started with Tmux](https://linuxize.com/post/getting-started-with-tmux/)
- [A Quick and Easy Guide to tmux](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
- [Making tmux Pretty and Usable - A Guide to Customizing your tmux.conf](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/)

1. copy .vimrc.
2. copy yank to PAHT and chmod +x for it.
3. edit `~/.config/nvim/init.lua` and add the following content.
4. yank what you want.

```
-- Here is the content for ~/.config/nvim/init.lua
--

-- source a vimscript file
vim.cmd('source ~/.vimrc')

vim.o.clipboard = 'unnamedplus' -- copy/paste to system clipboard
vim.opt.clipboard = 'unnamedplus' -- copy/paste to system clipboard
```

## tmux on alacritty (mac)

```
docker container exec -u ide -ti neovim ash
```

See [here](https://github.com/tmux/tmux/wiki/Clipboard) for the official tmux clipboard document. For tmux, use the following configuration in `.tmux.conf`,

```
set -s set-clipboard on
```

For neovim, use the following configuration in `~/.config/nvim/init.lua`

```
vim.o.clipboard = 'unnamedplus' -- copy/paste to system clipboard
vim.opt.clipboard = 'unnamedplus' -- copy/paste to system clipboard
```

when you run `:checkhealth`, neovim reports

```
## Clipboard (optional)
  - OK: Clipboard tool found: pbcopy
```

## true color test:

```
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | ash
```

## Guide for neovim and lua

TODO: install lua language server.

```
$ apk add alpine-sdk curl bash unzip
$ apk add lua5.3
$ wget https://luarocks.org/releases/luarocks-3.8.0.tar.gz
$ tar zxpf luarocks-3.8.0.tar.gz
$ cd luarocks-3.8.0
$ apk add lua5.3-dev
$ ./configure --lua-version=5.3
$ make
$ make install

check the result.
$ luarocks path --help

$ luarocks install --server=https://luarocks.org/dev luaformatter
```

- [Customizing Neovim LSP (nvim-lsp)](https://rishabhrd.github.io/jekyll/update/2020/09/19/nvim_lsp_config.html)
- [Setup Neovim for Lua Development](https://www.chrisatmachine.com/Neovim/28-neovim-lua-development/)
- [luarocks.org](https://luarocks.org/)
- [luarocks at github.com](https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix)
- [sumneko lua](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua)
- [Build and Run lua language server](https://github.com/sumneko/lua-language-server/wiki/Build-and-Run)
- [Color scheme - sonokai ](https://github.com/sainnhe/sonokai)
- [Neovim 0.5 features and the switch to init.lua](https://oroques.dev/notes/neovim-init/)
- [LSP- go language server](https://github.com/golang/tools/tree/master/gopls)
- [学习 Neovim 全配置，逃离 VSCode](https://zhuanlan.zhihu.com/p/434727338)
- [iTerm2](https://sourabhbajaj.com/mac-setup/iTerm/)
- [Go neovim configuration](https://www.getman.io/posts/programming-go-in-neovim/)
- [Base neovim configuration](https://github.com/brainfucksec/neovim-lua)
- [Alacritty yaml](https://github.com/alacritty/alacritty/blob/master/alacritty.yml)
- [Telescope example](https://gitee.com/sternelee/neovim-nvim/blob/master/init.lua)
- [clipper](https://github.com/wincent/clipper)
- [Yank from container](https://stackoverflow.com/questions/43075050/how-to-yank-to-host-clipboard-from-inside-a-docker-container)
- [打通 Neovim 与系统剪切板](https://zhuanlan.zhihu.com/p/419472307)
- [How to set up Neovim 0.5 + Modern plugins (LSP, Treesitter, Fuzzy finder, etc)](https://blog.inkdrop.app/how-to-set-up-neovim-0-5-modern-plugins-lsp-treesitter-etc-542c3d9c9887)

## [Moving to modern Neovim](https://toroid.org/modern-neovim#update)

- [Vista.vim](https://github.com/liuchengxu/vista.vim)
- [Package management - packer](https://github.com/wbthomason/packer.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Status line? - lualine](https://github.com/hoob3rt/lualine.nvim)
- [Key mappings? - which-key.nvim](https://github.com/folke/which-key.nvim)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [NvimTree](https://github.com/kyazdani42/nvim-tree.lua)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [Treesitter - romgrk/nvim-treesitter-context](https://github.com/romgrk/nvim-treesitter-context)
- [LSP - nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [LSP - nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [LSP - symbols-outline.nvim](https://github.com/simrat39/symbols-outline.nvim)
- [LSP - lsp-signature](https://github.com/ray-x/lsp_signature.nvim)
- [Debug? - nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [Debug? - nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)

## .profile

```
$more .profile
export GOPATH=/go
export PATH=$PATH:$GOPATH/bin
export PS1='\u@\h:\w $ '
alias vi=nvim
```

## [Nert font support](https://github.com/ryanoasis/nerd-fonts#glyph-sets)

[homebrew font](https://github.com/Homebrew/homebrew-cask-fonts/tree/master/Casks)

```
% brew tap homebrew/cask-fonts
% brew install --cask font-hack-nerd-font
% brew install --cask font-cousine-nerd-font
```

## docker file

### apk part

- apk add neovim neovim-doc (30m)
- apk add git curl tzdata htop (48m)
- apk add go (538m, 50 packages)
- apk add tmux (539m, 52 packages)

### neovim environment and packer

- export HOME=/home/ide
- export GOPATH=/go
- mkdir /go
- addgroup develop && adduser -D -h $HOME -s /bin/ash -G develop ide
- chown -R ide:develop $GOPATH
- su - ide
- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
- git clone https://github.com/brainfucksec/neovim-lua.git
- cd neovim-lua
- mkdir -p ~/.config/
- cp -r nvim/ ~/.config/
- disable color scheme first, run :PackerSync
- mkdir -p .config/alacritty/
- touch .config/alacritty/alacritty.yml
- apk add g++ "need g++ to compile treesitter"
- apk add ccls "c/c++ language server need npm" (860 MiB in 64 packages)

for vista

- apk add ctags fzf

## Telescope

- apk add ripgrep

## others

-
- python3 fzf
- apk add tree-sitter nodejs
- apk add make musl-dev g++
- git clone https://github.com/savq/paq-nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim
- go install golang.org/x/tools/gopls@latest
- mkdir -p ~/.config/nvim/lua
- copy init.lua only keep the basics.lua
- git clone https://github.com/optimizacija/neovim-config.git
- cd
- makedir .config
- cd .config
- ln -s ../neovim-config/ nvim
