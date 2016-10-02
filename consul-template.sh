#!/bin/sh

echo "Starting consul-template daemon "
exec /usr/local/bin/consul-template -config=/etc/consul-template.d/config > /var/log/consul-template 2>&1
