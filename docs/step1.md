# 안정적인 서비스 만들기

## 1단계 - 화면 응답 개선하기

### 요구사항
- [x] 부하테스트 각 시나리오의 요청시간을 목푯값 이하로 개선
  - [x] k6
    <details>
    <summary>접기/펼치기</summary>
  
    - Smoke Test
      ```
        execution: local
        script: subway-k6-test.js
        output: -
      
        scenarios: (100.00%) 1 scenario, 1 max VUs, 31s max duration (incl. graceful stop):
        * default: 1 looping VUs for 1s (gracefulStop: 30s)
      
      
      running (01.0s), 0/1 VUs, 8 complete and 0 interrupted iterations
      default ✓ [======================================] 1 VUs  1s
      
           ✓ main status was 200
           ✓ join status was 201
           ✓ login status was 200
           ✓ favorite status was 200
           ✓ path status was 200
      
           checks.........................: 100.00% ✓ 40        ✗ 0  
           data_received..................: 25 kB   24 kB/s
           data_sent......................: 5.4 kB  5.2 kB/s
           http_req_blocked...............: avg=4.89ms   min=0s      med=0s      max=195.62ms p(90)=1µs      p(95)=1µs     
           http_req_connecting............: avg=93.87µs  min=0s      med=0s      max=3.75ms   p(90)=0s       p(95)=0s      
         ✓ http_req_duration..............: avg=21.11ms  min=4.96ms  med=13.2ms  max=95.8ms   p(90)=57.41ms  p(95)=63.01ms
             { expected_response:true }...: avg=21.11ms  min=4.96ms  med=13.2ms  max=95.8ms   p(90)=57.41ms  p(95)=63.01ms
           http_req_failed................: 0.00%   ✓ 0         ✗ 40
           http_req_receiving.............: avg=33µs     min=8µs     med=34µs    max=134µs    p(90)=45.1µs   p(95)=54.19µs
           http_req_sending...............: avg=74.52µs  min=24µs    med=51.5µs  max=620µs    p(90)=95.3µs   p(95)=126.04µs
           http_req_tls_handshaking.......: avg=556.75µs min=0s      med=0s      max=22.27ms  p(90)=0s       p(95)=0s      
           http_req_waiting...............: avg=21.01ms  min=4.86ms  med=13.15ms max=95.69ms  p(90)=57.29ms  p(95)=62.9ms  
           http_reqs......................: 40      38.201803/s
           iteration_duration.............: avg=130.71ms min=53.62ms med=58.17ms max=285.53ms p(90)=276.41ms p(95)=280.97ms
           iterations.....................: 8       7.640361/s
           vus............................: 1       min=1       max=1
           vus_max........................: 1       min=1       max=1
      ```
  
    - Load Test
      ```
        execution: local
        script: subway-k6-test.js
        output: -
      
        scenarios: (100.00%) 1 scenario, 100 max VUs, 1m40s max duration (incl. graceful stop):
        * default: Up to 100 looping VUs for 1m10s over 7 stages (gracefulRampDown: 30s, gracefulStop: 30s)
      
      
      running (1m10.0s), 000/100 VUs, 21998 complete and 0 interrupted iterations
      default ✓ [======================================] 000/100 VUs  1m10s
      
           ✓ main status was 200
           ✓ join status was 201
           ✓ login status was 200
           ✓ favorite status was 200
           ✓ path status was 200
      
           checks.........................: 100.00% ✓ 109990      ✗ 0     
           data_received..................: 57 MB   814 kB/s
           data_sent......................: 13 MB   192 kB/s
           http_req_blocked...............: avg=31.29µs  min=0s      med=0s      max=194.65ms p(90)=1µs      p(95)=1µs     
           http_req_connecting............: avg=6.18µs   min=0s      med=0s      max=16.57ms  p(90)=0s       p(95)=0s      
         ✓ http_req_duration..............: avg=37.69ms  min=2.72ms  med=19.5ms  max=351.42ms p(90)=98.62ms  p(95)=123.52ms
             { expected_response:true }...: avg=37.69ms  min=2.72ms  med=19.5ms  max=351.42ms p(90)=98.62ms  p(95)=123.52ms
           http_req_failed................: 0.00%   ✓ 0           ✗ 109990
           http_req_receiving.............: avg=38.53µs  min=4µs     med=16µs    max=15.67ms  p(90)=58µs     p(95)=101µs   
           http_req_sending...............: avg=48.88µs  min=8µs     med=36µs    max=15.21ms  p(90)=74µs     p(95)=102µs   
           http_req_tls_handshaking.......: avg=23.08µs  min=0s      med=0s      max=46.46ms  p(90)=0s       p(95)=0s      
           http_req_waiting...............: avg=37.6ms   min=0s      med=19.4ms  max=351.32ms p(90)=98.55ms  p(95)=123.43ms
           http_reqs......................: 109990  1570.240405/s
           iteration_duration.............: avg=189.03ms min=37.37ms med=184.2ms max=619.63ms p(90)=326.14ms p(95)=360.64ms
           iterations.....................: 21998   314.048081/s
           vus............................: 11      min=1         max=100
           vus_max........................: 100     min=100       max=100
      ```
  
    - Stress Test
      - 1500 VUs
        ```
        {duration: '10s', target: 10},
        {duration: '10s', target: 1000},
        {duration: '10s', target: 2000},
        {duration: '10s', target: 3000},
        {duration: '10s', target: 3000},
        {duration: '10s', target: 1500},
        {duration: '10s', target: 10},
        ```
        - 모두 성공하지만 요청의 99%가 1.5초 안에 응답해야 하는 임계값 평가에서 실패
        ```
          execution: local
          script: subway-k6-test.js
          output: -
        
          scenarios: (100.00%) 1 scenario, 3000 max VUs, 1m40s max duration (incl. graceful stop):
          * default: Up to 3000 looping VUs for 1m10s over 7 stages (gracefulRampDown: 30s, gracefulStop: 30s)
        
        
        running (1m21.6s), 0000/3000 VUs, 8109 complete and 0 interrupted iterations
        default ↓ [======================================] 1954/3000 VUs  1m10s
        
             ✓ main status was 200
             ✓ join status was 201
             ✓ login status was 200
             ✓ favorite status was 200
             ✓ path status was 200
        
             checks.........................: 100.00% ✓ 40545      ✗ 0     
             data_received..................: 76 MB   935 kB/s
             data_sent......................: 12 MB   148 kB/s
             http_req_blocked...............: avg=66.95ms  min=0s      med=0s     max=1.2s     p(90)=83.01ms p(95)=591.88ms
             http_req_connecting............: avg=1.76ms   min=0s      med=0s     max=97.96ms  p(90)=6.07ms  p(95)=7.12ms  
           ✗ http_req_duration..............: avg=3.41s    min=2.69ms  med=2.46s  max=24.28s   p(90)=8.53s   p(95)=11.39s  
               { expected_response:true }...: avg=3.41s    min=2.69ms  med=2.46s  max=24.28s   p(90)=8.53s   p(95)=11.39s  
             http_req_failed................: 0.00%   ✓ 0          ✗ 40545
             http_req_receiving.............: avg=226.39µs min=5µs     med=52µs   max=22.67ms  p(90)=370µs   p(95)=928µs   
             http_req_sending...............: avg=462.51µs min=10µs    med=56µs   max=959.92ms p(90)=216µs   p(95)=347µs   
             http_req_tls_handshaking.......: avg=65.12ms  min=0s      med=0s     max=1.19s    p(90)=73.74ms p(95)=585.41ms
             http_req_waiting...............: avg=3.41s    min=1.99ms  med=2.46s  max=24.28s   p(90)=8.53s   p(95)=11.39s  
             http_reqs......................: 40545   497.113237/s
             iteration_duration.............: avg=17.38s   min=86.77ms med=17.01s max=46.6s    p(90)=33.04s  p(95)=38.5s   
             iterations.....................: 8109    99.422647/s
             vus............................: 49      min=1        max=3000
             vus_max........................: 3000    min=3000     max=3000
        
        ERRO[0083] some thresholds have failed
        ```
        
      - 600 VUs
        ```
        {duration: '10s', target: 10},
        {duration: '10s', target: 200},
        {duration: '10s', target: 400},
        {duration: '10s', target: 600},
        {duration: '10s', target: 600},
        {duration: '10s', target: 300},
        {duration: '10s', target: 10},
        ```
        - 모두 성공하지만 요청의 99%가 1.5초 안에 응답해야 하는 임계값 평가에서 실패
        ```
          execution: local
          script: subway-k6-test.js
          output: -
        
          scenarios: (100.00%) 1 scenario, 600 max VUs, 1m40s max duration (incl. graceful stop):
          * default: Up to 600 looping VUs for 1m10s over 7 stages (gracefulRampDown: 30s, gracefulStop: 30s)
        
        
        running (1m10.1s), 000/600 VUs, 9851 complete and 0 interrupted iterations
        default ✓ [======================================] 000/600 VUs  1m10s
        
             ✓ main status was 200
             ✓ join status was 201
             ✓ login status was 200
             ✓ favorite status was 200
             ✓ path status was 200
        
             checks.........................: 100.00% ✓ 49255      ✗ 0    
             data_received..................: 36 MB   518 kB/s
             data_sent......................: 7.4 MB  106 kB/s
             http_req_blocked...............: avg=1.16ms   min=0s      med=0s       max=305.92ms p(90)=1µs   p(95)=2µs  
             http_req_connecting............: avg=268.44µs min=0s      med=0s       max=46.44ms  p(90)=0s    p(95)=0s   
           ✗ http_req_duration..............: avg=443.63ms min=2.44ms  med=126.27ms max=6.41s    p(90)=1.26s p(95)=1.52s
               { expected_response:true }...: avg=443.63ms min=2.44ms  med=126.27ms max=6.41s    p(90)=1.26s p(95)=1.52s
             http_req_failed................: 0.00%   ✓ 0          ✗ 49255
             http_req_receiving.............: avg=37.44µs  min=4µs     med=15µs     max=27.16ms  p(90)=49µs  p(95)=70µs
             http_req_sending...............: avg=67.85µs  min=9µs     med=34µs     max=76.83ms  p(90)=74µs  p(95)=100µs
             http_req_tls_handshaking.......: avg=872.53µs min=0s      med=0s       max=57.52ms  p(90)=0s    p(95)=0s   
             http_req_waiting...............: avg=443.52ms min=0s      med=126.2ms  max=6.41s    p(90)=1.26s p(95)=1.52s
             http_reqs......................: 49255   702.606021/s
             iteration_duration.............: avg=2.22s    min=67.38ms med=2.14s    max=9.06s    p(90)=4.12s p(95)=4.55s
             iterations.....................: 9851    140.521204/s
             vus............................: 15      min=1        max=600
             vus_max........................: 600     min=600      max=600
        
        ERRO[0071] some thresholds have failed
        ```
        
      - 500 VUs
        ```
        {duration: '10s', target: 10},
        {duration: '10s', target: 100},
        {duration: '10s', target: 300},
        {duration: '10s', target: 500},
        {duration: '10s', target: 500},
        {duration: '10s', target: 300},
        {duration: '10s', target: 10},
        ```
        ```
          execution: local
          script: subway-k6-test.js
          output: -
        
          scenarios: (100.00%) 1 scenario, 500 max VUs, 1m40s max duration (incl. graceful stop):
          * default: Up to 500 looping VUs for 1m10s over 7 stages (gracefulRampDown: 30s, gracefulStop: 30s)
        
        
        running (1m10.1s), 000/500 VUs, 11825 complete and 0 interrupted iterations
        default ✓ [======================================] 000/500 VUs  1m10s
        
             ✓ main status was 200
             ✓ join status was 201
             ✓ login status was 200
             ✓ favorite status was 200
             ✓ path status was 200
        
             checks.........................: 100.00% ✓ 59125      ✗ 0    
             data_received..................: 38 MB   536 kB/s
             data_sent......................: 8.1 MB  116 kB/s
             http_req_blocked...............: avg=692.79µs min=0s      med=0s      max=186.72ms p(90)=1µs      p(95)=1µs  
             http_req_connecting............: avg=153.09µs min=0s      med=0s      max=37.16ms  p(90)=0s       p(95)=0s   
           ✓ http_req_duration..............: avg=279.03ms min=2.44ms  med=62.15ms max=2.54s    p(90)=812.32ms p(95)=1.06s
               { expected_response:true }...: avg=279.03ms min=2.44ms  med=62.15ms max=2.54s    p(90)=812.32ms p(95)=1.06s
             http_req_failed................: 0.00%   ✓ 0          ✗ 59125
             http_req_receiving.............: avg=27.79µs  min=4µs     med=14µs    max=18.3ms   p(90)=39µs     p(95)=57µs
             http_req_sending...............: avg=47.69µs  min=8µs     med=32µs    max=103.99ms p(90)=60µs     p(95)=79µs
             http_req_tls_handshaking.......: avg=527.35µs min=0s      med=0s      max=70.29ms  p(90)=0s       p(95)=0s   
             http_req_waiting...............: avg=278.95ms min=2.39ms  med=62.08ms max=2.54s    p(90)=812.26ms p(95)=1.06s
             http_reqs......................: 59125   843.826479/s
             iteration_duration.............: avg=1.39s    min=57.05ms med=1.29s   max=4.85s    p(90)=2.79s    p(95)=3.08s
             iterations.....................: 11825   168.765296/s
             vus............................: 13      min=1        max=500
             vus_max........................: 500     min=500      max=500
        ```
  
    </details>
    

