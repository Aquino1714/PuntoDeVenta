import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';
import '../../utils/validators.dart';
import 'lista_negocios.dart';

/// Pantalla de inicio de sesión del administrador (dueño del negocio).
/// Pide correo y contraseña, con opción de mostrar u ocultar la contraseña.
class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Libera los controladores de texto al cerrar la pantalla.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Credenciales temporales de prueba.
  /// Pendiente: reemplazarlas por la autenticación real (servidor o servicio
  /// de usuarios); no conviene dejar contraseñas escritas en el código.
  static const _correoValido = 'julio@gmail.com';
  static const _passwordValida = 'uttlaxcala';

  /// Valida el correo y la contraseña. Si son correctos, abre la lista de
  /// negocios; si no, muestra un aviso sin decir cuál de los dos falló.
  void _login() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _mostrarAviso('Escribe tu correo y tu contraseña');
      return;
    }
    if (email != _correoValido || password != _passwordValida) {
      _mostrarAviso('Correo o contraseña incorrectos');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Screen4()),
    );
  }

  /// Muestra un mensaje breve en la parte inferior de la pantalla.
  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Abre la ventana flotante que pide el correo para restablecer la contraseña.
  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (_) => const _RecuperarPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.maybePop(context),
                        child: const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.keyboard_return,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Column(
                      children: [
                        Text(
                          'MY BUSINESS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                '¡Hola de nuevo administrador!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppColors.text),
              ),

              const SizedBox(height: 40),

              const Text(
                'Rellena los campos necesarios\npara iniciar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppColors.text),
              ),

              const SizedBox(height: 40),

              const _FieldLabel('Correo electrónico'),
              const SizedBox(height: 8),
              _RoundedTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 24),

              const _FieldLabel('Contraseña'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _EyeButton(
                    obscured: _obscurePassword,
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ),

              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 28),

              SizedBox(
                height: 66,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ventana flotante que pide un correo electrónico para enviar el enlace
/// de restablecimiento de contraseña.
class _RecuperarPasswordDialog extends StatefulWidget {
  const _RecuperarPasswordDialog();

  @override
  State<_RecuperarPasswordDialog> createState() =>
      _RecuperarPasswordDialogState();
}

class _RecuperarPasswordDialogState extends State<_RecuperarPasswordDialog> {
  final _emailController = TextEditingController();
  String? _error;
  bool _enviando = false;

  /// Libera el controlador de texto al cerrar la ventana.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Pendiente: conectar con el servicio que envía el correo de
  /// restablecimiento (por ejemplo, FirebaseAuth.instance
  /// .sendPasswordResetEmail(email: email) o tu propio servidor).
  /// Por ahora solo simula la espera, no se envía ningún correo.
  Future<void> _enviarCorreoRestablecer(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Valida el formato del correo, "envía" el enlace y cierra la ventana
  /// con un aviso. El aviso no confirma si el correo existe, para no revelar
  /// qué cuentas están registradas.
  Future<void> _enviar() async {
    if (_enviando) return;

    final error = V.correo(_emailController.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _enviando = true;
    });

    final email = _emailController.text.trim();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _enviarCorreoRestablecer(email);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Si el correo está registrado, recibirás un enlace para '
            'restablecer tu contraseña',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = 'No se pudo enviar el correo. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(33),
        side: const BorderSide(color: AppColors.primary, width: 3),
      ),
      title: const Text(
        'Restablecer contraseña',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Escribe tu correo electrónico y te enviaremos un enlace '
            'para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.text),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          _RoundedTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _enviar(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB3261E),
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33),
            ),
          ),
          onPressed: _enviando ? null : _enviar,
          child: _enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Enviar enlace',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

/// Etiqueta en negritas que se coloca arriba de cada campo de texto.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

/// Botón circular con ícono de ojo para mostrar u ocultar la contraseña.
class _EyeButton extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;

  const _EyeButton({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.primary, width: 3),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(
            obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 30,
          ),
        ),
      ),
    );
  }
}

/// Campo de texto con borde azul y esquinas muy redondeadas.
class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _RoundedTextField({
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: AppColors.primary, width: 3),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        enabledBorder: border,
        focusedBorder: border,
        border: border,
      ),
    );
  }
}