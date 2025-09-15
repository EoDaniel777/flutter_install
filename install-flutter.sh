#!/bin/bash

# Função para exibir barra de progresso estilo Pacman
show_progress() {
    local title=$1
    local progress=0
    local pid=$2
    local dots='•'
    local empty='·'
    local bar_size=20
    
    # Adiciona um timeout para a barra de progresso
    local max_time=300 # 5 minutos, ajuste conforme necessário
    local start_time=$(date +%s)

    while [ $progress -le 100 ] && ([ -z "$pid" ] || kill -0 $pid 2>/dev/null); do
        local current_time=$(date +%s)
        if (( current_time - start_time > max_time )); then
            echo -e "\n⚠️ A operação '$title' demorou muito. A barra de progresso será finalizada."
            break
        fi

        local filled=$((progress * bar_size / 100))
        local empty_count=$((bar_size - filled))
        local bar=""
        
        for ((i=0; i<filled; i++)); do
            bar="${bar}${dots}"
        done
        
        bar="${bar}ᗧ"
        
        for ((i=0; i<empty_count-1; i++)); do
            bar="${bar}${empty}"
        done
        
        echo -ne "\r🎮 ${title}... ${bar} ${progress}% "
        sleep 0.1
        progress=$((progress + 5))
    done
    echo -ne "\r🎮 ${title}... ${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}${dots}ᗧ 100% \n"
}

# Função para executar comando com barra de progresso
run_with_progress() {
    local title=$1
    shift
    show_progress "$title" &
    local progress_pid=$!
    # Redireciona stdout e stderr para /dev/null para reduzir a verbosidade do comando real
    "$@" > /dev/null 2>&1 
    local exit_code=$?
    kill $progress_pid 2>/dev/null
    wait $progress_pid 2>/dev/null
    return $exit_code
}

# Função para configurar variáveis de ambiente permanentemente
configurar_variaveis_ambiente() {
    local profile_file="$HOME/.profile"
    local zshrc_file="$HOME/.zshrc"
    local bashrc_file="$HOME/.bashrc"

    echo "🔧 Configurando variáveis de ambiente permanentemente..."

    # Detectar o shell atual
    local current_shell=$(basename "$SHELL" 2>/dev/null || echo "bash")

    # Configurações do Flutter - Usando sintaxe correta para adicionar ao PATH
    local flutter_exports='export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"'

    # Função auxiliar para limpar configurações antigas de um arquivo
    clean_old_flutter_config() {
        local file="$1"
        if [ -f "$file" ]; then
            # Remove linhas relacionadas ao Flutter
            sed -i '/# Configurações do Flutter/,/# Fim Configurações do Flutter/d' "$file" 2>/dev/null
            sed -i '/export.*flutter/d' "$file" 2>/dev/null
            sed -i '/export.*ANDROID_HOME/d' "$file" 2>/dev/null
            sed -i '/export.*ANDROID_SDK_ROOT/d' "$file" 2>/dev/null
            sed -i '/export.*CHROME_EXECUTABLE/d' "$file" 2>/dev/null
        fi
    }

    # Função auxiliar para adicionar configurações
    add_flutter_config() {
        local file="$1"
        local file_name=$(basename "$file")

        if [ ! -f "$file" ]; then
            touch "$file"
            echo "🔧 Arquivo ~/$file_name criado."
        fi

        clean_old_flutter_config "$file"

        echo "" >> "$file"
        echo "# Configurações do Flutter - Gerado automaticamente" >> "$file"
        echo "$flutter_exports" >> "$file"
        echo "# Fim Configurações do Flutter" >> "$file"

        echo "✨ Configurações adicionadas ao ~/$file_name"
    }

    # Configurar arquivos baseado no shell
    case "$current_shell" in
        "zsh")
            add_flutter_config "$zshrc_file"
            add_flutter_config "$profile_file"  # Para compatibilidade
            ;;
        "bash")
            add_flutter_config "$bashrc_file"
            add_flutter_config "$profile_file"
            ;;
        *)
            add_flutter_config "$profile_file"
            # Tentar zshrc se existir
            if [ -f "$zshrc_file" ]; then
                add_flutter_config "$zshrc_file"
            fi
            # Tentar bashrc se existir
            if [ -f "$bashrc_file" ]; then
                add_flutter_config "$bashrc_file"
            fi
            ;;
    esac

    # Aplicar as variáveis na sessão atual do script - usando sintaxe correta
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    export PATH="$PATH:$HOME/flutter/bin"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

    echo "🎯 Variáveis aplicadas na sessão atual do script!"
}

