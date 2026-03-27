FROM ubuntu:24.04

# 禁用交互 + 设置中国时区
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装必要工具 + 配置时区
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends curl wget ca-certificates tzdata && \
  # 配置时区
  ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  # 清理缓存，减小镜像体积
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
