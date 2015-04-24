#!/usr/bin/env bash

#set -x
#set -e

echo "Setting up passphraseless ssh"
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

