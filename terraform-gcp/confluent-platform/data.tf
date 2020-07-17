data "google_compute_network" "vpc_network2" {

  name = "${var.name}-kafka-network"
}
