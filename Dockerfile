FROM public.ecr.aws/nginx/nginx:1.29
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  _;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    location /dev/ {
        alias  /usr/share/nginx/html/;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