# Função para verificar se Flutter está funcionando corretamente
verificar_flutter_funcionando() {
    echo "🧪 Verificando se Flutter está funcionando corretamente..."

    # Aplicar variáveis no contexto atual - usando sintaxe correta
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    export PATH="$PATH:$HOME/flutter/bin"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

    # Verificar se o flutter está no PATH
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter não encontrado no PATH!"
        return 1
    fi

    # Testar comando básico do flutter
    echo "🔍 Testando 'flutter --version'..."
    if flutter --version > /dev/null 2>&1; then
        echo "✅ Flutter --version funcionando!"
    else
        echo "❌ Erro ao executar flutter --version"
        return 1
    fi

    # Testar flutter doctor
    echo "🔍 Testando 'flutter doctor'..."
    local doctor_output=$(flutter doctor 2>&1)
    local doctor_exit_code=$?

    if [ $doctor_exit_code -eq 0 ]; then
        echo "✅ Flutter doctor executado com sucesso!"

        # Verificar se há problemas críticos
        local critical_errors=$(echo "$doctor_output" | grep -c "✗")
        local warnings=$(echo "$doctor_output" | grep -c "!")

        if [ $critical_errors -eq 0 ]; then
            echo "🎉 Flutter está funcionando perfeitamente - SEM ERROS!"
        else
            echo "⚠️ Flutter funcionando, mas com $critical_errors erro(s) e $warnings aviso(s)"
        fi

        echo ""
        echo "📋 Resumo do Flutter Doctor:"
        echo "$doctor_output"
        return 0
    else
        echo "❌ Erro ao executar flutter doctor"
        return 1
    fi
}

# Função para garantir configuração permanente
garantir_configuracao_permanente() {
    echo "🔒 Garantindo que configurações sejam permanentes..."

    # Verificar e configurar novamente se necessário
    configurar_variaveis_ambiente

    echo "💡 INSTRUÇÕES IMPORTANTES:"
    echo "   1. FECHE E REABRA seu terminal para aplicar as configurações"
    echo "   2. Ou execute: source ~/.zshrc (para zsh) ou source ~/.bashrc (para bash)"
    echo "   3. Teste com: flutter --version"
    echo ""
    echo "🎯 O Flutter deve funcionar em QUALQUER diretório após reiniciar o terminal!"
}

# Função para instalar Android Studio
instalar_android_studio() {
    local android_studio_dir="$HOME/android-studio"
    local studio_download_url="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.3.2.14/android-studio-2024.3.2.14-linux.tar.gz"
    local studio_zip_file="/tmp/android-studio.tar.gz"

    if [ -d "$android_studio_dir" ]; then
        echo "🎮 Android Studio já está instalado em $android_studio_dir. Pulando a instalação."
    else
        echo "🎮 Instalando Android Studio..."
        run_with_progress "Baixando Android Studio" \
            wget -q "$studio_download_url" -O "$studio_zip_file"
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao baixar Android Studio."
            exit 1
        fi

        run_with_progress "Extraindo Android Studio" \
            tar -xzf "$studio_zip_file" -C "$HOME"
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao extrair Android Studio."
            exit 1
        fi
        rm "$studio_zip_file"
        echo "✨ Android Studio instalado com sucesso!"
    fi
    
    # Tentar inicializar o Android Studio para que ele crie os arquivos de configuração
    # e o Flutter possa detectar a versão.
    echo "🔧 Tentando inicializar o Android Studio em segundo plano para detecção da versão..."
    if [ -f "$android_studio_dir/bin/studio.sh" ]; then
        # Usa nohup para garantir que o processo não seja morto quando o script terminar
        # Redireciona a saída para evitar poluição do terminal
        nohup "$android_studio_dir/bin/studio.sh" > /dev/null 2>&1 & 
        STUDIO_PID=$!
        echo "⏳ Dando 10 segundos para o Android Studio inicializar e criar arquivos de configuração..."
        sleep 10 # Dá tempo para o Android Studio criar seus arquivos de configuração
        kill $STUDIO_PID 2>/dev/null # Tenta matar o processo
        wait $STUDIO_PID 2>/dev/null # Espera o processo morrer
        echo "✨ Tentativa de inicialização do Android Studio concluída (se ele não fechou sozinho, pode ter que fechar manualmente)."
    else
        echo "⚠️ Arquivo studio.sh não encontrado em '$android_studio_dir/bin'. Não foi possível tentar inicializar o Android Studio."
    fi
}

