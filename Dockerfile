############
# OS setup #
############

FROM ubuntu:18.04

ENV GAME_URL "http://rocksmith.ubi.com/rocksmith/en-US/home/index.aspx"
ENV STEAM_APPID "221680"

# branches are: stable staging devel
ENV WINEBRANCH "devel"

ENV GOSU_VERSION "1.11"
ENV MONO_VER "4.9.4"
ENV GECKO_VER "2.47.1"
ENV USER_ID "1000"
ENV GROUP_ID "1000"

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
ENV DEBIAN_FRONTEND noninteractive

## Basic setup
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends gnupg curl ca-certificates pulseaudio-utils pavucontrol software-properties-common


## Setup GOSU to match user and group ids
##
## User: user
## Pass: 123
##
## Note that this setup also relies on entrypoint.sh
## Set LOCAL_USER_ID as an ENV variable at launch or the default uid 9001 will be used
## Set LOCAL_GROUP_ID as an ENV variable at launch or the default uid 250 will be used
## (e.g. docker run -e LOCAL_USER_ID=151149 ....)
##
## Initial password for user will be 123
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    curl --fail --show-error --silent --location --output /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" && \
    curl --fail --show-error --silent --location --output /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -fr "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

RUN addgroup --gid $GROUP_ID userg
RUN useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m user && \
    usermod -a -G audio user

##############
# Wine setup #
##############

## Add wine repository
RUN curl --fail --show-error --silent --location https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    curl --fail --show-error --silent --location https://dl.winehq.org/wine-builds/Release.key | apt-key add - && \
    apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
    add-apt-repository ppa:cybermax-dexter/sdl2-backport && \
    apt-get update && \
    apt-get -y install --install-recommends winehq-${WINEBRANCH} cabextract && \
    apt-get remove -y software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl --fail --show-error --silent --location --output /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/bin/winetricks

ENV HOME /home/user
RUN chown -R $USER_ID:$GROUP_ID $HOME
RUN echo 'user:123' | chpasswd

# ENV WINEPREFIX /home/user
VOLUME /home/wineuser

COPY pulse-client.conf /etc/pulse/client.conf

## Make sure the user inside the docker has the same ID as the user outside
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
