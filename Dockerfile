FROM registry.fedoraproject.org/fedora:30

RUN dnf update -y && \
    dnf install -y origin-clients make git-core python3-beautifulsoup4 /usr/bin/envsubst findutils && \
    dnf clean all

ADD . /jobs
WORKDIR /jobs

CMD ["make"]
