FROM certbot/certbot 

RUN pip --no-cache-dir install awscli \
  && apk --no-cache add jq bash

ADD build/authenticator.sh /
ADD build/cleanup.sh /
ADD build/docker-entrypoint.sh /

RUN chmod +x /authenticator.sh /cleanup.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]