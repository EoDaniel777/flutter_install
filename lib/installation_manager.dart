import 'dart:io';

class InstallationManager {
  static Future<bool> isLinux() async {
    return Platform.isLinux;
  }

  static Future<bool> isWindows() async {
    return Platform.isWindows;
  }

  static Future<bool> isMacOS() async {
    return Platform.isMacOS;
  }

  static Future<bool> isAndroid() async {
    return Platform.isAndroid;
  }

  static Future<bool> isIOS() async {
    return Platform.isIOS;
  }

  // Função para executar comandos shell no Linux
  static Future<ProcessResult?> runLinuxCommand(String command) async {
    if (!await isLinux()) {
      print("Comando só pode ser executado no Linux");
      return null;
    }

    try {
      // Dividir o comando em partes para Process.run
      List<String> parts = command.split(' ');
      String executable = parts[0];
      List<String> args = parts.skip(1).toList();

      ProcessResult result = await Process.run(executable, args, runInShell: true);
      return result;
    } catch (e) {
      print("Erro ao executar comando: $e");
      return null;
    }
  }

  // Função para executar comandos shell no Windows
  static Future<ProcessResult?> runWindowsCommand(String command) async {
    if (!await isWindows()) {
      print("Comando só pode ser executado no Windows");
      return null;
    }

    try {
      List<String> parts = command.split(' ');
      String executable = parts[0];
      List<String> args = parts.skip(1).toList();

      ProcessResult result = await Process.run(executable, args, runInShell: true);
      return result;
    } catch (e) {
      print("Erro ao executar comando: $e");
      return null;
    }
  }

  // Função para executar comandos shell no macOS
  static Future<ProcessResult?> runMacOSCommand(String command) async {
    if (!await isMacOS()) {
      print("Comando só pode ser executado no macOS");
      return null;
    }

    try {
      List<String> parts = command.split(' ');
      String executable = parts[0];
      List<String> args = parts.skip(1).toList();

      ProcessResult result = await Process.run(executable, args, runInShell: true);
      return result;
    } catch (e) {
      print("Erro ao executar comando: $e");
      return null;
    }
  }

  // Função para verificar se o Dart já está instalado
  static Future<bool> isDartInstalled() async {
    try {
      if (await isLinux() || await isMacOS()) {
        ProcessResult? result = await runLinuxCommand('dart --version');
        return result?.exitCode == 0;
      } else if (await isWindows()) {
        ProcessResult? result = await runWindowsCommand('dart --version');
        return result?.exitCode == 0;
      }
      return false;
    } catch (e) {
      print("Erro ao verificar instalação do Dart: $e");
      return false;
    }
  }

  // Função para verificar se o Flutter já está instalado
  static Future<bool> isFlutterInstalled() async {
    try {
      if (await isLinux() || await isMacOS()) {
        ProcessResult? result = await runLinuxCommand('flutter --version');
        return result?.exitCode == 0;
      } else if (await isWindows()) {
        ProcessResult? result = await runWindowsCommand('flutter --version');
        return result?.exitCode == 0;
      }
      return false;
    } catch (e) {
      print("Erro ao verificar instalação do Flutter: $e");
      return false;
    }
  }

  // Função para verificar se o Android Studio já está instalado
  static Future<bool> isAndroidStudioInstalled() async {
    try {
      String homeDir = Platform.environment['HOME'] ?? '/home/user';
      String androidStudioDir = '$homeDir/android-studio';
      return Directory(androidStudioDir).existsSync();
    } catch (e) {
      print("Erro ao verificar instalação do Android Studio: $e");
      return false;
    }
  }

  // Função para verificar se o VS Code já está instalado
  static Future<bool> isVSCodeInstalled() async {
    try {
      if (await isLinux() || await isMacOS()) {
        ProcessResult? result = await runLinuxCommand('code --version');
        return result?.exitCode == 0;
      } else if (await isWindows()) {
        ProcessResult? result = await runWindowsCommand('code --version');
        return result?.exitCode == 0;
      }
      return false;
    } catch (e) {
      print("Erro ao verificar instalação do VS Code: $e");
      return false;
    }
  }

