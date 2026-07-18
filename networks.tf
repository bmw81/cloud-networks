# Создать облачную сеть(VPC):

resource "yandex_vpc_network" "develop" {
  name = "devops"
}

# Cоздать подсеть public:

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.10.0/24"]								
}

# Cоздать подсеть :

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id						
}

# Создание ВМ NAT

resource "yandex_compute_instance" "nat-instance" {
  name        = "nat_vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8eag95cjr8pasn9c4r" 
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    ip_address         = "192.168.10.254"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/tf_ed25519.pub")}"
  }
}

# Создаем сетевой маршрут для выхода в интернет через NAT:

resource "yandex_vpc_route_table" "rt" {
  name       = "rt"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

# Security Group для vm_private

resource "yandex_vpc_security_group" "LAN" {
  name       = "lan-sg"
  network_id = yandex_vpc_network.develop.id
  ingress {
    description    = "Allow 192.168.10.0/24"
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.10.0/24"]
    from_port      = 0
    to_port        = 65535
  }
  egress {
    description    = "Allow ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

}

# Security Group для сети public

# Управление группой безопасности по умолчанию для сети develop
# resource "yandex_vpc_default_security_group" "default" {
#   network_id = yandex_vpc_network.develop.id

#   # Правила для входящего трафика
#   ingress {
#     description    = "Allow SSH"
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 22
#   }

#   ingress {
#     description    = "Allow HTTP"
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 80
#   }

#   # Правила для исходящего трафика (по умолчанию разрешен весь)
#   egress {
#     description    = "Allow ANY"
#     protocol       = "ANY"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 0
#     to_port        = 65535
#   }
# }