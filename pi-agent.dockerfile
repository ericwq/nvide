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
  sudo \
  bash \
  git \
  ripgrep \
  fd-find \
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3016
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# 2. 创建组 develop，创建用户 ide，创建工作目录
RUN groupadd develop \
  && useradd -m -g develop ide \
  && mkdir -p /ide \
  && chown -R ide:develop /ide

# 切换默认用户为 ide
USER ide
WORKDIR /ide

# 默认进入交互式shell
CMD ["/bin/bash"]
