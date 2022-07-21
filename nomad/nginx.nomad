job "nginx" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
    }

    service {
      name = "nginx-https"
      tags = ["global", "nginx"]
      port = "https"
    }

    service {
      name = "nginx-http"
      tags = ["global", "nginx"]
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"
        ports = ["https", "http"]

        volumes = [
          "local/nginx.conf:/etc/nginx/nginx.conf",
          "local/cert.pem:/etc/nginx/cert.pem",
          "local/key.pem:/etc/nginx/key.pem",
          "local/conf.d:/etc/nginx/conf.d"
        ]
      }

      template {
        data = <<EOF
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
  worker_connections  2048;
}

http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  access_log  /var/log/nginx/access.log  main;

  sendfile        on;
  #tcp_nopush     on;

  keepalive_timeout  65;

  #gzip  on;
  gzip on;
  gzip_disable "msie6";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 9;
  gzip_buffers 16 8k;
  gzip_http_version 1.1;
  gzip_min_length 256;
  gzip_types text/plain text/css application/json application/x-javascript application/javascript text/xml application/xml application/rss+xml text/javascript image/svg+xml application/vnd.ms-fontobject application/x-font-ttf font/opentype;

  ## Proxy 캐시 파일 경로, 메모리상 점유할 크기, 캐시 유지기간, 전체 캐시의 최대 크기 등 설정
  proxy_cache_path /etc/nginx/cache levels=1:2 keys_zone=cache_zone:32m inactive=10m max_size=256m;

  ## 캐시를 구분하기 위한 Key 규칙
  proxy_cache_key "$scheme$host$request_uri $cookie_user";

  include /etc/nginx/conf.d/*.conf;
}
EOF

        destination   = "local/nginx.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
upstream backend {
{{ range service "subway" }}  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502{{ end }}}

# Redirect all traffic to HTTPS
server {
  listen 80;
  server_name give928.asuscomm.com;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  server_name give928.asuscomm.com;

  ssl_certificate /etc/nginx/cert.pem;
  ssl_certificate_key /etc/nginx/key.pem;

  # Disable SSL
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  # 통신과정에서 사용할 암호화 알고리즘
  ssl_prefer_server_ciphers on;
  ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

  # Enable HSTS
  # client의 browser에게 http로 어떠한 것도 load 하지 말라고 규제합니다.
  # 이를 통해 http에서 https로 redirect 되는 request를 minimize 할 수 있습니다.
  add_header Strict-Transport-Security "max-age=31536000" always;

  # SSL sessions
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  location / {
    proxy_pass http://backend;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
  }

  location ~* \.(?:css|js|gif|png|jpg|jpeg)$ {
    proxy_pass http://backend;

    ## 캐시 설정 적용 및 헤더에 추가
    # 캐시 존을 설정 (캐시 이름)
    proxy_cache cache_zone;
    # X-Proxy-Cache 헤더에 HIT, MISS, BYPASS와 같은 캐시 적중 상태정보가 설정
    add_header X-Proxy-Cache $upstream_cache_status;
    # 200 302 코드는 10분간 캐싱
    proxy_cache_valid 200 302 10m;
    # 만료기간을 1 달로 설정
    expires 1M;
    # access log 를 찍지 않는다.
    access_log off;
  }
}
EOF

        destination   = "local/conf.d/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        source        = "../../../data/nginx/cert.pem"
        destination   = "local/cert.pem"
        change_mode   = "signal"
        change_signal = "SIGINT"
      }

      template {
        source        = "../../../data/nginx/key.pem"
        destination   = "local/key.pem"
        change_mode   = "signal"
        change_signal = "SIGINT"
      }

      resources {
        cpu    = 2000 # MHz
        memory = 2048 # MB
      }
    }
  }
}