# Função para criar atalho do Android Studio no menu
criar_atalho_android_studio() {
    local desktop_file="$HOME/.local/share/applications/android-studio.desktop"
    local android_studio_dir="$HOME/android-studio"

    echo "🔧 Criando atalho para o Android Studio..."
    mkdir -p "$HOME/.local/share/applications"

    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec=$android_studio_dir/bin/studio.sh
Icon=$android_studio_dir/bin/studio.png
Categories=Development;IDE;
Terminal=false
StartupNotify=true
EOF

    if [ $? -ne 0 ]; then
        echo "❌ Erro ao criar o atalho do Android Studio."
        exit 1
    fi
    echo "✨ Atalho do Android Studio criado com sucesso!"
}

# Função para instalar o Google Chrome oficial
instalar_google_chrome() {
    echo "🎮 Verificando e instalando Google Chrome..."
    if ! command -v google-chrome-stable &> /dev/null; then
        echo "🌐 Google Chrome não encontrado. Tentando instalar via pacman..."

        # Primeiro tenta instalar do repositório oficial do Arch
        run_with_progress "Instalando Google Chrome" \
            sudo pacman -S --noconfirm google-chrome

        if [ $? -ne 0 ]; then
            echo "⚠️ Não foi possível instalar via pacman. Você pode instalar manualmente usando:"
            echo "   yay -S google-chrome (se tiver yay instalado)"
            echo "   ou baixar o .tar.xz do site oficial do Google Chrome"
            return 1
        fi
        echo "✨ Google Chrome instalado com sucesso!"
    else
        echo "🎮 Google Chrome já está instalado."
    fi
    return 0
}


# Função para instalar dependências do Android SDK
instalar_android_sdk() {
    echo "🎮 Iniciando configuração do Android SDK..."
    
    ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools" || { echo "❌ Erro ao criar diretório $ANDROID_SDK_ROOT/cmdline-tools"; exit 1; }
    
    # Remover diretórios inconsistentes de cmdline-tools antes de prosseguir
    if [ -d "$ANDROID_SDK_ROOT/cmdline-tools/latest-2" ]; then
        echo "🔧 Removendo diretório inconsistente: $ANDROID_SDK_ROOT/cmdline-tools/latest-2"
        rm -rf "$ANDROID_SDK_ROOT/cmdline-tools/latest-2"
    fi
    if [ -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
        echo "🔧 Removendo instalação antiga de cmdline-tools para garantir uma instalação limpa."
        rm -rf "$ANDROID_SDK_ROOT/cmdline-tools/latest"
    fi

    # Download e extração do cmdline-tools
    if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
        run_with_progress "Baixando Android Command Line Tools" \
            wget -q "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" \
            -O "/tmp/commandlinetools.zip"
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao baixar Android Command Line Tools."
            exit 1
        fi
        
        # Correção: Certifique-se de que a extração e a atualização não se sobreponham
        run_with_progress "Extraindo Command Line Tools" \
            bash -c "unzip -q /tmp/commandlinetools.zip -d /tmp && \
                     mkdir -p '$ANDROID_SDK_ROOT/cmdline-tools/latest' && \
                     mv /tmp/cmdline-tools/* '$ANDROID_SDK_ROOT/cmdline-tools/latest/' && \
                     rm -rf /tmp/cmdline-tools /tmp/commandlinetools.zip"
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao extrair Command Line Tools."
            exit 1
        fi
    else
        echo "🎮 Android Command Line Tools já estão instalados."
    fi
    
    # Configurar variáveis de ambiente temporárias para o script
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
    export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
    export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
    
    # Configurar variáveis temporárias para que o sdkmanager funcione
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
    export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

    # Atualizar SDK Manager
    echo "🎮 Atualizando SDK Manager..."
    SDKMANAGER="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"

    # Verifica se o sdkmanager existe e é executável
    if [ ! -x "$SDKMANAGER" ]; then
        echo "❌ SDKManager não encontrado ou não executável em $SDKMANAGER"
        return 1
    fi

    # Executa a atualização com timeout
    timeout 120 "$SDKMANAGER" --update > /dev/null 2>&1
    echo "✨ SDK Manager atualizado."

    # Aceitar licenças - usar uma abordagem mais robusta
    echo "🎮 Aceitando licenças do Android SDK..."
    # Criar arquivo com 'y' repetidos para aceitar todas as licenças
    TEMP_LICENSE_FILE="/tmp/android_licenses_accept"
    for i in {1..10}; do echo "y"; done > "$TEMP_LICENSE_FILE"

    # Aceitar licenças usando o arquivo temporário
    "$SDKMANAGER" --licenses < "$TEMP_LICENSE_FILE" > /dev/null 2>&1
    LICENSE_EXIT_CODE=$?
    rm -f "$TEMP_LICENSE_FILE"

    if [ $LICENSE_EXIT_CODE -eq 0 ]; then
        echo "✨ Licenças do Android SDK aceitas com sucesso!"
    else
        echo "⚠️ Algumas licenças podem não ter sido aceitas. Continuando..."
    fi
    
    # Instalar componentes do SDK, verificando se já estão instalados
    echo "🎮 Verificando e instalando componentes do Android SDK..."

    COMPONENTS=(
        "platform-tools"
        "build-tools;34.0.0" # Pode precisar ajustar a versão para a mais recente compatível
        "platforms;android-34" # Pode precisar ajustar a versão para a mais recente compatível
        "cmdline-tools;latest"
    )

    for component in "${COMPONENTS[@]}"; do
        COMPONENT_NAME=$(echo "$component" | cut -d';' -f1 | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) tolower(substr($i,2))}} 1')

        # Verifica se o componente já está instalado
        INSTALLED_CHECK=$("$SDKMANAGER" --list_installed 2>/dev/null | grep -q "^$component" && echo "installed" || echo "not_installed")

        if [ "$INSTALLED_CHECK" = "installed" ]; then
            echo "🎮 $COMPONENT_NAME já está instalado. Pulando."
        else
            echo "🎮 Instalando $COMPONENT_NAME..."
            # Usar timeout para evitar travamentos e instalar sem barra de progresso personalizada
            timeout 300 "$SDKMANAGER" "$component" > /dev/null 2>&1
            INSTALL_EXIT_CODE=$?

            if [ $INSTALL_EXIT_CODE -eq 0 ]; then
                echo "✨ $COMPONENT_NAME instalado com sucesso!"
            else
                echo "❌ Erro ao instalar $COMPONENT_NAME (timeout ou falha)."
            fi
        fi
    done
    
    echo "✨ Android SDK configurado com sucesso!"
    # Rodar flutter doctor --android-licenses após a instalação do SDK com aceitação automática
    echo "🎮 Rodando flutter doctor --android-licenses para garantir..."

    # Aceitar licenças via flutter doctor
    echo "y
