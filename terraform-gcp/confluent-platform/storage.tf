variable "disk_size" {
  type    = map
  default = {
    bastion   = 512
    broker    = 1024
    zookeeper = 1024
    connect   = 512
  }
}

resource "google_compute_attached_disk" "broker" {
  disk     = element(google_compute_disk.broker.*.id, count.index)
  instance = element(google_compute_instance.broker.*.id, count.index)
  count    = var.brokers
}

resource "google_compute_disk" "broker" {
  name  = "${var.name}-broker-${count.index}-disk"
  count = var.brokers
  type  = "pd-standard"
  zone  = var.zones[count.index]
  image = var.image_type
  labels = {
    environment = var.environment
  }
  size = var.disk_size["broker"]
  physical_block_size_bytes = 4096
}


resource "google_compute_attached_disk" "zookeeper" {
  disk     = element(google_compute_disk.zookeeper.*.id, count.index)
  instance = element(google_compute_instance.zookeeper.*.id, count.index)
  count    = var.zookeepers
}

resource "google_compute_disk" "zookeeper" {
  name  = "${var.name}-zookeeper-${count.index}-disk"
  count = var.zookeepers
  type  = "pd-ssd"
  zone  = var.zones[count.index]
  image = var.image_type
  labels = {
    environment = var.environment
  }
  size = var.disk_size["zookeeper"]
  physical_block_size_bytes = 4096
}
