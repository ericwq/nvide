# pi-agent.dockerfile
FROM ubuntu:26.04

LABEL maintainer="ericwq057@qq.com"

# 开启 pipefail + errexit，管道失败直接终止构建
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-c"]

# 关闭apt交互式询问
ENV DEBIAN_FRONTEND=noninteractive
# 设置时区上海
ENV TZ=Asia/Shanghai

# 安装 curl ca-certificates + tzdata，增加 --no-install-recommends 消除 DL3015
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  tzdata \
  unzip \
  wget \
  curl \
  bash \
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
  && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 安装 python-docx
RUN python3 -m venv /opt/pyvenv
ENV PATH="/opt/pyvenv/bin:$PATH"
# hadolint ignore=DL3013
RUN python3 -m pip install --no-cache-dir python-docx

ARG GRADLE_VERSION=9.8.2
RUN curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle.zip \
  && unzip -q /tmp/gradle.zip -d /opt \
  && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
  && rm /tmp/gradle.zip
ENV GRADLE_HOME=/opt/gradle
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# 设置 JAVA_HOME
RUN ln -sfn "/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)" /usr/lib/jvm/java-21-openjdk
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# 安装 nono
# hadolint ignore=DL4001
RUN VERSION=$(curl -sIL https://github.com/nolabs-ai/nono/releases/latest | grep -i location | grep -oP 'v\K[0-9a-zA-Z.-]+') \
  && ARCH=$(dpkg --print-architecture) \
  && wget -q https://github.com/nolabs-ai/nono/releases/download/v${VERSION}/nono-cli_${VERSION}_${ARCH}.deb \
  && dpkg -i nono-cli_${VERSION}_${ARCH}.deb \
  && rm nono-cli_${VERSION}_${ARCH}.deb

# 安装最新版 Maven（固定版本以保证可复现）
# ARG MAVEN_VERSION=3.10.0
# RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz \
#   && mkdir -p /opt \
#   && tar -xzf /tmp/maven.tar.gz -C /opt \
#   && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
#   && rm /tmp/maven.tar.gz
# ENV MAVEN_HOME=/opt/maven
# ENV PATH="${MAVEN_HOME}/bin:${PATH}"

# 创建组 develop，创建用户 ide，创建工作目录
RUN groupadd develop \
  && useradd -m -g develop ide \
  && mkdir -p /home/ide \
  && chown -R ide:develop /home/ide

USER ide

# 切换工作目录
WORKDIR /home/ide
ENV HOME=/home/ide
ARG NPM_PATH=/home/ide/.npm-global

RUN mkdir -p ${NPM_PATH} \
  && npm config set prefix "${NPM_PATH}" \
  && chown -R ide:develop ${NPM_PATH}
ENV PATH=${NPM_PATH}/bin:$PATH

# 安装 pi agent
# hadolint ignore=DL3016
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# 安装 lattice
ARG PI_SKILLS=${HOME}/.pi/agent/skills/
RUN mkdir -p ${PI_SKILLS} ${HOME}/.m2 ${HOME}/.gradle
# hadolint ignore=DL3003
RUN git clone https://github.com/techygarg/lattice.git && \
  cd lattice && \
  ./tools/install.sh ${PI_SKILLS}

# install rust, ast-grep, rust-analyzer
# hadolint ignore=DL4001
# RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y && \
#   $HOME/.cargo/bin/cargo install ast-grep --locked && \
#   $HOME/.cargo/bin/rustup component add rust-analyzer


# 安装 nono, pi agent 配置文件
WORKDIR /home/ide
ARG NONO_PROFILE=/home/ide/.config/nono/profiles/
RUN mkdir -p ${NONO_PROFILE} && chown -R ide:develop ${NONO_PROFILE}
COPY --chown=ide:develop ./pi/pi-mono.json  ${NONO_PROFILE}/pi-mono.json
COPY --chown=ide:develop ./pi/AGENTS.md     ${HOME}/.pi/agent/AGENTS.md

# setup LANG
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 添加别名到 bashrc
RUN cat >> /home/ide/.bashrc <<'EOF'
alias np='nono run --profile pi-mono -- pi'
EOF

# 默认进入交互式SHELL
CMD ["/bin/bash"]
