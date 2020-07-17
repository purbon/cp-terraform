
output "static-ip" {
  value = google_compute_address.vm_static_ip.address
}

output "ip" {
  value = ["${google_compute_instance.broker.*.network_interface.0.access_config.0.nat_ip}"]
}

output "brokers" {
  value = google_compute_instance.broker.*.id
}
