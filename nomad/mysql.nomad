job "database" {
  datacenters = ["dc1"]
  type        = "service"

  group "database" {
    count = 1

    network {
      port "mysql-master" {
        to = 3306
        static = 3306
      }
      port "mysql-slave" {
        to = 3306
        static = 3307
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql-master" {
      driver = "docker"

      service {
        name = "database-mysql-master"
        tags = ["global", "database", "mysql"]
        port = "mysql-master"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env = {
        "MYSQL_REPLICATION_MODE"     = "master"
        "MYSQL_REPLICATION_USER"     = "repl_user"
        "MYSQL_REPLICATION_PASSWORD" = "repl_password"
        "MYSQL_DATABASE"             = "subway"
        "MYSQL_USER"                 = "subway"
        "MYSQL_PASSWORD"             = "subway_password"
        "MYSQL_ROOT_PASSWORD"        = "root_password"
      }

      config {
        image   = "docker.io/bitnami/mysql:8.0"
        ports   = ["mysql-master"]
        volumes = [
          "../../../data/mysql:/var/lib/mysql"
        ]
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }
    }

    task "mysql-slave" {
      driver = "docker"

      service {
        name = "database-mysql-slave"
        tags = ["global", "database", "mysql"]
        port = "mysql-slave"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      template {
        data        = <<EOF
MYSQL_REPLICATION_MODE=slave
MYSQL_REPLICATION_USER=repl_user
MYSQL_REPLICATION_PASSWORD=repl_password
MYSQL_DATABASE=subway
MYSQL_USER=subway
MYSQL_PASSWORD=subway_password
MYSQL_MASTER_ROOT_PASSWORD=root_password
{{ range service "database-mysql-master" }}
MYSQL_MASTER_HOST={{ .Address }}
MYSQL_MASTER_PORT_NUMBER={{ .Port }}
{{ end }}
EOF
        destination = "local/env"
        env         = true
      }

      config {
        image = "docker.io/bitnami/mysql:8.0"
        ports = ["mysql-slave"]
      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }
    }
  }
}
