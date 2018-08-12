FROM centos:7

RUN yum update -y && \
    yum install -y centos-release-openshift-origin && \
    yum install -y origin-clients make git-core && \
    yum clean all

ADD . /jobs
WORKDIR /jobs

CMD ["make"]
