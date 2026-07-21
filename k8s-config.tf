# Просто выводим команду для получения kubeconfig
output "k8s_connect_command" {
  value = "yc k8s cluster get-credentials ${yandex_kubernetes_cluster.netology_k8s.name} --external"
  description = "Команда для получения kubeconfig через yc CLI"
}

output "k8s_cluster_info" {
  value = {
    cluster_name = yandex_kubernetes_cluster.netology_k8s.name
    cluster_id   = yandex_kubernetes_cluster.netology_k8s.id
    master_ip    = yandex_kubernetes_cluster.netology_k8s.master[0].external_v4_address
    status       = yandex_kubernetes_cluster.netology_k8s.status
  }
}