#!/bin/bash

# Script para facilitar a instalação e desinstalação do Docker

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root ou use sudo."
    exit 1
fi

instalar_docker() {
    echo "Atualizando o sistema..."
    apt update && apt upgrade -y

    echo "Instalando dependências..."
    apt install -y apt-transport-https ca-certificates curl software-properties-common

    echo "Adicionando a chave GPG do Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null

    echo "Adicionando o repositório do Docker..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Atualizando o índice de pacotes novamente..."
    apt update

    echo "Instalando o Docker..."
    apt install -y docker-ce docker-ce-cli containerd.io

    echo "Docker instalado com sucesso!"
}


desinstalar_docker() {
    echo "Parando o serviço do Docker..."
    systemctl stop docker

    echo "Desinstalando o Docker..."
    apt purge -y docker-ce docker-ce-cli containerd.io

    echo "Removendo imagens, containers e volumes..."
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd

    echo "Docker desinstalado com sucesso!"
}


# Verifica se o Docker já está instalado
if command -v docker &> /dev/null; then
    echo "Docker já está instalado. Para reinstalar, desinstale primeiro."
    exit 1
fi


# Exemplo de uso
if [[ "$1" == "instalar" ]]; then
    instalar_docker
elif [[ "$1" == "desinstalar" ]]; then
    desinstalar_docker
else
    echo "Uso: $0 {instalar|desinstalar}"
    exit 1
fi
