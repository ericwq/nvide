# ubuntu-lazy.dockerfile
# 单文件同时支持 linux/amd64 与 linux/arm64。
#
# 构建（BuildKit，推荐，一次出双架构）：
#   docker buildx build --platform linux/amd64,linux/arm64 -t ulazy:0.2.0 -f ubuntu-lazy.dockerfile . --push
# 构建（仅本机架构）：
#   docker build -t ulazy:0.2.0 -f ubuntu-lazy.dockerfile .
#
# 可选组件（默认全关，按需打开；改取值会使其后的所有层缓存失效并重建）：
#   --build-arg WITH_GO=true      # Go + gopls/goimports/gotags/protoc-gen-go/gofumpt（约 +400MB）
#   --build-arg WITH_JDK17=true   # 额外装 OpenJDK 17（约 +200MB）
#   --build-arg WITH_JDK21=true   # 额外装 OpenJDK 21（约 +200MB）
#   docker build -t ulazy:0.2.0 -f ubuntu-lazy.dockerfile . \
#     --build-arg WITH_GO=true --build-arg WITH_JDK17=true
#
# 注意：apt 层用了 --mount=type=cache，需要 BuildKit（Docker 23+ 默认开启）；
#       DOCKER_BUILDKIT=0 的经典构建会报 Unknown flag: mount
#
# 内置工具提示（默认安装，非开关）：hadolint（Dockerfile linter）、
#   Mermaid CLI（mmdc，依赖 chrome-headless-shell；渲染时用
#   mmdc ... -p "$HOME/.config/mermaid/puppeteer.json" 走 --no-sandbox 配置）。
#
# 架构说明：lazygit 用 26.04 自带包；neovim / tree-sitter-cli / Go / nono / hadolint 需下载架构相关二进制。
# ARCH 取 BuildKit 注入的 TARGETARCH（经典构建下回退 dpkg --print-architecture），
# 用于拼接 OpenJDK 目录名、上游包文件名与 nono .deb 包名；Go 受 WITH_GO 控制，关闭时其下载层整体跳过。
#
# 基础镜像：Ubuntu 26.04 LTS。需要按 digest 固定时可覆盖参数（不用改本文件）：
#   --build-arg UBUNTU_IMAGE=ubuntu:26.04@sha256:xxxxxxxx
ARG UBUNTU_IMAGE=ubuntu:26.04
FROM ${UBUNTU_IMAGE}

LABEL org.opencontainers.image.maintainer="ericwq057@qq.com" \
  org.opencontainers.image.title="nvide"

# 管道中任一命令失败即中止构建（curl | tar、curl | sh、命令替换里的 curl | jq 都依赖 pipefail）
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-c"]

# BuildKit 自动注入的平台架构（amd64 / arm64）；经典构建下为空，各处用 ${TARGETARCH:-$(dpkg --print-architecture)} 回退
ARG TARGETARCH

# 可选组件开关：默认 false = 不装
ARG WITH_GO=false
ARG WITH_JDK17=false
ARG WITH_JDK21=false

# 非交互安装 + 中国时区 + UTF-8 locale
# DEBIAN_FRONTEND 不写进 ENV（否则会烘进镜像，容器内交互式 apt 会异常），只在 apt 那一层内 export
# LANG / LC_ALL 必须显式设置：官方 ubuntu 镜像不设 LANG，glibc 会按 C/POSIX 处理，中文与 emoji 会异常
ENV TZ=Asia/Shanghai \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# 上游版本：需要可复现构建时可钉版本
#   docker build -f ubuntu-lazy.dockerfile -t ulazy:0.2.0 . --build-arg LAZYVIM_REF=main
# 注意：LazyVim/starter 仓库没有任何 release tag，LAZYVIM_REF 实际上只能钉分支（--depth 1 不支持裸 commit）
# Go 工具链（gopls/goimports/gotags/protoc-gen-go/gofumpt）仍是 @latest：五个模块版本号各异，
# 单个 ARG 无法统一钉住，需要可复现时请直接改下面 go install 行里的 @版本号
ARG LAZYVIM_REF=main