y
y
y
y
y
y
y
y
y" | flutter doctor --android-licenses > /dev/null 2>&1

    FLUTTER_LICENSE_EXIT=$?
    if [ $FLUTTER_LICENSE_EXIT -eq 0 ]; then
        echo "✨ Licenças aceitas via Flutter Doctor!"
    else
        echo "⚠️ Algumas licenças podem precisar de aceitação manual."
    fi
}

# Função para desinstalar Flutter completamente
desinstalar_flutter() {
    echo "🧹 Iniciando desinstalação completa do Flutter..."

    # Remover diretório do Flutter
    if [ -d "$HOME/flutter" ]; then
        run_with_progress "Removendo Flutter" rm -rf "$HOME/flutter"
        if [ $? -eq 0 ]; then
            echo "✨ Diretório do Flutter removido com sucesso!"
        else
            echo "❌ Erro ao remover diretório do Flutter."
            return 1
        fi
    else
        echo "🎮 Diretório do Flutter não encontrado."
    fi

    # Remover Android SDK
    if [ -d "$HOME/Android" ]; then
        echo "🧹 Removendo Android SDK..."
        run_with_progress "Removendo Android SDK" rm -rf "$HOME/Android"
        if [ $? -eq 0 ]; then
            echo "✨ Android SDK removido com sucesso!"
        else
            echo "❌ Erro ao remover Android SDK."
        fi
    else
        echo "🎮 Android SDK não encontrado."
    fi

    # Remover Android Studio
    if [ -d "$HOME/android-studio" ]; then
        echo "🧹 Removendo Android Studio..."
        run_with_progress "Removendo Android Studio" rm -rf "$HOME/android-studio"
        if [ $? -eq 0 ]; then
            echo "✨ Android Studio removido com sucesso!"
        else
            echo "❌ Erro ao remover Android Studio."
        fi
    else
        echo "🎮 Android Studio não encontrado."
    fi

    # Remover configurações do .profile
    if [ -f "$HOME/.profile" ]; then
        echo "🧹 Removendo configurações do Flutter do ~/.profile..."
        sed -i '/# Configurações do Flutter/,/# Fim Configurações do Flutter/d' "$HOME/.profile"
        echo "✨ Configurações removidas do ~/.profile!"
    fi

    # Remover atalho do Android Studio
    if [ -f "$HOME/.local/share/applications/android-studio.desktop" ]; then
        rm -f "$HOME/.local/share/applications/android-studio.desktop"
        echo "✨ Atalho do Android Studio removido!"
    fi

    echo ""
    echo "🎉 Desinstalação completa do Flutter concluída!"
    echo "   Para aplicar as mudanças nas variáveis de ambiente, reinicie o terminal ou execute 'source ~/.profile'"
}

