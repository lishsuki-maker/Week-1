# Stage 1:
FROM nginx:1.26.2-alpine AS validator
COPY index.html /usr/share/nginx/html/index.html
RUN test -s /usr/share/nginx/html/index.html

# Stage 2:
FROM nginx:1.26.2-alpine
COPY --from=validator /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
    CMD wget --spider -q http://127.0.0.1:80 || exit 1
ENTRYPOINT ["/entrypoint.sh"]
