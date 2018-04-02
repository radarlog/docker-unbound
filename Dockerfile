FROM alpine:3.7

MAINTAINER Ilian Ranguelov <me@radarlog.net>

ENV BUILD_DEPS make gcc musl-dev ldns-dev libevent-dev expat-dev shadow libsodium-dev
ENV RUNTIME_DEPS bash libevent libsodium libressl expat curl

ENV UNBOUND_VERSION 1.7.0
ENV UNBOUND_SHA1 d90b09315c75ad2843b868785b3d12a2c4f27b28
ENV UNBOUND_DOWNLOAD_URL https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz

RUN set -e \
    && cd /tmp \
    #
    # Install dependencies
    && apk --no-cache add --update $RUNTIME_DEPS $BUILD_DEPS \
    #
    # Download and extract
    && curl -o unbound.tar.gz -fSL ${UNBOUND_DOWNLOAD_URL} \
    && echo "${UNBOUND_SHA1} *unbound.tar.gz" | sha1sum -c - \
    && tar zxvf unbound.tar.gz \
    && cd unbound-${UNBOUND_VERSION} \
    #
    # Build
    && ./configure \
       --with-libevent \
       --enable-event-api \
       --enable-dnscrypt \
    && make install \
    #
    # Create custom user
    && groupadd unbound \
    && useradd -g unbound -d /dev/null unbound \
    #
    # Clean up
    && apk del --purge $BUILD_DEPS \
    && rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /bin/entrypoint.sh
COPY unbound.conf /usr/local/etc/unbound/

EXPOSE 53/udp 53/tcp
EXPOSE 443/udp 443/tcp

VOLUME /usr/local/etc/unbound/keys

ENTRYPOINT ["entrypoint.sh"]
CMD ["unbound", "-d"]