# Função de correção rápida do Flutter (integrada)
corrigir_flutter_rapido() {
    echo ""
    echo ""
    echo "==============================================="
    echo "        CORREÇÃO RÁPIDA DO FLUTTER"
    echo "==============================================="

    # Aplicar variáveis de ambiente imediatamente - usando sintaxe correta
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    export PATH="$PATH:$HOME/flutter/bin"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

    echo "✅ Variáveis de ambiente aplicadas na sessão atual"

    # Verificar se o diretório do Flutter existe
    if [ ! -d "$HOME/flutter" ]; then
        echo "❌ Diretório ~/flutter NÃO encontrado!"
        echo "💡 O Flutter precisa ser instalado primeiro."
        echo "   Use a opção 1 do menu para instalar o Flutter."
        return 1
    fi

    echo "✅ Diretório ~/flutter encontrado"

    # Testar Flutter
    echo "🧪 Testando comandos do Flutter..."

    if command -v flutter &> /dev/null; then
        echo "✅ Comando 'flutter' está funcionando!"

        echo "📋 Versão do Flutter:"
        flutter --version

        echo ""
        echo "🩺 Executando Flutter Doctor..."
        local doctor_output=$(flutter doctor 2>&1)
        echo "$doctor_output"

        local critical_errors=$(echo "$doctor_output" | grep -c "✗")
        local warnings=$(echo "$doctor_output" | grep -c "!")

        if [ $critical_errors -eq 0 ]; then
            echo ""
            echo "🎉 PERFEITO! Flutter funcionando sem erros críticos!"
        else
            echo ""
            echo "⚠️ Encontrados $critical_errors erro(s) e $warnings aviso(s)"
        fi

        return 0
    else
        echo "❌ Comando 'flutter' NÃO está funcionando!"

        # Tentar corrigir as configurações
        echo "🔧 Tentando corrigir configurações permanentemente..."

        # Verificar estado atual dos arquivos de configuração
        echo "🔍 Verificando arquivos de configuração..."

        local current_shell=$(basename "$SHELL" 2>/dev/null || echo "bash")
        local config_file=""

        case "$current_shell" in
            "zsh")
                config_file="$HOME/.zshrc"
                ;;
            "bash")
                config_file="$HOME/.bashrc"
                ;;
            *)
                config_file="$HOME/.profile"
                ;;
        esac

        echo "📁 Usando arquivo: $config_file"

        # Verificar se as configurações existem
        if ! grep -q "flutter/bin" "$config_file" 2>/dev/null; then
            echo "❌ Configurações do Flutter não encontradas em $config_file"
            echo "🔧 Adicionando configurações..."

            # Reconfigurar variáveis de ambiente
            configurar_variaveis_ambiente

            echo "✅ Configurações adicionadas!"
        else
            echo "✅ Configurações encontradas, mas podem estar incorretas."
            echo "🔧 Reconfigurando..."
            configurar_variaveis_ambiente
        fi

        # Aplicar na sessão atual usando sintaxe correta
        export ANDROID_HOME="$HOME/Android/Sdk"
        export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
        export PATH="$PATH:$HOME/flutter/bin"
        export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
        export PATH="$PATH:$ANDROID_HOME/platform-tools"
        export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

        # Testar novamente
        if command -v flutter &> /dev/null; then
            echo "✅ Correção bem-sucedida! Flutter funcionando na sessão atual."
            echo ""
            echo "⚠️  IMPORTANTE: Para funcionar em novos terminais:"
            echo "   1. Feche COMPLETAMENTE este terminal"
            echo "   2. Abra um novo terminal"
            echo "   3. Teste: flutter --version"
            echo ""
            echo "🔧 OU EXECUTE AGORA (mais rápido):"
            echo "   source ~/.zprofile"
            echo "   source $config_file"
            return 0
        else
            echo "❌ Correção falhou. Tentando método alternativo..."
            echo ""

            # Verificar se o flutter existe fisicamente
            if [ ! -f "$HOME/flutter/bin/flutter" ]; then
                echo "   ❌ Arquivo flutter NÃO existe em ~/flutter/bin/flutter"
                echo "   💡 Execute a opção 1 para reinstalar o Flutter"
                return 1
            fi

            echo "   ✅ Arquivo flutter existe em ~/flutter/bin/flutter"

            # Verificar e corrigir permissões
            if [ ! -x "$HOME/flutter/bin/flutter" ]; then
                echo "   🔧 Corrigindo permissões do Flutter..."
                chmod +x "$HOME/flutter/bin/flutter"
                echo "   ✅ Permissões corrigidas"
            fi

            # MÉTODO DEFINITIVO: Configuração específica para Oh-My-Zsh
            echo "🔧 Aplicando método definitivo para Arch Linux + Oh-My-Zsh..."

            # Verificar se Oh-My-Zsh está instalado
            if [ -d "$HOME/.oh-my-zsh" ]; then
                echo "   📋 Oh-My-Zsh detectado - usando método específico"

                # Criar arquivo de configuração no diretório custom do Oh-My-Zsh
                local custom_flutter_file="$HOME/.oh-my-zsh/custom/flutter.zsh"

                # Limpar arquivo antigo se existir
                if [ -f "$custom_flutter_file" ]; then
                    rm "$custom_flutter_file"
                fi

                # Criar novo arquivo de configuração
                cat > "$custom_flutter_file" << 'EOF'
