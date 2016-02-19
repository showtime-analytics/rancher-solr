FROM showtimeanalytics/rancher-jvm8:0.0.2
MAINTAINER Alberto Gregoris <alberto@showtimeanalytics.com>

#RUN apk update && apk add lsof && rm /var/cache/apk/*
RUN apk update && apk add sed lsof && rm /var/cache/apk/*

ENV SOLR_UID 8983

ENV SOLR_ROOT /opt/solr
ENV SOLR_VERSION 5.4.1
ENV SOLR_INCLUDE /var/solr/solr.in.sh

RUN curl -sS -k http://mirrors.whoishostingthis.com/apache/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz  | gunzip -c - | tar -xf - -C /opt && \
  ln -s /opt/solr-$SOLR_VERSION ${SOLR_ROOT} && \
  mkdir -p /opt/solr/server/solr/lib && \
  mkdir -p /var/solr/data && \
  mkdir -p /var/solr/logs && \
  cp /opt/solr/server/resources/log4j.properties /var/solr/log4j.properties

# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start and restart scripts
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

WORKDIR ${SOLR_ROOT}

ENTRYPOINT ["/usr/bin/start.sh"]
