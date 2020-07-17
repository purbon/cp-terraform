#!/usr/bin/env bash


terraform plan -var myip=$1 -parallelism=20
