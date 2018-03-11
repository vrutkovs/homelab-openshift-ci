TOKEN := $(shell cat /var/run/secrets/kubernetes.io/serviceaccount/token)

login:
	oc login kubernetes.default.svc --token ${TOKEN} --insecure-skip-tls-verify=true

seed: login
	oc delete jobs --all
	for f in job_*.yaml ; do \
    oc create -f ${f} ; \
  done

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
