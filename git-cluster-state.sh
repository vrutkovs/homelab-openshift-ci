#!/bin/bash
set -eux
set -o pipefail
cd /tmp
git clone https://robot:foo@gitea.vrutkovs.eu/vadim/cluster-state.git
cd cluster-state

rm -rf ./*

# Globals
types=("clusterroles" "clusterrolebindings")
for type in "${types[@]}"; do
  mkdir -p globals/${type::-1}
  mapfile -t objs < <( oc get $type -o name )
  for obj in "${objs[@]}"; do
    oc get --export $obj -o yaml > globals/${type::-1}/${obj/*\//}.yml || true
  done
done

# Globals - singular
types=("pv" "scc")
for type in "${types[@]}"; do
  mkdir -p globals/${type}
  mapfile -t objs < <( oc get $type -o name )
  for obj in "${objs[@]}"; do
    oc get --export $obj -o yaml > globals/${type}/${obj/*\//}.yml || true
  done
done

# namespaced objects
while read p; do
  mkdir $p
  oc get namespace $p -o yaml --export > project-$p.yml
  pushd $p
  oc project $p > /dev/null

  types=("is" "bc" "dc" "cm" "secret" "cronjob" "route" "svc" "pvc" "role" "rolebinding" "ds" "sa" "sts")

  for type in "${types[@]}"; do
    mapfile -t objs < <( oc get $type -o name )
    for obj in "${objs[@]:-}"; do
      [ ! -z $obj ] || continue
      oc get --export $obj -o yaml > ${type}-${obj/*\//}.yml || true
    done
  done
  popd
done <<< $(oc projects -q)

git config --global user.name "Openshift robot"
git config --global user.email roignac+test@gmail.com

git add -A
git commit -am "Cluster state on $(date)"
git push -f
