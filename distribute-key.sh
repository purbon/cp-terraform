#!/usr/bin/env bash

INSTANCES=`aws ec2 describe-instances --filters "Name=tag:Name,Values=pub*" | jq '.Reservations | .[].Instances | .[].PublicDnsName' |  tr '""' ' '`

KEY=`cat $HOME/.ssh/ida_rsa_interaws.pub`

for instance in $INSTANCES
do
  echo "Working on $instance..."
  echo ""
  echo $instance
  scp $HOME/.ssh/ida_rsa_interaws ubuntu@$instance:./.ssh
  ssh ubuntu@$instance 'echo '$KEY' >> .ssh/authorized_keys'
done
