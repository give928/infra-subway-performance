job "cache" {
  datacenters = ["dc1"]
  type        = "service"

  group "cache" {
    count = 1

    network {
      port "redis" {
        to = 6379
      }
    }

    service {
      name = "cache-redis"
      tags = ["global", "cache", "redis"]
      port = "redis"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "redis" {
      driver = "docker"

      config {
        image   = "redis"
        ports   = ["redis"]
        volumes = [
          "../../../data/redis:/data"
        ]
      }

      resources {
        cpu    = 500 # MHz
        memory = 1024 # MB
      }
    }
  }
}
