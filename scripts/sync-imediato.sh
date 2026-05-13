#!/bin/bash
# MAXIMOUS v2.0 - Sync Imediato em Eventos Críticos
# Melhoria 1: Hook em cada mensagem importante

CONFIG_DIR="$HOME/.openclaw/workspace/skills/maximous-v2"
ARCASVR="192.168.0.72"
PRIORITY_FILE="$CONFIG_DIR/data/priority-events.log"

evento_critico() {
    local tipo="$1"
    local conteudo="$2"
    local timestamp=$(date +%Y-%m-%d-%H%M%S)
    
    # Salvar imediatamente com prioridade alta
    echo "[URGENTE] $timestamp - $tipo" >> "$PRIORITY_FILE"
    echo "$conteudo" | base64 >> "$PRIORITY_FILE"
    echo "---" >> "$PRIORITY_FILE"
    
    # Sync imediato para DATASVR
    if ping -c 1 -W 2 "$ARCASVR" > /dev/null 2>&1; then
        # Usar SSH key se disponível
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
            scp -o StrictHostKeyChecking=no -i "$HOME/.ssh/id_ed25519" \
                "$PRIORITY_FILE" "root@$ARCASVR:/home/master/LAN/MEMORIES/priority-sync/" 2>/dev/null
        fi
    fi
    
    # Backup local criptografado (melhoria 6)
    if command -v gpg > /dev/null; then
        echo "$conteudo" | gpg --symmetric --passphrase "$(cat $CONFIG_DIR/.secret 2>/dev/null || echo 'maximous2024')" \
            --batch --yes -o "$CONFIG_DIR/secure/priority-${timestamp}.gpg" 2>/dev/null
    fi
}

# Exportar função para uso externo
export -f evento_critico

echo "✅ Sync Imediato v2.0 ativado"
echo "Eventos críticos serão salvos instantaneamente"
