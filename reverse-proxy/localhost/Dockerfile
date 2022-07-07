FROM nginx:1.23-alpine

RUN mkdir /etc/nginx/cache
COPY nginx/conf/nginx.conf /etc/nginx/nginx.conf
COPY minica.pem /etc/letsencrypt/live/localhost/minica.pem
COPY minica-key.pem /etc/letsencrypt/live/localhost/minica-key.pem
