# Региональный кластер Kubernetes
resource "yandex_kubernetes_cluster" "netology_k8s" {
  name        = "netology-k8s-cluster"
  description = "Regional Kubernetes cluster"
  network_id  = yandex_vpc_network.develop.id
  
  # Региональный мастер с размещением в 3 зонах
  master {
    # Используем актуальную версию Kubernetes
    version = "1.31"  # Изменено с 1.28 на 1.31
    
    regional {
      region = "ru-central1"
      
      location {
        zone      = "ru-central1-a"
        subnet_id = yandex_vpc_subnet.public.id
      }
      
      location {
        zone      = "ru-central1-b"
        subnet_id = yandex_vpc_subnet.public_b.id
      }
      
      location {
        zone      = "ru-central1-d"
        subnet_id = yandex_vpc_subnet.public_d.id
      }
    }
    
    public_ip = true
  }
  
  # Настройки шифрования с использованием KMS
  kms_provider {
    key_id = yandex_kms_symmetric_key.key-1784609715047.id
  }
  
  # Сервис-аккаунт для управления кластером
  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id
  
  # Настройка сетевой политики
  network_policy_provider = "CALICO"
  
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_sa_editor,
    yandex_resourcemanager_folder_iam_member.k8s_sa_images
  ]
}

# Группа узлов Kubernetes с автомасштабированием
resource "yandex_kubernetes_node_group" "netology_nodes" {
  cluster_id = yandex_kubernetes_cluster.netology_k8s.id
  name       = "netology-node-group"
  
  scale_policy {
    auto_scale {
      min     = var.k8s_node_count
      max     = var.k8s_node_max
      initial = var.k8s_node_count
    }
  }
  
  allocation_policy {
    location {
      zone      = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
    
    location {
      zone      = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public_b.id
    }
    
    location {
      zone      = "ru-central1-d"
      subnet_id = yandex_vpc_subnet.public_d.id
    }
  }
  
  instance_template {
    platform_id = "standard-v3"
    
    resources {
      cores         = var.k8s_node_cores
      memory        = var.k8s_node_memory
      core_fraction = 100
    }
    
    boot_disk {
      type = "network-ssd"
      size = 50
    }
    
    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.public.id,
        yandex_vpc_subnet.public_b.id,
        yandex_vpc_subnet.public_d.id
      ]
      nat = true
    }
    
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/tf_ed25519.pub")}"
    }
  }
  
  maintenance_policy {
    auto_upgrade = false
    auto_repair  = true
    
    maintenance_window {
      start_time = "23:00"
      duration   = "2h"
    }
  }
}