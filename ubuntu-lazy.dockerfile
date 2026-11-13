# ubuntu-lazy.dockerfile
# 单文件同时支持 linux/amd64 与 linux/arm64。
#
# 构建（BuildKit，推荐，一次出双架构）：
#   docker buildx build --platform linux/amd64,linux/arm64 -t ulazy:0.2.0 -f ubuntu-lazy.dockerfile .
# 构建（仅本机架构）：
#   docker build -t ulazy:0.2.0 -f ubuntu-lazy.dockerfile .
#
# 注意：apt 层用了 --mount=type=cache，需要 BuildKit（Docker 23+ 默认开启）；
#       DOCKER_BUILDKIT=0 的经典构建会报 Unknown flag: mount
#
# 架构说明：neovim / lazygit / tree-sitter-cli 全用 26.04 自带包（不再从 GitHub 下载架构相关二进制），
# ARCH 取 dpkg --print-architecture（即 amd64 / arm64），只在两处使用：
# apt 层拼 OpenJDK 目录名、nono 层拼 .deb 包名（nono 仍从 GitHub 下载，是唯一的架构相关外部二进制）
#
# 基础镜像：Ubuntu 26.04 LTS。需要按 digest 固定时可覆盖参数（不用改本文件）：
#   --build-arg UBUNTU_IMAGE=ubuntu:26.04@sha256:xxxxxxxx
ARG UBUNTU_IMAGE=ubuntu:26.04
FROM ${UBUNTU_IMAGE}

LABEL org.opencontainers.image.maintainer="ericwq057@qq.com" \
  org.opencontainers.image.title="ulazy"

# 管道中任一命令失败即中止构建（配合下面的 curl | gunzip、curl | sh）
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-c"]

# 非交互安装 + 中国时区 + UTF-8 locale
# DEBIAN_FRONTEND 不写进 ENV（否则会烘进镜像，容器内交互式 apt 会异常），只在 apt 那一层内 export
ENV TZ=Asia/Shanghai \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# 上游版本：需要可复现构建时可钉版本（GRADLE_VERSION 是一处，LAZYVIM_REF 是另一处）
#   docker build -f ubuntu-lazy.dockerfile -t ulazy:0.2.0 . --build-arg LAZYVIM_REF=main
# 注意：LazyVim/starter 仓库没有任何 release tag，LAZYVIM_REF 实际上只能钉分支（--depth 1 不支持裸 commit）
# Go 工具链（gopls/goimports/gotags/protoc-gen-go/gofumpt）仍是 @latest：五个模块版本号各异，
# 单个 ARG 无法统一钉住，需要可复现时请直接改下面 go install 行里的 @版本号
ARG LAZYVIM_REF=main

