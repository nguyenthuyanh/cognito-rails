# Base image
FROM nginx
# Install dependencies
RUN apt-get update -qq && apt-get -y install apache2-utils openssl
# establish where Nginx should look for files
ENV RAILS_ROOT /var/www/kolimmo
# Set our working directory inside the image
WORKDIR $RAILS_ROOT
# create log directory
RUN mkdir log
# copy over static assets
COPY ./public public/
# Copy Nginx config template
COPY docker/web/nginx.conf /tmp/docker.nginx
RUN openssl req -subj '/C=FR/ST=Paris/L=Paris/O=orisha.com/OU=K Department/CN=pognito.local' -x509 -newkey rsa:4096 -nodes -keyout /etc/ssl/key.pem -out /etc/ssl/cert.pem -days 365
# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN envsubst '$RAILS_ROOT' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf
EXPOSE 80
# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]
