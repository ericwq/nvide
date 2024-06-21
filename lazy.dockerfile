FROM alpine:3.20
LABEL maintainer="ericwq057@qq.com"
LABEL build_date="2024-06-19"

# 1. go and docs
# 2. LazyVim starter depends
# 3. lazy.nvim depends
RUN apk add -U icu-data-full docs go \
	git lazygit neovim ripgrep alpine-sdk \
	curl wget fzf fd tree-sitter-cli nodejs bash npm py3-pip py3-pynvim py3-wheel gzip unzip

RUN apk add -U sudo tzdata clang-dev

RUN npm install -g neovim

ENV HOME=/home/ide
ENV GOPATH /go
ENV PATH=$PATH:$GOPATH/bin
ENV ENV=$HOME/.profile

RUN addgroup develop && adduser -D -h $HOME -s /bin/ash -G develop ide
RUN mkdir -p $GOPATH && chown -R ide:develop $GOPATH
RUN echo 'ide ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ide

USER ide:develop
WORKDIR $HOME

RUN go install golang.org/x/tools/gopls@latest && \
	go install golang.org/x/tools/cmd/goimports@latest && \
	#    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
	go install github.com/jstemmer/gotags@latest && \
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
	go install mvdan.cc/gofumpt@latest && \
	go clean -cache -modcache -testcache && \
	rm -rf $GOPATH/src/*

# https://github.com/LazyVim/LazyVim/discussions/2862 transparent
# run :LazyHealth after installation.
#
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim
COPY ./lazy/config/options.lua 		$HOME/.config/nvim/lua/config/options.lua
COPY ./lazy/profile			$HOME/.profile
COPY ./lazy/plugins/*.lua		$HOME/.config/nvim/lua/plugins/

RUN nvim --headless "+Lazy! sync" +MasonToolsInstallSync +q!
# RUN nvim --headless "+Lazy! sync" +qa
# RUN nvim --headless "+LspInstall lua_ls" +q!
# RUN nvim --headless "+LspInstall clangd" +q!
CMD ["/bin/ash"]
