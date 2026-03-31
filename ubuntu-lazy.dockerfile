FROM ubuntu:24.04
LABEL maintainer="ericwq057@qq.com"
# build_date="2026-03-31"

# 设置环境变量避免交互提示
ENV DEBIAN_FRONTEND=noninteractive
# 设置中国时区
ENV TZ=Asia/Shanghai

# setup LANG
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安装必要工具 + 配置时区
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  git curl wget tar gzip ca-certificates unzip \
  openjdk-17-jdk-headless \
  clang lld llvm build-essential \
  lua5.4 luarocks ripgrep fd-find fzf sudo \
  tzdata && \
  # 配置时区
  ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  # 清理缓存，减小镜像体积
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# 1. Neovim
# hadolint ignore=SC3040
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz  && \
  rm -rf /opt/nvim-linux-x86_64 && \
  tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
  rm nvim*.tar.gz && \
  ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# 安装 Go 1.26
RUN curl -LO https://go.dev/dl/go1.26.1.linux-amd64.tar.gz && \
  rm -rf /usr/local/go && \
  tar -C /usr/local -xzf go1.26.1.linux-amd64.tar.gz && \
  rm go1.26.1.linux-amd64.tar.gz



# 设置 JAVA_HOME GOPATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=/usr/local/go/bin:$PATH
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH
ENV PATH=$JAVA_HOME/bin:$PATH

# 安装 tree-sitter-cli
# hadolint ignore=DL4006
RUN curl -L https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz | \
  gunzip -c > /usr/local/bin/tree-sitter && \
  chmod +x /usr/local/bin/tree-sitter

# hadolint ignore=DL4006
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*') && \
  LAZYGIT_ARCH=$(uname -m | sed -e 's/aarch64/arm64/') && \
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" && \
  tar xf lazygit.tar.gz lazygit && \
  install lazygit -D -t /usr/local/bin/

# 验证安装
RUN nvim --version && \
  git --version && \
  lazygit --version && \
  tree-sitter --version && \
  curl --version && \
  fzf --version && \
  rg --version && \
  fdfind --version

# 创建用户组 develop、创建用户ide并加入该组
RUN groupadd develop \
  && useradd -m -s /bin/bash -g develop ide \
  && usermod -aG sudo ide

RUN mkdir -p $GOPATH && chown -R ide:develop $GOPATH

# 免密sudo（容器开发常用）
RUN echo 'ide ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers

# 切换工作目录 & 默认用户
WORKDIR /home/ide
USER ide
ENV HOME=/home/ide

# install Go
# hadolint ignore=DL3062
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

# install OpenCode
# hadolint ignore=DL4006
RUN curl -fsSL https://opencode.ai/install | bash

# install node.js npm
# hadolint ignore=DL4006
RUN curl -o- https://fnm.vercel.app/install | bash && \
  $HOME/.local/share/fnm/fnm install 24 

# prepare for fd link
RUN mkdir -p $HOME/.local/bin && ln -s "$(which fdfind)" $HOME/.local/bin/fd

RUN git clone https://github.com/LazyVim/starter $HOME/.config/nvim
COPY --chown=ide:develop ./lazy/clang-format        $HOME/.clang-format
COPY --chown=ide:develop ./lazy/plugins/*.lua       $HOME/.config/nvim/lua/plugins/
COPY --chown=ide:develop ./lazy/config/options.lua  $HOME/.config/nvim/lua/config/options.lua

RUN echo 'export LANG=C.UTF-8' >> /home/ide/.bashrc && \
  echo 'export LC_ALL=C.UTF-8' >> /home/ide/.bashrc

ENV PATH=$HOME/.local/bin:$PATH
RUN nvim --headless +"Lazy! sync" +"MasonInstall shfmt lua-language-server stylua " +qa

CMD ["/bin/bash"]
