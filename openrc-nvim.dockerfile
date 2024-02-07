# https://github.com/gliderlabs/docker-alpine/issues/437
# https://github.com/neeravkumar/dockerfiles/blob/master/alpine-openrc/Dockerfile
# https://github.com/robertdebock/docker-alpine-openrc/blob/master/dockerfiles
#
# https://github.com/dockage/alpine/blob/main/3.17/Dockerfile
#
FROM nvide:0.8.4
LABEL maintainer="ericwq057@qq.com"
LABEL build_date="2023-12-21"

# ENV container=docker

ARG ROOT_PWD=inject_from_args
ARG USER_PWD=inject_from_args
ARG SSH_PUB_KEY
ARG HOME=/home/ide

USER ide:develop
WORKDIR $HOME

# setup ssh for user ide
# setup public key login for normal user
#
RUN mkdir -p $HOME/.ssh \
	&& chmod 0700 $HOME/.ssh \
	&& echo "$SSH_PUB_KEY" > $HOME/.ssh/authorized_keys

USER root

# Enable init.
RUN apk add --update --no-cache openssh-server openrc utmps mandoc man-pages ncurses-doc ncurses rsyslog rsyslog-openrc \
	&& apk add --no-cache --virtual .build-dependencies uuidgen \
	&& uuidgen -r > /etc/machine-id \
	# Disable getty's
	&& sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
	&& sed -i \
	# Change subsystem type to "docker"
	-e 's/#rc_sys=".*"/rc_sys="docker"/g' \
	# Allow all variables through
	-e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
	# Start crashed services
	-e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
	-e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
	# Define extra dependencies for services
	-e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
	/etc/rc.conf \
	# Remove unnecessary services
	&& rm -f /etc/init.d/hwdrivers \
	/etc/init.d/hwclock \
	/etc/init.d/hwdrivers \
	/etc/init.d/modules \
	/etc/init.d/modules-load \
	/etc/init.d/machine-id \
	/etc/init.d/modloop \
	# Can't do cgroups
	&& sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
	&& sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
	&& apk del .build-dependencies

# enable sshd, permit root login, enable port 22, generate ssh key.
#
RUN rc-update add sshd boot \
	&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
	&& sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
	# && echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
	&& ssh-keygen -A \
	# && adduser ide wheel \
	&& rm -rf /var/cache/apk/*

# enable rsyslog 
#
# How do I match any character across multiple lines in a regular expression?
# https://stackoverflow.com/questions/159118/how-do-i-match-any-character-across-multiple-lines-in-a-regular-expression
#
# GNU sed live editor - JS.ORG
# https://sed.js.org/
#
RUN rc-update add rsyslog boot \
   # H;1h;$!d;x; slurps the file into memory
	&& sed -i \
	'H;1h;$!d;x; s/#module.*imudp\(.*\)514\(.*\)#)/module(load="imudp")\ninput(type="imudp" port="514")/g' \
	/etc/rsyslog.conf

# enable root login, for debug dockerfile purpose.
# set root password
# set ide password
# set root public key login
RUN mkdir -p /root/.ssh \
	&& chmod 0700 /root/.ssh \
	&& echo "root:${ROOT_PWD}" | chpasswd \
	&& echo "ide:${USER_PWD}" | chpasswd \
	&& echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys

# setup utmp
# the following script doesn't work for image build.
# you need to run it in container and reboot it again.
#
# https://stackoverflow.com/questions/30716937/dockerfile-build-possible-to-ignore-error
# RUN setup-utmp -y || true

VOLUME ["/sys/fs/cgroup"]

# change the ssh hello message
#
COPY ./conf/motd 		/etc/motd

EXPOSE 22
# EXPOSE 6060
EXPOSE 60000/udp
EXPOSE 60001/udp
EXPOSE 60002/udp
EXPOSE 60003/udp

# setup time zone
# RUN echo "export TZ=Asia/Shanghai" >> /etc/profile

# start open-rc
#
ENTRYPOINT ["/sbin/init"]
