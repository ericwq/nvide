# pi-agent.dockerfile
FROM node:24-bookworm-slim

LABEL maintainer="ericwq057@qq.com"

# 开启 pipefail + errexit，管道失败直接终止构建
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-c"]

# 关闭apt交互式询问
ENV DEBIAN_FRONTEND=noninteractive
# 设置时区上海
ENV TZ=Asia/Shanghai

# 1. 安装 curl ca-certificates + tzdata，增加 --no-install-recommends 消除 DL3015
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  tzdata \
  wget \
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
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 安装 python-docx
RUN python3 -m venv /opt/pyvenv
ENV PATH="/opt/pyvenv/bin:$PATH"
# hadolint ignore=DL3013
RUN pip install --no-cache-dir python-docx

# 安装 nono
# hadolint ignore=DL4001
RUN VERSION=$(curl -sIL https://github.com/nolabs-ai/nono/releases/latest | grep -i location | grep -oP 'v\K[0-9a-zA-Z.-]+') \
  && ARCH=$(dpkg --print-architecture) \
  && wget -q https://github.com/nolabs-ai/nono/releases/download/v${VERSION}/nono-cli_${VERSION}_${ARCH}.deb \
  && dpkg -i nono-cli_${VERSION}_${ARCH}.deb \
  && rm nono-cli_${VERSION}_${ARCH}.deb

# 安装 pi agent
# hadolint ignore=DL3016
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# 2. 创建组 develop，创建用户 ide，创建工作目录
RUN groupadd develop \
  && useradd -m -g develop ide \
  && mkdir -p /home/ide \
  && chown -R ide:develop /home/ide

# 切换工作目录
WORKDIR /home/ide
ENV HOME=/home/ide
ARG NPM_PATH=/home/ide/.npm-global

RUN mkdir -p ${NPM_PATH} \
  && npm config set prefix "${NPM_PATH}" \
  && chown -R ide:develop ${NPM_PATH}
ENV PATH=${NPM_PATH}/bin:$PATH

USER ide

# 安装 lattice
ARG PI_SKILLS=${HOME}/.pi/agent/skills/
RUN mkdir -p ${PI_SKILLS} && chown -R ide:develop ${PI_SKILLS}
# hadolint ignore=DL3003
RUN git clone https://github.com/techygarg/lattice.git && \
  cd lattice && \
  ./tools/install.sh ${PI_SKILLS}

# 安装 nono, pi agent 配置文件
WORKDIR /home/ide
ARG NONO_PROFILE=/home/ide/.config/nono/profiles/
RUN mkdir -p ${NONO_PROFILE} && chown -R ide:develop ${NONO_PROFILE}
COPY --chown=ide:develop ./pi/pi-mono.json  ${NONO_PROFILE}/pi-mono.json
COPY --chown=ide:develop ./pi/AGENTS.md     ${HOME}/.pi/agent/AGENTS.md

# 添加别名到 bashrc
RUN cat >> /home/ide/.bashrc <<'EOF'
alias np='nono run --profile pi-mono -- pi'
EOF

# 默认进入交互式SHELL
CMD ["/bin/bash"]
