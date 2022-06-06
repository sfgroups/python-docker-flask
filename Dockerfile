FROM nginx:alpine
#FROM python:alpine


WORKDIR /app

EXPOSE 5000
EXPOSE 8080
#COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt

ARG UID=1001
ARG GID=1001

RUN addgroup -g $GID -S webgroup  \
    && adduser -S -D -H -u $UID -h /var/cache/nginx -s /sbin/nologin -G webgroup -g nginx webuser

COPY . /app 
RUN chown -R webuser:webgroup /app

RUN apk add --no-cache tzdata \
    # Bring in curl and ca-certificates to make registering on DNS SD easier
    && apk add --no-cache curl ca-certificates \
    # create a docker-entrypoint.d directory
    && mkdir -p /docker-entrypoint.d

# implement changes required to run NGINX as an unprivileged user
RUN sed -i 's,listen       80;,listen       8080;,' /etc/nginx/conf.d/default.conf \
    && sed -i '/user  nginx;/d' /etc/nginx/nginx.conf \
    && sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf \
    && sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf \
# nginx user must own the cache and etc directory to write cache and tweak the nginx config
    && chown -R $UID:$GID /var/cache/nginx  /var/log/nginx \
    && chmod -R g+w /var/cache/nginx \
    && chown -R $UID:$GID /etc/nginx \
    && chmod -R g+w /etc/nginx

USER webuser

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \

#CMD ["gunicorn", "--workers=4", "--bind=0.0.0.0:5000", "app:app"]
STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]