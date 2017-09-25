FROM ubuntu:16.04

# preparations
RUN echo 'root:remotex11' | chpasswd
RUN dpkg --add-architecture i386
ENV DEBIAN_FRONTEND noninteractive
ENV WINEDEBUG -all
RUN apt-get update && apt-get -qy upgrade && apt-get -qy install wget software-properties-common apt-transport-https openssh-server xauth cabextract winbind squashfs-tools xvfb x11vnc xserver-xephyr websockify dbus-x11 pulseaudio

# wine & xpra
RUN wget -qO- https://dl.winehq.org/wine-builds/Release.key | apt-key add - && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN wget -qO- http://winswitch.org/gpg.asc | apt-key add - && apt-add-repository http://winswitch.org/
RUN apt-get update && apt-get -qy install --install-recommends winehq-devel xpra

# X11 forwarding
RUN mkdir /var/run/sshd
RUN sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "X11Forwarding yes\n" >> /etc/ssh/ssh_config
RUN echo "ForwardX11Trusted yes\n" >> /etc/ssh/ssh_config

# user
RUN useradd -m -s /bin/bash -G xpra,sudo wineuser && echo 'wineuser:remotex11' | chpasswd
USER wineuser
ENV LOGNAME=wineuser
WORKDIR /home/wineuser

# winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && chmod +x winetricks
RUN WINEARCH=win32 USERNAME=wineuser ./winetricks -q dotnet462 corefonts

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
