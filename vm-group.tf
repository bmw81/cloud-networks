# Создать группу ВМ:

resource "yandex_compute_instance_group" "my-group" {
  allocation_policy {
    zones = [
      "ru-central1-a"
    ]
  }
  deletion_protection = false
  deploy_policy {
    max_creating     = 3
    max_deleting     = 3
    max_unavailable  = 3
    max_expansion    = 3
    startup_duration = 0
    strategy         = "proactive"
  }
  folder_id = "b1grbnd43egs57caqic6"

   # ========== ДОБАВЛЯЕМ HEALTH CHECK ==========
  health_check {
    # Проверка через HTTP (порт 80)
    http_options {
      port = 80
      path = "/"
    }
    
    # Интервал между проверками (в секундах)
    interval = 5
    
    # Время ожидания ответа (в секундах)
    timeout = 2
    
    # Количество успешных проверок для признания ВМ здоровой
    healthy_threshold = 2
    
    # Количество неудачных проверок для признания ВМ больной
    unhealthy_threshold = 2
  }

  # ========== ДОБАВЛЯЕМ TARGET GROUP ДЛЯ БАЛАНСИРОВЩИКА ==========
  load_balancer {
    target_group_name = "my-target-group"
  }

  # ===========================================

  instance_template {
    platform_id        = "standard-v3"
    service_account_id = "ajepborfug7r3nao6pfq"
    metadata = {
      user-data = <<-EOF
        #cloud-config
        packages:
          - nginx
        write_files:
          - path: /var/www/html/index.html
            permissions: '0644'
            content: |
              <!DOCTYPE html>
              <html>
              <head><title>Стартовая страница</title></head>
              <body>
                <h1>Привет от группы ВМ!</h1>
                <p>Вот ссылка на картинку из бакета:</p>
                <img src="https://bmw17072026.website.yandexcloud.net/Get_money.jpg" alt="Get money">
              </body>
              </html>
        runcmd:
          - systemctl start nginx
          - systemctl enable nginx
      EOF
      ssh-keys                 = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQaBegnXA0Tnun43hkbpj/XuthOp6f+SYzc6zzb/pAC mike@mike-Perfectum-Series"
      private_ui_access-method = "ssh-key"
      serial-port-enable       = "1"
    }
    network_interface {
      network_id = yandex_vpc_network.develop.id
      subnet_ids = [yandex_vpc_subnet.public.id]
      security_group_ids = [
        yandex_vpc_default_security_group.default.id
      ]
    }
    scheduling_policy {
      preemptible = true
    }
    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
      gpus          = 0
    }
    boot_disk {
      mode = "READ_WRITE"
      name = "disk-lamp-1784353334189"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 20
        type     = "network-ssd"
      }
    }
  }
  name = "my-group"
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  service_account_id = "ajepborfug7r3nao6pfq"
}