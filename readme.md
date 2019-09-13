# Terraform for Confluent Platform provisioning

# Running
- The `build.sh` will run terraform and generate an inventory file from the current terraform state.
- Requires terraform-inventory: available from: https://github.com/adammck/terraform-inventory.
- Requires to pass your own IP to setup access in the security groups.

# Notes
- Can be used to setup full clusters in as many regions as you like
- All instance counts and types are configurable
- This repo is in early stages, could be used as example for building your own provisioning scripts
- There is no zone (security-group) for broker port access between regions
