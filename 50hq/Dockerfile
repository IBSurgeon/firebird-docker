FROM ubuntu:22.04

ENTRYPOINT ["/entrypoint.sh"]
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive
ARG TZ UTC
WORKDIR /opt/hqbird
ENV PATH=$PATH:/opt/firebird/bin

#RUN locale-gen "en_US.UTF-8" 
RUN apt update \
    && apt install --no-install-recommends -y net-tools libtommath1 libicu70 wget unzip  gettext libncurses5 curl tar openjdk-8-jre jsvc tzdata locales sudo mc xz-utils file libatomic1 \
    && ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0 \
    && locale-gen "en_US.UTF-8"

COPY ep.sh  /entrypoint.sh
COPY start_svc.sh /start_svc.sh
COPY install.sh /install.sh

#COPY ./healthcheck.sh.tpl /healthcheck.sh.tpl
#COPY ./access.properties.tpl /access.properties.tpl

RUN chmod +x /entrypoint.sh
RUN chmod +x /start_svc.sh
RUN chmod +x /install.sh

#CMD ["/bin/bash","-c","/install.sh"]
RUN /install.sh
RUN rm /install.sh
#VOLUME /data /opt/hqbird/conf /opt/hqbird/outdataguard

EXPOSE 3050 3059 8082 8083 8721 8765 40000

#HEALTHCHECK --start-period=30s --interval=15s --timeout=5s --retries=2 CMD /healthcheck.sh
