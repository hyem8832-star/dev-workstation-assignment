FROM nginx:1.27-alpine
LABEL org.opencontainers.image.title="workstation-lab-web"
LABEL org.opencontainers.image.description="CLI Docker Git workstation training web server"
COPY site/ /usr/share/nginx/html/
EXPOSE 80
