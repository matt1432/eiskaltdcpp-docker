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
RUN curl -L https://github.com/NikitaBeloglazov/icecult-reborn/archive/1b80d69e0446aa46df01980986f27c79cd34e281.tar.gz | tar xz -C /tmp
RUN mv /tmp/icecult-reborn-1b80d69e0446aa46df01980986f27c79cd34e281 /tmp/icecult-master
RUN curl -L https://github.com/caddyserver/caddy/releases/download/v2.11.3/caddy_2.11.3_linux_amd64.tar.gz | tar xz -C /bin caddy

FROM golang:1.22 AS forego-builder

# forego - process manager
RUN GOPATH="/tmp" go install github.com/ddollar/forego@89fb456a167f59ace41e0e9294f4b7c01f76943e


# -----------------------------------------------------------------------------
# production image:
# -----------------------------------------------------------------------------
FROM debian:trixie-slim
COPY --from=builder /tmp/eiskaltdcpp-master/builddir/eiskaltdcpp-daemon/eiskaltdcpp-daemon \
                    /bin/caddy \
                    /bin/
COPY --from=forego-builder /tmp/bin/forego /bin
COPY --from=builder /tmp/icecult-master/app /opt/icecult

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    iproute2 \
    libboost-system1.55.0

ADD ./Procfile /
ADD ./Caddyfile /

EXPOSE 80/tcp 7000/udp

CMD ["/bin/forego", "start"]
