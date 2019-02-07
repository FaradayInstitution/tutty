# --- build Quantum Espresso ---
FROM debian:jessie as qe-builder

RUN apt-get -y update && \
    apt-get install -y gfortran make git tar bash && \
    rm -rf /var/lib/apt/lists/* 

RUN git clone https://gitlab.com/QEF/q-e.git
WORKDIR /q-e
RUN ./configure LDFLAGS="-static-libgfortran -static-libgcc -Bstatic"
RUN make all


FROM node:8.15.0-jessie
MAINTAINER d.kramer@soton.ac.uk

RUN apt-get update -y && \
    apt-get install -y python bash git nano vim && \
    rm -rf /var/lib/apt/lists/*

COPY terminal/prompt.sh /etc/profile.d/prompt.sh
COPY terminal/motd /etc/motd
COPY terminal/bashrc /etc/bash.bashrc

EXPOSE 3000

WORKDIR /app

# Create a custom group for tutorial users
RUN addgroup --gid 2000 tutorial

COPY --from=qe-builder /q-e/bin/* /opt/q-e/
RUN chgrp -R tutorial /opt/q-e && for f in $(ls /opt/q-e); do ln -s /opt/q-e/$f /usr/bin; done

CMD yarn --dev && node bin
