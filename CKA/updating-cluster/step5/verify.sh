#!/bin/bash

installed_kubeadm=$(kubeadm version -o short)
installed_kubelet=$(kubelet --version 2>/dev/null | awk '{print $2}')
installed_kubectl=$(kubectl version --client | head -n 1 | awk '{print $3}')

if [ "$installed_kubeadm" == "$installed_kubelet" ] && [ "$installed_kubeadm" == "$installed_kubectl" ]; then
    echo "kubeadm, kubelet, and kubectl are all on the same version"
else
    echo "Version mismatch detected:"
    [ "$installed_kubeadm" != "$installed_kubelet" ] && echo " - kubelet ($installed_kubelet) does not match kubeadm ($installed_kubeadm)"
    [ "$installed_kubeadm" != "$installed_kubectl" ] && echo " - kubectl ($installed_kubectl) does not match kubeadm ($installed_kubeadm)"
    exit 1
fi

if apt-mark showhold | grep -q "^kubectl$"; then
  echo "kubectl is on hold"
else
  echo "kubectl is not on hold"
  exit 1
fi
