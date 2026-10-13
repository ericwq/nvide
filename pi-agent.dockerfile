# hadolint global ignore=DL3008
# pi-agent.dockerfile
# 目标平台 linux/arm64，基础镜像 ubuntu 24.04 LTS
FROM ubuntu:24.04

LABEL maintainer="ericwq057@qq.com"

# 开启 pipefail + errexit，管道失败直接终止构建
SHELL ["/bin/bash", "-o", "pipefail", "-e", "-c"]

# 关闭apt交互式询问
ENV DEBIAN_FRONTEND=noninteractive
# 设置时区上海
ENV TZ=Asia/Shanghai
# 设置终端类型，保证交互式 shell 的彩色输出和光标控制正常
ENV TERM=xterm-256color

# 1. 安装 curl ca-certificates + tzdata，增加 --no-install-recommends 消除 DL3015
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

# 2. 创建组 develop，创建用户 ide，创建工作目录
RUN groupadd develop \
  && useradd -m -g develop ide \
  && mkdir -p /ide \
  && chown -R ide:develop /ide

# 切换默认用户为 ide
USER ide

# 3. 配置 npm 使用国内镜像源，加速后续安装
# RUN npm config set registry https://registry.npmmirror.com

# 4. 使用官方脚本安装 pi-agent（pi-agent 内部自行安装 node/npm）
WORKDIR /ide
RUN curl -fsSL https://pi.dev/install.sh | sh

# 默认工作目录
WORKDIR /ide

# 默认进入交互式shell
CMD ["/bin/bash"]