# Flutter Configuration for Oh-My-Zsh
# This file is loaded by Oh-My-Zsh automatically

# Flutter PATH
export PATH="$PATH:$HOME/flutter/bin"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Chrome for Flutter web development
export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

# Verify Flutter is available
if [[ -d "$HOME/flutter" ]]; then
    export FLUTTER_INSTALLED=true
else
    export FLUTTER_INSTALLED=false
fi
EOF

                echo "   ✅ Arquivo flutter.zsh criado em ~/.oh-my-zsh/custom/"

                # Limpar configurações duplicadas do zshrc principal
                if [ -f "$HOME/.zshrc" ]; then
                    cp "$HOME/.zshrc" "$HOME/.zshrc.backup_$(date +%s)"
                    sed -i '/export.*flutter/d' "$HOME/.zshrc" 2>/dev/null
                    sed -i '/export.*ANDROID/d' "$HOME/.zshrc" 2>/dev/null
                    sed -i '/export.*CHROME_EXECUTABLE/d' "$HOME/.zshrc" 2>/dev/null
                    sed -i '/# Configurações do Flutter/,/# Fim Configurações do Flutter/d' "$HOME/.zshrc" 2>/dev/null
                    echo "   🧹 Configurações duplicadas removidas do ~/.zshrc"
                fi

            else
                echo "   📁 Oh-My-Zsh não detectado - usando método padrão"

                # Método padrão para shells sem Oh-My-Zsh
                if [ -f "$config_file" ]; then
                    cp "$config_file" "${config_file}.backup_$(date +%s)"
                    sed -i '/export.*flutter/d' "$config_file" 2>/dev/null
                    sed -i '/export.*ANDROID/d' "$config_file" 2>/dev/null
                    sed -i '/export.*CHROME_EXECUTABLE/d' "$config_file" 2>/dev/null
                    sed -i '/# Configurações do Flutter/,/# Fim Configurações do Flutter/d' "$config_file" 2>/dev/null
                fi

                echo "" >> "$config_file"
                echo "# Configurações do Flutter - Método Padrão" >> "$config_file"
                echo 'export PATH="$PATH:$HOME/flutter/bin"' >> "$config_file"
                echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> "$config_file"
                echo 'export ANDROID_SDK_ROOT="$HOME/Android/Sdk"' >> "$config_file"
                echo 'export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"' >> "$config_file"
                echo "# Fim Configurações do Flutter" >> "$config_file"

                echo "   ✅ Configurações adicionadas ao $config_file"
            fi

            # Aplicar imediatamente na sessão atual
            export PATH="$PATH:$HOME/flutter/bin"
            export ANDROID_HOME="$HOME/Android/Sdk"
            export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
            export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

            # Testar uma última vez
            if command -v flutter &> /dev/null; then
                echo "   🎉 SUCESSO! Correção funcionou com método alternativo!"
                echo ""
                echo "📋 PASSOS FINAIS (ESCOLHA UM):"
                echo ""
                echo "   OPÇÃO A (MAIS RÁPIDO):"
                echo "   1. 🔧 Execute: source ~/.zprofile"
                echo "   2. 🧪 Teste: flutter --version"
                echo ""
                echo "   OPÇÃO B (TRADICIONAL):"
                echo "   1. 🚪 FECHE COMPLETAMENTE este terminal"
                echo "   2. 🆕 ABRA um novo terminal"
                echo "   3. 🧪 Teste: flutter --version"
                echo ""
                return 0
            else
                echo "   ❌ Ainda não funcionou. Diagnóstico avançado:"
                echo ""
                echo "🆘 INFORMAÇÕES DE DEPURAÇÃO:"
                echo "   🗂️  Shell: $current_shell"
                echo "   📁 Arquivo config: $config_file"
                echo "   📍 PATH atual: $PATH"
                echo "   🎯 Flutter location: $(which flutter 2>/dev/null || echo 'NÃO ENCONTRADO')"
                echo ""
                echo "📝 SOLUÇÕES MANUAIS:"
                echo "   1. Execute manualmente: export PATH=\"\$PATH:\$HOME/flutter/bin\""
                echo "   2. Depois teste: flutter --version"
                echo "   3. Se funcionar, o problema é na configuração permanente"
                echo "   4. Caso contrário, use opção 1 (reinstalar Flutter)"
                echo ""
                return 1
            fi
        fi
    fi
}

