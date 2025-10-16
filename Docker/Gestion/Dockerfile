FROM debian:13.1-slim

LABEL autor="matyas-cyril"

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y man-db htop db-util locate gettext-base systemctl

RUN apt-get install -y --no-install-recommends iproute2 netcat-traditional telnet rlwrap \
     inetutils-ping dnsutils swaks tree rlwrap vim vim-common sasl2-bin rsyslog rsyslog-doc

RUN apt-get autoremove -y

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

COPY --chown=root:root rsyslog.conf /etc/rsyslog.conf

RUN echo 'while [ 1 ]; do sleep 1 ;done;' > /loop_inf.sh && chmod +x /loop_inf.sh

CMD systemctl restart rsyslog.service && \
    /loop_inf.sh
