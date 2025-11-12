#!/bin/bash

# Script para facilitar a instalação, atualização e desinstalação do Docker

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root ou use sudo."
    exit 1
fi

instalar_docker() {
    echo "🔄 Atualizando o sistema..."
    apt update && apt upgrade -y

    echo "📦 Instalando dependências..."
    apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

    echo "🔑 Adicionando a chave GPG do Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null

    echo "➕ Adicionando o repositório oficial do Docker..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "🔄 Atualizando o índice de pacotes..."
    apt update

    echo "🐋 Instalando o Docker..."
    apt install -y docker-ce docker-ce-cli containerd.io

    echo "✅ Docker instalado com sucesso!"
}

atualizar_docker() {
    echo "🔄 Atualizando o Docker para a versão mais recente..."
    # Verificando a versão instalada do Docker
    VERSAO_ATUAL=$(docker --version | awk '{print $3}' | sed 's/,//')
    VERSAO_REPOSITORIO=$(apt-cache show docker-ce | grep Version | head -n 1 | awk '{print $2}')

    if [[ "$VERSAO_ATUAL" == "$VERSAO_REPOSITORIO" ]]; then
        echo "🔔 O Docker já está na versão mais recente ($VERSAO_ATUAL). Nenhuma atualização necessária."
    else
        apt update
        apt install --only-upgrade -y docker-ce docker-ce-cli containerd.io
        systemctl daemon-reload
        systemctl restart docker
        echo "✅ Docker atualizado com sucesso!"
    fi
}


desinstalar_docker() {
    echo "🛑 Parando o serviço do Docker..."
    systemctl stop docker

    echo "❌ Desinstalando o Docker..."
    apt purge -y docker-ce docker-ce-cli containerd.io

    echo "🧹 Removendo imagens, containers, volumes e redes do Docker..."
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -rf /etc/docker
    rm -rf /var/run/docker
    rm -rf /var/lib/systemd/system/docker.service.d

    echo "🔴 Removendo qualquer configuração de rede do Docker..."
    rm -rf /etc/systemd/system/docker.service
    rm -rf /etc/systemd/system/multi-user.target.wants/docker.service

    echo "🧼 Limpando o cache de pacotes do apt..."
    apt-get clean

    echo "✅ Docker e todos os arquivos relacionados foram removidos com sucesso!"
}

# Verifica se o Docker já está instalado
if command -v docker &> /dev/null; then
    echo "🐋 Docker já está instalado."
    docker --version
    echo ""
    echo "Escolha uma opção:"
    echo "1) Atualizar Docker"
    echo "2) Desinstalar Docker"
    echo "3) Cancelar"
    read -rp "Digite o número da opção desejada: " opcao

    case $opcao in
        1)
            atualizar_docker
            ;;
        2)
            desinstalar_docker
            ;;
        3)
            echo "Operação cancelada."
            exit 0
            ;;
        *)
            echo "Opção inválida."
            exit 1
            ;;
    esac
    exit 0
fi

# Caso o Docker não esteja instalado, seguir com a instalação
if [[ "$1" == "instalar" ]]; then
    instalar_docker
elif [[ "$1" == "desinstalar" ]]; then
    desinstalar_docker
else
    echo "Uso: $0 {instalar|desinstalar}"
    exit 1
fi
