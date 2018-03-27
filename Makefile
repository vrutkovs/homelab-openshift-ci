TOKEN := $(shell cat /var/run/secrets/kubernetes.io/serviceaccount/token)
JOBS := $(shell find . -name 'job_*.yaml')
NAMESPACE := 'gitea'

login:
	oc login kubernetes.default.svc --token ${TOKEN} --insecure-skip-tls-verify=true

seed: login
	oc project ${NAMESPACE}
	oc delete jobs -l generated-by=seed-job
	oc delete cronjobs -l generated-by=seed-job
	for f in ${JOBS}; do oc create -f $$f; done

prune: login
	oc adm prune builds --confirm
	oc adm prune builds --orphans --confirm
	oc adm prune images --confirm
	oc adm prune deployments --confirm
	oc adm prune deployments --orphans --confirm

import-images: login
	oc import-image sonarr -n transmission
	oc import-image headphones -n transmission
	oc import-image deluge -n transmission
	oc import-image jackett -n transmission
	oc import-image gitea -n gitea
	oc import-image duplicati -n duplicati
	oc import-image wallabag -n wallabag
	oc import-image tt-rss -n ttrss
