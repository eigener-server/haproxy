FROM haproxy:1.7.5

RUN apt-get update && \
    apt-get -y --no-install-recommends install ssl-cert && \
    apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/*

ENV HAPROXY_ADMIN_USER=admin
ENV HAPROXY_ADMIN_PASSWORD=eigenerserver
ENV HAPROXY_ADMIN_USER_IP=192.168.1.0/24

COPY haproxy.cfg /tmp/haproxy.cfg

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/*

VOLUME ["/host/haproxy"]

ENTRYPOINT ["/bin/bash", "/usr/local/bin/run.sh"]
CMD ["haproxy", "-f", "/host/haproxy/config/haproxy.cfg"]