# 安装必要工具 + 配置时区
# apt 缓存挂载：重建时不用重新下载 .deb 与索引（不进镜像层），所以不再需要 apt-get clean / rm lists
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
  ARCH="$(dpkg --print-architecture)"; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update && apt-get install -y --no-install-recommends \
  git curl wget tar gzip zip ca-certificates unzip jq \
  openjdk-21-jdk-headless openjdk-17-jdk-headless openjdk-25-jdk-headless maven \
  clang clangd build-essential pkg-config libssl-dev \
  lua5.4 luarocks ripgrep fd-find fzf sudo \
  python3 python3-pynvim python3-pip python3-venv python3-lxml python3-docx poppler-utils \
  python-is-python3 \
  golang-go \
  lazygit fish \
  tzdata && \
  # Node 取 NodeSource 24.x（与 pi-agent 一致）：仓库自带的是 22.22.1，Node 24 需单独加源安装（npm 随 nodejs 包提供）
  curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
  apt-get install -y --no-install-recommends nodejs && \
  # 配置时区（/etc/localtime 是 libc 真正读取的；/etc/timezone 仅发行版约定，ENV TZ 已生效，删）
  ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  # JAVA_HOME 固定为一个与架构无关的路径（amd64/arm64 目录名前缀相同）；默认用 25（jdtls 1.63 要求的版本）
  ln -sfn "/usr/lib/jvm/java-25-openjdk-${ARCH}" /usr/lib/jvm/java-25-openjdk && \
  # update-alternatives 的优先级由 deb 包决定（不可控），显式把 java/javac 指到 25
  update-alternatives --set java "/usr/lib/jvm/java-25-openjdk-${ARCH}/bin/java" && \
  update-alternatives --set javac "/usr/lib/jvm/java-25-openjdk-${ARCH}/bin/javac" && \
  # apt 的 clangd 是过渡包（实测 26.04：仅 Depends: clangd-21，自身不带二进制）；
  # clangd-21 提供 /usr/bin/clangd-21（符号链接）与 /usr/lib/llvm-21/bin/clangd（真实二进制），
  # 但没有无后缀的 /usr/bin/clangd —— Debian 系 LLVM 不用 alternatives。
  # 所以用 find 找到最高版本二进制并自建 /usr/local/bin/clangd 入口，
  # 否则 clangd --version 自检和 nvim 的 clangd LSP 都会失败
  clangd_bin="$(find -L /usr/bin /usr/lib -maxdepth 3 \( -name clangd -o -name 'clangd-*' \) -type f 2>/dev/null | sort -V | tail -n1)" && \
  test -n "$clangd_bin" && \
  ln -sfn "$clangd_bin" /usr/local/bin/clangd && \
  # 清掉不再需要的自动依赖，再删 apt 索引；索引不进镜像（重建时靠 cache 挂载重建，代价是一次 apt update）
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# JAVA_HOME 供 neovim / 构建工具（mvn/gradle 等）读取，默认指向 25（jdtls 1.63 要求的版本）；
# 17 / 21 仍保留，供需要旧版本的项目用（update-alternatives --list / --set 或改 JAVA_HOME 切换）
# update-alternatives 已在 apt 层显式 --set 到 25，所以 /usr/bin/java（javac）也是 25
# java、javac 本身由 update-alternatives 提供在 /usr/bin，所以不再把 ${JAVA_HOME}/bin 重复加进 PATH
# Go 用 26.04 自带的 golang-go（/usr/bin/go，GOROOT 自动推导），只有 go install 产物在 GOPATH/bin
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk \
  GOPATH=/go \
  PATH=/go/bin:${PATH}

# Gradle：apt 的 gradle 停在 4.4.1（2017 年，-22ubuntu1），现代项目用不了，所以取官方发行包；
# 下载后用上游发布的 .sha256 校验（pi-agent.dockerfile 里没有这一步）。
# Maven 则直接用 26.04 自带的 3.9.12（universe），不必下载。
ARG GRADLE_VERSION=9.9.1
RUN curl -fsSLo /tmp/gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
  curl -fsSLo /tmp/gradle.sha256 "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256" && \
  echo "$(awk '{print $1}' /tmp/gradle.sha256)  /tmp/gradle.zip" | sha256sum -c - && \
  unzip -q /tmp/gradle.zip -d /opt && \
  ln -sfn "/opt/gradle-${GRADLE_VERSION}" /opt/gradle && \
  rm -f /tmp/gradle.zip /tmp/gradle.sha256

ENV GRADLE_HOME=/opt/gradle \
  PATH=/opt/gradle/bin:${PATH}

# Install Neovim
RUN ARCH="$(dpkg --print-architecture)"; \
  case "$ARCH" in \
  amd64) NVIM_ARCH="x86_64" ;; \
  arm64) NVIM_ARCH="arm64" ;; \
  *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
  esac; \
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz" && \
  rm -rf "/opt/nvim-linux-${NVIM_ARCH}" && \
  tar -C /opt -xzf "nvim-linux-${NVIM_ARCH}.tar.gz" && \
  rm nvim*.tar.gz && \
  ln -s "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim

