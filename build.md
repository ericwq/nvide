## Build pi-agent image

下面的命令假定你的 $HOME 目录下有一个 `dev` 子目录，可以建立 `dev` 子目录。
也可以更改下面的命令参数，调整为自己的子目录。
最后的效果就是：你宿主机的指定目录（`dev` 子目录）在容器中被挂载到了 `/home/ide/develop` 目录下。

### build for amd64

```sh
# 构建命令
docker build --platform linux/amd64 -t pi-agent:0.5 -f pi-agent.dockerfile .

# 后台启动
docker run -d -ti --name pi-agent -h pi-agent  \
    --env TZ=Asia/Shanghai --platform linux/amd64 \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    pi-agent:0.5
```

### build for arm64

```sh
# 构建命令
docker build --platform linux/arm64 -t pi-agent:0.5 -f pi-agent.dockerfile .

# 后台启动
docker run -d -ti --name pi-agent -h pi-agent \
    --env TZ=Asia/Shanghai --platform linux/arm64 \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    pi-agent:0.5
```

### 进入容器
```sh
docker exec -u root -it pi-agent /bin/bash
docker exec -u ide -it pi-agent /bin/bash
```

### build from stock image

```sh
# 仅 pi-agent 缺少其他工具
docker pull --platform linux/amd64 michaelwadman/pi-agent
docker pull --platform linux/arm64 ocramz/pi-container
```

## Build base image

```sh
docker build -t nvide:0.9.4 -f lazy.dockerfile .
docker build --progress plain -t nvide:0.9.4 -f lazy.dockerfile .
docker build --no-cache --progress plain -t nvide:0.9.4 -f lazy.dockerfile .
```

### 构建 nvide（ubuntu-lazy）

`ubuntu-lazy.dockerfile` 单文件同时支持 amd64 / arm64，不再需要按架构分文件。
需要 BuildKit（apt 层用了 `--mount=type=cache`，Docker 23+ 默认开启；`DOCKER_BUILDKIT=0` 会报 `Unknown flag: mount`）。

```sh
# 多架构：一次构建两个平台并推送 manifest（推荐）
docker buildx build --platform linux/amd64,linux/arm64 \
    -t nvide:0.9.4 -f ubuntu-lazy.dockerfile . --push

# 只构建本机架构（最快，构建期会自检 java/clangd/go/mvn/gradle/nvim 等）
docker build -t nvide:0.9.4 -f ubuntu-lazy.dockerfile .

# 单独验证另一架构（需已注册 qemu）
docker buildx build --platform linux/arm64 \
    -t nvide:0.9.4 -f ubuntu-lazy.dockerfile . --load
```

#### 可复现构建（钉版本）

默认都是「跟随发行版 / 上游最新版」，需要可复现时显式钉住：

```sh
docker build -f ubuntu-lazy.dockerfile -t nvide:0.2.0 . \
    --build-arg UBUNTU_IMAGE=ubuntu:26.04@sha256:<digest> \
    --build-arg LAZYVIM_REF=main \
    --build-arg GRADLE_VERSION=9.9.1

docker run -d -ti --name nvide -h nvide  \
    --env TZ=Asia/Shanghai \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    nvide:0.9.4

docker exec -u root -it nvide /bin/bash
docker exec -u ide -it nvide /bin/bash
```

`LAZYVIM_REF` 只能是分支（starter 仓库没有任何 release tag，且 `git clone --depth 1` 不支持裸 commit）。
Go 工具链（gopls 等 5 个）仍为 `@latest`，要钉就改 `ubuntu-lazy.dockerfile` 里 `go install` 行的 `@版本号`。

#### 构建后自检

```sh
docker run --rm -it nvide:0.9.4 bash -lc '
  nvim --version | head -1
  go version; java -version 2>&1 | head -1
  mvn -v | head -1; gradle --version | grep -E "^Gradle"
  clangd --version | head -1
  python3 -c "import pynvim; print(\"pynvim ok\")"
  node --version; npm ls -g --depth=0 | grep neovim
  rust-analyzer --version; lazygit --version; tree-sitter --version
  pi --version; nono --version
  nvim --headless "+checkhealth vim.provider" +qa 2>&1 | tail -20'
```

> 旧的 `ubuntu-lazy-amd64.dockerfile` / `ubuntu-lazy-arm64.dockerfile` / `ulazy-arm64.dockerfile`
> 已由单文件取代，待新镜像验证通过后删除。

## Create docker volume

```sh
docker volume create proj-vol
```

Please change the ownership of mount directory.
## Build `sshd-lazy` image

```sh
docker tag nvide:0.9.3 ericwq057/nvide:0.9.3
docker build --build-arg ROOT_PWD=password \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t sshd-lazy:0.11.3 -f sshd-lazy.dockerfile .
```
## Dry run base container

```sh
docker run --rm -ti nvide:0.9.4
docker run --rm -ti -u ide -p 22:22 sshd-lazy:0.11.3
```

## Start base container

```sh
# start container as daemon
docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    nvide:0.9.3

# start container and mount local directory
docker run -it --rm --mount type=bind,source=${HOME}/dev,target=/develop ubuntu:24.04 /bin/bash

# start container and run in background
# check https://oneuptime.com/blog/post/2026-03-16-use-bind-mounts-podman/view for rootful and rootless mode
docker run -it -d -h ulazy --env TZ=Asia/Shanghai --name ulazy --tty \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -v proj-vol:/home/ide/proj \
    -v ${HOME}/dev:/home/ide/develop \
    ulazy:0.2.0

# start container and destroy it after use
docker run --rm -ti --privileged -h nvide --env TZ=Asia/Shanghai --name nvide \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    nvide:0.9.3
```

## Start sshd-lazy container

```sh
# normal start
docker run --env TZ=Asia/Shanghai --tty --privileged \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    -h sshd-lazy --name sshd-lazy -d -p 22:22 -p 80:80 -p 8080:8080 \
    -p 8101:8101/udp -p 8102:8102/udp -p 8103:8103/udp sshd-lazy:0.11.3

# map port 22 to 8022, 810x to 820x
docker run --env TZ=Asia/Shanghai --tty --privileged \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=${HOME}/dev,target=/home/ide/develop \
    -h sshd-lazy --name sshd-lazy -d -p 8022:22 -p 80:80 -p 8080:8080 \
    -p 8201:8101/udp -p 8202:8102/udp -p 8203:8103/udp sshd-lazy:0.11.3
```

## Login to the container

```sh
rm ~/.ssh/known_hosts*
kitty +kitten ssh ide@localhost   # setup TERM
kitty +kitten ssh root@localhost  # setup TERM
ssh root@localhost
setup-utmp                        # start utmps service
ssh ide@localhost
# docker exec -u 0 -it nvide bash
# docker exec -u ide -it nvide ash
docker exec -u root -it ulazy bash # login with root
docker exec -u ide -it ulazy bash
```

## Attach to the container

```
docker attach nvide
```

## Upgrade to new version
```shell
sed -i 's/0\.9\.0/0\.9\.1/g' build.md sshd-lazy.dockerfile lazy.dockerfile README.md
sed -i 's/0\.11\.0/0\.11\.1/g' build.md README.md lazy/motd
```

## Publish images to [docker](hub.docker.com)

### 1. Tag the image

```sh
docker tag nvide:0.9.3 ericwq057/nvide:0.9.3
```

### 2. Sign in with your account at hub.docker.com

### 3. Push to docker.io

```sh
docker push ericwq057/nvide:0.9.3
git tag -a 0.9.3 -m "release message."
git push origin 0.9.3
```
