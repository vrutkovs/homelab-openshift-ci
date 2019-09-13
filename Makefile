TOKEN := $(shell cat /var/run/secrets/kubernetes.io/serviceaccount/token)
TEKTON := $(shell find . -name 'tekton-*.yaml')
NAMESPACE := 'ci'

.ONESHELL:
login:
	oc login kubernetes.default.svc --token ${TOKEN} --insecure-skip-tls-verify=true

seed: login
	oc project ${NAMESPACE}
	oc delete jobs -l generated-by=seed-job
	oc delete cronjobs -l generated-by=seed-job
	for f in ${TEKTON}; do oc apply -f $$f; done

run-pipeline: login
	cat pipeline-run.tmpl | envsubst | oc create -f -

prune: login
	oc adm prune builds --confirm
	oc adm prune builds --orphans --confirm
	oc adm prune images --confirm
	oc adm prune deployments --confirm
	oc adm prune deployments --orphans --confirm

import-images: login
	oc import-image centos:7 -n ci
	oc import-image fedora:30 -n ci
	oc import-image gitea -n gitea
	oc import-image jackett -n torrents
	oc import-image lidarr -n torrents
	oc import-image sonarr -n torrents
	oc import-image transmission -n torrents

save-cluster-state: login
	bash /jobs/git-cluster-state.sh

check-firefox-release: login
	bash /jobs/check-firefox-release.sh

trigger-builds: login
	oc start-build htop -n ci
