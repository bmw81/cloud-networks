# Дополнительные подсети для отказоустойчивости

# Публичные подсети в разных зонах
resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_vpc_subnet" "public_d" {
  name           = "public-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

# Приватные подсети в разных зонах
resource "yandex_vpc_subnet" "private_b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.21.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "private_d" {
  name           = "private-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.22.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}