# Install tree-sitter-cli
RUN ARCH="$(dpkg --print-architecture)"; \
  case "$ARCH" in \
  amd64) TS_ARCH="x64" ;; \
  arm64) TS_ARCH="arm64" ;; \
  *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
  esac; \
  curl -fsSL -o /tmp/tree-sitter.gz \
  "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${TS_ARCH}.gz" && \
  gunzip -c /tmp/tree-sitter.gz > /usr/local/bin/tree-sitter && \
  chmod +x /usr/local/bin/tree-sitter && \
  rm /tmp/tree-sitter.gz

# 验证安装
RUN nvim --version && \
  git --version && \
  java -version && \
  mvn -v && \
  gradle --version && \
  test -d "/usr/lib/jvm/java-17-openjdk-$(dpkg --print-architecture)" && \
  clangd --version && \
  python3 --version && \
  command -v pdftotext jq zip && \
  node --version && npm --version && \
  test "$(node -p "process.versions.node.split('.')[0]")" = 24 && \
  python3 -c 'import pynvim, docx, lxml' && \
  go version && \
  lazygit --version && \
  curl --version && \
  fzf --version && \
  rg --version && \
  tree-sitter --version && \
  fdfind --version

# 预装 jdtls：不经过 mason，直接取 eclipse 里程碑包（milestones/ 比 snapshots/ 保留更久）。
# 1.63 的 bundle 要求 Java 25（实测 1.55/1.62/1.63 都要 25），
# 默认 JAVA_HOME 已指向 25，启动器会直接使用，无需再补丁；
# python-is-python3 提供 /usr/bin/python（启动脚本 shebang 需要）；lombok 为注解支持
RUN curl -fsSL -o /tmp/jdtls.tar.gz \
  "https://download.eclipse.org/jdtls/milestones/1.63.0/jdt-language-server-1.63.0-202610191322.tar.gz" && \
  curl -fsSL -o /tmp/lombok.jar https://projectlombok.org/downloads/lombok.jar && \
  mkdir -p /opt/jdtls && tar -C /opt/jdtls -xzf /tmp/jdtls.tar.gz && \
  mv /tmp/lombok.jar /opt/jdtls/plugins/ && \
  rm -f /tmp/jdtls.tar.gz && \
  ln -sfn /opt/jdtls/bin/jdtls /usr/local/bin/jdtls && \
  # 唯一命门检查：launcher 靠它在 plugins/ 里找 OSGi 启动器，缺失时 jdtls 直接起不来
  ls /opt/jdtls/plugins/org.eclipse.equinox.launcher_*.jar

