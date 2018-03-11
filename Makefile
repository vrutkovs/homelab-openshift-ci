TOKEN := $(shell cat /var/run/secrets/kubernetes.io/serviceaccount/token)

all: login prune

login:
	oc login kubernetes.default.svc --token ${TOKEN} --insecure-skip-tls-verify=true

prune:
	oc adm prune builds --confirm
	oc adm prune builds --orphans --confirm
	oc adm prune images --confirm
	oc adm prune deployments --confirm
	oc adm prune deployments --orphans --confirm