# 安装必要工具 + 配置时区
# apt 缓存挂载：重建时不用重新下载 .deb 与索引（不进镜像层），所以不需要 apt-get clean / rm lists
# hadolint ignore=DL3008,SC3054
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
  ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
  export DEBIAN_FRONTEND=noninteractive; \
  # JDK：25 必装（jdtls 1.63 要求），17 / 21 由开关独立追加；set -e 下不能用 [ ] && 拼接（条件为假会返回 1 中断构建）
  # 包名放数组里，用 "${JDK_PKGS[@]}" 展开：加引号的字符串变量会因空格被 apt 当成单个包名
  # RUN 由上面的 SHELL 指定为 bash，数组合法；linter 报的 SC3054 是按 POSIX sh 解析的误报（已在上方 ignore）
  JDK_PKGS=(openjdk-25-jdk-headless); \
  if [ "$WITH_JDK17" = "true" ]; then JDK_PKGS+=(openjdk-17-jdk-headless); fi; \
  if [ "$WITH_JDK21" = "true" ]; then JDK_PKGS+=(openjdk-21-jdk-headless); fi; \
  apt-get update && apt-get install -y --no-install-recommends \
  git curl wget tar gzip zip ca-certificates unzip jq \
  "${JDK_PKGS[@]}" maven \
  clang clangd build-essential pkg-config libssl-dev \
  lua5.4 luarocks ripgrep fd-find fzf sudo \
  python3 python3-pynvim python3-pip python3-venv python3-lxml python3-docx poppler-utils \
  python-is-python3 \
  lazygit fish \
  tzdata && \
  # Node 取 NodeSource 24.x（与 pi-agent 一致）：仓库自带的是 22.22.1，Node 24 需单独加源安装（npm 随 nodejs 包提供）
  # 注意：setup 脚本内部自带一次 apt-get update，因此本层有第二次索引刷新，属预期（索引在 cache mount 内，增量刷新）
  curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
  apt-get install -y --no-install-recommends nodejs && \
  # 旧版 JDK 的连通性自检：装了就断言目录真实存在
  if [ "$WITH_JDK17" = "true" ]; then test -d "/usr/lib/jvm/java-17-openjdk-${ARCH}"; fi && \
  if [ "$WITH_JDK21" = "true" ]; then test -d "/usr/lib/jvm/java-21-openjdk-${ARCH}"; fi && \
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
  # 清掉不再需要的自动依赖；apt 索引与 deb 缓存都在 cache mount 里，不进镜像层，无需 clean / rm
  apt-get autoremove -y

# chrome-headless-shell 运行所需系统库（Mermaid CLI 渲染依赖，缺一个就启动失败）；
# fonts-noto-cjk 让图表里的中文不显示成豆腐块，fonts-dejavu-core（约 2MB）作为非 CJK 字体的兜底
# （mermaid-cli 只自带 open-sans/recursive 的 web 字体，图里指定其它字体家族时靠 fontconfig 回退）
# 单独成层而没并进上面的主 apt 层：这组包只为 Mermaid CLI 服务，单独一层便于按需裁掉
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update && apt-get install -y --no-install-recommends \
  libasound2t64 libatk-bridge2.0-0t64 libatk1.0-0t64 libcairo2 libcups2t64 \
  libdbus-1-3 libexpat1 libgbm1 libglib2.0-0t64 libnspr4 libnss3 libpango-1.0-0 \
  libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 \
  fonts-noto-cjk fonts-dejavu-core && \
  apt-get autoremove -y

# JAVA_HOME 供 neovim / 构建工具（mvn/gradle 等）读取，默认指向 25（jdtls 1.63 要求的版本）；
# 17 / 21 仅在 WITH_JDK17 / WITH_JDK21 打开时才存在（update-alternatives --list / --set 或改 JAVA_HOME 切换）
# update-alternatives 已在 apt 层显式 --set 到 25，所以 /usr/bin/java（javac）也是 25
# java、javac 本身由 update-alternatives 提供在 /usr/bin，所以不再把 ${JAVA_HOME}/bin 重复加进 PATH
# Go 由 WITH_GO 控制（默认 false = 不装）；开启时下载官方发行包到 /usr/local/go（GOROOT 自动推导），
# go install 产物落在 GOPATH/bin。以下两条 Go 路径在关闭状态下指向不存在的目录，无副作用
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk \
  GOPATH=/go \
  PATH=/go/bin:/usr/local/go/bin:${PATH}

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

