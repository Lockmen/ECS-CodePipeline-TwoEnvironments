FROM public.ecr.aws/nginx/nginx:1.29
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
