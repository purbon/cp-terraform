#!/bin/bash
set -xe

terraform plan -var myip=$1 -var region="eu-west-1" -parallelism=20
