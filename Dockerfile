FROM debian:trixie-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    gettext \
    libboost-system-dev \
    libbz2-dev \
    libssl-dev \
    pkg-config \
    zlib1g-dev

# eiskaltdcpp
RUN curl -L https://github.com/eiskaltdcpp/eiskaltdcpp/archive/697db4b03e3d9ffa48b3d4c74fd043dee7663266.tar.gz | tar xz -C /tmp
RUN mv /tmp/eiskaltdcpp-697db4b03e3d9ffa48b3d4c74fd043dee7663266 /tmp/eiskaltdcpp-master
RUN mkdir -p /tmp/eiskaltdcpp-master/builddir
RUN cd /tmp/eiskaltdcpp-master/builddir \
 && cmake -DCMAKE_BUILD_TYPE=Release \
          -DUSE_QT=OFF \
          -DUSE_QT5=OFF \
          -DNO_UI_DAEMON=ON \
          -DLUA_SCRIPT=OFF \
          -DUSE_MINIUPNP=OFF \
          -DFREE_SPACE_BAR_C=OFF \
          -DWITH_EMOTICONS=OFF \
          -DWITH_EXAMPLES=OFF \
          -DWITH_LUASCRIPTS=OFF \
          -DWITH_SOUNDS=OFF \
          -DPERL_REGEX=OFF \
          -DUSE_IDN2=OFF \
          -DJSONRPC_DAEMON=ON \
          -DBUILD_STATIC=ON \
          ..
RUN cd /tmp/eiskaltdcpp-master/builddir \
 && make

# icecult + webserver
RUN curl -L https://github.com/kraiz/icecult/archive/master.tar.gz | tar xz -C /tmp
RUN curl -L https://caddyserver.com/download/linux/amd64?license=personal | tar xz -C /bin

# forego - process manager
RUN curl https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz | tar xz -C /bin


# -----------------------------------------------------------------------------
# production image:
# -----------------------------------------------------------------------------
FROM debian:trixie-slim
COPY --from=builder /tmp/eiskaltdcpp-master/builddir/eiskaltdcpp-daemon/eiskaltdcpp-daemon \
                    /bin/forego \
                    /bin/caddy \
                    /bin/
COPY --from=builder /tmp/icecult-master/app /opt/icecult

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    iproute2 \
    libboost-system1.55.0

ADD ./Procfile /
ADD ./Caddyfile /

EXPOSE 80/tcp 7000/udp

CMD ["/bin/forego", "start"]
