" build it
% docker build -t nvide:0.7.0 -f nvim.dockerfile .
% docker build --progress plain -t nvide:0.7.0 -f nvim.dockerfile .
% docker build --no-cache --progress plain -t nvide:0.7.0 -f nvim.dockerfile .

" dryrun the container
% docker run --rm -ti nvide:0.7.0

" Share images on Docker Hub
" 1. Tag the image correctly

% docker tag nvide:0.7.0 ericwq057/nvide:0.7.0

" 2. sign in with your account at hub.docker.com
" 3. Push to docker.io

% docker push ericwq057/nvide:0.7.0

" start the container
% docker run -it -d -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.7.0

% docker run --rm -ti -h nvide --env TZ=Asia/Shanghai --name nvide \
        --mount source=proj-vol,target=/home/ide/proj \
        --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
        nvide:0.7.0

" loing to the containter
% docker exec -u 0 -it nvide ash
% docker exec -u ide -it nvide ash

" attach / mirror the container
% docker attach nvide
