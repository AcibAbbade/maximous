#!/bin/bash
# MAXIMOUS v2.0 - Compressão Inteligente (Diferencial)
# Melhoria 5: Só salva mudanças

CONFIG_DIR="$HOME/.openclaw/workspace/skills/maximous-v2"
DATA_DIR="$CONFIG_DIR/data"
COMPRESSED_DIR="$CONFIG_DIR/compressed"
SNAPSHOTS_DIR="$CONFIG_DIR/snapshots"

mkdir -p "$COMPRESSED_DIR" "$SNAPSHOTS_DIR"

# Criar snapshot com rsync e hard links
snapshot_diferencial() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local new_snapshot="$SNAPSHOTS_DIR/snapshot-$timestamp"
    local latest_snapshot=$(ls -td "$SNAPSHOTS_DIR"/snapshot-* 2>/dev/null | head -1)
    
    if [ -d "$latest_snapshot" ]; then
        # Usar hard links para arquivos não modificados
        rsync -a --link-dest="$latest_snapshot" "$DATA_DIR/" "$new_snapshot/"
        echo "✅ Snapshot diferencial criado: $timestamp"
        echo "   (apenas arquivos modificados ocupam espaço novo)"
    else
        # Primeiro snapshot (completo)
        cp -r "$DATA_DIR/" "$new_snapshot/"
        echo "✅ Primeiro snapshot criado: $timestamp"
    fi
    
    # Manter apenas últimos 10 snapshots
    ls -td "$SNAPSHOTS_DIR"/snapshot-* 2>/dev/null | tail -n +11 | xargs rm -rf 2>/dev/null
    
    echo "$new_snapshot"
}

# Comprimir com zstd (mais rápido que gzip)
comprimir_zstd() {
    local origem="$1"
    local destino="$2"
    
    if command -v zstd > /dev/null; then
        tar --zstd -cf "$destino" -C "$(dirname $origem)" "$(basename $origem)"
        echo "✅ Comprimido com zstd: $destino"
    else
        # Fallback para gzip
        tar -czf "$destino" -C "$(dirname $origem)" "$(basename $origem)"
        echo "✅ Comprimido com gzip: $destino"
    fi
}

# Calcular economia de espaço
calcular_economia() {
    local original=$(du -sb "$DATA_DIR" | awk '{print $1}')
    local comprimido=$(du -sb "$COMPRESSED_DIR" | awk '{print $1}')
    
    if [ $original -gt 0 ]; then
        local economia=$((100 - (comprimido * 100 / original)))
        echo "💾 Economia de espaço: ${economia}%"
        echo "   Original: $(du -sh "$DATA_DIR" | awk '{print $1}')"
        echo "   Comprimido: $(du -sh "$COMPRESSED_DIR" | awk '{print $1}')"
    fi
}

# Exportar
export -f snapshot_diferencial
export -f comprimir_zstd

case "$1" in
    snapshot)
        snapshot_diferencial
        ;;
    compress)
        comprimir_zstd "$2" "$3"
        ;;
    stats)
        calcular_economia
        ;;
    *)
        echo "Uso: $0 {snapshot|compress [origem] [destino]|stats}"
        ;;
esac
