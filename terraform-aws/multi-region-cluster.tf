# EU (Ireland)  eu-west-1
# EU (London) eu-west-2
# EU (Frankfurt) eu-central-1

variable "region" {
  default = "eu-west-1"
}

variable "Owner_Name" {
  default = "Pere Urbon"
}


variable "Owner_Email" {
  default = "pere@confluent.io"
}

variable "ownershort" {
  default = "pub"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "myip" {
}

#module "frankfurt-cluster" {
#  source         = "./confluent"
#  broker-count   = 3
#  zk-count       = 3
#  connect-count  = 1
#  producer-count = 0
#  consumer-count = 1
#  c3-count       = 1
#  name           = "frankfurt-cluster"
#  region         = "eu-central-1"
#  azs            = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
#  owner          = var.owner
#  ownershort     = var.ownershort
#  key_name       = "purbon-frankfurt"
#  myip           = var.myip
#}

module "ireland-cluster" {
  source         = "./confluent"
  broker-count   = 3
  zk-count       = 3
  connect-count  = 1
  producer-count = 0
  consumer-count = 0
  c3-count       = 1
  name           = "ireland-cluster"
  region         = "eu-west-1"
  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  Owner_Name     = var.Owner_Name
  Owner_Email    = var.Owner_Email
  key_name       = "purbon-ireland-sa"
  myip           = var.myip
  ownershort     = var.ownershort
}
