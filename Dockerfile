FROM centos:7

RUN yum update -y && \
    yum install -y centos-release-openshift-origin && \
    yum install -y origin-clients && \
    yum clean all

ADD Makefile /

CMD ["make"]
