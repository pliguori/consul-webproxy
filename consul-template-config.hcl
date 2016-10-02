consul = "127.0.0.1:8500"

template {
  source = "/etc/consul-template.d/templates/app-proxied.conf.ctmpl"
  destination = "/etc/nginx/sites-enabled/app-proxied.conf"
  command = "sv reload nginx || true"
}
