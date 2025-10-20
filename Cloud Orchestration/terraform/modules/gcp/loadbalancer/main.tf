resource "google_compute_global_address" "ip" {
  name = "cloudshirt-global-ip"
}

resource "google_compute_backend_service" "backend" {
  name        = "cloudshirt-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
}

resource "google_compute_url_map" "url_map" {
  name            = "cloudshirt-url-map"
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = "cloudshirt-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "cloudshirt-http-rule"
  ip_address = google_compute_global_address.ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.proxy.id
}

output "external_ip" {
  value = google_compute_global_address.ip.address
}