### 개선
- Reverse Proxy 개선하기
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

    인증서 발급
      - domain
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

      - localhost
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

    nginx.conf
    ```
    http {
      server {
        listen 80;
        return 301 https://$host$request_uri;
      }
      server {  
        listen 443 ssl http2;
   
        ssl_certificate <인증서 파일 경로>
        ssl_certificate_key <인증서 키 파일 경로>;
   
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

- 가 성능 개선하기
  - [x] Spring Data Cache
    - local redis 실행
      <details>
      <summary>접기/펼치기</summary>
      
        ```shell
        $ cd redis
        $ docker-compose up -d
        ```
      </details>
    - Service layer 에 적용
      - 역 목록 조회
      - 노선 목록 조회
      - 노선 조회
      - 경로 조회
  
  - [x] 응답 압축

  - [x] 정적 자원
    - 모든 정적 자원에 대해 no-cache, private 설정
      - 확장자는 css인 경우는 max-age를 1년, js인 경우는 no-cache, private 설정
    - 모든 정적 자원에 대해 ETag 를 설정해서 캐시 적용
    - 테스트 코드를 통해 검증

- Scale out - 초간단 Blue-Green 배포 구성하기
  - [nomad](https://learn.hashicorp.com/nomad) & [consul](https://learn.hashicorp.com/consul)

    <details>
    <summary>접기/펼치기</summary>

    - 애플리케이션 배포 및 관리를 위한 오케스트레이션 도구
    - task driver 로 docker 를 사용하도록 설정해둬서 docker 가 설치되어 있어야 함
    - 설치
      - macOS
        ```shell
        $ brew tap hashicorp/tap
        $ brew install hashicorp/tap/nomad
        $ brew install hashicorp/tap/consul
        ```
        - file sharing
          - Docker > Preferences > Resources > File sharing 에서 프로젝트 디렉터리가 포함되도록 설정
          - nomad/start_agents.sh 에서 에이전트 실행 시 data-dir, alloc-dir 를 ./nomad 하위로 설정함

      - linux
        ```shell
        $ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        $ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        $ sudo apt-get update && sudo apt-get install nomad

        $ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        $ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        $ sudo apt-get update && sudo apt-get install consul
        ```

    - agent 실행
      - network interface 확인
        ```shell
        $ ip a
        ```
      - nomad agent network-interface 설정
        ```shell
        $ cd nomad
        $ vi start_agents.sh
        nomad agent -network-interface="eno2"
        ```
      - agent 시작
        ```shell
        $ cd nomad
        $ ./start_agents.sh
        
        $ nomad node status
        ID        DC   Name    Class   Drain  Eligibility  Status
        92fba198  dc1  ubuntu  <none>  false  eligible     ready
        
        $ nomad server members
        Name           Address         Port  Status  Leader  Raft Version  Build  Datacenter  Region
        ubuntu.global  192.168.50.100  4648  alive   true    3             1.3.2  dc1         global
        
        $ consul members
        Node    Address         Status  Type    Build   Protocol  DC   Partition  Segment
        ubuntu  127.0.0.1:8301  alive   server  1.12.3  2         dc1  default    <all>
        ```

    - redis, mysql 배포
      ```shell
      $ cd nomad
      $ nomad job run redis.nomad
      $ nomad job run mysql.nomad

      $ nomad status cache
      ...
      Allocations
      ID        Node ID   Task Group  Version  Desired  Status    Created     Modified
      5dd700c5  ff145549  cache       0        run      running   2m59s ago   2m43s ago
      
      $ nomad status database
      ...
      Allocations
      ID        Node ID   Task Group  Version  Desired  Status    Created     Modified
      1646bc92  ff145549  database    0        run      running   3m48s ago   3m32s ago

      $ consul catalog services
      cache-redis
      consul
      database-mysql
      nomad
      nomad-client
      ```

    - application 배포
      - build docker image
        ```shell
        $ ./gradlew jibDockerBuild
        $ docker images
        REPOSITORY                             TAG       IMAGE ID       CREATED         SIZE
        give928/infra-subway-performance       0.0.1     16d90f2739b3   3 hours ago     164MB
        give928/infra-subway-performance       latest    16d90f2739b3   3 hours ago     164MB
        ```
      - nomad 작업 파일에 이미지 설정
        ```shell
        $ cd nomad
        $ vi subway.nomad
        ...
        config {
           image = "give928/infra-subway-performance:0.0.1"
        ...
        ```
      - nomad 작업 실행하고 상태 확인
        ```shell
        $ nomad job run subway.nomad
        ==> 2022-07-19T13:22:38Z: Monitoring evaluation "7fbb7541"
        2022-07-19T13:22:38Z: Evaluation triggered by job "subway"
        2022-07-19T13:22:38Z: Allocation "a1b34146" created: node "92fba198", group "subway"
        2022-07-19T13:22:39Z: Evaluation within deployment: "3de1c25c"
        2022-07-19T13:22:39Z: Allocation "a1b34146" status changed: "pending" -> "running" (Tasks are running)
        2022-07-19T13:22:39Z: Evaluation status changed: "pending" -> "complete"
        ==> 2022-07-19T13:22:39Z: Evaluation "7fbb7541" finished with status "complete"
        
        $ nomad status subway
        ...
        Deployed
        Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
        subway      1        1       1        0          2022-07-19T13:33:01Z
        
        Allocations
        ID        Node ID   Task Group  Version  Desired  Status   Created  Modified
        a1b34146  92fba198  subway      0        run      running  41s ago  18s ago
        
        $ nomad alloc logs a1b34146
          .   ____          _            __ _ _
         /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
         ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
         \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
         '  |____| .__|_| |_|_| |_\__, | / / / /
         =========|_|==============|___/=/_/_/_/
         :: Spring Boot ::       (v2.4.0-SNAPSHOT)
        ...
        ```
      - scale out
        - 컨테이너 개수 확장(1 -> 3)
          ```shell
          $ vi subway.nomad
          ...
          - count = 1
          + count = 3

            update {
          -   max_parallel     = 1
          +   max_parallel     = 2
          ...
          ```
        - 작업 계획 확인(2개 생성, 1개 업데이트)
          ```shell
          $ nomad job plan subway.nomad
          +/- Job: "subway"
          +/- Task Group: "subway" (2 create, 1 in-place update)
            +/- Count: "1" => "3" (forces create)
            +/- Update {
                  AutoPromote:      "false"
                  AutoRevert:       "false"
                  Canary:           "0"
                  HealthCheck:      "checks"
                  HealthyDeadline:  "60000000000"
              +/- MaxParallel:      "1" => "2"
                  MinHealthyTime:   "10000000000"
                  ProgressDeadline: "600000000000"
                }
                Task: "subway"
          
          Scheduler dry-run:
          - All tasks successfully allocated.
          
          Job Modify Index: 93
          To submit the job with version verification run:
          
          nomad job run -check-index 93 subway.nomad
          ...
          ```
        - 작업 실행 명령을 복사해서 실행
          ```shell
          $ nomad job run -check-index 93 subway.nomad
          ==> 2022-07-19T13:25:48Z: Monitoring evaluation "0c85691c"
          2022-07-19T13:25:48Z: Evaluation triggered by job "subway"
          2022-07-19T13:25:49Z: Evaluation within deployment: "469f2912"
          2022-07-19T13:25:49Z: Allocation "21f2215e" created: node "92fba198", group "subway"
          2022-07-19T13:25:49Z: Allocation "bd28af40" created: node "92fba198", group "subway"
          2022-07-19T13:25:49Z: Allocation "a1b34146" modified: node "92fba198", group "subway"
          2022-07-19T13:25:49Z: Evaluation status changed: "pending" -> "complete"
          ==> 2022-07-19T13:25:49Z: Evaluation "0c85691c" finished with status "complete"
          
          $ nomad status subway
          Deployed
          Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
          subway      3        3       3        0          2022-07-19T13:36:15Z
          
          Allocations
          ID        Node ID   Task Group  Version  Desired  Status   Created    Modified
          21f2215e  92fba198  subway      1        run      running  29s ago    9s ago
          bd28af40  92fba198  subway      1        run      running  29s ago    3s ago
          a1b34146  92fba198  subway      1        run      running  3m39s ago  19s ago
          ```
      - Update the application version
        - build.gradle 파일에서 image 버전 번경
          ```
          jib {
              ...
              to {
                  image = 'give928/infra-subway-performance'
          -       tags = ['0.0.1']
          +       tags = ['0.0.2']
              }
              ...
          ```
        - build docker image

          프로젝트 루트로 이동해서 실행
          ```shell
          $ ./gradlew jibDockerBuild
          $ docker images
          REPOSITORY                             TAG       IMAGE ID       CREATED          SIZE
          give928/infra-subway-performance       0.0.2     ae74a535c983   11 seconds ago   164MB
          give928/infra-subway-performance       latest    ae74a535c983   11 seconds ago   164MB
          give928/infra-subway-performance       0.0.1     5a114be01b1a   50 seconds ago   164MB
          ```
        - 작업 파일 image 버전 변경
          ```shell
          $ cd nomad
          $ vi subway.nomad
          ...
          config {
          - image = "give928/infra-subway-performance:0.0.1"
          + image = "give928/infra-subway-performance:0.0.2"
          }
          ...
          ```
        - 작업 계획 확인(2개 생성/삭제 업데이트, 1개 무시)
          ```shell
          $ nomad job plan subway.nomad
          +/- Job: "subway"
          +/- Task Group: "subway" (2 create/destroy update, 1 ignore)
            +/- Task: "subway" (forces create/destroy update)
              +/- Config {
                +/- image:    "give928/infra-subway-performance:0.0.1" => "give928/infra-subway-performance:0.0.2"
                    ports[0]: "http"
                  }
          
          Scheduler dry-run:
          - All tasks successfully allocated.
          
          Job Modify Index: 105
          To submit the job with version verification run:
          
          nomad job run -check-index 105 subway.nomad
          ...
          ```
        - 작업 실행 명령을 복사해서 실행하면 롤링 업데이트 실행
          ```shell
          $ nomad job run -check-index 105 subway.nomad
          ==> 2022-07-19T13:32:02Z: Monitoring evaluation "3d6bf256"
          2022-07-19T13:32:02Z: Evaluation triggered by job "subway"
          2022-07-19T13:32:03Z: Evaluation within deployment: "be611a22"
          2022-07-19T13:32:03Z: Allocation "0bce9c66" created: node "92fba198", group "subway"
          2022-07-19T13:32:03Z: Allocation "228641d3" created: node "92fba198", group "subway"
          2022-07-19T13:32:03Z: Evaluation status changed: "pending" -> "complete"
          ==> 2022-07-19T13:32:03Z: Evaluation "3d6bf256" finished with status "complete"
          
          $ nomad status subway
          Deployed
          Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
          subway      3        3       3        0          2022-07-19T13:42:49Z
          
          Allocations
          ID        Node ID   Task Group  Version  Desired  Status    Created     Modified
          aeefc305  92fba198  subway      2        run      running   42s ago     16s ago
          0bce9c66  92fba198  subway      2        run      running   1m3s ago    44s ago
          228641d3  92fba198  subway      2        run      running   1m3s ago    42s ago
          21f2215e  92fba198  subway      1        stop     complete  7m16s ago   1m2s ago
          bd28af40  92fba198  subway      1        stop     complete  7m16s ago   42s ago
          a1b34146  92fba198  subway      1        stop     complete  10m26s ago  1m2s ago
          ```

    - nginx 배포
      - 인증서 설정
          - nomad/data/nginx 경로에 인증서 복사
          - 인증서 파일명 설정
        ```shell
        $ vi nginx.nomad
        ...
          ssl_certificate /etc/nginx/conf.d/cert.pem;
          ssl_certificate_key /etc/nginx/conf.d/key.pem;
        ...
        template {
          source        = "../../../data/nginx/cert.pem"
          destination   = "local/cert.pem"
          change_mode   = "signal"
          change_signal = "SIGINT"
        }
        ```
      - nomad 작업 실행하고 상태 확인
        ```shell
        $ nomad job run nginx.nomad

        $ nomad status nginx
        ...
        Allocations
        ID        Node ID   Task Group  Version  Desired  Status   Created    Modified
        54b4e62e  ff145549  nginx       0        run      running  1m11s ago  57s ago
        ```
      - 로드 밸런서 설정 확인
        ```shell
        $ nomad alloc fs 54b nginx/local/load-balancer.conf
        ...
        upstream backend {
          server 192.168.50.100:25191;
          server 192.168.50.100:31133;
          server 192.168.50.100:21159;
        }
        ...
        ```
      - template 으로 로드 밸런서 설정 파일을 구성
        - 서비스 엔드포인트 중 하나의 상태가 변경되면 즉시 알림을 받고 정상적인 서비스 인스턴스만 포함하는 새 로드 밸런서 구성 파일을 다시 렌더링해서 변경 내용이 적용됨
  </details>


- 정적 파일 경량화
  - [x] 렌더링 차단 리소스 제거하기
  - [x] dynamic import 사용해서 리소스 지연 로딩 적용
  - [x] 누적 레이아웃 이동 최적화
  - [x] 웹폰트 로드 중에 텍스트가 계속 표시되도록 하기
  - [x] 웹 폰트 최적화
  - [x] Code Splitting
  - [x] 번들 크기 줄이기
    - vuetify-loader treeshaking 적용

![lighthouse](lighthouse.png)
