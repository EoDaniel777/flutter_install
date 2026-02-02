import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'installation_manager.dart';
import 'dart:io';

void main() {
  runApp(const FlutterInstallerApp());
}

class FlutterInstallerApp extends StatelessWidget {
  const FlutterInstallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Install - Instalador Oficial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF02569B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF02569B),
              const Color(0xFF0288D1),
              const Color(0xFF0FBCF9),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo do Flutter com animação shimmer
                    Hero(
                      tag: 'flutter_logo',
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.white.withValues(alpha: 0.6),
                            period: const Duration(milliseconds: 2000),
                            child: const FlutterLogo(size: 120),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Título principal
                    Text(
                      'Instalador Oficial do Flutter',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subtítulo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Instale o Flutter, Dart, Android SDK e\nferramentas necessárias com apenas alguns cliques',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Botão principal com efeito glassmorphism
                    Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.15),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const DartInstallScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF02569B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Começar Instalação',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, size: 26),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Tela genérica para instalação de componentes
class ComponentInstallScreen extends StatefulWidget {
  final String componentName;
  final String componentDescription;
  final Widget componentIcon;
  final Color componentColor;
  final String defaultInstallPath;
  final Future<bool> Function() checkInstalled;
  final Future<bool> Function(String path, Function(double, String) onProgress) installFunction;
  final Widget? nextScreen;
  final bool isOptional;
  final int currentStep;
  final int totalSteps;

  const ComponentInstallScreen({
    super.key,
    required this.componentName,
    required this.componentDescription,
    required this.componentIcon,
    required this.componentColor,
    required this.defaultInstallPath,
    required this.checkInstalled,
    required this.installFunction,
    this.nextScreen,
    this.isOptional = false,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<ComponentInstallScreen> createState() => _ComponentInstallScreenState();
}

class _ComponentInstallScreenState extends State<ComponentInstallScreen> with SingleTickerProviderStateMixin {
  late TextEditingController pathController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool isInstalled = false;
  bool isChecking = true;
  bool isInstalling = false;
  double progress = 0.0;
  String currentStatus = '';
  bool pathModified = false;

  @override
  void initState() {
    super.initState();
    pathController = TextEditingController(text: widget.defaultInstallPath);
    pathController.addListener(_onPathChanged);
    _checkInstallation();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    pathController.removeListener(_onPathChanged);
    pathController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPathChanged() {
    if (pathController.text != widget.defaultInstallPath && !pathModified) {
      setState(() => pathModified = true);
      _showPathWarning();
    }
  }

  void _showPathWarning() {
    Fluttertoast.showToast(
      msg: "⚠️ Alterar o diretório padrão pode causar problemas. Recomendamos usar o caminho padrão.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFFFF6B35),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _checkInstallation() async {
    setState(() => isChecking = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Dar tempo para animação
    bool installed = await widget.checkInstalled();
    setState(() {
      isInstalled = installed;
      isChecking = false;
    });
  }

  Future<void> _startInstallation() async {
    setState(() {
      isInstalling = true;
      progress = 0.0;
      currentStatus = 'Iniciando instalação...';
    });

    bool success = await widget.installFunction(
      pathController.text,
      (double progressValue, String status) {
        if (mounted) {
          setState(() {
            progress = progressValue;
            currentStatus = status;
          });
        }
      },
    );

    if (mounted) {
      setState(() => isInstalling = false);

      if (success) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: widget.componentColor, size: 32),
                  const SizedBox(width: 12),
                  const Text('Sucesso!'),
                ],
              ),
              content: Text(
                '${widget.componentName} foi instalado com sucesso.',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToNext();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.componentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Continuar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.error_rounded, color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Text('Erro'),
                ],
              ),
              content: Text(
                'Erro ao instalar ${widget.componentName}. Verifique os logs.',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _navigateToNext() {
    if (widget.nextScreen != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration_rounded, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Instalação Completa!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Todas as ferramentas foram instaladas com sucesso!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'IMPORTANTE',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Para aplicar as configurações de ambiente, você precisa:\n\n'
                      '• Fazer logout da sessão atual\n'
                      '• Fazer login novamente\n\n'
                      'Ou reiniciar o computador.',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Após reiniciar, teste com:\nflutter --version',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: Text(
                      'Voltar ao Início',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      SystemNavigator.pop(); // Fecha o aplicativo
                    },
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: Text(
                      'Fechar App',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instalando ${widget.componentName}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: widget.componentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !isInstalling,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.componentColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: isChecking
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: widget.componentColor),
                    const SizedBox(height: 20),
                    Text(
                      'Verificando instalação...',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator melhorado
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Passo ${widget.currentStep} de ${widget.totalSteps}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${((widget.currentStep / widget.totalSteps) * 100).round()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: widget.componentColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: widget.currentStep / widget.totalSteps,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(widget.componentColor),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Component info card melhorado
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: widget.componentColor.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          children: [
                            // Ícone com efeito glassmorphism
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.componentColor.withValues(alpha: 0.15),
                                    widget.componentColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.componentColor.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: widget.componentIcon,
                            ),
                            const SizedBox(height: 20),

                            // Nome do componente
                            Text(
                              widget.componentName,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: widget.componentColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Descrição
                            Text(
                              widget.componentDescription,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Status badge melhorado
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isInstalled
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isInstalled
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.orange.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isInstalled ? Icons.check_circle_rounded : Icons.info_rounded,
                                    color: isInstalled ? Colors.green : Colors.orange,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isInstalled ? 'Já está instalado' : 'Não está instalado',
                                    style: GoogleFonts.inter(
                                      color: isInstalled ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Installation path (apenas se não instalado e não instalando)
                      if (!isInstalled && !isInstalling)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diretório de instalação:',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: pathController,
                                style: GoogleFonts.jetBrainsMono(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Diretório de instalação',
                                  hintStyle: GoogleFonts.jetBrainsMono(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: widget.componentColor, width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.folder_open_rounded, color: widget.componentColor),
                                  suffixIcon: pathModified
                                      ? const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35))
                                      : null,
                                ),
                              ),
                              if (pathModified)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35), size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Você alterou o diretório padrão. Isso pode causar problemas.',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: const Color(0xFFFF6B35),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Progress section durante instalação
                      if (isInstalling)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Instalação em andamento...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Stack(
                                  children: [
                                    Container(
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: 24,
                                      width: MediaQuery.of(context).size.width * 0.8 * progress,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            widget.componentColor,
                                            widget.componentColor.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.componentColor.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: widget.componentColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: widget.componentColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(widget.componentColor),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          currentStatus,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Action buttons melhorados
                      if (!isInstalling)
                        Column(
                          children: [
                            if (isInstalled)
                              Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.componentColor.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _navigateToNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.componentColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 24),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Pular - Já instalado',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.componentColor.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _startInstallation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.componentColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.download_rounded, size: 24),
                                      const SizedBox(width: 10),
                                      Text(
                                        widget.isOptional ? 'Instalar (Opcional)' : 'Instalar Agora',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.isOptional && !isInstalled)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: TextButton.icon(
                                  onPressed: _navigateToNext,
                                  icon: const Icon(Icons.skip_next_rounded),
                                  label: Text(
                                    'Pular instalação',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// Tela de instalação do Dart
class DartInstallScreen extends StatelessWidget {
  const DartInstallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String homeDir = Platform.environment['HOME'] ?? '/home/user';
    return ComponentInstallScreen(
      componentName: 'Dart SDK',
      componentDescription: 'Linguagem de programação otimizada para desenvolvimento multiplataforma',
      componentIcon: SvgPicture.asset(
        'assets/images/Dart.svg',
        width: 70,
        height: 70,
      ),
      componentColor: const Color(0xFF0175C2),
      defaultInstallPath: '$homeDir/flutter',
      checkInstalled: InstallationManager.isDartInstalled,
      installFunction: InstallationManager.installDart,
      nextScreen: const FlutterInstallScreen(),
      isOptional: false,
      currentStep: 1,
      totalSteps: 5,
    );
  }
}

// Tela de instalação do Flutter
class FlutterInstallScreen extends StatelessWidget {
  const FlutterInstallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String homeDir = Platform.environment['HOME'] ?? '/home/user';
    return ComponentInstallScreen(
      componentName: 'Flutter SDK',
      componentDescription: 'Framework para criar aplicativos compilados nativamente',
      componentIcon: const Icon(BoxIcons.bxl_flutter, size: 70, color: Color(0xFF02569B)),
      componentColor: const Color(0xFF02569B),
      defaultInstallPath: '$homeDir/flutter',
      checkInstalled: InstallationManager.isFlutterInstalled,
      installFunction: InstallationManager.installFlutter,
      nextScreen: const AndroidStudioInstallScreen(),
      isOptional: false,
      currentStep: 2,
      totalSteps: 5,
    );
  }
}

// Tela de instalação do Android Studio
class AndroidStudioInstallScreen extends StatelessWidget {
  const AndroidStudioInstallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String homeDir = Platform.environment['HOME'] ?? '/home/user';
    return ComponentInstallScreen(
      componentName: 'Android Studio',
      componentDescription: 'Ambiente de desenvolvimento integrado para Android',
      componentIcon: const Icon(BoxIcons.bxl_android, size: 70, color: Color(0xFF3DDC84)),
      componentColor: const Color(0xFF3DDC84),
      defaultInstallPath: '$homeDir/android-studio',
      checkInstalled: InstallationManager.isAndroidStudioInstalled,
      installFunction: InstallationManager.installAndroidStudio,
      nextScreen: const VSCodeInstallScreen(),
      isOptional: false,
      currentStep: 3,
      totalSteps: 5,
    );
  }
}

// Tela de instalação do VS Code
class VSCodeInstallScreen extends StatelessWidget {
  const VSCodeInstallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentInstallScreen(
      componentName: 'VS Code',
      componentDescription: 'Editor de código leve e poderoso',
      componentIcon: const Icon(BoxIcons.bxl_visual_studio, size: 70, color: Color(0xFF007ACC)),
      componentColor: const Color(0xFF007ACC),
      defaultInstallPath: '/usr/bin/code',
      checkInstalled: InstallationManager.isVSCodeInstalled,
      installFunction: InstallationManager.installVSCode,
      nextScreen: const ChromeInstallScreen(),
      isOptional: true,
      currentStep: 4,
      totalSteps: 5,
    );
  }
}

// Tela de instalação do Google Chrome
class ChromeInstallScreen extends StatelessWidget {
  const ChromeInstallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentInstallScreen(
      componentName: 'Google Chrome',
      componentDescription: 'Navegador web para testes de aplicações Flutter',
      componentIcon: const Icon(BoxIcons.bxl_chrome, size: 70, color: Color(0xFFDB4437)),
      componentColor: const Color(0xFFDB4437),
      defaultInstallPath: '/usr/bin/google-chrome-stable',
      checkInstalled: InstallationManager.isChromeInstalled,
      installFunction: InstallationManager.installChrome,
      nextScreen: null, // Última tela
      isOptional: true,
      currentStep: 5,
      totalSteps: 5,
    );
  }
}
