# cf. https://hackerbox.io/articles/dockerised-nginx-env-vars/
FROM nginx:stable-alpine-perl
ARG HOST

EXPOSE 80

ADD nginx.conf /etc/nginx/nginx.conf

RUN rm /etc/nginx/conf.d/default.conf
RUN echo "HOST at build-time: $HOST"
