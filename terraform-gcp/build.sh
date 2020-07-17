#!/usr/bin/env bash


terraform apply -var myip=$1 -parallelism=20
