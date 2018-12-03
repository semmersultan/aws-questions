FROM alpine

ENV SHUSH_VERSION 1.3.3

RUN apk update && apk add curl \
    && curl -sL -o /usr/local/bin/shush https://github.com/realestate-com-au/shush/releases/download/v${SHUSH_VERSION}/shush_linux_amd64 \
    && chmod +x /usr/local/bin/shush

ENTRYPOINT ["/usr/local/bin/shush","decrypt"]