# 安装 nono（dpkg -i 需 root，必须在 USER ide 之前；用 apt 里的 jq 解析最新版本；
# 依赖只有 libc6，用 dpkg -i 即可，避免依赖 apt 索引——apt 层已删索引）
RUN VERSION=$(curl -fsSL https://api.github.com/repos/nolabs-ai/nono/releases/latest | jq -r '.tag_name' | sed 's/^v//') \
  && test -n "$VERSION" \
  && ARCH="$(dpkg --print-architecture)" \
  && curl -fsSL -o "/tmp/nono-cli_${VERSION}_${ARCH}.deb" \
  "https://github.com/nolabs-ai/nono/releases/download/v${VERSION}/nono-cli_${VERSION}_${ARCH}.deb" \
  && dpkg -i "/tmp/nono-cli_${VERSION}_${ARCH}.deb" \
  && rm "/tmp/nono-cli_${VERSION}_${ARCH}.deb"


# 创建用户组 develop、创建用户 ide 并加入 sudo 组、准备 GOPATH、配置免密 sudo
# sudoers 写入 sudoers.d 而不是覆盖 /etc/sudoers，后者会丢掉文件末尾的 #includedir 指令
RUN groupadd develop \
  && useradd -m -s /bin/bash -g develop ide \
  && usermod -aG sudo ide \
  && mkdir -p "$GOPATH" \
  && chown -R ide:develop "$GOPATH" \
  && echo 'ide ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ide \
  && chmod 0440 /etc/sudoers.d/ide

# 切换工作目录 & 默认用户
WORKDIR /home/ide
USER ide
ENV HOME=/home/ide

# npm 全局前缀统一到 ~/.npm-global：ide 用户免 sudo 就能 npm i -g（同 pi-agent.dockerfile 的思路）。
# 同时把 nvim 的 node provider 依赖包 neovim 装到这个前缀下，让 npm root -g 与实际安装位置一致。
ENV NPM_CONFIG_PREFIX=${HOME}/.npm-global
# hadolint ignore=DL3016
RUN npm install -g neovim && test -d "$(npm root -g)/neovim"

# install Go
# hadolint ignore=DL3062
RUN go install golang.org/x/tools/gopls@latest && \
  go install golang.org/x/tools/cmd/goimports@latest && \
  go install github.com/jstemmer/gotags@latest && \
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
  go install mvdan.cc/gofumpt@latest && \
  go clean -cache -modcache -testcache && \
  rm -rf "${GOPATH:?}/src/"*

# install rust, ast-grep, rust-analyzer
RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -sSf | sh -s -- -y && \
  "$HOME/.cargo/bin/cargo" install ast-grep --locked && \
  "$HOME/.cargo/bin/rustup" component add rust-analyzer

## use latest tree-sitter-cli
# RUN "$HOME/.cargo/bin/cargo" install --locked tree-sitter-cli &&\
#   tree-sitter --version

# prepare for fd link，并预建 Maven / Gradle 缓存目录（方便挂 volume 持久化依赖）
RUN mkdir -p "$HOME/.local/bin" "$HOME/.m2" "$HOME/.gradle" \
  && ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"

# 安装 pi agent（安装脚本只写 $HOME，不需要 root）
ENV PATH=${HOME}/.pi/agent/bin:${PATH}
RUN curl -fsSL https://pi.dev/install.sh | sh \
  && pi install npm:pi-models-discovery

# 安装 lattice（pi 的技能集，装完删掉克隆目录）
ARG PI_SKILLS=${HOME}/.pi/agent/skills
RUN git clone --depth 1 https://github.com/techygarg/lattice.git "$HOME/.cache/lattice" && \
  "$HOME/.cache/lattice/tools/install.sh" "$PI_SKILLS" && \
  rm -rf "$HOME/.cache/lattice"

# pi 配置文件 + nono profile 目录
ARG NONO_PROFILE=${HOME}/.config/nono/profiles
RUN mkdir -p "$NONO_PROFILE"
COPY --chown=ide:develop ./pi/pi-mono.json  $NONO_PROFILE/pi-mono.json
COPY --chown=ide:develop ./pi/AGENTS.md     ${HOME}/.pi/agent/AGENTS.md
COPY --chown=ide:develop ./pi/models.json   ${HOME}/.pi/agent/models.json

# LAZYVIM_REF 只能是分支（starter 仓库无 release tag；--depth 1 也不支持裸 commit SHA）
RUN git clone --depth 1 --branch "$LAZYVIM_REF" https://github.com/LazyVim/starter "$HOME/.config/nvim"
COPY --chown=ide:develop ./lazy/clang-format        $HOME/.clang-format
COPY --chown=ide:develop ./lazy/plugins/*.lua       $HOME/.config/nvim/lua/plugins/
COPY --chown=ide:develop ./lazy/config/options.lua  $HOME/.config/nvim/lua/config/options.lua

# LANG / LC_ALL 已由上面的 ENV 全局生效，这里补别名（vi / np）与 umask
RUN printf 'alias vi=nvim\nalias np=\"nono run --profile pi-mono -- pi\"\numask 022\n' >> "${HOME}/.bashrc"

# rustup 只把 cargo/rust-analyzer 的 PATH 写进 ~/.profile（仅登录 shell 生效），
# 非交互 shell（bash -c、docker exec）必须显式加进 ENV 才能找到 rust-analyzer
ENV PATH=${HOME}/.cargo/bin:${HOME}/.local/bin:${NPM_CONFIG_PREFIX}/bin:${PATH}

RUN nvim --headless +"Lazy! sync" +"MasonInstall shfmt lua-language-server stylua " +qa

CMD ["/bin/bash"]
