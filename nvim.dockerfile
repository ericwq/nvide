FROM alpine:edge
LABEL maintainer="ericwq057@qq.com"

# This is the base pacakges for neovim 
#
# tree-sitter depends on tree-sitter-cli, nodejs, alpine-sdk
# telscope depends on ripgrep, fzf, fd
# vista depends on ctags
#
RUN apk add --no-cache --update git neovim neovim-doc tree-sitter-cli nodejs ripgrep fzf fd ctags alpine-sdk icu-data-full

# additional pacakges
# mainly go, tmux, htop, protoc
# 
RUN apk add --no-cache --update tmux colordiff curl tzdata htop go protoc cloc gzip wget

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
# c family language build tools: autoconf, automake,bear
#
RUN apk add --no-cache --update py3-pip py3-pynvim npm clang-dev cppcheck ninja bash unzip cmake readline-dev lua5.3-dev autoconf automake bear waf

# https://github.com/fsouza/prettierd
#
RUN npm install -g @fsouza/prettierd neovim dockerfile-language-server-nodejs

ENV HOME=/home/ide
ENV GOPATH /go

# proselint is installed in $HOME/.local/bin
# luarocks is also installed in $HOME/.local/
#
# save PATH in OLDPATH, depends on HOME/.profile for environment setup
ENV OLDPATH=$PATH
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
	curl -R -O https://luarocks.github.io/luarocks/releases/$LUA_ROCKS.tar.gz && \
	tar zxpf $LUA_ROCKS.tar.gz && \
	cd $LUA_ROCKS  && \
	./configure --lua-version=5.3 --prefix=$HOME/.local && \
	make && \
	make install && \
	rm -rf /tmp/$LUA_ROCKS
# use the following command to check luarocks is ready for use
# luarocks path --help

# Prepare for the nvim
# RUN mkdir -p $HOME/.config/nvim/lua

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
	#    go install golang.org/x/tools/cmd/goimports@latest && \
	#    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
	#    go install github.com/jstemmer/gotags@latest && \
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
	go install mvdan.cc/gofumpt@latest && \
	go clean -cache -modcache -testcache && \
	rm -rf $GOPATH/src/*

# https://github.com/amperser/proselint
#
# prepare for the pip installation
ENV VIRTUAL_ENV=$HOME/.local/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN pip install proselint --upgrade pip

# Install lua-language-server
# https://github.com/LuaLS/lua-language-server/wiki/Getting-Started#command-line
# the lua-language-server is installed in $HOME/.local
#
# check the following refs to bulid the musl version of lua-language-server.
# https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobs
# https://github.com/LuaLS/lua-language-server/blob/master/.github/workflows/build.yml
#
WORKDIR $HOME/.local
RUN git clone https://github.com/LuaLS/lua-language-server && \
	cd lua-language-server && \
	./make.sh && \
	rm -rf ./.git ./3rd ./log ./test
ENV PATH=$PATH:$HOME/.local/lua-language-server/bin
WORKDIR $HOME

# Install lazy.nvim
# https://github.com/folke/lazy.nvim
# WORKDIR $HOME
# RUN git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable \
# 	$HOME/.local/share/nvim/lazy/lazy.nvim

#------------------------------ NOTICE ------------------------------
# The neovim configuration
# based on https://github.com/NvChad/NvChad
#
RUN git clone https://github.com/NvChad/NvChad.git $HOME/.config/nvim --depth 1
# Add file type to solve the dockerfile filetype problem. 2022/05/29
COPY --chown=ide:develop ./conf/filetype.lua	$HOME/.config/nvim/
COPY --chown=ide:develop ./custom		$HOME/.config/nvim/lua/custom

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

# Put the .clang-format in home directory 2022/04/30
COPY --chown=ide:develop ./conf/clang-format.txt $HOME/.clang-format

# Add xterm-kitty link for alpine linux 2022/04/30
# RUN mkdir -p $HOME/.terminfo/x
# RUN ln -s /etc/terminfo/k/kitty $HOME/.terminfo/x/xterm-kitty
# RUN ln -s /etc/terminfo/x/xterm-color $HOME/.terminfo/x/xterm-256color

# Init shadafile
# RUN nvim --headless -u NONE -c 'echo "init shadafile"' -c qall

# Install the packer plugins
# https://github.com/wbthomason/packer.nvim/issues/502
#
# NvChad version
# RUN nvim --headless -c 'packadd packer.nvim' -c 'lua require"plugins"' -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

RUN nvim --headless "+Lazy! sync" +qa

# Install treesitter language parsers
# See :h packages
# https://github.com/wbthomason/packer.nvim/issues/237
#
# RUN nvim --headless -c 'packadd lazy.nvim' -c 'lua require"plugins"' -c 'packadd nvim-treesitter' -c 'TSInstallSync go c cpp yaml lua json dockerfile markdown proto' +qall

#RUN nvim --headless -c "MasonInstall --target=linux_x64_gnu lua-language-server" -c qall

ENV PATH=$OLDPATH
CMD ["/bin/ash"]