# Função para verificar e corrigir problemas do Flutter
verificar_e_corrigir() {
    local doctor_output
    doctor_output=$(flutter doctor -v 2>&1)
    # Não vamos sair se houver erro aqui, pois a função tenta corrigir
    
    # Instalar Google Chrome
    instalar_google_chrome
    if [ $? -ne 0 ]; then
        echo "⚠️ Não foi possível instalar o Google Chrome automaticamente. Por favor, instale-o manualmente."
    fi
    
    # Instalar Android Studio
    instalar_android_studio

    # Criar atalho para Android Studio
    criar_atalho_android_studio

    # Verificar Android SDK (a função já trata a instalação e licenças)
    instalar_android_sdk

    # Instalar dependências do sistema
    local deps=(
        "ninja"
        "cmake"
        "clang"
        "pkgconf"
        "gtk3"
        "xz"
        "jdk17-openjdk"
    )
    
    echo "🎮 Verificando dependências do sistema..."
    for dep in "${deps[@]}"; do
        if ! pacman -Qi "$dep" &> /dev/null; then
            run_with_progress "Instalando $dep" \
                sudo pacman -S --noconfirm "$dep"
            if [ $? -ne 0 ]; then
                echo "❌ Erro ao instalar $dep."
            fi
        else
            echo "🎮 $dep já está instalado."
        fi
    done
    
    # Configurar variáveis de ambiente permanentemente
    configurar_variaveis_ambiente

    # Aplicar variáveis na sessão atual para que o flutter funcione imediatamente - usando sintaxe correta
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    export PATH="$PATH:$HOME/flutter/bin"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

    # Limpar o cache do Flutter para forçar uma nova detecção
    echo "🔧 Limpando o cache do Flutter para forçar uma nova detecção de ferramentas..."
    if command -v flutter &> /dev/null; then
        flutter clean > /dev/null 2>&1
        echo "✨ Cache do Flutter limpo."
    else
        echo "⚠️ Flutter não encontrado para limpar cache. Continuando..."
    fi

    # Garantir configurações permanentes
    garantir_configuracao_permanente
}

# Função para realizar a instalação completa do Flutter e dependências
instalar_completo() {
    # Baixar e instalar Flutter
    run_with_progress "Baixando Flutter" \
        wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz" \
        -O "/tmp/flutter.tar.xz"
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao baixar Flutter."
        exit 1
    fi

    run_with_progress "Extraindo Flutter" \
        tar -xf "/tmp/flutter.tar.xz" -C "$HOME"
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao extrair Flutter."
        exit 1
    fi
    rm "/tmp/flutter.tar.xz"

    # Configurar variáveis de ambiente
    configurar_variaveis_ambiente

    # Verificar e corrigir problemas (inclui a instalação do SDK, Android Studio e Chrome)
    verificar_e_corrigir

    # Garantir que as configurações sejam aplicadas corretamente
    garantir_configuracao_permanente

    # Verificar se o Flutter está funcionando
    if verificar_flutter_funcionando; then
        echo "🎉 SUCESSO! Flutter instalado e funcionando corretamente!"
    else
        echo "⚠️ Flutter instalado, mas pode precisar de reinicialização do terminal."
        echo "   Por favor, feche e reabra o terminal e teste: flutter --version"
    fi
}

# Início do script
# Limpa a linha de progresso antes de pedir a senha do sudo, se necessário
echo -ne "\r" # Limpa a linha de progresso
echo "🎮 Atualizando repositórios do sistema..."
sudo pacman -Syu --noconfirm > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Erro ao atualizar repositórios. Verifique sua conexão ou permissões."
    exit 1
fi
echo "✨ Repositórios atualizados com sucesso!"
echo "" # Nova linha após a atualização para melhor legibilidade

# Variável para controlar se o Flutter está instalado
FLUTTER_INSTALLED=false
# source ~/.profile é executado aqui para garantir que o script saiba o estado atual
source "$HOME/.profile" > /dev/null 2>&1
if command -v flutter &> /dev/null; then
    FLUTTER_INSTALLED=true
fi

