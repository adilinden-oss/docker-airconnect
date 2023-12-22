FROM debian:bookworm-slim as builder

RUN apt-get update -qy && \
    apt-get -qy install build-essential git openssl libssl-dev

WORKDIR /root
RUN set -i; GIT_CURL_VERBOSE=1 git clone --depth=1 https://github.com/philippe44/AirConnect.git && \
    cd ~/AirConnect && \
    set -i; GIT_CURL_VERBOSE=1 git submodule update --init --depth=1
RUN cd ~/AirConnect/airupnp && make
RUN cd ~/AirConnect/aircast && make

###

FROM debian:bookworm-slim

RUN apt-get update -qy && \
    apt-get -qy install libssl3 libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root
COPY aircast.xml /etc/aircast.xml
COPY --from=builder /root/AirConnect/bin/aircast-linux-x86_64 /usr/bin/aircast
COPY --from=builder /root/AirConnect/bin/airupnp-linux-x86_64 /usr/bin/airupnp

CMD ["aircast", "-Z", "-x", "/etc/aircast.xml"]

# docker build --tag 'adilinden/aircast' .
# docker run -it --rm adilinden/aircast
# docker push adilinden/aircast
