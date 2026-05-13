#!/bin/bash
# MAXIMOUS v2.0 - Criptografia de Dados Sensíveis
# Melhoria 6: Proteger credenciais e dados pessoais

CONFIG_DIR="$HOME/.openclaw/workspace/skills/maximous-v2"
SECURE_DIR="$CONFIG_DIR/secure"
PUBLIC_DIR="$CONFIG_DIR/data"

mkdir -p "$SECURE_DIR" "$PUBLIC_DIR"

# Verificar se gpg está disponível
check_gpg() {
    if ! command -v gpg > /dev/null; then
        echo "⚠️ GPG não instalado. Instalando..."
        apt-get update && apt-get install -y gnupg 2>/dev/null
    fi
}

# Gerar chave mestre se não existir
gerar_chave_mestre() {
    local chave_file="$SECURE_DIR/.master-key"
    
    if [ ! -f "$chave_file" ]; then
        openssl rand -base64 32 > "$chave_file"
        chmod 600 "$chave_file"
        echo "✅ Chave mestre gerada"
    fi
    
    cat "$chave_file"
}

# Criptografar dado sensível
criptografar() {
    local dado="$1"
    local arquivo_saida="$2"
    local chave=$(gerar_chave_mestre)
    
    echo "$dado" | openssl enc -aes-256-cbc -salt -pass pass:"$chave" -out "$arquivo_saida" -base64
    echo "✅ Dado criptografado em: $arquivo_saida"
}

# Descriptografar
descriptografar() {
    local arquivo="$1"
    local chave=$(gerar_chave_mestre)
    
    openssl enc -aes-256-cbc -d -salt -pass pass:"$chave" -in "$arquivo" -base64
}

# Classificar dados
classificar_dados() {
    local arquivo="$1"
    local tipo="$2"
    
    case "$tipo" in
        sensivel|private|password|token|key)
            # Mover para área segura
            criptografar "$(cat $arquivo)" "$SECURE_DIR/$(basename $arquivo).enc"
            rm "$arquivo"
            echo "🔒 $(basename $arquivo) → criptografado"
            ;;
        public|open|general)
            # Manter em área pública
            mv "$arquivo" "$PUBLIC_DIR/"
            echo "📂 $(basename $arquivo) → público"
            ;;
    esac
}

# Sanitizar arquivo (remover dados sensíveis antes de backup)
sanitizar_para_backup() {
    local origem="$1"
    local destino="$2"
    
    # Padrões de dados sensíveis
    local sensivel_patterns="senha|password|token|key|secret|credential|login"
    
    # Criar cópia sanitizada
    cp "$origem" "$destino"
    
    # Substituir dados sensíveis por [REDACTED]
    sed -i -E "s/($sensivel_patterns)[\"']?\s*[:=]\s*[\"'][^\"']+[\"']/[REDACTED]/gi" "$destino"
    
    echo "✅ Arquivo sanitizado: $destino"
}

# Lista de dados que devem ser criptografados
auto_classificar() {
    echo "🔍 Analisando arquivos em busca de dados sensíveis..."
    
    for arquivo in "$CONFIG_DIR"/data/*.{json,md,txt,env} 2>/dev/null; do
        [ -f "$arquivo" ] || continue
        
        # Detectar padrões sensíveis
        if grep -qiE "password|senha|token|key|secret|credential|login|@" "$arquivo" 2>/dev/null; then
            echo "   🔒 Detectado dado sensível: $(basename $arquivo)"
            # Não criptografa automaticamente para não quebrar funcionalidade
            echo "      → Marcado para revisão manual"
        fi
    done
}

# Exportar
export -f criptografar
export -f descriptografar
export -f sanitizar_para_backup

case "$1" in
    encrypt)
        criptografar "$2" "$3"
        ;;
    decrypt)
        descriptografar "$2"
        ;;
    scan)
        auto_classificar
        ;;
    sanitize)
        sanitizar_para_backup "$2" "$3"
        ;;
    *)
        echo "Uso: $0 {encrypt [dado] [saida]|decrypt [arquivo]|scan|sanitize [origem] [destino]}"
        ;;
esac
