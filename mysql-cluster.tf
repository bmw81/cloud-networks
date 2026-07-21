# Создаем кластер MySQL
resource "yandex_mdb_mysql_cluster" "netology_cluster" {
  name                = "netology-mysql-cluster"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.develop.id
  version             = "8.0"
  deletion_protection = true
  
  resources {
    resource_preset_id = "s2.micro"
    disk_size          = 20
    disk_type_id       = "network-ssd"
  }
  
  backup_window_start {
    hours   = 23
    minutes = 59
  }
  
  mysql_config = {
    max_connections = "100"
    sql_mode        = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO"
  }
  
  # Хосты в разных зонах для отказоустойчивости
  host {
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.private.id
    assign_public_ip = false
  }
  
  host {
    zone             = "ru-central1-b"
    subnet_id        = yandex_vpc_subnet.private_b.id
    assign_public_ip = false
  }
  
  host {
    zone             = "ru-central1-d"
    subnet_id        = yandex_vpc_subnet.private_d.id  # Исправлено с private_c на private_d
    assign_public_ip = false
  }
}

# Создаем базу данных отдельным ресурсом
resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.netology_cluster.id
  name       = "netology_db"
}

# Создаем пользователя отдельным ресурсом
resource "yandex_mdb_mysql_user" "netology_user" {
  cluster_id = yandex_mdb_mysql_cluster.netology_cluster.id
  name       = "netology_user"
  password   = local.mysql_password
  
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}

# Генерируем пароль для MySQL (если не указан в переменных)
resource "random_password" "mysql_password" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

variable "mysql_password" {
  description = "Пароль для пользователя MySQL"
  type        = string
  sensitive   = true
  default     = null
}

# Используем сгенерированный пароль, если не указан
locals {
  mysql_password = var.mysql_password != null ? var.mysql_password : random_password.mysql_password.result
}

# Вывод информации о кластере
output "mysql_cluster_info" {
  value = {
    id                = yandex_mdb_mysql_cluster.netology_cluster.id
    name              = yandex_mdb_mysql_cluster.netology_cluster.name
    hosts             = yandex_mdb_mysql_cluster.netology_cluster.host[*].fqdn
    database          = yandex_mdb_mysql_database.netology_db.name
    user              = yandex_mdb_mysql_user.netology_user.name
    password          = local.mysql_password
    connection_string = "mysql://${yandex_mdb_mysql_user.netology_user.name}:${local.mysql_password}@${yandex_mdb_mysql_cluster.netology_cluster.host[0].fqdn}:3306/${yandex_mdb_mysql_database.netology_db.name}"
  }
  sensitive = true
}