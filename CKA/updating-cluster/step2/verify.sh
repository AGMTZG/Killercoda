#!/bin/bash

latest_version=$(apt-cache madison kubeadm | head -n 1 | awk '{print $3}' | cut -d- -f1)
installed_version=$(kubeadm version -o short | sed 's/^v//')

if [ "$installed_version" = "$latest_version" ]; then
    echo "kubeadm updated to: v$installed_version"
else
    echo "Error: kubeadm not updated"
    exit 1
fi

if apt-mark showhold | grep -q "^kubeadm$"; then
  echo "kubeadm is on hold"
else
  echo "kubeadm is not on hold"
  exit 1
fi
