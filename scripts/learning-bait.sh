#!/bin/bash
# learning-bait.sh - Sistema de "iscas" para aprender preferências

# Perguntas estratégicas por contexto

ask_project_questions() {
    cat << 'EOF'
🎯 NOVO PROJETO DETECTADO!

Para me ajudar a ajudar você melhor nas próximas vezes:

1/4 🔧 TECNOLOGIA:
Qual stack prefere? (ou deixo eu sugerir?)
A) Já tenho preferências definidas
B) Deixa eu recomendar baseado no projeto
C) Quero explorar opções

2/4 ⏰ PRAZO:
Tem data definida?
A) Sim, é urgente (prazo curto)
B) Sim, mas há tempo
C) Sem prazo, explorar

3/4 🏗️ INFRAESTRUTURA:
Onde vai rodar?
A) Tenho infraestrutura pronta
B) Preciso criar do zero
C) Depende do que descobrirmos

4/4 🎨 ESTILO:
Como prefere trabalhar?
A) Rápido e direto (só o essencial)
B) Explorar opções (mais tempo)
C) Depende do momento

Responda A, B ou C para cada (ex: A-B-A-B)
EOF
}

ask_stress_question() {
    cat << 'EOF'
⚠️ PERCEBI QUE VOCÊ PODE ESTÁ PRESSIONADO

Quando tá assim, você prefere:

A) 🚀 AÇÃO IMEDIATA
   - Eu decido e executo
   - Sem explicações longas
   - Resultado rápido

B) ⚡ OPÇÕES RÁPIDAS  
   - 2-3 alternativas em 30s
   - Você escolhe
   - Executo imediatamente

C) 🎯 SIMPLIFICAÇÃO MÁXIMA
   - Só o essencial
   - Passo a passo minimalista
   - Nada de extras

Isso me ajuda a adaptar para as próximas vezes!

Responda A, B ou C:
EOF
}

ask_satisfaction_question() {
    cat << 'EOF'
🎉 TÁ FLUINDO BEM!

Antes de continuar, uma rápida para eu manter o que funciona:

O que mais gostou até agora?

A) ⚡ VELOCIDADE
   - Respostas rápidas
   - Ação imediata
   - Sem enrolação

B) 📖 CLAREZA
   - Explicações claras
   - Bem organizado
   - Fácil entender

C) 🎯 INICIATIVA
   - Eu antecipando
   - Sugerindo próximos passos
   - Pensando à frente

D) 📊 VISUAL
   - Formato das respostas
   - Tabelas/cores
   - Bem apresentado

Responda A, B, C ou D:
EOF
}

ask_workflow_question() {
    cat << 'EOF'
🔧 DETECTEI SEU WORKFLOW

Percebi que você faz assim:
1. [observação do sistema]
2. [observação do sistema]
3. [observação do sistema]

Isso é um padrão que quer que eu sempre siga?

A) ✅ SIM, sempre faça assim
   - Grava como padrão
   - Aplica automaticamente
   
B) ⚠️ SÓ AGORA
   - Situacional
   - Pergunte na próxima
   
C) 🔄 VARIA
   - Depende do contexto
   - Me pergunte sempre

Isso me ajuda a padronizar ou personalizar!
EOF
}

# Detectar contexto e perguntar
main() {
    local context="$1"
    
    case "$context" in
        "new_project")
            ask_project_questions
            ;;
        "stress_detected")
            ask_stress_question
            ;;
        "flow_good")
            ask_satisfaction_question
            ;;
        "workflow_pattern")
            ask_workflow_question
            ;;
        *)
            echo "Uso: $0 --context [new_project|stress_detected|flow_good|workflow_pattern]"
            ;;
    esac
}

# Executar se chamado diretamente
if [ "$1" = "--context" ]; then
    main "$2"
fi
