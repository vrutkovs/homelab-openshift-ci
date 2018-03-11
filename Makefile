all: login

login:
	oc login kubernetes.default.svc --token $(cat /var/run/secrets/kubernetes.io/serviceaccount/token) --insecure-skip-tls-verify=true
