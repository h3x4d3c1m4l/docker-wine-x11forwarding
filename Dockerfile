FROM ubuntu:16.04

# inspired by webanck/docker-wine-steam

# preparations
WORKDIR /tmp
ENV DEBIAN_FRONTEND noninteractive
ENV WINEDEBUG -all
ENV WINEPREFIX /home/wineuser/.wine
ENV WINEARCH win32

	# activate i386 arch for Wine and install stuff we need
RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -qy upgrade && apt-get -qy install wget software-properties-common apt-transport-https openssh-server xauth cabextract winbind squashfs-tools xvfb x11vnc xserver-xephyr websockify dbus-x11 pulseaudio sudo xserver-xorg-video-dummy x11-apps xfce4 && \
	
	# install latest Wine and Xpra
	wget -qO- https://dl.winehq.org/wine-builds/Release.key | apt-key add - && \
	apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
	wget -qO- http://winswitch.org/gpg.asc | apt-key add - && \
	apt-add-repository http://winswitch.org/ && \
	apt-get update && apt-get -qy install --install-recommends winehq-devel xpra && \

	# make sshd work and enable X11 forwarding
	mkdir /var/run/sshd && \
	sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
	echo "X11Forwarding yes\n" >> /etc/ssh/ssh_config && \
	echo "ForwardX11Trusted yes\n" >> /etc/ssh/ssh_config && \

	# create our user for Wine
	useradd -m -s /bin/bash -G xpra,sudo,tty,video,dialout wineuser && echo 'wineuser:remotex11' | chpasswd && \

	# winetricks
	wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /tmp/winetricks && \
	chmod +x /tmp/winetricks && \
	su -p -l wineuser -c 'xvfb-run -a /tmp/winetricks -q corefonts dotnet462' && \
	
	# Cleaning up.
	apt-get autoremove -y --purge software-properties-common && \
	apt-get autoremove -y --purge xvfb && \
	apt-get autoremove -y --purge && \
	apt-get clean -y && \
	rm -rf /home/wine/.cache && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