# Menu principal
while true; do
    echo ""
    echo "╭────────────────────────────────────────╮"
    echo "│         ✨ Instalador Flutter ✨       │"
    echo "╰────────────────────────────────────────╯"
    echo ""

    if [ "$FLUTTER_INSTALLED" = true ]; then
        echo "🎮 Flutter já está instalado! Verificando por erros..."
        # Executa flutter doctor para checar erros, mas não impede o script de continuar
        # Redireciona para /dev/null para evitar poluir o menu
        flutter doctor > /tmp/flutter_doctor.log 2>&1 
        ERROS=$(grep -c "✗" /tmp/flutter_doctor.log)

        if [[ "$ERROS" -gt 0 ]]; then
            echo "❌ $ERROS problema(s) detectado(s)!"
            echo ""
            echo "   1) Reinstalar o Flutter completamente (recomendado para problemas graves)"
            echo "   2) Apenas corrigir dependências e configurações (Android Studio, SDK, Chrome, etc.)"
            echo "   3) Correção rápida do Flutter (se comando 'flutter' não funciona)"
            echo "   4) Desinstalar o Flutter completamente"
        else
            echo "✨ Flutter já está instalado e funcionando corretamente!"
            echo ""
            echo "   1) Reinstalar o Flutter completamente (se algo estiver estranho)"
            echo "   2) Verificar e corrigir dependências (Android Studio, SDK, Chrome, etc.)"
            echo "   3) Correção rápida do Flutter (testar e corrigir comandos)"
            echo "   4) Desinstalar o Flutter completamente"
        fi
        echo "   5) Sair"
        echo ""
        read -r -p "Escolha uma opção: " opcao

        case "$opcao" in
            1)
                echo "Removendo instalação antiga do Flutter..."
                run_with_progress "Removendo Flutter antigo" rm -rf "$HOME/flutter"
                if [ $? -ne 0 ]; then
                    echo "❌ Erro ao remover Flutter antigo."
                    exit 1
                fi
                instalar_completo
                break # Sai do loop após a instalação
                ;;
            2)
                verificar_e_corrigir
                break # Sai do loop após a correção
                ;;
            3)
                corrigir_flutter_rapido
                echo ""
                read -r -p "Pressione ENTER para voltar ao menu..." dummy
                ;;
            4)
                read -r -p "🚨 Tem certeza que deseja desinstalar completamente o Flutter? (s/N): " confirma
                if [[ "$confirma" =~ ^[sS]$ ]]; then
                    desinstalar_flutter
                    exit 0
                else
                    echo "⚠️ Desinstalação cancelada."
                fi
                ;;
            5)
                echo "Saindo..."
                exit 0
                ;;
            *)
                echo "❌ Opção inválida! Por favor, escolha novamente."
                ;;
        esac
    else
        echo "🎮 Flutter não encontrado no sistema."
        echo ""
        echo "   1) Instalar Flutter e todas as dependências (Android Studio, SDK, Chrome, etc.)"
        echo "   2) Correção rápida (se Flutter já estiver instalado mas não detectado)"
        echo "   3) Sair"
        echo ""
        read -r -p "Escolha uma opção: " opcao

        case "$opcao" in
            1)
                instalar_completo
                break # Sai do loop após a instalação
                ;;
            2)
                corrigir_flutter_rapido
                echo ""
                read -r -p "Pressione ENTER para voltar ao menu..." dummy
                ;;
            3)
                echo "Saindo..."
                exit 0
                ;;
            *)
                echo "❌ Opção inválida! Por favor, escolha novamente."
                ;;
        esac
    fi
done

# Recarregar variáveis de ambiente (novamente, para o próprio script e esta sessão)
source "$HOME/.profile" || { echo "❌ Erro ao recarregar ~/.profile"; exit 1; }

# Verificação final
echo ""
echo "============================================"
echo "  🎉 VERIFICAÇÃO FINAL DO FLUTTER 🎉    "
echo "============================================"

# Usar nossa função de verificação melhorada
if verificar_flutter_funcionando; then
    echo ""
    echo "🎊 PARABÉNS! Flutter instalado e funcionando PERFEITAMENTE!"
    echo "🚀 Você já pode usar Flutter em qualquer diretório!"
else
    echo ""
    echo "⚠️ Flutter instalado, mas configurações podem precisar de reinicialização."
fi

echo ""
echo "============================================"
echo "           📝 INSTRUÇÕES FINAIS             "
echo "============================================"
echo "1. 🔄 FECHE E REABRA seu terminal (IMPORTANTE!)"
echo "2. 🧪 Teste com: flutter --version"
echo "3. 🩺 Verifique tudo com: flutter doctor"
echo "4. 🎯 O Flutter funcionará em QUALQUER pasta/diretório"
echo ""
echo "💡 Se ainda não funcionar após reiniciar:"
echo "   - Execute: source ~/.zshrc (para zsh)"
echo "   - Ou execute: source ~/.bashrc (para bash)"
echo "============================================"
