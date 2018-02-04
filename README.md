# Unbound
[Unbound](https://github.com/NLnetLabs/unbound) is a very secure validating, recursive and caching DNS server. Documentation and more information can be found at the home page [https://www.unbound.net](https://www.unbound.net)

## FEATURES
Current docker image is built from [alpine](https://hub.docker.com/_/alpine/) with DNSCrypt, DNSSEC, prefetching and no logs. The number of threads is automatically adjusted. Qname minimisation and  0x20-encoded random bits are enabled by default. Root hints file is updated every time container starts.

## USAGE
[Default](https://github.com/radarlog/docker-unbound/blob/master/unbound.conf) config file is extendable by mounting additional *.conf files to `/usr/local/etc/unbound/conf.d/` folder. Files prefix must match the corresponding section name in the config file to be included in.

```shell
docker run -p 53:53/udp radarlog/unbound
```
