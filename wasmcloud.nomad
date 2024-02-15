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
        port = "client"
        name = "nats"
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
}
