# 안정적인 서비스 만들기

## 1단계 - 화면 응답 개선하기

### 요구사항
- [ ] 부하테스트 각 시나리오의 요청시간을 목푯값 이하로 개선
  - 개선 전 / 후를 직접 계측하여 확인

### 개선
1. Reverse Proxy 개선하기
   - [x] gzip 압축
     <details>
     <summary>접기/펼치기</summary>

     nginx.conf
     ```
     http {
       gzip on; ## http 블록 수준에서 gzip 압축 활성화
       gzip_comp_level 9;
       gzip_vary on;
       gzip_types text/plain text/css application/json application/x-javascript application/javascript text/xml application/xml application/rss+xml text/javascript image/svg+xml application/vnd.ms-fontobject application/x-font-ttf font/opentype;
     }
     ```
     </details>

   - [x] cache
     <details>
     <summary>접기/펼치기</summary>

     nginx.conf
     ```
     http {
       ## Proxy 캐시 파일 경로, 메모리상 점유할 크기, 캐시 유지기간, 전체 캐시의 최대 크기 등 설정
       proxy_cache_path /tmp/nginx levels=1:2 keys_zone=mycache:10m inactive=10m max_size=200M;
    
       ## 캐시를 구분하기 위한 Key 규칙
       proxy_cache_key "$scheme$host$request_uri $cookie_user";
    
       server {
         location ~* \.(?:css|js|gif|png|jpg|jpeg)$ {
           proxy_pass http://app;
          
           ## 캐시 설정 적용 및 헤더에 추가
           # 캐시 존을 설정 (캐시 이름)
           proxy_cache mycache;
           # X-Proxy-Cache 헤더에 HIT, MISS, BYPASS와 같은 캐시 적중 상태정보가 설정
           add_header X-Proxy-Cache $upstream_cache_status;
           # 200 302 코드는 20분간 캐싱
           proxy_cache_valid 200 302 10m;    
           # 만료기간을 1 달로 설정
           expires 1M;
           # access log 를 찍지 않는다.
           access_log off;
         }
       }
     }
     ```
     </details>

   - [x] TLS, HTTP/2 설정
     <details>
     <summary>접기/펼치기</summary>

     nginx.conf
     ```
     http {
       server {
         listen 80;
         return 301 https://$host$request_uri;
       }
       server {  
         listen 443 ssl http2;
    
         ssl_certificate /etc/letsencrypt/live/[도메인주소]/fullchain.pem;
         ssl_certificate_key /etc/letsencrypt/live/[도메인주소]/privkey.pem;
    
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
       }
     }
     ```
     </details>

   - nginx ssl 설정
     <details>
     <summary>접기/펼치기</summary>
     
     - domain 사용
       - CertBot

         Let's Encrypt 인증서를 자동으로 발급 및 갱신을 해주는 봇 프로그램
         ```shell
         $ cd reverse-proxy/domain
         $ curl -L https://raw.githubusercontent.com/wmnnd/nginx-certbot/master/init-letsencrypt.sh > init-letsencrypt.sh
         $ chmod +x init-letsencrypt.sh
         $ vi init-letsencrypt.sh
         // 도메인, 이메일, 디렉토리 수정
         $ sudo ./init-letsencrypt.sh // 인증서 발급
         $ docker-compose up -d
         ```
       - 설정 파일
         - [nginx.conf](../reverse-proxy/domain/nginx/conf/nginx.conf)
         - [docker-compose](../reverse-proxy/domain/docker-compose.yml)
         - [init-letsencrypt.sh](../reverse-proxy/domain/init-letsencrypt.sh)

     - localhost 사용
       - minica 사용해서 localhost 인증서 생성
         ```shell
         $ cd reverse-proxy/localhost
         $ brew install minica
         $ minica -domains www.localhost,localhost -ip-addresses 127.0.0.1
         $ ls -al
         -rw-------   1 joohokim  staff  1675 Jul  7 23:30 minica-key.pem
         -rw-------   1 joohokim  staff  1204 Jul  7 23:30 minica.pem
         drwx------   4 joohokim  staff   128 Jul  7 23:30 www.localhost
         ```
       - nginx build & run
         ```shell
         $ docker build -t proxy .
         $ docker run -d -p 80:80 -p 443:443 --name proxy proxy
         ```
       - 설정 파일
         - [nginx.conf](../reverse-proxy/localhost/nginx/conf/nginx.conf)
         - [Dockerfile](../reverse-proxy/localhost/Dockerfile)
     </details>
