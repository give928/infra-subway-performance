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
{{ range service "database-mysql-master" }}
MYSQL_MASTER_HOST={{ .Address }}
MYSQL_MASTER_PORT={{ .Port }}
{{ end }}
MYSQL_MASTER_DATABASE=subway
MYSQL_MASTER_USERNAME=subway
MYSQL_MASTER_PASSWORD=subway_password
{{ range service "database-mysql-slave" }}
MYSQL_SLAVE_HOST={{ .Address }}
MYSQL_SLAVE_PORT={{ .Port }}
{{ end }}
MYSQL_SLAVE_DATABASE=subway
MYSQL_SLAVE_USERNAME=subway
MYSQL_SLAVE_PASSWORD=subway_password
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
