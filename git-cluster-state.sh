#!/bin/bash
set -eux
set -o pipefail
cd /tmp
git clone https://robot:foo@gitea.vrutkovs.eu/vadim/cluster-state.git
cd cluster-state

rm -rf ./*

# Globals
types=("persistentvolumes" "clusterroles" "clusterrolebindings")
for type in "${types[@]}"; do
  mkdir -p globals/$type
  while read -d ' ' obj; do
    if [ ! -z "$obj" ]; then
      oc export $obj > globals/${obj}.yml
    fi
  done <<< $(oc get $type -o name)
done

# namespaced objects
while read -d ' ' p; do
  mkdir $p
  oc export project $p > project-$p.yml
  pushd $p
  oc project $p > /dev/null

  types=("is" "bc" "dc" "cm" "secret" "cronjob" "route" "svc" "pv" "pvc" "role" "rolebinding" "ds" "sa" "sts")

  for type in "${types[@]}"; do
    while read -d ' ' obj; do
      if [ ! -z "$obj" ]; then
        oc export $obj > ${obj/\//-}.yml
      fi
    done <<< $(oc get $type -o name)
  done

  popd
done <<< $(oc projects -q)

git config --global user.name "Openshift robot"
git config --global user.email roignac+test@gmail.com

git add -A
git commit -am "Cluster state on $(date)"
git push -f
