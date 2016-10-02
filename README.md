# Apps Proxy

## Description

This project contains an [nginx](https://nginx.org/) + [consul-template](https://github.com/hashicorp/consul-template) setup to automatically expose services through a reverse proxy.

## Requirements

- Hashicorp Consul
- Hashicorp Nomad (optional)
- DNS entries to handle the reverse proxy:
  - *.service.consul --> DNS zone delegation to Consul
  - *.apps.consul --> DNS CNAME entry pointing to infra-proxy-apps.service.consul
  - infra-proxy-apps.service.consul --> nginx entry in Consul

For sake of simplicity, the root domain is hardcoded as .consul, but it can be easily parametrized later.


## Usage

Once deployed, there will be reverse proxy listening to `infra-proxy-apps.service.consul`. In the UM DNS there is a wildcard entry mapping `*.apps.consul` to `infra-proxy-apps.service.consul`. Consul template will be looking for services tagged with `app-proxied`. If there is a change in one of the `app-proxied` services, the nginx configuration gets updated and reloaded, making the service available through `<service>.apps.consul`. For services tagged also with `auth_basic` the corresponding configuration lines will be added.

In case you need basic authentication for Tenant1, you can add the `auth_basic_tenant1` tag in addition to `app-proxied` to your service.

**Example**

You run a Nomad job which registers a service called `infra-my-web-ui` at Consul. The service is tagged with `app-proxied`. After the job is started and all health checks for the `infra-my-web-ui` service succeed, you can go to `infra-my-web-ui.apps.consul` to access your web UI.

## Installation

### Using the Docker Image

To start the job, use the nomad job definition. It requires a working version of the docker image in our registry. Also it requires your nomad nodes to be logged into the docker registry.

```
nomad run job.hcl
```


## Building from Source

If you want to build from source, you need to first build the docker image and then push it to the registry.

### Building the Docker Image

The private key of the wildcard certificate should be always encrypted.

The unencrypted key and certificate are required to be present during build time of the image, so they can be injected. To build the image after unencrypting the key, run:

```sh
docker build -t infra-registry.service.consul:5043/apps-proxy .
```

### Pushing to the Docker Registry

```sh
docker login infra-registry.service.consul:5043
docker push infra-registry.service.consul:5043/apps-proxy
```

## Debugging

As nginx and consul-template run inside the same container, they are managed by [runsv](http://smarden.org/runit/sv.8.html).
In order to restart them, you can use the sv commands.
