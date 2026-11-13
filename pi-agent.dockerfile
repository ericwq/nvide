# pi-agent.dockerfile
FROM ubuntu:26.04

LABEL maintainer="ericwq057@qq.com"

# 开启 pipefail + errexit，管道失败直接终止构建
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-c"]

# 设置时区上海
# DEBIAN_FRONTEND 不写进 ENV（否则会烘进镜像，容器内交互式 apt 会异常），只在 apt 层内 export
ENV TZ=Asia/Shanghai

# 安装 curl ca-certificates + tzdata，增加 --no-install-recommends 消除 DL3015
# hadolint ignore=DL3008
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  tzdata \
  zip \
  unzip \
  wget \
  curl \
  jq \
  git \
  ripgrep \
  fd-find \
  neovim \
  poppler-utils \
  python3 \
  python3-pip \
  python3-lxml \
  python3-venv \
  openjdk-21-jdk-headless \
  openjdk-17-jdk-headless \
  maven \
  sudo \
  build-essential \
  pkg-config \
  libssl-dev \
  && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 安装 python-docx
RUN python3 -m venv /opt/pyvenv
ENV PATH="/opt/pyvenv/bin:$PATH"
# hadolint ignore=DL3013
RUN python3 -m pip install --no-cache-dir python-docx

# 设置 JAVA_HOME
ARG DEFAULT_JDK=17
RUN ln -sfn "/usr/lib/jvm/java-${DEFAULT_JDK}-openjdk-$(dpkg --print-architecture)" /usr/lib/jvm/java-${DEFAULT_JDK}-openjdk
ENV JAVA_HOME=/usr/lib/jvm/java-${DEFAULT_JDK}-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN update-alternatives --set java  "/usr/lib/jvm/java-${DEFAULT_JDK}-openjdk-$(dpkg --print-architecture)/bin/java" \
  && update-alternatives --set javac "/usr/lib/jvm/java-${DEFAULT_JDK}-openjdk-$(dpkg --print-architecture)/bin/javac"

# install Gradle
# apt 的 gradle 停在 4.4.1（2017 年），所以取官方发行包；Maven 则用 26.04 自带的 3.9.12，不必下载
ARG GRADLE_VERSION=9.9.1
RUN curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip \
  && unzip -q /tmp/gradle.zip -d /opt \
  && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
  && rm /tmp/gradle.zip
ENV GRADLE_HOME=/opt/gradle
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# 安装 nono
RUN VERSION=$(curl -fsSL https://api.github.com/repos/nolabs-ai/nono/releases/latest | jq -r '.tag_name' | sed 's/^v//') \
  && test -n "$VERSION" \
  && ARCH=$(dpkg --print-architecture) \
  && curl -fsSL -o "nono-cli_${VERSION}_${ARCH}.deb" \
  "https://github.com/nolabs-ai/nono/releases/download/v${VERSION}/nono-cli_${VERSION}_${ARCH}.deb" \
  && dpkg -i "nono-cli_${VERSION}_${ARCH}.deb" \
  && rm "nono-cli_${VERSION}_${ARCH}.deb"

# 创建组 develop，创建用户 ide（默认 shell 为 bash），加入 sudo 组并免密，创建工作目录
RUN groupadd develop \
  && useradd -m -s /bin/bash -g develop ide \
  && usermod -aG sudo ide \
  && echo 'ide ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ide \
  && chmod 0440 /etc/sudoers.d/ide \
  && mkdir -p /home/ide \
  && chown -R ide:develop /home/ide

# 切换工作目录
USER ide
WORKDIR /home/ide
ENV HOME=/home/ide

# install rust, ast-grep, rust-analyzer
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y && \
  $HOME/.cargo/bin/cargo install ast-grep --locked && \
  $HOME/.cargo/bin/rustup component add rust-analyzer
# rustup 只把 cargo/rust-analyzer 的 PATH 写进 ~/.profile（仅登录 shell 生效），
# 非交互 shell（bash -c、docker exec）必须显式加进 ENV 才能找到 rust-analyzer
ENV PATH=${HOME}/.cargo/bin:$PATH

ARG NPM_PATH=/home/ide/.npm-global
RUN mkdir -p ${NPM_PATH} \
  && npm config set prefix "${NPM_PATH}" \
  && chown -R ide:develop ${NPM_PATH}
ENV PATH=${NPM_PATH}/bin:$PATH

# nvim 的 node provider 需要全局 npm 包 neovim（否则 :checkhealth 报 provider 不可用）
# hadolint ignore=DL3016
RUN npm install -g neovim

# 安装 pi agent
# hadolint ignore=DL3016
ENV PATH=${HOME}/.pi/agent/bin:$PATH
RUN curl -fsSL https://pi.dev/install.sh | sh \
  && pi install npm:pi-models-discovery

# 安装 lattice
ARG PI_SKILLS=${HOME}/.pi/agent/skills/
RUN mkdir -p ${PI_SKILLS} ${HOME}/.m2 ${HOME}/.gradle
# hadolint ignore=DL3003
RUN git clone https://github.com/techygarg/lattice.git && \
  cd lattice && \
  ./tools/install.sh ${PI_SKILLS} && \
  cd .. && rm -rf lattice

# 安装 nono, pi agent 配置文件
WORKDIR /home/ide
ARG NONO_PROFILE=/home/ide/.config/nono/profiles/
RUN mkdir -p ${NONO_PROFILE} && chown -R ide:develop ${NONO_PROFILE}
COPY --chown=ide:develop ./pi/pi-mono.json  ${NONO_PROFILE}/pi-mono.json
COPY --chown=ide:develop ./pi/AGENTS.md     ${HOME}/.pi/agent/AGENTS.md
COPY --chown=ide:develop ./pi/models.json   ${HOME}/.pi/agent/models.json

# setup LANG
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 添加别名到 bashrc
RUN cat >> /home/ide/.bashrc <<'EOF'
alias np='nono run --profile pi-mono -- pi'
umask 022
EOF

# 默认进入交互式SHELL
CMD ["/bin/bash"]
