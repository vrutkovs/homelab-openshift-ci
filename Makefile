TOKEN := $(shell cat /var/run/secrets/kubernetes.io/serviceaccount/token)

all: login

login:
	oc login kubernetes.default.svc --token ${TOKEN} --insecure-skip-tls-verify=true
