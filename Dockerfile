FROM centos:7

RUN yum update -y && \
    yum install -y centos-release-openshift-origin && \
    yum install -y origin-clients make && \
    yum clean all

ADD Makefile /

CMD ["make"]
