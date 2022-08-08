## Build the image

```sh
% docker build -t nvide:0.7.5 -f nvim.dockerfile .
% docker build --progress plain -t nvide:0.7.5 -f nvim.dockerfile .
% docker build --no-cache --progress plain -t nvide:0.7.5 -f nvim.dockerfile .
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
	--progress plain -t nvide:0.8.2 -f sshd-nvim.dockerfile .
```

## Dryrun the container

```sh
% docker run --rm -ti nvide:0.7.5
% docker run -ti --rm -u ide -p 22:22 nvide:0.8.2
```

## Publish images to [docker](hub.docker.com)

### 1. Tag the image

```sh
% docker tag nvide:0.7.5 ericwq057/nvide:0.7.5
```

### 2. sign in with your account at hub.docker.com

### 3. Push to docker.io

```sh
% docker push ericwq057/nvide:0.7.5
% git tag -a 0.7.5 -m "release message."
% git push origin 0.7.5
```

## Start the container

```sh
% docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.7.5

% docker run --rm -ti -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.7.5

% docker run -d -p 22:22 -h nvide-ssh --env TZ=Asia/Shanghai --name nvide-ssh \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.8.2

% docker run -d -p 22:22 -p 60001:60001/udp -h nvide-ssh --env TZ=Asia/Shanghai --name nvide-ssh \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.8.2
```

## Login to the containter

```sh
% rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old
% ssh ide@localhost
% ssh root@localhost
% docker exec -u 0 -it nvide ash
% docker exec -u ide -it nvide ash
```

## Attach to the container

```
% docker attach nvide
```
