FROM phusion/baseimage:latest

ENV CONSUL_TEMPLATE_VERSION 0.15.0

RUN apt-get update && apt-get install -y \
    nginx \
    nginx-extras \
    wget \
    curl \
    unzip

RUN unlink /etc/nginx/sites-enabled/default

RUN  wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && mv consul-template /usr/local/bin \
  && rm -f consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run
RUN chmod a+x /etc/service/nginx/run

ADD nginx-sites-available/health-check.conf /etc/nginx/sites-enabled/health-check.conf
ADD nginx-sites-available/not-found.conf /etc/nginx/sites-enabled/not-found.conf
ADD nginx.conf /etc/nginx/nginx.conf

RUN mkdir /etc/service/consul-template
ADD consul-template.sh /etc/service/consul-template/run
RUN chmod a+x /etc/service/consul-template/run
RUN touch /var/log/consul-template

RUN mkdir -p /etc/consul-template.d/config
RUN mkdir -p /etc/consul-template.d/templates
ADD consul-template-config.hcl /etc/consul-template.d/config/config.hcl
COPY nginx-sites-available-templates/app-proxied.conf.ctmpl /etc/consul-template.d/templates/app-proxied.conf.ctmpl

COPY apps.consul-wildcard.cert /ssl/apps.consul-wildcard.cert
COPY apps.consul-wildcard.key /ssl/apps.consul-wildcard.key

EXPOSE 80 443

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/sbin/my_init"]
