FROM alpine:latest
LABEL maintainer="Vivek Gite webmater@cyberciti.biz"
RUN apk add --update --no-cache openssh 
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN adduser -h /home/vivek -s /bin/sh -D vivek
RUN echo -n 'vivek:some_password_here' | chpasswd
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
COPY entrypoint.sh /
