FROM alpine:3.7

MAINTAINER Ilian Ranguelov <me@radarlog.net>

ENV BUILD_DEPS make gcc musl-dev ldns-dev libevent-dev expat-dev shadow libsodium-dev
ENV RUNTIME_DEPS bash libevent libsodium openssl expat curl

# Build dependencies
RUN apk --no-cache add --update $RUNTIME_DEPS $BUILD_DEPS

ENV UNBOUND_VERSION 1.6.8
ENV UNBOUND_SHA1 492737be9647c26ee39d4d198f2755062803b412
ENV UNBOUND_DOWNLOAD_URL https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz

RUN set -e \
    && cd /tmp \
    && curl -o unbound.tar.gz -fSL ${UNBOUND_DOWNLOAD_URL} \
    && echo "${UNBOUND_SHA1} *unbound.tar.gz" | sha1sum -c - \
    && tar zxvf unbound.tar.gz \
    && cd unbound-${UNBOUND_VERSION} \
    && ./configure \
       --with-libevent \
       --enable-event-api \
       --enable-dnscrypt \
    && make install

RUN set -e \
	   && groupadd unbound \
    && useradd -g unbound -d /dev/null unbound

RUN set -e \
    && apk del --purge $BUILD_DEPS \
    && rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /bin/entrypoint.sh
COPY unbound.conf /usr/local/etc/unbound/

EXPOSE 53/udp

ENTRYPOINT ["entrypoint.sh"]
CMD ["unbound", "-d"]
