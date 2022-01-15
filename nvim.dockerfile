#------------------------------ NOTICE ------------------------------
# please perform the following command before you build the image.
# run the following command in the dockerfile directory.
#
# git clone https://github.com/NvChad/NvChad.git
#
FROM alpine:edge
LABEL maintainer="ericwq057@qq.com"

# This is the base pacakges for neovim 
# https://github.com/NvChad/NvChad
#
# tree-sitter depends on tree-sitter-cli, nodejs, alpine-sdk
# telscope depends on ripgrep, fzf, fd
# vista depends on ctags
#
RUN apk add git neovim neovim-doc tree-sitter-cli nodejs ripgrep fzf fd ctags alpine-sdk --update

# additional pacakges
# mainly go, tmux, htop, protoc
# 
RUN apk add tmux colordiff curl tzdata htop go protoc --update

# language server packages
# https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
#
# proselint (null-ls) depends on py3-pip 
# prettierd (null-ls) depends on npm
# clang-format (null-ls) depends on clang-dev
# cppcheck (null-ls)
# clangd depends on clang-dev
# lua-language-server depends on ninja, bash
# luarocks depends on readline-dev, lua5.3-dev, cmake, unzip
#
RUN apk add py3-pip npm clang-dev cppcheck ninja bash unzip cmake readline-dev lua5.3-dev --update

# https://github.com/fsouza/prettierd
#
RUN npm install -g @fsouza/prettierd neovim

ENV HOME=/home/ide
ENV GOPATH /go

# proselint is installed in $HOME/.local/bin
# luarocks is also installed in $HOME/.local/
#
ENV PATH=$PATH:$GOPATH/bin:$HOME/.local/bin

# The source script
# https://hhoeflin.github.io/2020/08/19/bash-in-docker/
# https://unix.stackexchange.com/questions/176027/ash-profile-configuration-file
#
# ENV=$HOME/.profile
#
ENV ENV=$HOME/.profile

# Create user/group 
# ide/develop
#
RUN addgroup develop && adduser -D -h $HOME -s /bin/ash -G develop ide
RUN mkdir -p $GOPATH && chown -R ide:develop $GOPATH

USER ide:develop
WORKDIR $HOME

# Install luarocks 3.8
# https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix
# 1. lua5.3
# 2. luarocks 3.8: is installed in $HOME/.local
# 3. luaformatter
# 4. efm-langserver
#
ENV LUA_ROCKS=luarocks-3.8.0
RUN cd /tmp &&\
    wget https://luarocks.org/releases/$LUA_ROCKS.tar.gz && \
    tar zxpf $LUA_ROCKS.tar.gz && \
    cd $LUA_ROCKS  && \
    ./configure --lua-version=5.3 --prefix=$HOME/.local && \
    make && \
    make install && \
    rm -rf /tmp/$LUA_ROCKS
# use the following command to check luarocks is ready for use
# luarocks path --help

# Prepare for the nvim
RUN mkdir -p $HOME/.config/nvim/lua

# Install null-ls source
# https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.mkdir
# https://github.com/mpeterv/luacheck
# https://github.com/Koihik/LuaFormatter
#
RUN  luarocks install --server=https://luarocks.org/dev luaformatter && \
     luarocks install luacheck

# Install go language server and
# Install null-ls source: goimports, golangci-lint
# https://golangci-lint.run/usage/install/
#
RUN go install golang.org/x/tools/gopls@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install github.com/jstemmer/gotags@latest && \
    go install github.com/mattn/efm-langserver@latest && \
    go install mvdan.cc/gofumpt@latest && \
    go clean -cache -modcache -testcache && \
    rm -rf $GOPATH/src/*

# https://github.com/amperser/proselint
#
RUN pip3 install proselint pynvim

# Install lua-language-server
# https://github.com/sumneko/lua-language-server/wiki/Build-and-Run
# the lua-language-server is installed in $HOME/.local
#
WORKDIR $HOME/.local
RUN git clone https://github.com/sumneko/lua-language-server && \
    cd lua-language-server && \
    git submodule update --init --recursive && \
    cd 3rd/luamake && \
    ./compile/install.sh && \
    cd ../.. && \
    ./3rd/luamake/luamake rebuild

ENV PATH=$PATH:$HOME/.local/lua-language-server/bin
WORKDIR $HOME

# Set the environment 
#
COPY --chown=ide:develop ./conf/profile		$HOME/.profile

# The clipboatd support for vim and tmux
# https://sunaku.github.io/tmux-yank-osc52.html
#
COPY --chown=ide:develop ./conf/tmux.conf 	$HOME/.tmux.conf
COPY --chown=ide:develop ./conf/vimrc 		$HOME/.config/nvim/vimrc
COPY --chown=ide:develop ./conf/yank 		$HOME/.local/bin/yank
RUN chmod +x $HOME/.local/bin/yank

# Install packer.vim
# PackerSync command will install packer.vim automaticlly, while the
# installation  will stop to wait for user <Enter> input.
# So we install it manually.
#
# we install packer to 'opt' directory instead of 'start' directory
# because NvChad install packer in 'opt' directory
# https://github.com/wbthomason/packer.nvim
#
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
	~/.local/share/nvim/site/pack/packer/opt/packer.nvim

# The neovim configuration
# based on https://github.com/NvChad/NvChad
#
COPY --chown=ide:develop ./NvChad/init.lua	$HOME/.config/nvim/
COPY --chown=ide:develop ./NvChad/lua		$HOME/.config/nvim/lua
COPY --chown=ide:develop ./custom			$HOME/.config/nvim/lua/custom


# Install the packer plugins
# https://github.com/wbthomason/packer.nvim/issues/502
#
# NvChad version
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Install treesitter language parsers
# See :h packages
# https://github.com/wbthomason/packer.nvim/issues/237
#
RUN nvim --headless -c 'packadd nvim-treesitter' -c 'TSInstallSync go c cpp yaml lua json dockerfile markdown' +qall


CMD ["/bin/ash"]
