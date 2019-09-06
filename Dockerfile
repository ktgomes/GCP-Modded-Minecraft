FROM openjdk:8u212-jre-alpine

LABEL maintainer kgomes

RUN apk add --no-cache -U \
  openssl \
  imagemagick \
  lsof \
  su-exec \
  shadow \
  bash \
  curl iputils wget \
  git \
  jq \
  mysql-client \
  tzdata \
  rsync \
  nano \
  wget \
  unzip \
  python python-dev py2-pip

RUN pip install mcstatus yq

HEALTHCHECK CMD mcstatus localhost:$SERVER_PORT ping

RUN addgroup -g 1000 minecraft
RUN adduser --disabled-password --home=/data -u 1000 -G minecraft --gecos "minecraft user" minecraft

RUN mkdir /tmp/feed-the-beast && cd /tmp/feed-the-beast && \
 wget -c https://www.curseforge.com/minecraft/modpacks/skyfactory-4/download/2725984/file -O SkyFactory_4_Server.zip && \
 unzip SkyFactory_4_Server.zip && \
 rm SkyFactory_4_Server.zip && \
 /bin/sh Install.sh && \
 chown -R minecraft /tmp/feed-the-beast

RUN echo 'hosts: files dns' > /etc/nsswitch.conf

#COPY start.sh /start.sh
RUN chmod +x /tmp/feed-the-beastServerStart.sh

USER minecraft

VOLUME /data
ADD server.properties /tmp/server.properties
WORKDIR /data

EXPOSE 25565

ENV UID=1000 GID=1000
ENV MOTD "A Minecraft (FTB SkyFactory 4) Server Powered by Docker"
ENV LEVEL world
ENV JVM_OPTS "-Xms2g -Xmx6g" PVP=true 

CMD ["/bin/sh", "/tmp/feed-the-beast/ServerStart.sh"]
