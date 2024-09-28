#!/bin/bash

# Fiz esse script para facilitar minha vida com oo install e uninstall do docker ;D


instalar_docker() {
    echo "Atualizando o sistema..."
    sudo apt-get update
    sudo apt-get upgrade -y

    echo "Instalando dependências..."
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y

    echo "Adicionando a chave GPG do Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "Adicionando o repositório do Docker..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    echo "Atualizando o índice de pacotes novamente..."
    sudo apt-get update

    echo "Instalando o Docker..."
    sudo apt-get install docker-ce -y

    echo "Docker instalado com sucesso!"
}

desistalar_docker() {
    echo "Parando o serviço do Docker..."
    sudo systemctl stop docker

    echo "Desinstalando o Docker..."
    sudo apt-get purge docker-ce docker-ce-cli containerd.io -y

    echo "Removendo imagens, containers e volumes..."
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    echo "Docker desinstalado com sucesso!"
}

# Exemplo de uso
if [[ "$1" == "instalar" ]]; then
    instalar_docker
elif [[ "$1" == "desistalar" ]]; then
    desistalar_docker
else
    echo "Uso: $0 {instalar|desistalar}"
fi
