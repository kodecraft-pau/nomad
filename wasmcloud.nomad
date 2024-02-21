job "wasmcloud-job" {
  datacenters = ["dc1"]

  group "nats" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "client" {
        static = 4222
      }

      port "monitoring" {
        static = 8222
      }
    }

    task "runtime" {
      driver = "docker"

      config {
        image = "nats:2.9"

        args = [
          "-n=nats",
          "-m", "${NOMAD_PORT_monitoring}",
          "-js"
        ]

        ports = ["client", "monitoring"]
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 512 # 128MB
      }

      service {
        name = "nats"
        provider = "consul"
        port = "client"
        tags = ["faas"]

        check {
          type     = "http"
          port     = "monitoring"
          path     = "/healthz"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }

  group "wasmcloud" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        static = 4000
      }
    }

    service {
      name = "wasmcloud"
      provider = "consul"
      tags = ["faas"]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "nats"
              local_bind_port  = 4222
            }
          }
        }
      }
    }

    task "runtime" {
      driver = "docker"

      env {
        WASMCLOUD_RPC_HOST      = "${NOMAD_UPSTREAM_IP_nats}"
        WASMCLOUD_CTL_HOST      = "${NOMAD_UPSTREAM_IP_nats}"
        WASMCLOUD_PROV_RPC_HOST = "${NOMAD_UPSTREAM_IP_nats}"
        WASMCLOUD_RPC_PORT      = "${NOMAD_UPSTREAM_PORT_nats}"
        WASMCLOUD_CTL_PORT      = "${NOMAD_UPSTREAM_PORT_nats}"
        WASMCLOUD_PROV_RPC_PORT = "${NOMAD_UPSTREAM_PORT_nats}"
        WASMCLOUD_RPC_TIMEOUT_MS = "10000"
        WASMCLOUD_ALLOW_FILE_LOAD = "true"
      }

      config {
        image = "louiaduc/wasmcloud-ubuntu:latest"
      }
    }
  }
}
