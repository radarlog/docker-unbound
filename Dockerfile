FROM alpine:3.12

LABEL maintainer="Ilian Ranguelov <me@radarlog.net>"

ENV BUILD_DEPS expat-dev gcc make musl-dev libevent-dev openssl-dev shadow
ENV RUNTIME_DEPS curl expat libevent openssl

ENV UNBOUND_VERSION 1.12.0
ENV UNBOUND_SHA1 68009078d5f5025c95a8c9fe20b9e84335d53e2d
ENV UNBOUND_DOWNLOAD_URL https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz

RUN set -e \
    && cd /tmp \
    #
    # Install dependencies
    && apk --no-cache add --update $RUNTIME_DEPS $BUILD_DEPS \
    #
    # Download and extract unbound
    && curl -o unbound.tar.gz -fSL ${UNBOUND_DOWNLOAD_URL} \
    && echo "${UNBOUND_SHA1} *unbound.tar.gz" | sha1sum -c - \
    && tar zxvf unbound.tar.gz \
    && cd unbound-${UNBOUND_VERSION} \
    #
    # Build unbound
    && ./configure \
       --with-libevent \
       --with-pthreads \
       --enable-event-api \
    && make install \
    #
    # Create custom user
    && groupadd unbound \
    && useradd -g unbound -d /dev/null unbound \
    #
    # Clean up
    && apk del --purge $BUILD_DEPS \
    && rm -rf /tmp/* /var/cache/apk/*

VOLUME /usr/local/etc/unbound/keys

EXPOSE 53/udp 53/tcp

COPY entrypoint.sh /bin/entrypoint.sh
COPY unbound.conf /usr/local/etc/unbound/

ENTRYPOINT ["entrypoint.sh"]
CMD ["unbound", "-d"]
