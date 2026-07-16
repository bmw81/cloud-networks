terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id = "b1g42vvurfj7l2uclca3"
  folder_id = "b1grbnd43egs57caqic6"
  service_account_key_file = file("~/.authorized_key.json")
  zone = "ru-central1-a"
}