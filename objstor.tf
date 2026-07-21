# Создать bucket

resource "yandex_storage_bucket" "bmw17072026" {
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = false
  }
  bucket                  = "bmw17072026"
  default_storage_class   = "STANDARD"
  disabled_statickey_auth = false
  folder_id               = "b1grbnd43egs57caqic6"
  max_size                = 10737418240
  versioning {
    enabled = false
  }

  # --- Добавлен блок для шифрования ---
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-1784609715047.id
        sse_algorithm     = "aws:kms" # Поддерживается только это значение [citation:1]
      }
    }
  }
  # ------------------------------------
}

# Загрузить картинку в bucket

resource "yandex_storage_object" "image" {
  bucket       = "bmw17072026"
  key          = "Get_money.jpg"
  source       = "./Get_money.jpg"
  content_type = "image/jpg"
}