  // Função para verificar se o Google Chrome já está instalado
  static Future<bool> isChromeInstalled() async {
    try {
      if (await isLinux() || await isMacOS()) {
        ProcessResult? result = await runLinuxCommand('google-chrome-stable --version');
        return result?.exitCode == 0;
      } else if (await isWindows()) {
        ProcessResult? result = await runWindowsCommand('chrome --version');
        return result?.exitCode == 0;
      }
      return false;
    } catch (e) {
      print("Erro ao verificar instalação do Chrome: $e");
      return false;
    }
  }

  // Função para instalar o Dart (na verdade, Dart vem incluído no Flutter SDK)
  static Future<bool> installDart(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    // O Dart vem incluído no Flutter SDK, então instalamos o Flutter
    return await installFlutter(installPath, onProgressUpdate);
  }

  // Função para instalar o Flutter
  static Future<bool> installFlutter(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      if (await isLinux()) {
        return await _installFlutterLinux(installPath, onProgressUpdate);
      } else if (await isWindows()) {
        return await _installFlutterWindows(installPath, onProgressUpdate);
      } else if (await isMacOS()) {
        return await _installFlutterMacOS(installPath, onProgressUpdate);
      }
      return false;
    } catch (e) {
      print("Erro ao instalar Flutter: $e");
      return false;
    }
  }

  // Função para instalar o Android Studio
  static Future<bool> installAndroidStudio(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      if (await isLinux()) {
        return await _installAndroidStudioLinux(installPath, onProgressUpdate);
      } else if (await isWindows()) {
        return await _installAndroidStudioWindows(installPath, onProgressUpdate);
      } else if (await isMacOS()) {
        return await _installAndroidStudioMacOS(installPath, onProgressUpdate);
      }
      return false;
    } catch (e) {
      print("Erro ao instalar Android Studio: $e");
      return false;
    }
  }

  // Função para instalar o VS Code
  static Future<bool> installVSCode(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      if (await isLinux()) {
        return await _installVSCodeLinux(onProgressUpdate);
      } else if (await isWindows()) {
        return await _installVSCodeWindows(onProgressUpdate);
      } else if (await isMacOS()) {
        return await _installVSCodeMacOS(onProgressUpdate);
      }
      return false;
    } catch (e) {
      print("Erro ao instalar VS Code: $e");
      return false;
    }
  }

  // Função para instalar o Google Chrome
  static Future<bool> installChrome(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      if (await isLinux()) {
        return await _installChromeLinux(onProgressUpdate);
      } else if (await isWindows()) {
        return await _installChromeWindows(onProgressUpdate);
      } else if (await isMacOS()) {
        return await _installChromeMacOS(onProgressUpdate);
      }
      return false;
    } catch (e) {
      print("Erro ao instalar Chrome: $e");
      return false;
    }
  }

  // Instalação individual do Flutter no Linux
  static Future<bool> _installFlutterLinux(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      String homeDir = Platform.environment['HOME'] ?? '/home/user';
      String flutterDir = installPath.isEmpty ? '$homeDir/flutter' : installPath;

      // Verificar se já está instalado
      if (Directory(flutterDir).existsSync()) {
        onProgressUpdate(0.1, "Flutter já está instalado em $flutterDir. Pulando instalação.");
        onProgressUpdate(1.0, "Flutter já instalado.");
        return true;
      }

      onProgressUpdate(0.1, "Baixando Flutter SDK...");
      String downloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz";

      ProcessResult? result = await runLinuxCommand('wget -q "$downloadUrl" -O "/tmp/flutter.tar.xz"');
      if (result?.exitCode != 0) {
        print("Erro ao baixar Flutter: ${result?.stderr}");
        return false;
      }

      onProgressUpdate(0.5, "Extraindo Flutter...");
      result = await runLinuxCommand('tar -xf "/tmp/flutter.tar.xz" -C "$homeDir"');
      if (result?.exitCode != 0) {
        print("Erro ao extrair Flutter: ${result?.stderr}");
        return false;
      }

      await runLinuxCommand('rm "/tmp/flutter.tar.xz"');

      onProgressUpdate(0.8, "Configurando variáveis de ambiente...");
      await _configureEnvironmentVariables(homeDir, '$homeDir/Android/Sdk');

      onProgressUpdate(1.0, "Flutter instalado com sucesso!");
      return true;
    } catch (e) {
      print("Erro durante a instalação do Flutter: $e");
      return false;
    }
  }

  // Instalação individual do Android Studio no Linux
  static Future<bool> _installAndroidStudioLinux(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      String homeDir = Platform.environment['HOME'] ?? '/home/user';
      String androidStudioDir = installPath.isEmpty ? '$homeDir/android-studio' : installPath;
      String androidSdkRoot = '$homeDir/Android/Sdk';

      if (Directory(androidStudioDir).existsSync()) {
        onProgressUpdate(0.1, "Android Studio já está instalado. Pulando instalação.");
        onProgressUpdate(1.0, "Android Studio já instalado.");
        return true;
      }

      onProgressUpdate(0.1, "Baixando Android Studio...");
      String studioDownloadUrl = "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.3.2.14/android-studio-2024.3.2.14-linux.tar.gz";
      String studioZipFile = "/tmp/android-studio.tar.gz";

      ProcessResult? result = await runLinuxCommand('wget -q "$studioDownloadUrl" -O "$studioZipFile"');
      if (result?.exitCode != 0) {
        print("Erro ao baixar Android Studio: ${result?.stderr}");
        return false;
      }

      onProgressUpdate(0.4, "Extraindo Android Studio...");
      result = await runLinuxCommand('tar -xzf "$studioZipFile" -C "$homeDir"');
      if (result?.exitCode != 0) {
        print("Erro ao extrair Android Studio: ${result?.stderr}");
        return false;
      }

      await runLinuxCommand('rm "$studioZipFile"');

      onProgressUpdate(0.6, "Configurando Android SDK...");
      Directory('$androidSdkRoot/cmdline-tools').createSync(recursive: true);

      // Baixar e configurar cmdline-tools
      onProgressUpdate(0.7, "Baixando Android Command Line Tools...");
      String cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip";
      String cmdlineZipFile = "/tmp/commandlinetools.zip";

      result = await runLinuxCommand('wget -q "$cmdlineToolsUrl" -O "$cmdlineZipFile"');
      if (result?.exitCode != 0) {
        print("Erro ao baixar cmdline-tools: ${result?.stderr}");
        return false;
      }

      result = await runLinuxCommand('unzip -q "$cmdlineZipFile" -d /tmp && '
                                    'mkdir -p "$androidSdkRoot/cmdline-tools/latest" && '
                                    'mv /tmp/cmdline-tools/* "$androidSdkRoot/cmdline-tools/latest/" && '
                                    'rm -rf /tmp/cmdline-tools "$cmdlineZipFile"');
      if (result?.exitCode != 0) {
        print("Erro ao extrair cmdline-tools: ${result?.stderr}");
        return false;
      }

      onProgressUpdate(0.9, "Configurando variáveis de ambiente...");
      await _configureEnvironmentVariables(homeDir, androidSdkRoot);

      onProgressUpdate(1.0, "Android Studio instalado com sucesso!");
      return true;
    } catch (e) {
      print("Erro durante a instalação do Android Studio: $e");
      return false;
    }
  }

  // Instalação individual do VS Code no Linux
  static Future<bool> _installVSCodeLinux(
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      onProgressUpdate(0.1, "Verificando VS Code...");
      ProcessResult? result = await runLinuxCommand('code --version');
      if (result?.exitCode == 0) {
        onProgressUpdate(0.5, "VS Code já está instalado.");
        onProgressUpdate(1.0, "VS Code já instalado.");
        return true;
      }

      onProgressUpdate(0.3, "Instalando VS Code...");
      result = await runLinuxCommand('sudo pacman -S --noconfirm code');
      if (result?.exitCode != 0) {
        print("Erro ao instalar VS Code: ${result?.stderr}");
        return false;
      }

      onProgressUpdate(1.0, "VS Code instalado com sucesso!");
      return true;
    } catch (e) {
      print("Erro durante a instalação do VS Code: $e");
      return false;
    }
  }

  // Instalação individual do Chrome no Linux
  static Future<bool> _installChromeLinux(
    Function(double progress, String status) onProgressUpdate,
  ) async {
    try {
      onProgressUpdate(0.1, "Verificando Google Chrome...");
      ProcessResult? result = await runLinuxCommand('google-chrome-stable --version');
      if (result?.exitCode == 0) {
        onProgressUpdate(0.5, "Google Chrome já está instalado.");
        onProgressUpdate(1.0, "Google Chrome já instalado.");
        return true;
      }

      onProgressUpdate(0.3, "Instalando Google Chrome...");
      result = await runLinuxCommand('sudo pacman -S --noconfirm google-chrome');
      if (result?.exitCode != 0) {
        print("Erro ao instalar Google Chrome: ${result?.stderr}");
        return false;
      }

      onProgressUpdate(1.0, "Google Chrome instalado com sucesso!");
      return true;
    } catch (e) {
      print("Erro durante a instalação do Chrome: $e");
      return false;
    }
  }

  // Implementações básicas para Windows
  static Future<bool> _installFlutterWindows(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando Flutter no Windows...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "Flutter instalado (simulação)");
    return true;
  }

  static Future<bool> _installAndroidStudioWindows(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando Android Studio no Windows...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "Android Studio instalado (simulação)");
    return true;
  }

  static Future<bool> _installVSCodeWindows(
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando VS Code no Windows...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "VS Code instalado (simulação)");
    return true;
  }

  static Future<bool> _installChromeWindows(
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando Chrome no Windows...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "Chrome instalado (simulação)");
    return true;
  }

  // Implementações básicas para macOS
  static Future<bool> _installFlutterMacOS(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando Flutter no macOS...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "Flutter instalado (simulação)");
    return true;
  }

  static Future<bool> _installAndroidStudioMacOS(
    String installPath,
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando Android Studio no macOS...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "Android Studio instalado (simulação)");
    return true;
  }

  static Future<bool> _installVSCodeMacOS(
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando VS Code no macOS...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "VS Code instalado (simulação)");
    return true;
  }

  static Future<bool> _installChromeMacOS(
    Function(double progress, String status) onProgressUpdate,
  ) async {
    onProgressUpdate(0.5, "Instalando Chrome no macOS...");
    await Future.delayed(Duration(seconds: 2));
    onProgressUpdate(1.0, "Chrome instalado (simulação)");
    return true;
  }

  // Função para instalar o Flutter no Linux (baseado no script shell)
  static Future<bool> installFlutterOnLinux({
    bool installFlutter = true,
    bool installAndroidStudio = true,
    bool installChrome = true,
    bool installVSCode = true,
    String installLocation = '',
    String javaVersion = 'java-17-openjdk',
    required Function(double progress, String status) onProgressUpdate,
  }) async {
    try {
      String homeDir = Platform.environment['HOME'] ?? '/home/user';
      String flutterDir = installLocation.isEmpty ? '$homeDir/flutter' : installLocation;
      String androidSdkRoot = '$homeDir/Android/Sdk';
      String androidStudioDir = '$homeDir/android-studio';

      // Passo 1: Atualizar repositórios
      onProgressUpdate(0.05, "Atualizando repositórios do sistema...");
      
      ProcessResult? result = await runLinuxCommand('sudo pacman -Syu --noconfirm');
      if (result?.exitCode != 0) {
        print("Erro ao atualizar repositórios: ${result?.stderr}");
        return false;
      }

      // Passo 2: Instalar dependências do sistema
      onProgressUpdate(0.10, "Instalando dependências do sistema...");
      List<String> deps = [
        "ninja",
        "cmake",
        "clang",
        "pkgconf",
        "gtk3",
        "xz",
        javaVersion.contains('17') ? 'jdk17-openjdk' : 'jdk11-openjdk',
        "unzip",
        "curl",
        "wget"
      ];

      for (String dep in deps) {
        onProgressUpdate(0.10 + (0.05 * (deps.indexOf(dep) + 1) / deps.length), "Instalando dependência: $dep");
        result = await runLinuxCommand('sudo pacman -S --noconfirm "$dep"');
        if (result?.exitCode != 0) {
          print("Erro ao instalar $dep: ${result?.stderr}");
          // Continuar mesmo se uma dependência falhar
        }
      }

      // Passo 3: Instalar Flutter (se selecionado)
      if (installFlutter) {
        onProgressUpdate(0.20, "Verificando Flutter...");
        if (Directory(flutterDir).existsSync()) {
          onProgressUpdate(0.22, "Flutter já está instalado em $flutterDir. Pulando instalação.");
        } else {
          onProgressUpdate(0.25, "Baixando Flutter...");
          String downloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz";
          
          result = await runLinuxCommand('wget -q "$downloadUrl" -O "/tmp/flutter.tar.xz"');
          if (result?.exitCode != 0) {
            print("Erro ao baixar Flutter: ${result?.stderr}");
            return false;
          }

          // Extrair o Flutter
          onProgressUpdate(0.30, "Extraindo Flutter...");
          result = await runLinuxCommand('tar -xf "/tmp/flutter.tar.xz" -C "$homeDir"');
          if (result?.exitCode != 0) {
            print("Erro ao extrair Flutter: ${result?.stderr}");
            return false;
          }

          // Remover arquivo temporário
          await runLinuxCommand('rm "/tmp/flutter.tar.xz"');
        }
      }

      // Passo 4: Instalar Google Chrome (se selecionado)
      if (installChrome) {
        onProgressUpdate(0.35, "Verificando Google Chrome...");
        result = await runLinuxCommand('google-chrome-stable --version');
        if (result?.exitCode != 0) {
          onProgressUpdate(0.40, "Instalando Google Chrome...");
          result = await runLinuxCommand('sudo pacman -S --noconfirm google-chrome');
          if (result?.exitCode != 0) {
            print("Erro ao instalar Google Chrome: ${result?.stderr}");
            // Continuar mesmo se falhar
          }
        } else {
          onProgressUpdate(0.40, "Google Chrome já está instalado.");
        }
      }

      // Passo 5: Instalar VS Code (se selecionado)
      if (installVSCode) {
        onProgressUpdate(0.42, "Verificando VS Code...");
        result = await runLinuxCommand('code --version');
        if (result?.exitCode != 0) {
          onProgressUpdate(0.45, "Instalando VS Code...");
          result = await runLinuxCommand('sudo pacman -S --noconfirm code');
          if (result?.exitCode != 0) {
            print("Erro ao instalar VS Code: ${result?.stderr}");
            // Continuar mesmo se falhar
          }
        } else {
          onProgressUpdate(0.45, "VS Code já está instalado.");
        }
      }

      // Passo 6: Instalar Android Studio (se selecionado)
      if (installAndroidStudio) {
        onProgressUpdate(0.50, "Verificando Android Studio...");
        if (Directory(androidStudioDir).existsSync()) {
          onProgressUpdate(0.52, "Android Studio já está instalado em $androidStudioDir. Pulando instalação.");
        } else {
          onProgressUpdate(0.55, "Instalando Android Studio...");
          String studioDownloadUrl = "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.3.2.14/android-studio-2024.3.2.14-linux.tar.gz";
          String studioZipFile = "/tmp/android-studio.tar.gz";

          result = await runLinuxCommand('wget -q "$studioDownloadUrl" -O "$studioZipFile"');
          if (result?.exitCode != 0) {
            print("Erro ao baixar Android Studio: ${result?.stderr}");
            return false;
          }

          result = await runLinuxCommand('tar -xzf "$studioZipFile" -C "$homeDir"');
          if (result?.exitCode != 0) {
            print("Erro ao extrair Android Studio: ${result?.stderr}");
            return false;
          }

          await runLinuxCommand('rm "$studioZipFile"');
          
          // Tentar inicializar o Android Studio para que ele crie os arquivos de configuração
          onProgressUpdate(0.57, "Inicializando Android Studio pela primeira vez...");
          if (File('$androidStudioDir/bin/studio.sh').existsSync()) {
            // Executar o Android Studio em segundo plano e aguardar 10 segundos
            Process.start('$androidStudioDir/bin/studio.sh', [], mode: ProcessStartMode.detached);
            await Future.delayed(const Duration(seconds: 10));
          }
        }
      }

      // Passo 7: Configurar Android SDK
      if (installFlutter) { // Só configura o SDK se o Flutter for instalado
        onProgressUpdate(0.60, "Configurando Android SDK...");
        Directory('$androidSdkRoot/cmdline-tools').createSync(recursive: true);

        // Remover diretórios inconsistentes de cmdline-tools antes de prosseguir
        Directory? latest2Dir = Directory('$androidSdkRoot/cmdline-tools/latest-2');
        if (latest2Dir.existsSync()) {
          onProgressUpdate(0.62, "Removendo diretório inconsistente de cmdline-tools...");
          latest2Dir.deleteSync(recursive: true);
        }

        Directory? latestDir = Directory('$androidSdkRoot/cmdline-tools/latest');
        if (latestDir.existsSync()) {
          onProgressUpdate(0.64, "Removendo instalação antiga de cmdline-tools...");
          latestDir.deleteSync(recursive: true);
        }

        // Baixar e extrair cmdline-tools
        onProgressUpdate(0.65, "Baixando Android Command Line Tools...");
        String cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip";
        String cmdlineZipFile = "/tmp/commandlinetools.zip";

        result = await runLinuxCommand('wget -q "$cmdlineToolsUrl" -O "$cmdlineZipFile"');
        if (result?.exitCode != 0) {
          print("Erro ao baixar cmdline-tools: ${result?.stderr}");
          return false;
        }

        result = await runLinuxCommand('unzip -q "$cmdlineZipFile" -d /tmp && '
                                      'mkdir -p "$androidSdkRoot/cmdline-tools/latest" && '
                                      'mv /tmp/cmdline-tools/* "$androidSdkRoot/cmdline-tools/latest/" && '
                                      'rm -rf /tmp/cmdline-tools "$cmdlineZipFile"');
        if (result?.exitCode != 0) {
          print("Erro ao extrair cmdline-tools: ${result?.stderr}");
          return false;
        }

        // Configurar variáveis de ambiente temporárias para o script
        String sdkManager = '$androidSdkRoot/cmdline-tools/latest/bin/sdkmanager';
        
        // Atualizar SDK Manager
        onProgressUpdate(0.70, "Atualizando SDK Manager...");
        result = await runLinuxCommand('timeout 120 "$sdkManager" --update');
        if (result?.exitCode != 0) {
          print("Erro ao atualizar SDK Manager: ${result?.stderr}");
        }

        // Aceitar licenças
        onProgressUpdate(0.75, "Aceitando licenças do Android SDK...");
        String licenseAcceptance = List.filled(10, 'y').join('\n');
        File('/tmp/android_licenses_accept').writeAsStringSync(licenseAcceptance);
        result = await runLinuxCommand('"$sdkManager" --licenses < /tmp/android_licenses_accept');
        await runLinuxCommand('rm /tmp/android_licenses_accept');
        if (result?.exitCode != 0) {
          print("Erro ao aceitar licenças: ${result?.stderr}");
        }

        // Instalar componentes do SDK
        onProgressUpdate(0.80, "Instalando componentes do Android SDK...");
        List<String> components = [
          "platform-tools",
          "build-tools;34.0.0",
          "platforms;android-34",
          "cmdline-tools;latest"
        ];

        for (String component in components) {
          onProgressUpdate(0.80 + (0.05 * (components.indexOf(component) + 1) / components.length), 
                           "Instalando componente: $component");
          result = await runLinuxCommand('timeout 300 "$sdkManager" "$component"');
          if (result?.exitCode != 0) {
            print("Erro ao instalar $component: ${result?.stderr}");
          }
        }

        // Aceitar licenças via flutter doctor
        onProgressUpdate(0.85, "Aceitando licenças via Flutter Doctor...");
        String licenseAcceptanceForDoctor = List.filled(10, 'y').join('\n');
        File('/tmp/flutter_licenses_accept').writeAsStringSync(licenseAcceptanceForDoctor);
        await runLinuxCommand('cat /tmp/flutter_licenses_accept | flutter doctor --android-licenses');
        await runLinuxCommand('rm /tmp/flutter_licenses_accept');
      }

      // Passo 8: Configurar variáveis de ambiente
      onProgressUpdate(0.90, "Configurando variáveis de ambiente...");
      await _configureEnvironmentVariables(homeDir, androidSdkRoot);

      // Passo 9: Verificar instalação
      if (installFlutter) {
        onProgressUpdate(0.95, "Verificando instalação do Flutter...");
        result = await runLinuxCommand('flutter doctor');
        if (result?.exitCode != 0) {
          print("Alguns problemas foram detectados: ${result?.stdout}");
        }
      }

      onProgressUpdate(1.0, "Instalação concluída com sucesso!");
      return true;
    } catch (e) {
      print("Erro durante a instalação: $e");
      return false;
    }
  }

  // Função para configurar variáveis de ambiente
  static Future<void> _configureEnvironmentVariables(String homeDir, String androidSdkRoot) async {
    String profileFile = '$homeDir/.profile';
    String zshrcFile = '$homeDir/.zshrc';
    String bashrcFile = '$homeDir/.bashrc';

    // Detectar shell atual
    String currentShell = Platform.environment['SHELL']?.split('/').last ?? 'bash';

    // Configurações do Flutter
    String flutterExports = '''
export ANDROID_HOME="$androidSdkRoot"
export ANDROID_SDK_ROOT="$androidSdkRoot"
export PATH="\$PATH:$homeDir/flutter/bin"
export PATH="\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="\$PATH:\$ANDROID_HOME/platform-tools"
export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
''';

    // Função auxiliar para adicionar configurações
    void addFlutterConfig(String file) {
      File configFile = File(file);
      if (!configFile.existsSync()) {
        configFile.createSync();
      }

      // Limpar configurações antigas
      String content = configFile.readAsStringSync();
      RegExp flutterSectionRegex = RegExp(r'# Configurações do Flutter.*?# Fim Configurações do Flutter', multiLine: true, dotAll: true);
      content = content.replaceAll(flutterSectionRegex, '');

      // Remover linhas antigas de Flutter
      List<String> lines = content.split('\n');
      lines.removeWhere((line) =>
        line.contains('export.*flutter') ||
        line.contains('export.*ANDROID_HOME') ||
        line.contains('export.*ANDROID_SDK_ROOT') ||
        line.contains('export.*CHROME_EXECUTABLE') ||
        line.contains('export.*JAVA_HOME')
      );
      content = lines.join('\n');

      // Adicionar novas configurações
      content += '''

# Configurações do Flutter - Gerado automaticamente
$flutterExports
# Fim Configurações do Flutter
''';

      configFile.writeAsStringSync(content);
    }

    // Configurar arquivos baseado no shell
    switch (currentShell) {
      case 'zsh':
        addFlutterConfig(zshrcFile);
        addFlutterConfig(profileFile); // Para compatibilidade
        break;
      case 'bash':
        addFlutterConfig(bashrcFile);
        addFlutterConfig(profileFile);
        break;
      default:
        addFlutterConfig(profileFile);
        if (File(zshrcFile).existsSync()) addFlutterConfig(zshrcFile);
        if (File(bashrcFile).existsSync()) addFlutterConfig(bashrcFile);
        break;
    }

    // Aplicar as variáveis na sessão atual
    Platform.environment.addAll({
      'ANDROID_HOME': androidSdkRoot,
      'ANDROID_SDK_ROOT': androidSdkRoot,
      'PATH': '${Platform.environment['PATH']}:$homeDir/flutter/bin:$androidSdkRoot/cmdline-tools/latest/bin:$androidSdkRoot/platform-tools',
      'CHROME_EXECUTABLE': '/usr/bin/google-chrome-stable',
      'JAVA_HOME': '/usr/lib/jvm/java-17-openjdk'
    });
  }

  // Função para instalar o Flutter no Windows
  static Future<bool> installFlutterOnWindows({
    bool installFlutter = true,
    bool installAndroidStudio = true,
    bool installChrome = true,
    bool installVSCode = true,
    String installLocation = '',
    String javaVersion = 'java-17-openjdk',
    required Function(double progress, String status) onProgressUpdate,
  }) async {
    // Implementação para Windows
    onProgressUpdate(0.1, "Iniciando instalação do Flutter no Windows...");

    // Esta é uma implementação simplificada - a implementação completa exigiria
    // mais detalhes sobre como instalar cada componente no Windows
    try {
      // Baixar Flutter
      onProgressUpdate(0.3, "Baixando Flutter para Windows...");
      String downloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip";

      // Em um ambiente real, usaríamos Dio ou HttpClient para baixar o arquivo
      // Mas para demonstração, apenas simulamos o processo
      await Future.delayed(Duration(seconds: 2));

      onProgressUpdate(0.6, "Extraindo Flutter...");
      await Future.delayed(Duration(seconds: 3));

      onProgressUpdate(0.8, "Configurando variáveis de ambiente...");
      await Future.delayed(Duration(seconds: 2));

      onProgressUpdate(1.0, "Instalação no Windows concluída (simulação)!");
      return true;
    } catch (e) {
      print("Erro na instalação do Windows: $e");
      return false;
    }
  }

  // Função para instalar o Flutter no macOS
  static Future<bool> installFlutterOnMacOS({
    bool installFlutter = true,
    bool installAndroidStudio = true,
    bool installChrome = true,
    bool installVSCode = true,
    String installLocation = '',
    String javaVersion = 'java-17-openjdk',
    required Function(double progress, String status) onProgressUpdate,
  }) async {
    // Implementação para macOS
    onProgressUpdate(0.1, "Iniciando instalação do Flutter no macOS...");

    try {
      // Baixar Flutter
      onProgressUpdate(0.3, "Baixando Flutter para macOS...");
      String downloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.5-stable.zip";

      // Em um ambiente real, usaríamos Dio ou HttpClient para baixar o arquivo
      // Mas para demonstração, apenas simulamos o processo
      await Future.delayed(Duration(seconds: 2));

      onProgressUpdate(0.6, "Extraindo Flutter...");
      await Future.delayed(Duration(seconds: 3));

      onProgressUpdate(0.8, "Configurando variáveis de ambiente...");
      await Future.delayed(Duration(seconds: 2));

      onProgressUpdate(1.0, "Instalação no macOS concluída (simulação)!");
      return true;
    } catch (e) {
      print("Erro na instalação do macOS: $e");
      return false;
    }
  }
}