job "infra-proxy-apps" {

  datacenters = ["dc1"]

  constraint {
    attribute = "${meta.oe_tag}"
    value = "infra"
  }

  update {
    max_parallel = 1
    stagger = "30s"
  }

  group "infra-proxy-group" {
    constraint {
      distinct_hosts = true
    }
    count = 2

    task "infra-proxy-apps" {
      driver = "raw_exec"

      artifact {
        source = "https://raw.githubusercontent.com/FRosner/nomad-docker-wrapper/1.2.1/nomad-docker-wrapper"
      }

      env {
        NOMAD_DOCKER_CONTAINER_NAME = "infra-proxy-apps"
        NOMAD_DOCKER_PULL_COMMAND = "pliguori/consul-webproxy:latest"
      }

      config {
        command = "nomad-docker-wrapper"
        args = ["--net", "host",
                "-v", "/etc/ssl/certs:/etc/ssl/certs",
                "-v", "/usr/share/ca-certificates:/usr/share/ca-certificates",
                "-v", "/infra01/jobs/infra-proxy-apps/auth_basic:/auth_basic",
                "pliguori/consul-webproxy:latest"]
      }

      resources {
        cpu = 4096
        memory = 2048
        network {
          mbits = 20
          port "nginx" { static = 443 }
        }
      }

      service {
        name = "infra-proxy-apps"
        port = "nginx"
      }
    }
  }
}
