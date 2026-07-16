data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm_public" {
  name        = "vm-public"
  hostname    = "vm-public"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"


  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/tf_ed25519.pub")}"
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
  }
}

resource "yandex_compute_instance" "vm_private" {
  name        = "vm-private"
  hostname    = "vm-private"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"


  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/tf_ed25519.pub")}"
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }
}