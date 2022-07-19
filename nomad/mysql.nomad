job "database" {
  datacenters = ["dc1"]
  type        = "service"

  group "database" {
    count = 1

    network {
      port "mysql" {
        to = 3306
      }
    }

    service {
      name = "database-mysql"
      tags = ["global", "database", "mysql"]
      port = "mysql"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql" {
      driver = "docker"

      env = {
        "MYSQL_ROOT_PASSWORD" = "password1!"
        "MYSQL_DATABASE"      = "subway"
        "TZ"                  = "Asia/Seoul"
      }

      config {
        image   = "mysql"
        ports   = ["mysql"]
        volumes = [
          "../../../data/mysql:/var/lib/mysql"
        ]
      }

      resources {
        cpu    = 500 # MHz
        memory = 1024 # MB
      }
    }
  }
}
