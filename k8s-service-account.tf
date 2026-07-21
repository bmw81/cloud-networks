# Сервис-аккаунт для Kubernetes
resource "yandex_iam_service_account" "k8s_sa" {
  name        = "k8s-service-account"
  description = "Service account for Kubernetes cluster"
  folder_id   = "b1grbnd43egs57caqic6"
}

# Назначаем права сервис-аккаунту
resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_editor" {
  folder_id = "b1grbnd43egs57caqic6"
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_images" {
  folder_id = "b1grbnd43egs57caqic6"
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

# Создаем статический ключ доступа для сервис-аккаунта
resource "yandex_iam_service_account_static_access_key" "k8s_sa_key" {
  service_account_id = yandex_iam_service_account.k8s_sa.id
  description        = "Static access key for Kubernetes cluster"
}