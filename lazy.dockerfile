FROM alpine:3.20
LABEL maintainer="ericwq057@qq.com"
# build_date="2024-06-19"

# 1. go
# 2. LazyVim starter depends
# 3. lazy.nvim depends
# 4. clangd, luarocks, protoc, fish_indent
# 5. clean apk cache
# 6. neovim npm
RUN apk add --no-cache icu-data-full go \
  git lazygit neovim ripgrep alpine-sdk \
  curl wget fzf fd tree-sitter-cli nodejs bash npm py3-pip py3-pynvim py3-wheel gzip unzip \
  sudo tzdata htop clang-dev luarocks5.1 protoc cloc fish && \
  npm install -g neovim

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
  # go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
  go install github.com/jstemmer/gotags@latest && \
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
  go install mvdan.cc/gofumpt@latest && \
  # go install golang.org/x/tools/go/analysis/passes/fieldalignment/cmd/fieldalignment@latest \
  go clean -cache -modcache -testcache && \
  rm -rf $GOPATH/src/*

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
RUN nvim --headless "+Lazy! sync" +"MasonInstall lua-language-server \
  stylua markdownlint shfmt dockerfile-language-server docker-compose-language-service" +qa
# RUN nvim --headless "+Lazy! sync" +qa
# RUN nvim --headless "+LspInstall lua_ls" +q!
# RUN nvim --headless "+LspInstall clangd" +q!
CMD ["/bin/ash"]
# https://gist.github.com/davidteren/898f2dcccd42d9f8680ec69a3a5d350e
# install nerd font
