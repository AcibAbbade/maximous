#!/bin/bash
# MAXIMOUS v2.0 - Backup Multi-Cloud
# Melhoria 3: Sync para GitHub Gist, Google Drive, Dropbox

CONFIG_DIR="$HOME/.openclaw/workspace/skills/maximous-v2"
DATA_DIR="$CONFIG_DIR/data"
BACKUP_DIR="$CONFIG_DIR/multi-cloud"

# Configurações (usuário deve preencher)
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
GIST_ID="${MAXIMOUS_GIST_ID:-}"
GOOGLE_DRIVE_FOLDER="${GDRIVE_FOLDER_ID:-}"
DROPBOX_TOKEN="${DROPBOX_TOKEN:-}"

log_multi() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Sync para GitHub Gist
sync_gist() {
    if [ -z "$GITHUB_TOKEN" ] || [ -z "$GIST_ID" ]; then
        log_multi "⚠️ GitHub Gist não configurado"
        return 1
    fi
    
    log_multi "☁️ Sync para GitHub Gist..."
    
    # Comprimir dados
    tar -czf "$BACKUP_DIR/maximous-backup.tar.gz" -C "$DATA_DIR" . 2>/dev/null
    
    # Converter para base64 para upload
    base64 "$BACKUP_DIR/maximous-backup.tar.gz" > "$BACKUP_DIR/maximous-backup.b64"
    
    # Atualizar Gist via API
    curl -s -X PATCH \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/gists/$GIST_ID" \
        -d "{\"files\":{\"maximous-context-$(date +%Y%m%d).json\":{\"content\":\"$(cat $DATA_DIR/context-current.json | base64 -w 0)\"}}}" \
        > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        log_multi "✅ GitHub Gist atualizado"
    else
        log_multi "❌ Falha no sync GitHub"
    fi
}

# Sync para Google Drive (via rclone se disponível)
sync_gdrive() {
    if [ -z "$GOOGLE_DRIVE_FOLDER" ]; then
        log_multi "⚠️ Google Drive não configurado"
        return 1
    fi
    
    if command -v rclone > /dev/null; then
        log_multi "☁️ Sync para Google Drive..."
        rclone sync "$DATA_DIR" "gdrive:$GOOGLE_DRIVE_FOLDER" --backup-dir="gdrive:$GOOGLE_DRIVE_FOLDER/old" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log_multi "✅ Google Drive atualizado"
        else
            log_multi "❌ Falha no sync Google Drive"
        fi
    else
        log_multi "⚠️ rclone não instalado (instale: apt install rclone)"
    fi
}

# Sync para Dropbox
sync_dropbox() {
    if [ -z "$DROPBOX_TOKEN" ]; then
        log_multi "⚠️ Dropbox não configurado"
        return 1
    fi
    
    log_multi "☁️ Sync para Dropbox..."
    
    # Upload via API Dropbox
    tar -czf "$BACKUP_DIR/maximous-$(date +%Y%m%d).tar.gz" -C "$DATA_DIR" . 2>/dev/null
    
    curl -s -X POST https://content.dropboxapi.com/2/files/upload \
        --header "Authorization: Bearer $DROPBOX_TOKEN" \
        --header "Dropbox-API-Arg: {\"path\": \"/maximous/backups/maximous-$(date +%Y%m%d).tar.gz\",\"mode\": \"add\",\"autorename\": true}" \
        --header "Content-Type: application/octet-stream" \
        --data-binary @"$BACKUP_DIR/maximous-$(date +%Y%m%d).tar.gz" \
        > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        log_multi "✅ Dropbox atualizado"
    else
        log_multi "❌ Falha no sync Dropbox"
    fi
}

# Sync para DATASVR (local)
sync_datasvr() {
    log_multi "☁️ Sync para DATASVR (ARCA)..."
    
    if ping -c 1 -W 2 "192.168.0.72" > /dev/null 2>&1; then
        # Usar SSH key
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
            rsync -az -e "ssh -i $HOME/.ssh/id_ed25519 -o StrictHostKeyChecking=no" \
                "$DATA_DIR/" "root@192.168.0.72:/home/master/LAN/MEMORIES/maximous-v2/" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                log_multi "✅ DATASVR atualizado via rsync"
            else
                # Fallback para scp
                scp -r -i "$HOME/.ssh/id_ed25519" -o StrictHostKeyChecking=no \
                    "$DATA_DIR" "root@192.168.0.72:/home/master/LAN/MEMORIES/" 2>/dev/null
                log_multi "✅ DATASVR atualizado via scp"
            fi
        else
            log_multi "⚠️ SSH key não encontrado"
        fi
    else
        log_multi "⚠️ DATASVR offline"
    fi
}

# Sync completo para todos os destinos
sync_all() {
    mkdir -p "$BACKUP_DIR"
    log_multi "🔄 Iniciando backup multi-cloud..."
    
    sync_datasvr
    sync_gist
    sync_gdrive
    sync_dropbox
    
    log_multi "✅ Backup multi-cloud concluído"
}

# Exportar
export -f sync_all
export -f sync_datasvr

# Configurar cron para execução automática
configurar_cron() {
    echo "📝 Para configurar backup automático a cada 30 minutos, execute:"
    echo "   (crontab -l 2>/dev/null; echo '*/30 * * * * $CONFIG_DIR/scripts/multi-cloud-sync.sh all') | crontab -"
}

case "$1" in
    all)
        sync_all
        ;;
    datasvr)
        sync_datasvr
        ;;
    gist)
        sync_gist
        ;;
    gdrive)
        sync_gdrive
        ;;
    dropbox)
        sync_dropbox
        ;;
    setup)
        configurar_cron
        ;;
    *)
        echo "Uso: $0 {all|datasvr|gist|gdrive|dropbox|setup}"
        ;;
esac
