#!/bin/bash
# MAXIMOUS v2.0 - Verificação de Integridade de Dados
# Melhoria 2: Hash de verificação + checksum

CONFIG_DIR="$HOME/.openclaw/workspace/skills/maximous-v2"
DATA_DIR="$CONFIG_DIR/data"

gerar_hash() {
    local arquivo="$1"
    if [ -f "$arquivo" ]; then
        sha256sum "$arquivo" | awk '{print $1}'
    else
        echo "ARQUIVO_NAO_EXISTE"
    fi
}

salvar_hash() {
    local arquivo="$1"
    local hash=$(gerar_hash "$arquivo")
    local hash_file="$DATA_DIR/.hashes/$(basename $arquivo).sha256"
    
    mkdir -p "$DATA_DIR/.hashes"
    echo "$hash  $(basename $arquivo)" > "$hash_file"
    echo "$hash"
}

verificar_integridade() {
    local arquivo="$1"
    local hash_file="$DATA_DIR/.hashes/$(basename $arquivo).sha256"
    
    if [ ! -f "$hash_file" ]; then
        echo "⚠️ Hash não encontrado, gerando..."
        salvar_hash "$arquivo"
        return 1
    fi
    
    local hash_atual=$(gerar_hash "$arquivo")
    local hash_esperado=$(cat "$hash_file" | awk '{print $1}')
    
    if [ "$hash_atual" = "$hash_esperado" ]; then
        echo "✅ INTEGRIDADE OK - $(basename $arquivo)"
        return 0
    else
        echo "🔴 CORRUPÇÃO DETECTADA - $(basename $arquivo)"
        echo "   Esperado: $hash_esperado"
        echo "   Atual:    $hash_atual"
        return 1
    fi
}

# Verificar todos os arquivos de dados
verificar_todos() {
    local falhas=0
    local total=0
    
    for arquivo in "$DATA_DIR"/*.json "$DATA_DIR"/*.md "$DATA_DIR"/*.log 2>/dev/null; do
        [ -f "$arquivo" ] || continue
        total=$((total + 1))
        verificar_integridade "$arquivo" || falhas=$((falhas + 1))
    done
    
    echo ""
    echo "Resumo: $((total - falhas))/$total arquivos OK"
    
    if [ $falhas -gt 0 ]; then
        echo "🔴 $falhas arquivo(s) corrompido(s) detectado(s)"
        return 1
    fi
    
    return 0
}

# Auto-reparar se necessário
auto_reparar() {
    echo "🔧 Tentando recuperar do backup..."
    local backup_dir="$CONFIG_DIR/backups/latest"
    
    if [ -d "$backup_dir" ]; then
        echo "✅ Backup encontrado em: $backup_dir"
        # Implementar recuperação seletiva aqui
    else
        echo "❌ Nenhum backup disponível"
    fi
}

# Exportar funções
export -f verificar_integridade
export -f salvar_hash
export -f verificar_todos

case "$1" in
    check)
        verificar_todos
        ;;
    repair)
        auto_reparar
        ;;
    *)
        echo "Uso: $0 {check|repair}"
        ;;
esac
