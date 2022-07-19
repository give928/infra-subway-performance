job "subway" {
  datacenters = ["dc1"]
  type        = "service"

  group "subway" {
    count = 1

    update {
      max_parallel     = 1
      min_healthy_time = "10s"
      healthy_deadline = "1m"
    }

    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "subway"
      tags = ["global", "subway"]
      port = "http"

      check {
        type     = "http"
        path     = "/actuator/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "subway" {
      driver = "docker"

      template {
        data        = <<EOF
{{ range service "cache-redis" }}
SPRING_REDIS_HOST={{ .Address }}
SPRING_REDIS_PORT={{ .Port }}
{{ end }}
{{ range service "database-mysql" }}
MYSQL_HOST={{ .Address }}
MYSQL_PORT={{ .Port }}
{{ end }}
MYSQL_DATABASE=subway
MYSQL_USERNAME=root
MYSQL_PASSWORD=password1!
EOF
        destination = "local/env"
        env         = true
      }

      config {
        image = "give928/infra-subway-performance:0.0.1"
        ports = ["http"]
      }

      resources {
        cpu    = 2000 # MHz
        memory = 4096 # MB
      }
    }
  }
}
