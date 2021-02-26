FROM nginx

# Copy static HTML pages (when building a new image)
COPY html /usr/share/nginx/html

# Start command
COPY docker_run.sh /docker_run.sh
CMD sh /docker_run.sh
