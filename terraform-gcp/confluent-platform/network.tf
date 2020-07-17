
resource "google_compute_address" "vm_static_ip" {
  name = "${var.name}-kafka-static-ip"
}


resource "google_compute_firewall" "default" {
  name    = "confluent-platform-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [ "${var.myip}/32" ]
  source_tags = ["kafka"]
  target_tags = ["kafka"]
}

resource "google_compute_firewall" "brokers" {
  name    = "confluent-platform-ak-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "9092"]
  }

  source_ranges = [ "${var.myip}/32" ]
  source_tags = ["bastion", "broker", "connect"]
  target_tags = ["broker"]
}

resource "google_compute_firewall" "zookeepers" {
  name    = "confluent-platform-zk-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "2181", "2888", "3888"]
  }

  source_ranges = [ "${var.myip}/32" ]
  source_tags = ["broker", "zookeeper"]
  target_tags = ["broker", "zookeeper"]
}

resource "google_compute_firewall" "connects" {
  name    = "confluent-platform-connect-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8083"]
  }

  source_ranges = [ "${var.myip}/32" ]
  source_tags = ["broker", "connect"]
  target_tags = ["broker", "connect"]
}

resource "google_compute_network" "vpc_network" {
  name = "${var.name}-kafka-network"
  description = "A network for Confluent Platform"
  auto_create_subnetworks = true
}
