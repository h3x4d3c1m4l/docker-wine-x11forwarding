FROM ubuntu:16.04

# preparations
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y install wget software-properties-common apt-transport-https openssh-server xauth

# wine
RUN wget -nc https://dl.winehq.org/wine-builds/Release.key
RUN apt-key add Release.key
RUN apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN apt-get update
RUN apt-get -y install --install-recommends winehq-devel

# X11 forwarding
RUN echo 'root:remotex11' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
