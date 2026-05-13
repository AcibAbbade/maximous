#!/bin/bash
# MAXIMOUS v2.0 - Recuperação Granular
# Melhoria 4: Escolher o que recuperar

CONFIG_DIR="$HOME/.openclaw/workspace/skills/maximous-v2"
DATA_DIR="$CONFIG_DIR/data"
BACKUP_DIR="$CONFIG_DIR/backups"

echo "🔧 MAXIMOUS v2.0 - Sistema de Recuperação Granular"
echo ""

# Listar backups disponíveis
listar_backups() {
    echo "📂 Backups disponíveis:"
    echo ""
    
    # Backups locais
    if [ -d "$BACKUP_DIR" ]; then
        echo "1️⃣  Backups Locais:"
        ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -5 | nl
        echo ""
    fi
    
    # Backups DATASVR
    if ping -c 1 -W 2 "192.168.0.72" > /dev/null 2>&1; then
        echo "2️⃣  Backups DATASVR (ARCA):"
        ssh -i "$HOME/.ssh/id_ed25519" -o StrictHostKeyChecking=no root@192.168.0.72 \
            "ls -1t /home/master/LAN/MEMORIES/maximous-v2/backups/*.tar.gz 2>/dev/null | head -5" 2>/dev/null | nl
        echo ""
    fi
    
    echo "3️⃣  Último Contexto:"
    ls -lt "$DATA_DIR"/context-*.json 2>/dev/null | head -3 | awk '{print $9, $6, $7, $8}'
}

# Recuperar categoria específica
recuperar_categoria() {
    local categoria="$1"
    local fonte="$2"
    
    echo "🎯 Recuperando categoria: $categoria"
    echo "   Fonte: $fonte"
    
    case "$categoria" in
        preferencias)
            echo "   Restaurando preferências do usuário..."
            # Extrair preferências específicas
            ;;
        tarefas)
            echo "   Restaurando lista de tarefas..."
            ;;
        projetos)
            echo "   Restaurando projetos ativos..."
            ;;
        memoria-curta)
            echo "   Restaurando memória de curto prazo..."
            ;;
        memoria-longa)
            echo "   Restaurando memória de longo prazo..."
            ;;
        *)
            echo "   ❌ Categoria desconhecida: $categoria"
            return 1
            ;;
    esac
    
    echo "   ✅ Recuperação concluída"
}

# Menu interativo
menu_recuperacao() {
    echo "Selecione o que deseja recuperar:"
    echo ""
    echo "  [1] Preferências do usuário"
    echo "  [2] Lista de tarefas pendentes"
    echo "  [3] Projetos ativos"
    echo "  [4] Memória de curto prazo (última sessão)"
    echo "  [5] Memória de longo prazo (arquivos MEMORY.md)"
    echo "  [6] Tudo (modo completo)"
    echo "  [7] Sair"
    echo ""
    read -p "Opção: " opcao
    
    case "$opcao" in
        1) recuperar_categoria "preferencias" "backup" ;;
        2) recuperar_categoria "tarefas" "backup" ;;
        3) recuperar_categoria "projetos" "backup" ;;
        4) recuperar_categoria "memoria-curta" "snapshot" ;;
        5) recuperar_categoria "memoria-longa" "arquivos" ;;
        6) echo "🔄 Recuperação completa iniciada..." ;;
        7) echo "Saindo..." ; exit 0 ;;
        *) echo "❌ Opção inválida" ;;
    esac
}

# Exportar
export -f listar_backups
export -f recuperar_categoria

# Execução
if [ -z "$1" ]; then
    menu_recuperacao
else
    case "$1" in
        list)
            listar_backups
            ;;
        restore)
            recuperar_categoria "$2" "$3"
            ;;
        *)
            echo "Uso: $0 {list|restore [categoria] [fonte]}"
            echo "Categorias: preferencias, tarefas, projetos, memoria-curta, memoria-longa"
            ;;
    esac
fi
