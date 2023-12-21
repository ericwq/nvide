FROM ericwq057/nvide:0.8.2
LABEL maintainer="ericwq057@qq.com"

# Arguement for passwords and ssh public key
#
ARG ROOT_PWD=nvide_root
ARG USER_PWD=develope
ARG SSH_PUB_KEY

ENV HOME=/home/ide

USER ide:develop
WORKDIR $HOME

# setup ssh for user ide
# setup ide public key login
#
RUN mkdir -p $HOME/.ssh \
	&& chmod 0700 $HOME/.ssh \
	&& echo "$SSH_PUB_KEY" > $HOME/.ssh/authorized_keys

USER root

# SSH related packages and configuration
# allow root login
# set sshd port 22
# set sudo user ide privilige
# generarte SSH server key pairs
#
# RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main ca-certificates curl
RUN apk add --no-cache openssh sudo mosh-server mandoc man-pages ncurses-doc ncurses --update \
	&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
	&& sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
	&& echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
	&& ssh-keygen -A \
	&& adduser ide wheel \
	&& rm -rf /var/cache/apk/*

# enable root login, for debug dockerfile purpose.
# set root password
# set ide password
# set root public key login
RUN mkdir -p /root/.ssh \
	&& chmod 0700 /root/.ssh \
	&& echo "root:${ROOT_PWD}" | chpasswd \
	&& echo "ide:${USER_PWD}" | chpasswd \
	&& echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys

# change the ssh hello message
#
COPY ./conf/motd 		/etc/motd

EXPOSE 22
EXPOSE 60001/udp

CMD ["/usr/sbin/sshd", "-D"]
