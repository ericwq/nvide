## Build the image

```sh
% docker build -t nvide:0.8.4 -f nvim.dockerfile .
% docker build --progress plain -t nvide:0.8.4 -f nvim.dockerfile .
% docker build --no-cache --progress plain -t nvide:0.8.4 -f nvim.dockerfile .
```

## create docker volume

```sh
% docker volume create proj-vol
```

please change the ownership of mount directory.

## Build the SSH image

```sh
% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t ssh-nvide:0.10.2 -f sshd-nvim.dockerfile .
```
## Build the Openrc image

```sh
% docker build --build-arg ROOT_PWD=password \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t openrc-nvide:0.10.2 -f openrc-nvim.dockerfile .
```
## Dryrun the container

```sh
% docker run --rm -ti nvide:0.8.4
% docker run -ti --rm -u ide -p 22:22 ssh-nvide:0.10.2
```

## Publish images to [docker](hub.docker.com)

### 1. Tag the image

```sh
% docker tag nvide:0.8.4 ericwq057/nvide:0.8.4
```

### 2. sign in with your account at hub.docker.com

### 3. Push to docker.io

```sh
% docker push ericwq057/nvide:0.8.4
% git tag -a 0.8.4 -m "release message."
% git push origin 0.8.4
```

## Start the container

```sh
% docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.8.4

% docker run --rm -ti --privileged -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.8.4

% docker run -d -p 22:22 -h ssh-nvide --env TZ=Asia/Shanghai --name ssh-nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        ssh-nvide:0.10.2

% docker run -d -p 22:22 -p 8101:8101/udp -h ssh-nvide --env TZ=Asia/Shanghai --name ssh-nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        ssh-nvide:0.10.2
```

## Start openrc-nvide container

```sh
% docker run --env TZ=Asia/Shanghai --tty --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
    -h openrc-nvide --name openrc-nvide -d -p 22:22 \
    -p 8101:8101/udp -p 8102:8102/udp -p 8103:8103/udp openrc-nvide:0.10.2
```

## Login to the containter

```sh
% rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old
% ssh ide@localhost
% ssh root@localhost
% apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main ca-certificates curl
% docker exec -u 0 -it nvide ash
% docker exec -u ide -it nvide ash
```

## Attach to the container

```
% docker attach nvide
```

## build lua_ls manually

check (act for macOS)[https://github.com/nektos/act/issues/1658]

```
% docker run -w /root -it --rm alpine:latest sh -uelic '
  apk add git ninja bash build-base --update
  sh
  '
% git clone https://github.com/LuaLS/lua-language-server
% cd lua-language-server/
% ./make.sh
```

## upgrade to new version
```shell
% sed -i 's/0\.8\.3/0\.8\.4/g' build.md sshd-nvim.dockerfile openrc-nvim.dockerfile README.md
% sed -i 's/0\.10\.1/0\.10\.2/g' build.md README.md conf/motd
```
