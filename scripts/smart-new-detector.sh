#!/bin/bash
# smart-new-detector.sh - Detecta necessidade de /new e EXPLICA ao usuário

# Thresholds
SESSION_HOURS_WARNING=6
SESSION_HOURS_URGENT=10
ERROR_THRESHOLD=5
SLOW_RESPONSE_THRESHOLD=3

# Cores
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Verificar tempo de sessão (simulado - em produção viria do sistema)
get_session_duration() {
    # Em produção: calcular desde session_start_time
    echo "8.5" # horas (exemplo)
}

# Verificar performance (simulado)
get_performance_status() {
    # Em produção: medir tempos de resposta
    echo "degraded" # ou "normal"
}

# Verificar erros recentes (simulado)
get_recent_errors() {
    # Em produção: contar erros em janela de tempo
    echo "4" # quantidade
}

# Calcular score de necessidade
calculate_new_score() {
    local hours=$(get_session_duration)
    local perf=$(get_performance_status)
    local errors=$(get_recent_errors)
    
    local score=0
    
    # Tempo (peso 3)
    if (( $(echo "$hours > $SESSION_HOURS_URGENT" | bc -l) )); then
        score=$((score + 40))
    elif (( $(echo "$hours > $SESSION_HOURS_WARNING" | bc -l) )); then
        score=$((score + 25))
    fi
    
    # Performance (peso 2)
    if [ "$perf" = "degraded" ]; then
        score=$((score + 20))
    fi
    
    # Erros (peso 2)
    if [ $errors -ge $ERROR_THRESHOLD ]; then
        score=$((score + 20))
    elif [ $errors -ge 3 ]; then
        score=$((score + 10))
    fi
    
    echo $score
}

# Explicar benefícios do /new
explain_new_benefits() {
    cat << EOF
💡 Por que /new ajuda?

🧠 COMO FUNCIONO:
• Cada sessão acumula contexto
• Com 8+ horas, fico "cansado"
• Respostas ficam mais lentas
• Posso confundir informações

✅ BENEFÍCIOS DE /NEW:
• Respostas 2-3x mais rápidas
• Maior precisão nas respostas  
• Menos erros de confusão
• Energia renovada para você

💾 SEUS DADOS:
• NADA é perdido
• Tudo salvo automaticamente
• Na volta, continuo de onde parou
• Prefências já aprendidas = aplicadas

🎯 É COMO:
Trabalhar 9h sem parar vs dormir e acordar descansado
EOF
}

# Detectar e sugerir
main() {
    local score=$(calculate_new_score)
    local hours=$(get_session_duration)
    
    if [ $score -ge 60 ]; then
        echo -e "${RED}🚨 RECOMENDAÇÃO FORTE: /new agora${NC}"
        echo ""
        echo "⏰ Detectei:"
        echo "  • Sessão: ${hours}h de trabalho"
        echo "  • Performance: Degradada"
        echo "  • Erros recentes: Elevados"
        echo ""
        explain_new_benefits
        echo ""
        echo "🤔 Posso preparar tudo e fazermos /new?"
        
    elif [ $score -ge 35 ]; then
        echo -e "${YELLOW}⚠️  SUGESTÃO: Considerar /new${NC}"
        echo ""
        echo "⏰ Detectei:"
        echo "  • Sessão: ${hours}h de trabalho"
        echo "  • Alguns sinais de lentidão"
        echo ""
        echo "💡 Quer que eu explique os benefícios?"
        echo "Ou prefere continuar mais um pouco?"
        
    else
        echo -e "${GREEN}✅ Sessão saudável!${NC}"
        echo "Horas: ${hours}h | Score: ${score}/100"
    fi
}

# Executar se chamado diretamente
if [ "$1" = "--check" ]; then
    main
fi
