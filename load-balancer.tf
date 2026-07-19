# Сетевой балансировщик
resource "yandex_lb_network_load_balancer" "my-balancer" {
  name = "my-network-balancer"
  
  listener {
    name        = "http-listener"
    port        = 80
    target_port = 80
    protocol    = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.my-group.load_balancer[0].target_group_id
    
    healthcheck {
      name                = "http-healthcheck"
      interval            = 5
      timeout             = 2
      unhealthy_threshold = 2
      healthy_threshold   = 2
      
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# Правильный способ получить IP адрес из nested sets
output "load_balancer_ip" {
  value = [
    for listener in yandex_lb_network_load_balancer.my-balancer.listener : 
    [
      for spec in listener.external_address_spec : 
      spec.address
    ][0]
  ][0]
  description = "Внешний IP адрес сетевого балансировщика"
}

output "load_balancer_url" {
  value = "http://${[
    for listener in yandex_lb_network_load_balancer.my-balancer.listener : 
    [
      for spec in listener.external_address_spec : 
      spec.address
    ][0]
  ][0]}"
  description = "URL для проверки работы балансировщика"
}