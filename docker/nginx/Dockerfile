FROM nginx:1.17.6-alpine AS development

COPY ./conf.d/default.conf /etc/nginx/conf.d/default.conf

# ---

FROM development AS debug
