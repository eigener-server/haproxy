FROM haproxy:1.7.5

RUN apt-get update && \
    apt-get -y --no-install-recommends install ssl-cert && \
    apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir -p /host/haproxy/config /host/haproxy/certs 
    
COPY haproxy.cfg /tmp/haproxy.cfg

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/bin/bash","/usr/local/bin/run.sh"]
CMD ["haproxy", "-f", "/host/haproxy/config/haproxy.cfg"]
