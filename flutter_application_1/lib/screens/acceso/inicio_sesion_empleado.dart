import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';

/// Pantalla de inicio de sesión para empleados. Pide el nombre de usuario
/// y la contraseña que les asignó el administrador. Fondo azul con
/// elementos blancos.
class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Libera los controladores de texto al cerrar la pantalla.
  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Lee el usuario y la contraseña capturados.
  /// Pendiente: validar los datos y llamar a la autenticación de empleado.
  void _login() {
    final user = _userController.text.trim();
    final password = _passwordController.text;
    debugPrint('Login empleado: $user / ${'*' * password.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.maybePop(context),
                        child: const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.keyboard_return,
                            color: AppColors.primary,
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
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Iniciar sesión con cuenta\nempleado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                '¡Hola nuevo usuario!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),

              const SizedBox(height: 40),

              const Text(
                'Inicia sesión con los datos que\nte asignaron en tu nuevo empleo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),

              const SizedBox(height: 40),

              const _FieldLabel('Nombre de usuario'),
              const SizedBox(height: 8),
              _RoundedTextField(
                controller: _userController,
                keyboardType: TextInputType.text,
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

              const SizedBox(height: 40),

              Container(height: 3, color: Colors.white),
              const SizedBox(height: 28),

              SizedBox(
                height: 66,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
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

/// Etiqueta blanca en negritas que se coloca arriba de cada campo de texto.
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
        color: Colors.white,
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
      color: Colors.transparent,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 3),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(
            obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

/// Campo de texto con borde blanco y esquinas muy redondeadas,
/// pensado para fondo azul.
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
      borderSide: BorderSide(color: Colors.white, width: 3),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      cursorColor: Colors.white,
      style: const TextStyle(fontSize: 18, color: Colors.white),
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