# neovim + tree-sitter-cli：上游两家的架构命名不一致（x86_64 / x64），
# 一次 case 同时得出两个名字，避免在同一层里重复解析架构
RUN ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
  case "$ARCH" in \
  amd64) NVIM_ARCH="x86_64"; TS_ARCH="x64" ;; \
  arm64) NVIM_ARCH="arm64"; TS_ARCH="arm64" ;; \
  *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
  esac; \
  curl -fsSLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"; \
  rm -rf "/opt/nvim-linux-${NVIM_ARCH}"; \
  tar -C /opt -xzf /tmp/nvim.tar.gz; \
  rm -f /tmp/nvim.tar.gz; \
  ln -sfn "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim; \
  curl -fsSLo /tmp/tree-sitter.gz "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${TS_ARCH}.gz"; \
  gunzip -c /tmp/tree-sitter.gz > /usr/local/bin/tree-sitter; \
  chmod +x /usr/local/bin/tree-sitter; \
  rm -f /tmp/tree-sitter.gz; \
  nvim --version > /dev/null; \
  tree-sitter --version

# 动态获取最新 Go 版本并安装（仅 WITH_GO=true；GOROOT 由安装路径自动推导）
# 上面的 ENV 已把 /usr/local/go/bin 放进 PATH，解包后直接 go version 顺带验证 PATH 生效
RUN if [ "$WITH_GO" = "true" ]; then \
  ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
  GO_VERSION="$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')"; \
  test -n "$GO_VERSION" && test "$GO_VERSION" != "null"; \
  curl -fsSL "https://go.dev/dl/${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -C /usr/local -xz; \
  go version; \
  fi

# 安装 hadolint（Dockerfile linter）：官方静态二进制，无外部依赖，直接放 /usr/local/bin
# 注意：资产名是 x86_64/arm64，与 dpkg 的 amd64/arm64 不一致，需显式映射
ARG HADOLINT_VERSION=v2.15.1
RUN ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
  case "$ARCH" in \
  amd64) HADOLINT_ARCH="x86_64" ;; \
  arm64) HADOLINT_ARCH="arm64" ;; \
  *) echo "Unsupported arch for hadolint: $ARCH" >&2; exit 1 ;; \
  esac; \
  curl -fsSLo /usr/local/bin/hadolint \
  "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-linux-${HADOLINT_ARCH}"; \
  chmod +x /usr/local/bin/hadolint; \
  hadolint --version

# 验证安装：只保留能真正暴露"装错/装漏"的检查。
# 不用 cmd | head 截断：pipefail 下 head 提前退出可能让 cmd 收到 SIGPIPE 被判失败；输出最长的 gradle 直接丢 /dev/null
# command -v 多参数时缺失项被忽略（只要有一个命中就返回 0，全部缺失才非 0），所以必须逐项循环检查
RUN java -version && \
  mvn -v && \
  gradle --version > /dev/null && \
  clangd --version && \
  python3 -c 'import pynvim, docx, lxml' && \
  node -e 'process.exit(+process.versions.node.split(".")[0] === 24 ? 0 : 1)' && \
  for c in lazygit fzf rg fdfind pdftotext jq unzip zip hadolint; do command -v "$c" > /dev/null || exit 1; done

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

