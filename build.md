## Build base image

```sh
docker build -t nvide:0.9.2 -f lazy.dockerfile .
docker build --progress plain -t nvide:0.9.2 -f lazy.dockerfile .
docker build --no-cache --progress plain -t nvide:0.9.2 -f lazy.dockerfile .
```

## Create docker volume

```sh
docker volume create proj-vol
```

Please change the ownership of mount directory.

## Build `sshd-lazy` image

```sh
docker tag nvide:0.9.2 ericwq057/nvide:0.9.2
docker build --build-arg ROOT_PWD=password \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t sshd-lazy:0.11.2 -f sshd-lazy.dockerfile .
```
## Dry run base container

```sh
docker run --rm -ti nvide:0.9.2
docker run --rm -ti -u ide -p 22:22 sshd-lazy:0.11.2
```

## Start base container

```sh
# start container as daemon
docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
    nvide:0.9.2

# start container and destroy it after use
docker run --rm -ti --privileged -h nvide --env TZ=Asia/Shanghai --name nvide \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
    nvide:0.9.2
```

## Start sshd-lazy container

```sh
# normal start
docker run --env TZ=Asia/Shanghai --tty --privileged \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
    -h sshd-lazy --name sshd-lazy -d -p 22:22 -p 80:80 -p 8080:8080 \
    -p 8101:8101/udp -p 8102:8102/udp -p 8103:8103/udp sshd-lazy:0.11.2

# map port 22 to 8022, 810x to 820x
docker run --env TZ=Asia/Shanghai --tty --privileged \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
    --mount source=proj-vol,target=/home/ide/proj \
    --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
    -h sshd-lazy --name sshd-lazy -d -p 8022:22 -p 80:80 -p 8080:8080 \
    -p 8201:8101/udp -p 8202:8102/udp -p 8203:8103/udp sshd-lazy:0.11.2
```

## Login to the container

```sh
rm ~/.ssh/known_hosts*
kitty +kitten ssh ide@localhost   # setup TERM
kitty +kitten ssh root@localhost  # setup TERM
ssh root@localhost
setup-utmp                        # start utmps service
ssh ide@localhost
docker exec -u 0 -it nvide ash
docker exec -u ide -it nvide ash
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
docker tag nvide:0.9.2 ericwq057/nvide:0.9.2
```

### 2. Sign in with your account at hub.docker.com

### 3. Push to docker.io

```sh
docker push ericwq057/nvide:0.9.2
git tag -a 0.9.2 -m "release message."
git push origin 0.9.2
```
