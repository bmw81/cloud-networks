#!/bin/bash

# Устанавливаем переменные
export KUBECONFIG=$(pwd)/kubeconfig

# Проверяем подключение к кластеру
echo "Проверка подключения к кластеру..."
kubectl cluster-info

# Выводим список узлов
echo -e "\nСписок узлов кластера:"
kubectl get nodes -o wide

# Выводим информацию о подах во всех неймспейсах
echo -e "\nПоды во всех неймспейсах:"
kubectl get pods --all-namespaces

# Проверяем, что шифрование работает
echo -e "\nПроверка секретов:"
kubectl create secret generic test-secret --from-literal=test=secret --dry-run=client -o yaml | kubectl apply -f -
kubectl get secret test-secret -o yaml
kubectl delete secret test-secret