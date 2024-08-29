FROM alpine:3.20
LABEL maintainer="ericwq057@qq.com"
# build_date="2024-08-29"

#  go
#  openjdk
#  LazyVim starter depends
#  lazy.nvim depends
#  c/c++, clangd, luarocks, protoc, fish_indent
#  neovim npm

# hadolint ignore=DL3018,DL3016
RUN apk add --no-cache icu-data-full go \
  openjdk17 maven \
  git lazygit neovim ripgrep alpine-sdk \
  curl wget fzf fd tree-sitter-cli nodejs bash npm py3-pip py3-pynvim py3-wheel gzip unzip \
  sudo tzdata htop clang-dev luarocks5.1 protoc cloc fish && \
  npm install -g neovim

# luarocks symbol link
WORKDIR /usr/bin
RUN ln -s luarocks-5.1 luarocks

ENV HOME=/home/ide
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin
ENV ENV=$HOME/.profile

RUN addgroup develop && adduser -D -h $HOME -s /bin/ash -G develop ide
RUN mkdir -p $GOPATH && chown -R ide:develop $GOPATH
RUN echo 'ide ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ide

USER ide:develop
WORKDIR $HOME

RUN go install golang.org/x/tools/gopls@latest && \
  go install golang.org/x/tools/cmd/goimports@latest && \
  # go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
  go install github.com/jstemmer/gotags@latest && \
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
  go install mvdan.cc/gofumpt@latest && \
  # go install golang.org/x/tools/go/analysis/passes/fieldalignment/cmd/fieldalignment@latest \
  go clean -cache -modcache -testcache && \
  rm -rf $GOPATH/src/*

# install rust, ast-grep, rust-analyzer
# hadolint ignore=DL4006
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y && \
  $HOME/.cargo/bin/cargo install ast-grep --locked && \
  $HOME/.cargo/bin/rustup component add rust-analyzer

# https://github.com/LazyVim/LazyVim/discussions/2862 transparent
# run :LazyHealth after installation.
#
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim
COPY --chown=ide:develop ./lazy/profile             $HOME/.profile
COPY --chown=ide:develop ./lazy/clang-format        $HOME/.clang-format
COPY --chown=ide:develop ./lazy/plugins/*.lua       $HOME/.config/nvim/lua/plugins/
COPY --chown=ide:develop ./lazy/config/options.lua  $HOME/.config/nvim/lua/config/options.lua

# https://github.com/folke/lazy.nvim/discussions/1188
#
# check new release
ADD --chown=ide:develop https://api.github.com/repos/folke/lazy.nvim/releases/latest .version/lazy.nvim.json
ADD --chown=ide:develop https://api.github.com/repos/LazyVim/LazyVim/releases/latest .version/LazyVim.json
RUN nvim --headless +"Lazy! sync" +"MasonInstall lua-language-server delve shfmt taplo \
  jdtls stylua markdownlint dockerfile-language-server docker-compose-language-service" +qa

CMD ["/bin/ash"]
# https://gist.github.com/davidteren/898f2dcccd42d9f8680ec69a3a5d350e
# install nerd font