# 安装 nono（dpkg -i 需 root，必须在 USER ide 之前；依赖只有 libc6，用 dpkg -i 即可，
# 避免依赖 apt 索引——apt 层缓存已挂载，索引不在镜像里）
# 版本号用 releases/latest 的 301 重定向解析，不走 api.github.com：未认证 API 限流 60 次/小时/IP，
# CI 或共享出口 IP 上会直接拿 403（API rate limit exceeded）。要可复现时用 --build-arg NONO_VERSION=x.y.z 钉住
ARG NONO_VERSION=
RUN VERSION="${NONO_VERSION}"; \
  if [ -z "$VERSION" ]; then \
  TAG_URL="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/nolabs-ai/nono/releases/latest)"; \
  VERSION="${TAG_URL##*/}"; \
  fi; \
  # 允许写成 v0.82.0 或 0.82.0，统一去掉前缀 v 再拼资产名
  VERSION="${VERSION#v}"; \
  test -n "$VERSION"; \
  ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
  curl -fsSL -o "/tmp/nono-cli_${VERSION}_${ARCH}.deb" \
  "https://github.com/nolabs-ai/nono/releases/download/v${VERSION}/nono-cli_${VERSION}_${ARCH}.deb"; \
  dpkg -i "/tmp/nono-cli_${VERSION}_${ARCH}.deb"; \
  rm "/tmp/nono-cli_${VERSION}_${ARCH}.deb"


# 创建用户组 develop、创建用户 ide 并加入 sudo 组、准备 GOPATH（仅 WITH_GO=true）、配置免密 sudo
# sudoers 写入 sudoers.d 而不是覆盖 /etc/sudoers，后者会丢掉文件末尾的 #includedir 指令
RUN groupadd develop \
  && useradd -m -s /bin/bash -g develop ide \
  && usermod -aG sudo ide \
  && if [ "$WITH_GO" = "true" ]; then mkdir -p "$GOPATH" && chown -R ide:develop "$GOPATH"; fi \
  && echo 'ide ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ide \
  && chmod 0440 /etc/sudoers.d/ide

# 切换工作目录 & 默认用户
WORKDIR /home/ide
# hadolint ignore=DL3066
USER ide
ENV HOME=/home/ide

# npm 全局前缀统一到 ~/.npm-global：ide 用户免 sudo 就能 npm i -g（同 pi-agent.dockerfile 的思路）。
# 同时把 nvim 的 node provider 依赖包 neovim 装到这个前缀下，让 npm root -g 与实际安装位置一致。
# 末尾断言校验前缀真的生效（否则 npm 会试图往 /usr/lib/node_modules 写，虽然会因权限失败，但断言更直接）
ENV NPM_CONFIG_PREFIX=${HOME}/.npm-global
# 前缀的 bin 必须马上进 PATH：npm 的全局命令（下面的 mmdc、以及后面可能再装的 npm 包）
# 都落在 ${NPM_CONFIG_PREFIX}/bin，不在这里加就要等到文件末尾那条 ENV 才生效，
# 中途的 RUN（比如 mmdc 冒烟测试）会报 command not found
ENV PATH=${NPM_CONFIG_PREFIX}/bin:${PATH}
# hadolint ignore=DL3016
RUN npm install -g neovim && test "$(npm root -g)" = "$NPM_CONFIG_PREFIX/lib/node_modules"

# 安装 Mermaid CLI（mmdc）：全局 npm 包；puppeteer 是 mermaid-cli 的 peerDependency，由 npm 自动装上。
# 容器内没有 GUI、/dev/shm 通常也偏小，chrome 必须带 --no-sandbox，配置固化到 ~/.config/mermaid/puppeteer.json；
# 用法：mmdc -i a.mmd -o a.svg -p "$HOME/.config/mermaid/puppeteer.json"
# 浏览器必须用 mermaid-cli 自己那份 puppeteer 的 CLI 下载：puppeteer 按自身钉死的 build id
# 查找 chrome-headless-shell，写死版本号（如 23.11.1）会随 mermaid-cli 升级而错位，mmdc 会报 Could not find Chrome。
# 浏览器落在 ~/.cache/puppeteer，mmdc 会自动找到，无需 PUPPETEER_EXECUTABLE_PATH。
# 这里不能用 --mount=type=cache 挂 ~/.npm：cache 目录由 BuildKit 以 root 创建，
# 本层已切到 USER ide，npm 写 _cacache 会直接 EACCES（Your cache folder contains root-owned files）。
# 所以照旧让它写镜像层里的 ~/.npm，末尾用 npm cache clean 清掉（否则 192 个包的 tarball 会进镜像，+100~200MB）
# hadolint ignore=DL3016
RUN npm install -g @mermaid-js/mermaid-cli \
  && MMDC_ROOT="$(npm root -g)/@mermaid-js/mermaid-cli" \
  && PUPPETEER_PKG="$(node -p "require.resolve('puppeteer/package.json', {paths: ['$MMDC_ROOT']})")" \
  && PUPPETEER_BIN="$(dirname "$(dirname "$PUPPETEER_PKG")")/.bin/puppeteer" \
  && test -x "$PUPPETEER_BIN" \
  && "$PUPPETEER_BIN" browsers install chrome-headless-shell \
  && mkdir -p "$HOME/.config/mermaid" \
  && printf '{"args": ["--no-sandbox", "--disable-setuid-sandbox"]}\n' > "$HOME/.config/mermaid/puppeteer.json" \
  && echo 'graph TD; A-->B;' > /tmp/test.mmd \
  && mmdc -i /tmp/test.mmd -o /tmp/test.svg -p "$HOME/.config/mermaid/puppeteer.json" \
  && rm -f /tmp/test.mmd /tmp/test.svg \
  && npm cache clean --force

