# base image
FROM alpine:3.10

RUN addgroup vault && \
    adduser -S -G vault vault

# create a new directory
RUN mkdir /vault && \
    mkdir /vault/certs && \
    chown -R vault:vault /vault/*

# download dependencies
RUN apk --no-cache add \
    bash \
    ca-certificates \
    wget

# download and set up vault
RUN wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/1.5.5/vault_1.5.5_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /bin && \
    rm -f /tmp/vault.zip && \
    chmod +x /bin

# update PATH
ENV PATH="PATH=$PATH:$PWD/vault"




# expose port 8200
EXPOSE 8200

# run vault
ENTRYPOINT ["vault"]
