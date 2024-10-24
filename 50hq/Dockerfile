FROM ubuntu:22.04

ENTRYPOINT ["/entrypoint.sh"]
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive
ARG TZ UTC
ENV PATH=$PATH:/opt/firebird/bin

COPY entrypoint.sh  /entrypoint.sh
COPY install.sh /install.sh

#COPY ./healthcheck.sh.tpl /healthcheck.sh.tpl
#COPY ./access.properties.tpl /access.properties.tpl

RUN chmod +x /entrypoint.sh
RUN chmod +x /install.sh

#CMD ["/bin/bash","-c","/install.sh"]
RUN /install.sh
RUN rm /install.sh
#VOLUME /data /opt/hqbird/conf /opt/hqbird/outdataguard

EXPOSE 3050 3059

#HEALTHCHECK --start-period=30s --interval=15s --timeout=5s --retries=2 CMD /healthcheck.sh