# Go 工具链（仅 WITH_GO=true）：gopls / goimports / gotags / protoc-gen-go / gofumpt
# hadolint ignore=DL3062
RUN if [ "$WITH_GO" = "true" ]; then \
  go install golang.org/x/tools/gopls@latest; \
  go install golang.org/x/tools/cmd/goimports@latest; \
  go install github.com/jstemmer/gotags@latest; \
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest; \
  go install mvdan.cc/gofumpt@latest; \
  go clean -cache -modcache -testcache; \
  fi

# install rust, ast-grep, rust-analyzer
RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -sSf | sh -s -- -y && \
  "$HOME/.cargo/bin/cargo" install ast-grep --locked && \
  "$HOME/.cargo/bin/rustup" component add rust-analyzer

# prepare for fd link，并预建 Maven / Gradle 缓存目录（方便挂 volume 持久化依赖）
RUN mkdir -p "$HOME/.local/bin" "$HOME/.m2" "$HOME/.gradle" \
  && ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"

# 安装 pi agent（安装脚本只写 $HOME，不需要 root）
ENV PATH=${HOME}/.pi/agent/bin:${PATH}
RUN curl -fsSL https://pi.dev/install.sh | sh \
  && pi install npm:pi-models-discovery

# 安装 lattice（pi 的技能集，装完删掉克隆目录）
RUN git clone --depth 1 https://github.com/techygarg/lattice.git "$HOME/.cache/lattice" && \
  "$HOME/.cache/lattice/tools/install.sh" "$HOME/.pi/agent/skills" && \
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
COPY --chown=ide:develop ./lazy/plugins/core.lua    $HOME/.config/nvim/lua/plugins/core.lua
COPY --chown=ide:develop ./lazy/config/options.lua  $HOME/.config/nvim/lua/config/options.lua

# LANG / LC_ALL 已由上面的 ENV 全局生效，这里补别名（vi / np）与 umask
RUN printf 'alias vi=nvim\nalias np=\"nono run --profile pi-mono -- pi\"\numask 022\n' >> "${HOME}/.bashrc"

# rustup 只把 cargo/rust-analyzer 的 PATH 写进 ~/.profile（仅登录 shell 生效），
# 非交互 shell（bash -c、docker exec）必须显式加进 ENV 才能找到 rust-analyzer
ENV PATH=${HOME}/.cargo/bin:${HOME}/.local/bin:${PATH}

# mason 工具（lua-language-server / stylua / shfmt）不预装进镜像，由 LazyVim 首次启动时按需下载
WORKDIR "$HOME/.config/nvim"
RUN timeout 900 nvim --headless "+Lazy! sync" +qa
# 回到默认工作目录：docker run 进入容器时落在 $HOME，而不是 nvim 配置目录
WORKDIR "$HOME"

# ubuntu 官方镜像历来默认 CMD 即 /bin/bash；这里显式声明是为了不依赖基础镜像默认值（UBUNTU_IMAGE 可被覆盖），
# 并与 pi-agent.dockerfile 保持一致
CMD ["/bin/bash"]
