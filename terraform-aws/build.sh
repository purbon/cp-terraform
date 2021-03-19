#!/bin/bash
set -xe

time terraform apply -var myip=$1 -var region="eu-west-1" -parallelism=20
#terraform-inventory -list ./ | jq 'with_entries(select(.key | startswith("role_")))' > inventory.json
#cp inventory.json $1
